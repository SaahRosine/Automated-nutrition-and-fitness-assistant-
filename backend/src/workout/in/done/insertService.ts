import { db } from "../../../db.js";
import { Workout } from "../../../db/schema.js";

export async function WorkoutInsertService(user_id: string, workout_objective: string, duration: number, distance: number, parcours: string, reps: string, estimated_calories: number) {
    try {
        const workout = await db.insert(Workout).values({
            user_id: user_id,
            workout_objective_id: workout_objective,
            duration: duration,
            distance: distance,
            parcours: parcours,
            reps: reps,
            calories: estimated_calories,
        })
        return { success: true, message: "Workout inserted successfully" };
    } catch (error) {
        console.error(error);
        return { success: false, message: "Internal server error" };
    }
}