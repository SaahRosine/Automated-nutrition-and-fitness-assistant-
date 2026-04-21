import { db } from "../../../index.js";
import { usersTable } from "../../db/schema.js";
import { eq } from "drizzle-orm";
import bcrypt from "bcrypt";

export async function UpdateService(email: string, password: string, newPassword?: string, newEmail?: string) {
    // 1. Récupérer l'utilisateur (Drizzle select retourne un tableau)
    const [user] = await db.select().from(usersTable).where(eq(usersTable.email, email)).limit(1);

    if (!user) {
        return { success: false, message: "User not found" };
    }

    // 2. VÉRIFIER le mot de passe actuel (Sécurité !)
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
        return { success: false, message: "Invalid current password" };
    }

    // 3. Préparer les données à mettre à jour
    const updateData: Partial<typeof usersTable.$inferInsert> = {};

    if (newEmail) updateData.email = newEmail;
    if (newPassword) {
        updateData.password = await bcrypt.hash(newPassword, 10);
    }

    // 4. Exécuter l'update en une seule fois
    try {
        await db.update(usersTable)
            .set(updateData)
            .where(eq(usersTable.email, email));

        return { success: true, message: "User updated successfully" };
    } catch (error) {
        return { success: false, message: "Update failed (email might be already taken)" };
    }
}
