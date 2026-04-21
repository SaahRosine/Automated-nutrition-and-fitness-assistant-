import type { Request, Response } from "express";
import { UpdateService } from "./updateService.js";

export async function UpdateController(req: Request, res: Response) {
    const { email, password, newPassword, newEmail } = req.body;

    if (!email || !password) {
        return res.status(400).json({ success: false, message: "Email and password are required" });
    }

    if (!newPassword && !newEmail) {
        return res.status(400).json({ success: false, message: "You must provide at least a new password or a new email to update" });
    }

    try {
        const user = await UpdateService(email, password, newPassword, newEmail);
        return res.status(200).json(user);
    } catch (error) {
        return res.status(500).json({ success: false, message: "Internal server error" });
    }
}
