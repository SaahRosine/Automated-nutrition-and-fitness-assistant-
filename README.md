# Bot API

A simple Python API for analyzing food images or typed food descriptions with OpenRouter.

## Setup

1. Install dependencies:

   ```bash
   python -m pip install -r requirements.txt
   ```

2. Create a `.env` file from `.env.example` and set your OpenRouter API key.

3. Start the app:

   ```bash
   uvicorn app:app --reload --port 8000
   ```

## Endpoints

### Health check

`GET /health`

### Analyze food

`POST /analyze-food`

Supports multipart form data with either:

- `image` file upload
- `text` description of the food

Example using `curl`:

```bash
curl -X POST http://localhost:8000/analyze-food \
  -F "image=@/path/to/food.jpg" \
  -F "text=Plate with salad and grilled chicken"
```

Example with only text:

```bash
curl -X POST http://localhost:8000/analyze-food \
  -F "text=Two slices of pizza with cheese and pepperoni"
```

## Response

The API returns:

- `nutrition_analysis`: raw text from OpenRouter
- `estimated_calories`: extracted calorie estimate when available
- `workout_needed`: yes/no if calories are high enough to recommend a workout
- `training_needed`: yes/no if calories are high enough to recommend a training session
- `openrouter_raw`: raw OpenRouter response for debugging
