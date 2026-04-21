DROP TABLE "bannedUser" CASCADE;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "isBanned" boolean DEFAULT false NOT NULL;