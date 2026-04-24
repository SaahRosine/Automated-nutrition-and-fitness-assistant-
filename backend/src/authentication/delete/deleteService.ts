import { db } from "../../db.js";
import { usersTable } from "../../db/schema.js";
import { eq } from "drizzle-orm";
import bcrypt from "bcrypt";

export async function deleteService(email: string, password: string) {
    const [user] = await db.select().from(usersTable).where(eq(usersTable.email, email)).limit(1);
    if (!user) {
        return { success: false, message: "User not found" };
    }
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
        return { success: false, message: "Invalid password" };
    }
    await db.delete(usersTable).where(eq(usersTable.email, email));
    return { success: true, message: "User deleted successfully" };
}
