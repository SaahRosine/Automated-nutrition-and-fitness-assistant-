import type { Request, Response } from "express";
import jwt from "jsonwebtoken";

export async function rotateTokenController(req: Request, res: Response) {
    try {
        const token = req.header('Authorization')?.replace('Bearer ', '');
        if (!token) {
            return res.status(401).json({ success: false, message: "Token not found" });
        }
        const decoded = jwt.verify(token, process.env.JWT_SECRET!);
        (req as any).user = decoded;
        const newToken = jwt.sign(
            { sub: (req as any).user.id, email: (req as any).user.email },
            process.env.JWT_SECRET!,
            { expiresIn: '30d' }
        );
        return res.status(200).json({ success: true, token: newToken });
    } catch (error) {
        return res.status(500).json({ success: false, message: "Internal server error" });
    }
}