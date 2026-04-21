import jwt from "jsonwebtoken";
import { usersTable } from "../../db/schema.js";
import { db } from "../../../index.js";
import { eq } from "drizzle-orm";
import bcrypt from "bcrypt";

const JWT_SECRET = process.env.JWT_SECRET || "ta_cle_secrete_super_secure";

export async function loginService(email: string, password: string) {
    try {
        // 1. Recherche de l'utilisateur
        const users = await db.select().from(usersTable)
            .where(eq(usersTable.email, email))
            .limit(1);

        const userFound = users[0];

        // 2. Vérification si l'utilisateur existe
        if (!userFound) {
            return { success: false, error: "User not found" };
        }

        // 3. Comparaison du mot de passe (AJOUT DE AWAIT ICI)
        const isMatch = await bcrypt.compare(password, userFound.password);

        if (!isMatch) {
            return { success: false, error: "Invalid password" };
        }

        // 4. Génération du token
        const token = jwt.sign(
            { sub: userFound.id, email: userFound.email },
            JWT_SECRET,
            { expiresIn: '30d' } // Note: On peut réduire ici si on fait de la rotation
        );

        return {
            success: true,
            token
        };
    } catch (error) {
        console.error(error); // Toujours loguer l'erreur pour le debug
        return { success: false, error: "Internal server error" };
    }
}