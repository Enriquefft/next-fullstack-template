import * as schema from "@/db/schema/index.ts";
import { createTestDb } from "../setup/db.ts";

/**
 * Test data factories for creating database records on-demand
 */

/**
 * Creates a user factory that generates unique users
 */
export function createUserFactory() {
	let counter = 0;

	return async (overrides?: Partial<typeof schema.user.$inferInsert>) => {
		const db = createTestDb(process.env["DATABASE_URL_TEST"]!);
		counter++;

		const [user] = await db
			.insert(schema.user)
			.values({
				createdAt: new Date(),
				email: `user-${counter}@test.com`,
				emailVerified: false,
				id: crypto.randomUUID(),
				name: `Test User ${counter}`,
				updatedAt: new Date(),
				...overrides,
			})
			.returning();

		return user;
	};
}

/**
 * Creates a session factory that generates unique sessions
 */
export function createSessionFactory() {
	return async (
		userId: string,
		overrides?: Partial<typeof schema.session.$inferInsert>,
	) => {
		const db = createTestDb(process.env["DATABASE_URL_TEST"]!);

		const [session] = await db
			.insert(schema.session)
			.values({
				createdAt: new Date(),
				expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24), // 24 hours
				id: crypto.randomUUID(),
				token: crypto.randomUUID(),
				updatedAt: new Date(),
				userId,
				...overrides,
			})
			.returning();

		return session;
	};
}
