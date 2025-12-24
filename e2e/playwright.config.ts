import path from "node:path";
import { fileURLToPath } from "node:url";
import { defineConfig, devices } from "@playwright/test";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Use PORT env variable to allow port override (defaults to 3000)
// Usage: PORT=3001 bun test:e2e
const PORT = process.env["PORT"] || 3000;
const baseURL = `http://localhost:${PORT}`;

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
	],
    /* Reporter to use. See https://playwright.dev/docs/test-reporters */
    reporter: "html",
    /* Retry on CI only */
    retries: process.env["CI"] ? 2 : 0,
    testDir: "./tests",

    /* Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions. */
    use: {
        /* Base URL to use in actions like `await page.goto('/')`. */
        baseURL,
        screenshot: "only-on-failure",
        /* Collect trace when retrying the failed test. See https://playwright.dev/docs/trace-viewer */
        trace: "on-first-retry",
    },

    /* Run your local dev server before starting the tests */
    webServer: {
        command: "bun run dev",
        env: {
            // Database
            DATABASE_URL_TEST: process.env["DATABASE_URL_TEST"] || "",
            NODE_ENV: "test",
            // Authentication
            GOOGLE_CLIENT_ID: process.env["GOOGLE_CLIENT_ID"] || "",
            GOOGLE_CLIENT_SECRET: process.env["GOOGLE_CLIENT_SECRET"] || "",
            BETTER_AUTH_SECRET: process.env["BETTER_AUTH_SECRET"] || "",
            // Analytics
            NEXT_PUBLIC_POSTHOG_KEY: process.env["NEXT_PUBLIC_POSTHOG_KEY"] || "",
            // Payments
            POLAR_ACCESS_TOKEN: process.env["POLAR_ACCESS_TOKEN"] || "",
            POLAR_MODE: process.env["POLAR_MODE"] || "sandbox",
            // File uploads
            UPLOADTHING_TOKEN: process.env["UPLOADTHING_TOKEN"] || "",
            // Project config
            NEXT_PUBLIC_PROJECT_NAME: process.env["NEXT_PUBLIC_PROJECT_NAME"] || "",
            // Server config
            PORT: PORT.toString(),
        },
        reuseExistingServer: !process.env["CI"],
        timeout: 120 * 1000,
        url: baseURL,
    },
    /* Opt out of parallel tests on CI. */
    workers: process.env["CI"] ? 1 : undefined,
});
