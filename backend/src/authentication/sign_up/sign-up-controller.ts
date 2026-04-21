import type { Request, Response } from "express";
import { signUpService } from "./sign-up-service.js";

export async function signUpController(req: Request, res: Response) {
    if (!req.body.email || !req.body.password || !req.body.weight) {
        return res.status(400).json({ success: false, message: "Email and password and weight are required" });
    }
    const { email, password, weight } = req.body;
    const user = await signUpService(email, password, weight);
    return res.status(201).json(user);
}
