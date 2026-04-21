import jwt from "jsonwebtoken";
import { usersTable } from "../../db/schema.js";
import { db } from "../../../index.js";
import { eq } from "drizzle-orm";
import bcrypt from "bcrypt";

// Utilise une variable d'environnement pour ta clé secrète !
const JWT_SECRET = process.env.JWT_SECRET || "ta_cle_secrete_super_secure";

export async function signUpService(email: string, password: string) {
    try {
        const existingUser = await db.select().from(usersTable)
            .where(eq(usersTable.email, email));
        if (existingUser.length > 0) {
            return { success: false, error: "User already exists" };
        }
        // 1. Insertion de l'utilisateur
        // Note : Assure-toi de hasher le password avec bcrypt AVANT l'insertion !
        const hashedPassword = await bcrypt.hash(password, 10);
        const [newUser] = await db.insert(usersTable).values({
            email,
            password: hashedPassword
        }).returning(); // .returning() est crucial pour récupérer l'ID généré
        if (!newUser) {
            throw new Error("Failed to create user");
        }
        // 2. Génération du Token JWT
        const token = jwt.sign(
            { sub: newUser.id, email: newUser.email },
            JWT_SECRET,
            { expiresIn: '30d' } // Le token expire après 1mois
        );

        return {
            user: { id: newUser.id, email: newUser.email },
            token
        };
    } catch (error) {
        console.error("Error in signUpService:", error);
        return { success: false, error: "Internal server error" };
    }
}