import { defineConfig } from "drizzle-kit";
import { clientEnv } from "@/env/client";
import { dbEnv } from "./src/env/db";

export default defineConfig({
	dbCredentials: {
		url: dbEnv.DRIZZLE_DATABASE_URL,
	},
	dialect: "postgresql",
	schema: "./src/db/schema/*",
	schemaFilter: clientEnv.NEXT_PUBLIC_PROJECT_NAME,
	strict: true,
	verbose: true,
});
