import { env } from "@/env.ts";
import { defineConfig } from "drizzle-kit";

export default defineConfig({
	schema: "./src/db/schema/*",
	dialect: "postgresql",
	dbCredentials: {
		url: env.DRIZZLE_DATABASE_URL,
	},
	schemaFilter: env.NEXT_PUBLIC_PROJECT_NAME,
});
