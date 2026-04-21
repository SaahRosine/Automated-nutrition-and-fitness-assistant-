import { pgTable, uuid, varchar, boolean } from "drizzle-orm/pg-core";

export const usersTable = pgTable("users", {
    // Use .defaultRandom() for UUID primary keys
    id: uuid("id").primaryKey().defaultRandom(),
    email: varchar("email", { length: 255 }).unique(),
    password: varchar("password", { length: 255 }).notNull(),
    isBanned: boolean("isBanned").default(false).notNull()
});

export const bannedToken = pgTable("bannedToken", {
    id: uuid("id").primaryKey().defaultRandom(),
    token: varchar("token", { length: 255 }).notNull(),
});