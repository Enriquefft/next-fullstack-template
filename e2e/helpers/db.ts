import { eq } from "drizzle-orm";
import * as schema from "@/db/schema/index.ts";
import { createTestDb } from "../setup/db.ts";

/**
 * Database query helpers for E2E tests
 * These provide convenient access to common database operations
 */

/**
 * Get user by email
 */
export async function getUserByEmail(email: string) {
	const db = createTestDb(process.env["DATABASE_URL_TEST"]!);

	const [user] = await db
		.select()
		.from(schema.user)
		.where(eq(schema.user.email, email));

	return user ?? null;
}

/**
 * Get user by ID
 */
export async function getUserById(id: string) {
	const db = createTestDb(process.env["DATABASE_URL_TEST"]!);

	const [user] = await db
		.select()
		.from(schema.user)
		.where(eq(schema.user.id, id));

	return user ?? null;
}

/**
 * Get session by token
 */
export async function getSessionByToken(token: string) {
	const db = createTestDb(process.env["DATABASE_URL_TEST"]!);

	const [session] = await db
		.select()
		.from(schema.session)
		.where(eq(schema.session.token, token));

	return session ?? null;
}

/**
 * Delete user by ID (cascades to sessions and accounts)
 */
export async function deleteUser(userId: string) {
	const db = createTestDb(process.env["DATABASE_URL_TEST"]!);

	await db.delete(schema.user).where(eq(schema.user.id, userId));
}

/**
 * Count total users in the database
 */
export async function countUsers() {
	const db = createTestDb(process.env["DATABASE_URL_TEST"]!);

	const users = await db.select().from(schema.user);
	return users.length;
}
