import base64
import io
import json
import os
import re
from typing import Optional

import requests
from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.responses import HTMLResponse
from PIL import Image

api_key = os.getenv("OPENROUTER_API_KEY")
OPENROUTER_API_URL = "https://api.openrouter.ai/v1/chat/completions"
MODEL = "openai/gpt-4-vision"

app = FastAPI(
    title="Food Nutrition Analyzer",
    description="Analyze food images or descriptions and return estimated calories, workout advice, and training recommendations.",
    version="0.1.0",
)


def build_prompt(text_input: str, image_provided: bool) -> str:
    base_instruction = (
        "You are a nutrition and fitness assistant. Analyze the food from the image or description, "
        "identify likely food items, estimate calories and macronutrients, and answer whether a workout is needed to burn the calories "
        "and whether training is recommended. Reply clearly and concisely."
    )
    if image_provided:
        question = "Please analyze the food in the uploaded image."
    else:
        question = "Please analyze the food described in the text."
    return f"{base_instruction}\n{question}\n{text_input.strip()}"


def extract_calories(text: str) -> Optional[int]:
    text = text.lower()
    patterns = [
        r"(\d{2,5})\s*(?:kcal|calories|calorie|cal)\b",
        r"estimated\s*calories?\s*[:=]?\s*(\d{2,5})",
        r"about\s*(\d{2,5})\s*(?:kcal|calories|calorie)s?",
    ]
    for pattern in patterns:
        match = re.search(pattern, text)
        if match:
            try:
                return int(match.group(1))
            except ValueError:
                continue
    return None


def parse_openrouter_response(data: dict) -> str:
    """Extract text from OpenRouter API response (OpenAI chat completions format)."""
    if not isinstance(data, dict):
        return str(data)

    if "choices" in data and isinstance(data["choices"], list) and data["choices"]:
        choice = data["choices"][0]
        message = choice.get("message")
        if isinstance(message, dict):
            content = message.get("content", "").strip()
            return content if content else "No response received."
        return choice.get("text", "No response received.").strip()

    return json.dumps(data)


def call_openrouter(prompt: str, image_file: Optional[UploadFile] = None) -> dict:
    if not OPENROUTER_API_KEY:
        raise RuntimeError("OPENROUTER_API_KEY environment variable is not set.")

    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
    }

    # Build message content
    content = []

    # Add text
    content.append({"type": "text", "text": prompt})

    # Add image if provided
    if image_file is not None:
        try:
            image_data = image_file.file.read()
            image_file.file.seek(0)
            base64_image = base64.b64encode(image_data).decode("utf-8")
            media_type = image_file.content_type or "image/jpeg"
            content.append(
                {
                    "type": "image_url",
                    "image_url": {"url": f"data:{media_type};base64,{base64_image}"},
                }
            )
        except Exception as e:
            raise RuntimeError(f"Failed to process image: {str(e)}")

    # OpenRouter OpenAI-compatible API
    payload = {
        "model": MODEL,
        "messages": [{"role": "user", "content": content}],
        "temperature": 0.7,
        "max_tokens": 1000,
    }

    try:
        response = requests.post(
            OPENROUTER_API_URL,
            headers=headers,
            json=payload,
            timeout=60,
        )
    except requests.exceptions.ConnectionError as e:
        raise RuntimeError(
            f"Failed to connect to OpenRouter API: {str(e)}. Check your internet connection."
        )

    if response.status_code >= 400:
        raise HTTPException(
            status_code=502,
            detail={
                "message": "OpenRouter API request failed.",
                "status_code": response.status_code,
                "response": response.text,
            },
        )

    return response.json()


