import * as schema from "@/db/schema/index.ts";
import type { createTestDb } from "../setup/db.ts";

/**
 * Baseline seed data for E2E tests
 * This data is inserted before all tests run and cleaned after
 */

/**
 * Seeds baseline users for testing
 */
export async function seedUsers(db: ReturnType<typeof createTestDb>) {
	await db.insert(schema.user).values([
		{
			createdAt: new Date("2024-01-01"),
			email: "admin@test.com",
			emailVerified: true,
			id: "seed-user-admin",
			name: "Admin User",
			updatedAt: new Date("2024-01-01"),
		},
		{
			createdAt: new Date("2024-01-02"),
			email: "user@test.com",
			emailVerified: false,
			id: "seed-user-regular",
			name: "Regular User",
			updatedAt: new Date("2024-01-02"),
		},
	]);

	// Create a session for the admin user (for quick auth tests)
	await db.insert(schema.session).values({
		createdAt: new Date("2024-01-01"),
		expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * 365), // 1 year
		id: "seed-session-admin",
		token: "seed-admin-session-token",
		updatedAt: new Date("2024-01-01"),
		userId: "seed-user-admin",
	});
}
