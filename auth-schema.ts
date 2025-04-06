import { boolean, text, timestamp, varchar } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";
import { schema } from "@/db/schema/schema";

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
	createdAt: timestamp("created_at").notNull(),
	dni: varchar("dni", { length: 8 }).unique(),
	email: text("email").notNull().unique(),
	emailVerified: boolean("email_verified").notNull(),
	id: text("id").primaryKey(),
	image: text("image"),
	name: text("name").notNull(),

	// extra fields
	phone: varchar("phone", { length: 24 }),
	role: roleEnum().notNull().default("user"),
	updatedAt: timestamp("updated_at").notNull(),
});

export const userSchema = createInsertSchema(user, {
	dni: dniSchema,
	email: (_schema) => _schema.email("Correo electronico inválido"),
	phone: phoneSchema,
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
