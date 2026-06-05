import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY;
const OPENROUTER_API_URL = "https://api.openrouter.ai/v1/chat/completions";
const MODEL = "openai/gpt-4-vision";

export class NutritionService {
    async callOpenRouter(prompt: string, imageBase64?: string, chatHistory: any[] = []) {
        if (!OPENROUTER_API_KEY) {
            throw new Error("OPENROUTER_API_KEY is not set");
        }

        const content: any[] = [{ type: "text", text: prompt }];

        if (imageBase64) {
            content.push({
                type: "image_url",
                image_url: { url: `data:image/jpeg;base64,${imageBase64}` }
            });
        }

        const messages = chatHistory.map(msg => ({
            role: msg.role === 'model' ? 'assistant' : msg.role,
            content: msg.parts[0].text
        }));

        messages.push({ role: "user", content });

        try {
            const response = await axios.post(OPENROUTER_API_URL, {
                model: MODEL,
                messages: messages,
                temperature: 0.7,
                max_tokens: 1000
            }, {
                headers: {
                    "Authorization": `Bearer ${OPENROUTER_API_KEY}`,
                    "Content-Type": "application/json"
                }
            });

            return response.data.choices[0].message.content;
        } catch (error: any) {
            console.error("OpenRouter Error:", error.response?.data || error.message);
            throw new Error("Failed to call OpenRouter API");
        }
    }

    parseJsonFromText(text: string) {
        const cleaned = text.replace(/```json/g, "").replace(/```/g, "").trim();
        try {
            return JSON.parse(cleaned);
        } catch (e) {
            const match = cleaned.match(/(\{[\s\S]*\})/);
            if (match) {
                try {
                    return JSON.parse(match[1]);
                } catch (e2) {}
            }
            return { error: "Could not parse JSON", raw_text: text };
        }
    }
}
