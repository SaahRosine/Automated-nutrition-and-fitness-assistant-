import type { Request, Response } from "express";
import { WorkoutInsertService } from "./insertService.js";
import jwt from "jsonwebtoken";

export async function InstertWorkOutController(req: Request, res: Response) {
    try {
        const { workout_objective, duration, distance, parcours, reps, estimated_calories, token } = req.body;
        if (!duration || !distance || !parcours || !reps || !estimated_calories || !token) {
            return res.status(400).json({ success: false, message: "All fields are required" });
        }
        const decoded = jwt.verify(token, process.env.JWT_SECRET as string);
        const user_id = decoded.sub;
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