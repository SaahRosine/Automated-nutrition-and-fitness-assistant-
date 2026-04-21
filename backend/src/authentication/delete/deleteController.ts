import { deleteService } from "./deleteService.js";
import type { Request, Response } from "express";

export async function deleteController(req: Request, res: Response) {
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(400).json({ success: false, message: "Email and password are required" });
        }
        const deleteResponse = await deleteService(email, password);
        return res.status(200).json(deleteResponse)
    } catch (error) {
        return res.status(500).json({ success: false, message: "Internal server error" });
    }
}