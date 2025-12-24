import { drizzle } from "drizzle-orm/neon-serverless";

import { databaseUrl } from "@/env/db.ts";
import * as schema from "./schema/index.ts";

export const db = drizzle(databaseUrl, { schema });
