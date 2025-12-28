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

    /* Increase timeout for slow server responses */
    timeout: 60 * 1000,

	/* Configure projects for major browsers */
	projects: [
		{
			name: "chromium",
			use: { ...devices["Desktop Chrome"] },
		},
	],
    /* Output directory for test artifacts */
    outputDir: path.resolve(__dirname, "./test-results"),
    /* Reporter to use. See https://playwright.dev/docs/test-reporters */
    reporter: [["html", { outputFolder: path.resolve(__dirname, "./playwright-report") }]],
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
        command: "bash scripts/start-test-server.sh",
        cwd: path.resolve(__dirname, ".."),
        env: {
            ...process.env,
            PORT: PORT.toString(),
            NODE_ENV: "test",
        },
        reuseExistingServer: !process.env["CI"],
        stdout: "pipe",
        stderr: "pipe",
        timeout: 120 * 1000,
        url: baseURL,
    },
    /* Limit parallel workers to avoid overwhelming dev server */
    workers: process.env["CI"] ? 1 : 3,
});
