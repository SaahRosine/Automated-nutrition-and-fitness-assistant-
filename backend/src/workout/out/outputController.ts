import type { Request, Response } from "express";
import jwt from "jsonwebtoken";
import { GetWorkoutService } from "./outputService.js";

export async function GetWorkoutController(req: Request, res: Response) {
    try {
        const { token } = req.body;
        if (!token) {
            return res.status(400).json({ success: false, message: "Token is required" });
        }
        const decoded = jwt.verify(token, process.env.JWT_SECRET as string);
        const user_id = decoded.sub;
        const result = await GetWorkoutService(user_id as string);
        if (!result.success) {
            return res.status(500).json({ success: false, message: "Internal server error" });
        }
        return res.status(200).json(result);
    } catch (error) {
        console.error(error);
        return res.status(500).json({ success: false, message: "Internal server error" });
    }
}