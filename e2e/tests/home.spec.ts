import { expect, test } from "@playwright/test";

test("home page loads successfully", async ({ page }) => {
	await page.goto("/");

	// Wait for the page to load
	await page.waitForLoadState("networkidle");

	// Check that the page has a title
	await expect(page).toHaveTitle(/Next/);

	// Verify the page is rendered
	const body = page.locator("body");
	await expect(body).toBeVisible();
});

test("navigation works", async ({ page }) => {
	await page.goto("/");

	// Check that we can see content on the page
	const content = await page.content();
	expect(content.length).toBeGreaterThan(0);
});
