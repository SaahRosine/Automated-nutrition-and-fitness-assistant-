import type { Request, Response } from "express";
import { loginService } from "./login-service.js";

export async function loginController(req: Request, res: Response) {
    console.log("Hello")
    try {
        if (!req.body.email || !req.body.password) {
            return res.status(400).json({ success: false, message: "Email and password are required" });
        }
        const { email, password } = req.body;
        const user = await loginService(email, password);
        return res.status(200).json(user);
    } catch (error) {
        return res.status(500).json({ success: false, message: "Internal server error" });
    }
}
