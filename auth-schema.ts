import { schema } from "@/db/schema/schema";
import { boolean, text, timestamp, varchar } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";

const PHONE_LENGTH = 9;
const DNI_LENGTH = 8;
export const phoneSchema = z
	.string()
	.regex(new RegExp(`^\\d{${PHONE_LENGTH}}$`, "u"), {
		message: `Número de teléfono inválido, debe tener ${PHONE_LENGTH} dígitos`,
	});
export const dniSchema = z
	.string()
	.regex(new RegExp(`^\\d{${DNI_LENGTH}}$`, "u"), {
		message: `Número de DNI inválido, debe tener ${DNI_LENGTH} dígitos`,
	});

export const roles = ["user", "admin"] as const;
export const roleSchema = z.enum(roles);
export type Role = z.infer<typeof roleSchema>;
export const roleEnum = schema.enum("role_enum", roles);

export const user = schema.table("user", {
	id: text("id").primaryKey(),
	name: text("name").notNull(),
	email: text("email").notNull().unique(),
	emailVerified: boolean("email_verified").notNull(),
	image: text("image"),
	createdAt: timestamp("created_at").notNull(),
	updatedAt: timestamp("updated_at").notNull(),

	// extra fields
	role: roleEnum().notNull().default("user"),
	dni: varchar("dni", { length: 8 }).unique(),
	phone: varchar("phone", { length: 24 }),
});

export const userSchema = createInsertSchema(user, {
	email: (_schema) => _schema.email("Correo electronico inválido"),
	phone: phoneSchema,
	dni: dniSchema,
});

export const session = schema.table("session", {
	id: text("id").primaryKey(),
	expiresAt: timestamp("expires_at").notNull(),
	token: text("token").notNull().unique(),
	createdAt: timestamp("created_at").notNull(),
	updatedAt: timestamp("updated_at").notNull(),
	ipAddress: text("ip_address"),
	userAgent: text("user_agent"),
	userId: text("user_id")
		.notNull()
		.references(() => user.id, { onDelete: "cascade" }),
});

export const account = schema.table("account", {
	id: text("id").primaryKey(),
	accountId: text("account_id").notNull(),
	providerId: text("provider_id").notNull(),
	userId: text("user_id")
		.notNull()
		.references(() => user.id, { onDelete: "cascade" }),
	accessToken: text("access_token"),
	refreshToken: text("refresh_token"),
	idToken: text("id_token"),
	accessTokenExpiresAt: timestamp("access_token_expires_at"),
	refreshTokenExpiresAt: timestamp("refresh_token_expires_at"),
	scope: text("scope"),
	password: text("password"),
	createdAt: timestamp("created_at").notNull(),
	updatedAt: timestamp("updated_at").notNull(),
});

export const verification = schema.table("verification", {
	id: text("id").primaryKey(),
	identifier: text("identifier").notNull(),
	value: text("value").notNull(),
	expiresAt: timestamp("expires_at").notNull(),
	createdAt: timestamp("created_at"),
	updatedAt: timestamp("updated_at"),
});
