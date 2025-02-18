import { neon } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-http";

import { env } from "@/env.ts";
import * as schema from "./schema/post";

const sql = neon(env.DRIZZLE_DATABASE_URL);
export const db = drizzle(sql, { schema });
