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
            // Inject test database URL for the Next.js dev server
            DRIZZLE_DATABASE_URL: process.env["DATABASE_URL_TEST"] || "",
            // Pass PORT to Next.js to ensure consistent port usage
            PORT: PORT.toString(),
        },
        reuseExistingServer: !process.env["CI"],
        timeout: 120 * 1000,
        url: baseURL,
    },
    /* Opt out of parallel tests on CI. */
    workers: process.env["CI"] ? 1 : undefined,
});
