import { pgTable, uuid, varchar, boolean, timestamp, integer, jsonb, foreignKey, real } from "drizzle-orm/pg-core";

export const usersTable = pgTable("users", {
    // Use .defaultRandom() for UUID primary keys
    id: uuid("id").primaryKey().defaultRandom(),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
    email: varchar("email", { length: 255 }).unique(),
    password: varchar("password", { length: 255 }).notNull(),
    weight: real("weight").notNull(),
    isBanned: boolean("isBanned").default(false).notNull(),

});

export const bannedToken = pgTable("bannedToken", {
    id: uuid("id").primaryKey().defaultRandom(),
    token: varchar("token", { length: 255 }).notNull(),
});

export const Workout_Objective = pgTable("workout_objective", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").notNull().references(() =>
        usersTable.id, { onDelete: "cascade", onUpdate: "cascade" }),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
    duration: integer("duration").notNull(),
    reps: jsonb("reps").notNull(),
    estimated_calories: integer("estimated_calories").notNull(),
}
)

export const Workout = pgTable("workout", {
    id: uuid("id").primaryKey().defaultRandom(),
    workout_objective_id: uuid("workout_objective_id").references(() =>
        Workout_Objective.id, { onDelete: "cascade", onUpdate: "cascade" }),
    created_at: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
    user_id: uuid("user_id").notNull().references(() => usersTable.id),
    duration: integer("duration").notNull(),
    distance: integer("distance").notNull(),
    parcours: jsonb("parcours").notNull(),
    reps: jsonb("reps").notNull(),
    calories: integer("calories").notNull(),
})

