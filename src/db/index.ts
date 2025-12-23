import { drizzle } from "drizzle-orm/neon-serverless";

import { dbEnv } from "@/env/db.ts";
import * as schema from "./schema/index.ts";

export const db = drizzle(dbEnv.DRIZZLE_DATABASE_URL, { schema });
