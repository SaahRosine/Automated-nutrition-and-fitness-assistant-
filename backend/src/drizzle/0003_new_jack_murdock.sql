ALTER TABLE "workout" DROP CONSTRAINT "workout_workout_objective_id_workout_objective_id_fk";
--> statement-breakpoint
ALTER TABLE "workout" ALTER COLUMN "workout_objective_id" SET DATA TYPE varchar(255);