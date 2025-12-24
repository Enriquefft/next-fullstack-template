import { defineConfig } from "drizzle-kit";
import { clientEnv } from "@/env/client";
import { databaseUrl } from "./src/env/db";

export default defineConfig({
	dbCredentials: {
		url: databaseUrl,
	},
	dialect: "postgresql",
	schema: "./src/db/schema/*",
	schemaFilter: clientEnv.NEXT_PUBLIC_PROJECT_NAME,
	strict: true,
	verbose: true,
});
