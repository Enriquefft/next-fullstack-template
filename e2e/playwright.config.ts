import path from "node:path";
import { defineConfig, devices } from "@playwright/test";

/**
 * See https://playwright.dev/docs/test-configuration.
 */
export default defineConfig({
	/* Fail the build on CI if you accidentally left test.only in the source code. */
	forbidOnly: !!process.env["CI"],

	/* Run tests in files in parallel */
	fullyParallel: true,
	globalSetup: path.resolve(__dirname, "./setup/global-setup.ts"),
	globalTeardown: path.resolve(__dirname, "./setup/global-teardown.ts"),

	/* Configure projects for major browsers */
	projects: [
		{
			name: "chromium",
			use: { ...devices["Desktop Chrome"] },
		},

		{
			name: "firefox",
			use: { ...devices["Desktop Firefox"] },
		},

		{
			name: "webkit",
			use: { ...devices["Desktop Safari"] },
		},

		/* Test against mobile viewports. */
		// {
		//   name: 'Mobile Chrome',
		//   use: { ...devices['Pixel 5'] },
		// },
		// {
		//   name: 'Mobile Safari',
		//   use: { ...devices['iPhone 12'] },
		// },

		/* Test against branded browsers. */
		// {
		//   name: 'Microsoft Edge',
		//   use: { ...devices['Desktop Edge'], channel: 'msedge' },
		// },
		// {
		//   name: 'Google Chrome',
		//   use: { ...devices['Desktop Chrome'], channel: 'chrome' },
		// },
	],
	/* Reporter to use. See https://playwright.dev/docs/test-reporters */
	reporter: "html",
	/* Retry on CI only */
	retries: process.env["CI"] ? 2 : 0,
	testDir: "./tests",

	/* Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions. */
	use: {
		/* Base URL to use in actions like `await page.goto('/')`. */
		baseURL: "http://localhost:3000",
		screenshot: "only-on-failure",
		/* Collect trace when retrying the failed test. See https://playwright.dev/docs/trace-viewer */
		trace: "on-first-retry",
	},

	/* Run your local dev server before starting the tests */
	webServer: {
		command: "bun run dev",
		env: {
			// Inject test database URL for the Next.js dev server
			DRIZZLE_DATABASE_URL: process.env["DATABASE_URL_TEST"] || "",
		},
		reuseExistingServer: !process.env["CI"],
		url: "http://localhost:3000",
	},
	/* Opt out of parallel tests on CI. */
	workers: process.env["CI"] ? 1 : undefined,
});
