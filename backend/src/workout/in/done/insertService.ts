import { db } from "../../../db.js";
import { Workout } from "../../../db/schema.js";

export async function WorkoutInsertService(user_id: string, workout_objective: string, duration: number, distance: number, parcours: string, reps: string, estimated_calories: number) {
    try {
        console.log('Inserting workout for user:', user_id);
        console.log('Workout data:', {
            user_id,
            workout_objective_id: workout_objective,
            duration,
            distance,
            parcours,
            reps,
            calories: estimated_calories,
        });

        const workout = await db.insert(Workout).values({
            user_id: user_id,
            workout_objective_id: workout_objective,
            duration: duration,
            distance: distance,
            parcours: parcours,
            reps: reps,
            calories: estimated_calories,
        });

        console.log('Workout inserted successfully, result:', workout);
        return { success: true, message: "Workout inserted successfully" };
    } catch (error) {
        console.error('Error inserting workout:', error);
        return { success: false, message: "Internal server error" };
    }
}