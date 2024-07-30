import { pgSchema } from "drizzle-orm/pg-core";
import { env } from "@/env.mjs";

export const schema = pgSchema(env.NEXT_PUBLIC_PROJECT_NAME);
