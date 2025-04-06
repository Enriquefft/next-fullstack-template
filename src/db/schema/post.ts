import { sql } from "drizzle-orm";
import { index, serial, timestamp, varchar } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { schema } from "./schema.ts";

export const posts = schema.table(
	"post",
	{
		createdAt: timestamp("created_at")
			.default(sql`CURRENT_TIMESTAMP`)
			.notNull(),
		createdById: varchar("createdById", { length: 255 }).notNull(),
		id: serial("id").primaryKey(),
		name: varchar("name", { length: 256 }),
		updatedAt: timestamp("updatedAt").$onUpdate(() => new Date()),
	},
	(example) => [
		index("createdById_idx").on(example.createdById),
		index("name_idx").on(example.name),
	],
);
export const insertPostSchema = createInsertSchema(posts);

export type InsertPost = typeof posts.$inferInsert;
export type SelectPost = typeof posts.$inferSelect;
