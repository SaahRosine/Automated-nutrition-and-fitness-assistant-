import { db } from "../../../index.js";
import { usersTable } from "../../db/schema.js";
import { eq } from "drizzle-orm";

export async function UpdateWeightService(email: string, weight: number) {
    try {
        const existingUser = await db.select().from(usersTable)
            .where(eq(usersTable.email, email));
        if (existingUser.length === 0) {
            return { success: false, error: "User not found" };
        }
        const [updatedUser] = await db.update(usersTable).set({
            weight
        }).where(eq(usersTable.email, email)).returning();
        if (!updatedUser) {
            throw new Error("Failed to update user");
        }
        return {
            success: true,
            user: { email: updatedUser.email, weight: updatedUser.weight }
        };
    } catch (error) {
        console.error("Error in UpdateWeightService:", error);
        return { success: false, error: "Internal server error" };
    }
}