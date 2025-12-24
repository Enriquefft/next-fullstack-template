import { expect, test } from "@playwright/test";
import {
	authenticatePage,
	createAndAuthenticateUser,
	createAuthenticatedUser,
} from "../helpers/auth.ts";
import { getSessionByToken, getUserByEmail } from "../helpers/db.ts";

test.describe("Authentication", () => {
	test("unauthenticated users can access home page", async ({ page }) => {
		await page.goto("/");
		await expect(page).toHaveURL("/");
	});

	test("can create authenticated user and verify in database", async () => {
		const user = await createAuthenticatedUser({
			email: "newuser@test.com",
			name: "New Test User",
		});

		// Verify user exists in database
		const dbUser = await getUserByEmail("newuser@test.com");
		expect(dbUser).toBeTruthy();
		expect(dbUser?.id).toBe(user.id);
		expect(dbUser?.name).toBe("New Test User");

		// Verify session exists
		const session = await getSessionByToken(user.sessionToken);
		expect(session).toBeTruthy();
		expect(session?.userId).toBe(user.id);
	});

	test("authenticated users can access protected routes", async ({ page }) => {
		// Create and authenticate a user
		await createAndAuthenticateUser(page, {
			email: "authenticated@test.com",
		});

		// Try to access a protected route (adjust URL to match your app)
		await page.goto("/");

		// Verify the user is logged in (adjust selector to match your app)
		// Example: check for user menu, profile link, etc.
		// await expect(page.getByText(user.email)).toBeVisible();
	});

	test("uses seeded admin user from baseline data", async ({ page }) => {
		// The admin user was seeded in global-setup
		const adminUser = {
			email: "admin@test.com",
			id: "seed-user-admin",
			sessionToken: "seed-admin-session-token",
		};

		await authenticatePage(page, adminUser);

		// Verify we can use the seeded user
		const dbUser = await getUserByEmail("admin@test.com");
		expect(dbUser).toBeTruthy();
		expect(dbUser?.emailVerified).toBe(true);
	});
});
