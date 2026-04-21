CREATE TABLE "workout" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"workout_objective_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"user_id" uuid NOT NULL,
	"duration" integer NOT NULL,
	"distance" integer NOT NULL,
	"parcours" jsonb NOT NULL,
	"reps" jsonb NOT NULL,
	"calories" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "workout_objective" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"duration" integer NOT NULL,
	"reps" jsonb NOT NULL,
	"estimated_calories" integer NOT NULL
);
--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "created_at" timestamp with time zone DEFAULT now() NOT NULL;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "weight" real NOT NULL;--> statement-breakpoint
ALTER TABLE "workout" ADD CONSTRAINT "workout_workout_objective_id_workout_objective_id_fk" FOREIGN KEY ("workout_objective_id") REFERENCES "public"."workout_objective"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "workout" ADD CONSTRAINT "workout_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "workout_objective" ADD CONSTRAINT "workout_objective_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE cascade;