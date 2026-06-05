import type { Request, Response } from "express";
import { GetWorkoutService } from "./outputService.js";

export async function GetWorkoutController(req: Request, res: Response) {
    try {
        // user_id is already verified and attached by the auth middleware
        const user = (req as any).user;
        const user_id = user.sub as string;

        if (!user_id) {
            return res.status(401).json({ success: false, message: "Unauthorized" });
        }

        const result = await GetWorkoutService(user_id);
        if (!result.success) {
            return res.status(500).json({ success: false, message: "Internal server error" });
        }
        return res.status(200).json(result);
    } catch (error) {
        console.error(error);
        return res.status(500).json({ success: false, message: "Internal server error" });
    }
}
