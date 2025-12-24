import type { Page } from "@playwright/test";
import * as schema from "@/db/schema/index.ts";
import { createTestDb } from "../setup/db.ts";

export interface TestUser {
	id: string;
	email: string;
	sessionToken: string;
}

/**
 * Creates an authenticated user with a valid session in the test database
 */
export async function createAuthenticatedUser(
	overrides?: Partial<typeof schema.user.$inferInsert>,
): Promise<TestUser> {
	const db = createTestDb(process.env["DATABASE_URL_TEST"]!);

	const userId = crypto.randomUUID();
	const sessionToken = crypto.randomUUID();

	// Create user
	await db.insert(schema.user).values({
		createdAt: new Date(),
		email: overrides?.email || `test-${userId}@example.com`,
		emailVerified: overrides?.emailVerified ?? false,
		id: userId,
		name: overrides?.name || "Test User",
		updatedAt: new Date(),
		...overrides,
	});

	// Create session (expires in 24 hours)
	await db.insert(schema.session).values({
		createdAt: new Date(),
		expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24),
		id: crypto.randomUUID(),
		token: sessionToken,
		updatedAt: new Date(),
		userId,
	});

	return {
		email: overrides?.email || `test-${userId}@example.com`,
		id: userId,
		sessionToken,
	};
}

/**
 * Authenticates a Playwright page by setting the Better Auth session cookie
 */
export async function authenticatePage(page: Page, user: TestUser) {
	// Better Auth uses 'better-auth.session_token' cookie
	await page.context().addCookies([
		{
			domain: "localhost",
			httpOnly: true,
			name: "better-auth.session_token",
			path: "/",
			sameSite: "Lax",
			value: user.sessionToken,
		},
	]);
}

/**
 * Creates and authenticates a user in one step
 */
export async function createAndAuthenticateUser(
	page: Page,
	overrides?: Partial<typeof schema.user.$inferInsert>,
): Promise<TestUser> {
	const user = await createAuthenticatedUser(overrides);
	await authenticatePage(page, user);
	return user;
}
