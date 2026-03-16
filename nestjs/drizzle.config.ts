// drizzle.config.ts
import { defineConfig } from "drizzle-kit";
import { config } from "dotenv";

config();

const databaseUrl = process.env.DATABASE_URL;

if (!databaseUrl) {
    throw new Error("DATABASE_URL environment variable is not defined");
}

export default defineConfig({
    dialect: "postgresql",
    dbCredentials: {
        url: databaseUrl,
    },
    // Consider adding these for migrations:
    // schema: "./src/db/schema.ts",
    // out: "./drizzle",
});
