import { defineConfig } from "drizzle-kit";
import { env } from "@/env.mjs";

export default defineConfig({
  schema: "./src/db/schema/*",
  dialect: "postgresql",
  dbCredentials: {
    url: env.DRIZZLE_DATABASE_URL,
  },
  tablesFilter: [`${env.NEXT_PUBLIC_PROJECT_NAME}_*`],
});
