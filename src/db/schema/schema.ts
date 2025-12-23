import { pgSchema } from "drizzle-orm/pg-core";
import { clientEnv } from "@/env/client.ts";

export const schema = pgSchema(clientEnv.NEXT_PUBLIC_PROJECT_NAME);
