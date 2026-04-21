import type { Request, Response } from "express";
import { signUpService } from "./sign-up-service.js";

export async function signUpController(req: Request, res: Response) {
    if (!req.body.email || !req.body.password) {
        return res.status(400).json({ success: false, message: "Email and password are required" });
    }
    const { email, password } = req.body;
    const user = await signUpService(email, password);
    return res.status(201).json(user);
}