def mock_analyze(text_input: str, image_file: Optional[UploadFile]) -> tuple[str, dict]:
    """Improved local mock analyzer.

    - Recognizes common foods, numeric quantities, grams, cups, and size modifiers (small/medium/large).
    - Returns a detailed per-item calorie breakdown and approximate macronutrients.
    """
    text = (text_input or "").strip().lower()

    # Food database: calories per unit or per 100g when appropriate
    foods = {
        "pizza": {"unit": "slice", "cal": 285},
        "burger": {"unit": "item", "cal": 500},
        "fries": {"unit": "serving", "cal": 365},
        "salad": {"unit": "serving", "cal": 150},
        "chicken": {"unit": "100g", "cal_per_100g": 165},
        "rice": {"unit": "100g", "cal_per_100g": 130},
        "pasta": {"unit": "100g", "cal_per_100g": 131},
        "steak": {"unit": "100g", "cal_per_100g": 271},
        "soup": {"unit": "bowl", "cal": 180},
        "sandwich": {"unit": "item", "cal": 300},
        "apple": {"unit": "item", "cal": 95},
        "banana": {"unit": "item", "cal": 105},
    }

    size_mod = {"small": 0.7, "medium": 1.0, "large": 1.5}

    identified = []
    total_cal = 0.0

    # Helper to add item
    def add_item(name: str, qty: float, cal: float, note: str | None = None):
        nonlocal total_cal
        item_cal = qty * cal
        total_cal += item_cal
        identified.append({
            "name": name,
            "quantity": qty,
            "cal_per_unit": cal,
            "calories": round(item_cal),
            "note": note,
        })

    # Try to parse explicit patterns like '2 slices of pizza', '150g chicken'
    for name, info in foods.items():
        if name in text:
            # default qty and cal per unit
            qty = None
            cal_per_unit = None

            # size modifier
            modifier = 1.0
            for mod_word, mult in size_mod.items():
                if f"{mod_word} {name}" in text:
                    modifier = mult

            # grams pattern
            m = re.search(rf"(\d+(?:\.\d+)?)\s*(?:g|grams)\s*(?:of\s+)?{re.escape(name)}", text)
            if m and info.get("cal_per_100g"):
                grams = float(m.group(1))
                cal_per_100g = info["cal_per_100g"]
                cal_per_unit = cal_per_100g / 1.0  # per 100g basis
                qty = grams / 100.0
                add_item(name, qty, cal_per_unit * 1.0, note=f"{grams}g")
                continue

            # quantity + unit pattern (e.g., '2 slices of pizza', '3 cups rice')
            m2 = re.search(rf"(\d+(?:\.\d+)?)\s*(slice|slices|serving|servings|cup|cups|piece|pieces|bowl|bowl|item|items)\s*(?:of\s+)?{re.escape(name)}", text)
            if m2:
                num = float(m2.group(1))
                unit_word = m2.group(2)
                # map unit to per-unit calories
                if "cal" in info:
                    cal_per_unit = info["cal"]
                    qty = num
                    add_item(name, qty * modifier, cal_per_unit, note=unit_word)
                    continue
                elif info.get("cal_per_100g") and unit_word.startswith("cup"):
                    # assume 1 cup = 200g cooked
                    grams = 200 * num
                    cal_per_100g = info["cal_per_100g"]
                    qty = grams / 100.0
                    add_item(name, qty, cal_per_100g, note=f"{num} cup(s)")
                    continue

            # simple leading quantity: '2 pizza' or '2 pizzas'
            m3 = re.search(rf"(\d+(?:\.\d+)?)\s+{re.escape(name)}s?", text)
            if m3:
                num = float(m3.group(1))
                if "cal" in info:
                    add_item(name, num * modifier, info["cal"], note="count")
                elif info.get("cal_per_100g"):
                    # assume a default serving size of 150g
                    grams = 150 * num
                    qty = grams / 100.0
                    add_item(name, qty, info["cal_per_100g"], note="assumed 150g per item")
                continue

            # no explicit quantity, default one serving
            if "cal" in info:
                add_item(name, 1 * modifier, info["cal"], note="default serving")
            elif info.get("cal_per_100g"):
                # assume default serving 150g
                qty = 150.0 / 100.0
                add_item(name, qty * modifier, info["cal_per_100g"], note="assumed 150g")

    # If no identified items and image exists -> generic meal
    if not identified and image_file is not None:
        add_item("meal (image)", 1, 600, note="generic image estimate")

    # If still nothing, fallback unspecified
    if not identified:
        add_item("unspecified food", 1, 400, note="fallback")

    total_cal_rounded = round(total_cal)

    # Approx macronutrients: assume carbs 50%, protein 20%, fat 30%
    carbs_kcal = total_cal * 0.5
    protein_kcal = total_cal * 0.2
    fat_kcal = total_cal * 0.3
    carbs_g = round(carbs_kcal / 4)
    protein_g = round(protein_kcal / 4)
    fat_g = round(fat_kcal / 9)

    items_text = ", ".join([f"{i['quantity']} x {i['name']} ({i['calories']} kcal)" for i in identified])
    model_text = (
        f"Identified items: {items_text}. Total estimated calories: {total_cal_rounded} kcal. "
        f"Approx macronutrients: carbs {carbs_g}g, protein {protein_g}g, fat {fat_g}g."
    )

    raw_response = {"choices": [{"message": {"content": model_text}}]}
    return model_text, raw_response


@app.get("/")
async def root():
    return {
        "service": "Food Nutrition Analyzer",
        "status": "running",
        "routes": ["/health", "/analyze-food"],
    }


