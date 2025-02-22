import { env } from "@/env.ts";
import { pgSchema } from "drizzle-orm/pg-core";

export const schema = pgSchema(env.NEXT_PUBLIC_PROJECT_NAME);
