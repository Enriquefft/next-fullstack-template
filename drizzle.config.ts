import { defineConfig } from "drizzle-kit";
import { env } from "@/env.ts";

export default defineConfig({
  schema: "./src/db/schema/*",
  dialect: "postgresql",
  dbCredentials: {
    url: env.DRIZZLE_DATABASE_URL,
  },
  schemaFilter: env.NEXT_PUBLIC_PROJECT_NAME,
});
