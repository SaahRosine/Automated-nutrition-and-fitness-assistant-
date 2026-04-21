import { pgTable, uuid, varchar } from "drizzle-orm/pg-core";

export const usersTable = pgTable("users", {
    // Use .defaultRandom() for UUID primary keys
    id: uuid("id").primaryKey().defaultRandom(),
    email: varchar("email", { length: 255 }).unique(),
    password: varchar("password", { length: 255 }).notNull()
});

export const bannedUser = pgTable("bannedUser", {
    id: uuid("id").primaryKey().defaultRandom(),
    email: varchar("email", { length: 255 }).unique().notNull(),
    reason: varchar("reason", { length: 255 })
});

export const bannedToken = pgTable("bannedToken", {
    id: uuid("id").primaryKey().defaultRandom(),
    token: varchar("token", { length: 255 }).notNull(),
});