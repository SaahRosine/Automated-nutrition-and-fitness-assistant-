import { Request, Response } from 'express';
import { NutritionService } from './nutritionService.js';

const nutritionService = new NutritionService();

export class NutritionController {
    async analyzeFood(req: Request, res: Response) {
        try {
            const { text, portion } = req.body;
            const file = req.file;

            let imageBase64 = "";
            if (file) {
                imageBase64 = file.buffer.toString('base64');
            }

            const prompt = `You are a professional nutritionist. Analyze the following food item(s) for ${portion || 1} serving(s).
Respond ONLY with a valid JSON object (no markdown, no code blocks) in this exact format:
{
  "name": "Food name (short, clear)",
  "icon_name": "restaurant",
  "calories": 0,
  "protein_g": 0,
  "carbs_g": 0,
  "fat_g": 0,
  "fiber_g": 0,
  "sugar_g": 0,
  "vitamins": "None",
  "nutrition_score": "B",
  "verdict": "Verdict text",
  "health_insight": "Insight text",
  "burn_workout": "Workout text",
  "is_healthy": true
}
Do not use emojis. Food item: ${text || (file ? "the food in the image" : "")}`;

            const responseText = await nutritionService.callOpenRouter(prompt, imageBase64);
            const result = nutritionService.parseJsonFromText(responseText);
            
            res.json(result);
        } catch (error: any) {
            res.status(500).json({ detail: error.message });
        }
    }

    async generateWorkout(req: Request, res: Response) {
        try {
            const { total_kcal, meals } = req.body;
            let mealsList = [];
            try {
                mealsList = typeof meals === 'string' ? JSON.parse(meals) : meals;
            } catch (e) {}

            const mealSummary = mealsList.map((m: any) => `${m.name} (${m.calories} kcal)`).join(", ");
            const prompt = `You are a certified fitness trainer. The user consumed ${total_kcal} kcal today from: ${mealSummary || 'various foods'}.
Respond ONLY with a valid JSON object in this exact format:
{
  "plan_name": "Workout Name",
  "estimated_calories_burned": 0,
  "warm_up": ["step 1"],
  "main_exercises": [{"name": "Ex", "reps": "3x10", "notes": "note"}],
  "cool_down": ["step 1"],
  "pro_tip": "tip"
}
Do not use emojis, HTML, or markdown.`;

            const responseText = await nutritionService.callOpenRouter(prompt);
            const result = nutritionService.parseJsonFromText(responseText);
            
            res.json(result);
        } catch (error: any) {
            res.status(500).json({ detail: error.message });
        }
    }

    async chat(req: Request, res: Response) {
        try {
            const { message, history } = req.body;
            let chatHistory = [];
            try {
                chatHistory = typeof history === 'string' ? JSON.parse(history) : history;
            } catch (e) {}

            const systemPrompt = "You are NutriBot, an expert AI nutritionist and fitness coach. Your personality is warm, motivating, and science-backed. Focus on nutrition and fitness. Keep answers clear and encouraging. Use bullet points. No emojis. No medical diagnoses.";
            const fullPrompt = `${systemPrompt}\n\nUser: ${message}`;

            const responseText = await nutritionService.callOpenRouter(fullPrompt, undefined, chatHistory);
            res.json({ response: responseText });
        } catch (error: any) {
            res.status(500).json({ detail: error.message });
        }
    }
}