@app.get("/capture", response_class=HTMLResponse)
async def capture_page():
        html = """
        <!doctype html>
        <html>
            <head>
                <meta charset="utf-8" />
                <title>Capture Food Photo</title>
                <style>
                    body { font-family: Arial, sans-serif; margin: 20px; }
                    video { max-width: 100%; border: 1px solid #ccc; }
                    canvas { display: none; }
                    #result { white-space: pre-wrap; background:#f7f7f7; padding:10px; border:1px solid #ddd; }
                </style>
            </head>
            <body>
                <h2>Capture Food Photo</h2>
                <p>Allow camera access, position the food, then click <b>Capture</b>.</p>
                <video id="video" autoplay playsinline width="640" height="480"></video>
                <br/>
                <button id="captureBtn">Capture</button>
                <button id="sendBtn" disabled>Send to Analyze</button>
                <p style="color: red; font-weight: bold;">
                   Food description is REQUIRED for accurate analysis
                </p>
                <p>
                    <label><b>Food Description:</b> <input id="desc" type="text" size="50" placeholder="e.g. 2 slices of pizza, burger with fries, 150g chicken with rice" required></label>
                </p>
                <canvas id="canvas" width="640" height="480"></canvas>
                <h3>Response</h3>
                <div id="result">No response yet.</div>

                <script>
                    const video = document.getElementById('video');
                    const canvas = document.getElementById('canvas');
                    const captureBtn = document.getElementById('captureBtn');
                    const sendBtn = document.getElementById('sendBtn');
                    const result = document.getElementById('result');
                    const desc = document.getElementById('desc');

                    async function startCamera(){
                        try{
                            const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' }, audio: false });
                            video.srcObject = stream;
                        }catch(e){
                            result.textContent = 'Camera error: ' + e.message;
                        }
                    }

                    captureBtn.addEventListener('click', ()=>{
                        const ctx = canvas.getContext('2d');
                        ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
                        sendBtn.disabled = false;
                        result.textContent = 'Captured. Click Send to Analyze.';
                    });

                    sendBtn.addEventListener('click', async ()=>{
                        if (!desc.value.trim()){
                            result.textContent = '❌ Error: Food description is required.\nExample: "2 slices of pizza", "burger with fries", or "150g chicken with rice".';
                            return;
                        }
                        canvas.toBlob(async (blob)=>{
                            const fd = new FormData();
                            fd.append('image', blob, 'capture.png');
                            fd.append('text', desc.value.trim());
                            result.textContent = 'Sending...';
                            try{
                                const resp = await fetch('/analyze-food', { method: 'POST', body: fd });
                                const data = await resp.json();
                                result.textContent = JSON.stringify(data, null, 2);
                            }catch(err){
                                result.textContent = 'Request error: ' + err;
                            }
                        }, 'image/png');
                    });

                    startCamera();
                </script>
            </body>
        </html>
        """
        return HTMLResponse(content=html, status_code=200)


@app.get("/health")
async def health_check():
    return {"status": "ok", "service": "Food Nutrition Analyzer"}


@app.post("/analyze-food")
async def analyze_food(
    text: str = Form(default=""),
    image: Optional[UploadFile] = File(default=None),
):
    if not text and image is None:
        raise HTTPException(
            status_code=422,
            detail="Submit either a text description or an image file under 'image'.",
        )
    if image is not None and (not text or not text.strip()):
        raise HTTPException(
            status_code=422,
            detail="When uploading an image, a food description is required (e.g., 'pizza', '2 slices of burger').",
        )

    prompt = build_prompt(text, image is not None)
    used_mock = False
    try:
        raw_response = call_openrouter(prompt, image_file=image)
        model_text = parse_openrouter_response(raw_response)
    except RuntimeError as exc:
        # If OpenRouter is unreachable, fall back to the local mock analyzer
        err_msg = str(exc)
        if "Failed to connect to OpenRouter API" in err_msg or "getaddrinfo failed" in err_msg:
            used_mock = True
            model_text, raw_response = mock_analyze(text, image)
        else:
            raise HTTPException(status_code=500, detail=err_msg)
    estimated_calories = extract_calories(model_text)
    workout_needed = None
    training_needed = None

    if estimated_calories is not None:
        workout_needed = "yes" if estimated_calories > 400 else "no"
        training_needed = "yes" if estimated_calories > 700 else "no"

    return {
        "nutrition_analysis": model_text,
        "estimated_calories": estimated_calories,
        "workout_needed": workout_needed,
        "training_needed": training_needed,
        "openrouter_raw": raw_response,
        "used_mock": used_mock,
    }
