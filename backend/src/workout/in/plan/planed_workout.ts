import type { Request, Response } from "express";
import { PlannedSessionInsertService } from "./planed_insert_service.js";
import jwt from "jsonwebtoken";

export async function PlanedWorkOutController(req: Request, res: Response) {
    try {
        const { token, duration, reps, estimated_calories } = req.body;
        if (!token || !duration || !reps || !estimated_calories) {
            return res.status(400).json({ success: false, error: "All fields are required" });
        }
        const decoded = jwt.verify(token, process.env.JWT_SECRET as string);
        const user_id = decoded.sub;
        const result = await PlannedSessionInsertService({ user_id: user_id as string, duration, reps, estimated_calories });
        return res.status(200).json(result);
    } catch (error) {
        return res.status(500).json({ success: false, error });
    }
}