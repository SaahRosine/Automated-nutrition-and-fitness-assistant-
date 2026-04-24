import type { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { bannedToken, usersTable } from '../db/schema.js';
import { db } from '../db.js';
import { eq } from 'drizzle-orm';


export const auth = async (req: Request, res: Response, next: NextFunction) => {
    const authHeader = req.header('Authorization');
    console.log('Auth middleware: Authorization header:', authHeader);
    const token = authHeader?.replace('Bearer ', '');
    console.log('Auth middleware: Extracted token:', token ? 'present' : 'missing');

    if (!token) return res.status(401).json({ success: false, error: 'Accès refusé' });

    try {
        console.log('Auth middleware: Checking blacklist...');
        // 1. Vérifier la blacklist
        const [banned] = await db.select().from(bannedToken)
            .where(eq(bannedToken.token, token))
            .limit(1);

        if (banned) {
            console.log('Auth middleware: Token is banned');
            return res.status(401).json({ success: false, error: 'Token révoqué' });
        }

        console.log('Auth middleware: Verifying JWT...');
        // 2. Décoder avec le BON TYPE (id est une string pour un UUID)
        const decoded = jwt.verify(token, process.env.JWT_SECRET!) as { sub: string; email: string };
        console.log('Auth middleware: Decoded token:', decoded);
        (req as any).user = decoded;

        console.log('Auth middleware: Checking user...');
        // 3. Vérifier l'utilisateur
        // 'decoded.sub' contient l'UUID de l'utilisateur
        const [user] = await db.select().from(usersTable)
            .where(eq(usersTable.id, decoded.sub))
            .limit(1);

        if (!user) {
            console.log('Auth middleware: User not found');
            return res.status(403).json({ error: 'Compte suspendu ou inexistant' });
        }

        if (user.isBanned === true) {
            console.log('Auth middleware: User is banned');
            return res.status(403).json({ error: 'Compte suspendu ou inexistant' });
        }

        console.log('Auth middleware: Auth successful for user:', user.id);
        next();
    } catch (err) {
        console.error('Auth middleware error:', err);
        return res.status(401).json({ error: 'Token invalide' });
    }
};
