import { createEnv } from "@t3-oss/env-nextjs";
import { z } from "zod";

// Neon PostgreSQL URL validator
const neonUrlSchema = z
	.url()
	.startsWith(
		"postgresql://",
		"Database URL must be a PostgreSQL connection string",
	)
	.refine(
		(url) => {
			// Validate that the URL has the required parts for authentication
			try {
				const parsed = new URL(url);
				return parsed.username && parsed.password && parsed.hostname;
			} catch {
				return false;
			}
		},
		{ message: "Invalid database URL format: missing credentials or hostname" },
	);

export const dbEnv = createEnv({
	client: {},
	emptyStringAsUndefined: true,
	experimental__runtimeEnv: process.env,
	// Explicitly mark as server-side - this module should never run on the client.
	// Without this, test environments with Happy DOM (which creates a `window` global)
	// are incorrectly detected as client environments by t3-env.
	isServer: true,
	server: {
		// Primary: DATABASE_URL (set by Vercel for production/preview)
		DATABASE_URL: neonUrlSchema.optional(),

		// Local development URLs (set in .env.local)
		DATABASE_URL_DEV: neonUrlSchema.optional(),
		DATABASE_URL_TEST: neonUrlSchema.optional(),

		NODE_ENV: z
			.enum(["development", "test", "production"])
			.default("development"),
	},
	skipValidation: false,
});

/**
 * Get the database URL based on the current environment.
 *
 * Priority:
 * 1. DATABASE_URL (set by Vercel for production/preview deployments)
 * 2. DATABASE_URL_TEST (when NODE_ENV=test, for E2E tests)
 * 3. DATABASE_URL_DEV (for local development)
 *
 * @throws {Error} If no valid database URL is configured
 */
function getDatabaseUrl(): string {
	// 1. Prefer DATABASE_URL (set by Vercel)
	if (dbEnv.DATABASE_URL) {
		return dbEnv.DATABASE_URL;
	}

	// 2. Fall back to local environment URLs
	const env = dbEnv.NODE_ENV;
	const url = env === "test" ? dbEnv.DATABASE_URL_TEST : dbEnv.DATABASE_URL_DEV;

	if (!url) {
		const varName = env === "test" ? "DATABASE_URL_TEST" : "DATABASE_URL_DEV";
		throw new Error(
			`Database URL not configured. Set DATABASE_URL or ${varName} in your .env.local file.`,
		);
	}

	return url;
}

export const databaseUrl = getDatabaseUrl();
