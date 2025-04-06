import { drizzle } from "drizzle-orm/neon-serverless";

import { env } from "@/env.ts";
import * as schema from "./schema/index.ts";

export const db = drizzle(env.DRIZZLE_DATABASE_URL, { schema });
