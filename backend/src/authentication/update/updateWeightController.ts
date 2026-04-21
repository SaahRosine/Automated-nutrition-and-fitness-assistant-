import type { Request, Response } from "express";
import { UpdateWeightService } from "./updateWeightService.js";

export async function UpdateWeightController(req: Request, res: Response) {
    if (!req.body.email || !req.body.weight) {
        return res.status(400).json({ success: false, message: "Email and weight are required" });
    }
    const { email, weight } = req.body;
    const user = await UpdateWeightService(email, weight);
    return res.status(200).json(user);
}
