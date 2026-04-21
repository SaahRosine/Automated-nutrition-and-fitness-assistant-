import { db } from "../../../index.js";
import { Workout } from "../../db/schema.js";
import { eq } from "drizzle-orm";

export async function GetWorkoutService(user_id: string) {
    try {
        const workout = await db.select().from(Workout).where(eq(Workout.user_id, user_id));
        return { success: true, message: "Workout fetched successfully", data: workout };
    } catch (error) {
        console.error(error);
        return { success: false, message: "Internal server error" };
    }
}