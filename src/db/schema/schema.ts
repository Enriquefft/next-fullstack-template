import { sql } from "drizzle-orm";
import {
  serial,
  index,
  pgTableCreator,
  timestamp,
  varchar,
} from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";

import { env } from "@/env.mjs";

export const createTable = pgTableCreator(
  (name) => `${env.NEXT_PUBLIC_PROJECT_NAME}_${name}`,
);

export const posts = createTable(
  "post",
  {
    id: serial("id").primaryKey(),
    name: varchar("name", { length: 256 }),
    createdById: varchar("createdById", { length: 255 }).notNull(),
    createdAt: timestamp("created_at")
      .default(sql`CURRENT_TIMESTAMP`)
      .notNull(),
    updatedAt: timestamp("updatedAt").$onUpdate(() => new Date()),
  },
  (example) => ({
    createdByIdIdx: index("createdById_idx").on(example.createdById),
    nameIndex: index("name_idx").on(example.name),
  }),
);
export const insertPostSchema = createInsertSchema(posts);
