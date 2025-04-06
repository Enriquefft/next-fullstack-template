import { boolean, text, timestamp } from "drizzle-orm/pg-core";

import { schema } from "./schema.ts";

export const user = schema.table("user", {
	createdAt: timestamp("created_at").notNull(),
	email: text("email").notNull().unique(),
	emailVerified: boolean("email_verified").notNull(),
	id: text("id").primaryKey(),
	image: text("image"),
	name: text("name").notNull(),
	updatedAt: timestamp("updated_at").notNull(),
});

export const session = schema.table("session", {
	createdAt: timestamp("created_at").notNull(),
	expiresAt: timestamp("expires_at").notNull(),
	id: text("id").primaryKey(),
	ipAddress: text("ip_address"),
	token: text("token").notNull().unique(),
	updatedAt: timestamp("updated_at").notNull(),
	userAgent: text("user_agent"),
	userId: text("user_id")
		.notNull()
		.references(() => user.id, { onDelete: "cascade" }),
});

export const account = schema.table("account", {
	accessToken: text("access_token"),
	accessTokenExpiresAt: timestamp("access_token_expires_at"),
	accountId: text("account_id").notNull(),
	createdAt: timestamp("created_at").notNull(),
	id: text("id").primaryKey(),
	idToken: text("id_token"),
	password: text("password"),
	providerId: text("provider_id").notNull(),
	refreshToken: text("refresh_token"),
	refreshTokenExpiresAt: timestamp("refresh_token_expires_at"),
	scope: text("scope"),
	updatedAt: timestamp("updated_at").notNull(),
	userId: text("user_id")
		.notNull()
		.references(() => user.id, { onDelete: "cascade" }),
});

export const verification = schema.table("verification", {
	createdAt: timestamp("created_at"),
	expiresAt: timestamp("expires_at").notNull(),
	id: text("id").primaryKey(),
	identifier: text("identifier").notNull(),
	updatedAt: timestamp("updated_at"),
	value: text("value").notNull(),
});
