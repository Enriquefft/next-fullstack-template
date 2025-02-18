import { drizzle } from "drizzle-orm/neon-http";

import { env } from "@/env.ts";
import * as schema from "./schema/post";

export const db = drizzle(env.DRIZZLE_DATABASE_URL, { schema });
