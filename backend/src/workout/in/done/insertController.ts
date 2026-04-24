import type { Request, Response } from "express";
import { WorkoutInsertService } from "./insertService.js";
import jwt from "jsonwebtoken";

export async function InstertWorkOutController(req: Request, res: Response) {
    try {
        const { workout_objective, duration, distance, parcours, reps, estimated_calories } = req.body;
        console.log('Received workout insert request:', { workout_objective, duration, distance, parcours, reps, estimated_calories });

        if (!duration || !distance || !parcours || !reps || !estimated_calories) {
            console.log('Missing required fields');
            return res.status(400).json({ success: false, message: "All fields are required" });
        }

        // User is already authenticated by middleware
        const user = (req as any).user;
        const user_id = user.sub;
        console.log('User ID from auth middleware:', user_id);

        const result = await WorkoutInsertService(user_id as string, workout_objective, duration, distance, parcours, reps, estimated_calories);
        if (!result.success) {
            console.log(result)
            return res.status(500).json({ success: false, message: "Internal server error" });
        }
        return res.status(200).json({ success: true, message: "Workout inserted successfully" });


    } catch (error) {
        return res.status(500).json({ success: false, message: "Internal server error" });
    }
}