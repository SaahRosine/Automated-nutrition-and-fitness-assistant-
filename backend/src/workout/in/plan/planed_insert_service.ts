import { db } from "../../../db.js";
import { Workout_Objective } from "../../../db/schema.js";

export async function PlannedSessionInsertService(params: { user_id: string, duration: number, reps: any, estimated_calories: number }) {
    try {
        const { user_id, duration, reps, estimated_calories } = params;
        const result = await db.insert(Workout_Objective).values({
            userId: user_id,
            duration,
            reps,
            estimated_calories,
        }).returning();
        return { success: true, message: "Workout plan inserted successfully" };
    } catch (error) {
        return { success: false, error };
    }
}