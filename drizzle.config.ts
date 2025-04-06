import { defineConfig } from "drizzle-kit";
import { env } from "@/env.ts";

export default defineConfig({
	dbCredentials: {
		url: env.DRIZZLE_DATABASE_URL,
	},
	dialect: "postgresql",
	schema: "./src/db/schema/*",
	schemaFilter: env.NEXT_PUBLIC_PROJECT_NAME,
	strict: true,
	verbose: true,
});
