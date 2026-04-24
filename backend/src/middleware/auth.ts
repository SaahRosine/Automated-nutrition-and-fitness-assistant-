import type { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { bannedToken, usersTable } from '../db/schema.js';
import { db } from '../db.js';
import { eq } from 'drizzle-orm';


export const auth = async (req: Request, res: Response, next: NextFunction) => {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) return res.status(401).json({ success: false, error: 'Accès refusé' });

    try {
        // 1. Vérifier la blacklist
        const [banned] = await db.select().from(bannedToken)
            .where(eq(bannedToken.token, token))
            .limit(1);

        if (banned) return res.status(401).json({ success: false, error: 'Token révoqué' });

        // 2. Décoder avec le BON TYPE (id est une string pour un UUID)
        const decoded = jwt.verify(token, process.env.JWT_SECRET!) as { sub: string; email: string };
        (req as any).user = decoded;

        // 3. Vérifier l'utilisateur
        // 'decoded.sub' contient l'UUID de l'utilisateur
        const [user] = await db.select().from(usersTable)
            .where(eq(usersTable.id, decoded.sub))
            .limit(1);

        if (!user || user.isBanned === true) {
            return res.status(403).json({ error: 'Compte suspendu ou inexistant' });
        }

        next();
    } catch (err) {
        console.error(err);
        return res.status(401).json({ error: 'Token invalide' });
    }
};
