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
		// next-intl redirects to locale-prefixed URL
		await expect(page).toHaveURL(/\/(en|es)/);
	});

	test("can create authenticated user and verify in database", async () => {
		// Use unique email to avoid conflicts when tests run in parallel
		const uniqueEmail = `newuser-${crypto.randomUUID()}@test.com`;
		const user = await createAuthenticatedUser({
			email: uniqueEmail,
			name: "New Test User",
		});

		// Verify user exists in database
		const dbUser = await getUserByEmail(uniqueEmail);
		expect(dbUser).toBeTruthy();
		expect(dbUser?.id).toBe(user.id);
		expect(dbUser?.name).toBe("New Test User");

		// Verify session exists
		const session = await getSessionByToken(user.sessionToken);
		expect(session).toBeTruthy();
		expect(session?.userId).toBe(user.id);
	});

	test("authenticated users can access protected routes", async ({ page }) => {
		// Create and authenticate a user with unique email
		const uniqueEmail = `authenticated-${crypto.randomUUID()}@test.com`;
		await createAndAuthenticateUser(page, {
			email: uniqueEmail,
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
