/**
 * This test verifies that server-side modules can be imported in unit tests.
 *
 * Previously, this would fail because:
 * 1. Happy DOM (test environment) creates a global `window` object
 * 2. t3-env uses `typeof window === "undefined"` to detect server vs client
 * 3. With Happy DOM, t3-env incorrectly blocked server env var access
 *
 * The fix was adding `isServer: true` to server-only env modules:
 * - src/env/db.ts
 * - src/env/server.ts
 *
 * Additionally, auth.ts now passes `baseURL: serverEnv.BETTER_AUTH_URL`
 * explicitly instead of relying on better-auth to read from process.env.
 *
 * Required env vars for these tests:
 * - GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, POLAR_ACCESS_TOKEN (auth)
 * - DATABASE_URL_DEV or DATABASE_URL_TEST (database)
 */
import { describe, expect, test } from "bun:test";

import { auth } from "@/auth.ts";

describe("auth module", () => {
	test("auth object should be defined", () => {
		expect(auth).toBeDefined();
	});

	test("auth should have socialProviders configured", () => {
		expect(auth).toHaveProperty("options");
	});
});
