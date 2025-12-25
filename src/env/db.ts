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
	server: {
		// Primary: single DATABASE_URL (for production/deployment)
		DATABASE_URL: neonUrlSchema.optional(),

		// Fallback: environment-specific URLs (for local development)
		DATABASE_URL_DEV: neonUrlSchema.optional(),
		DATABASE_URL_PROD: neonUrlSchema.optional(),
		DATABASE_URL_STAGING: neonUrlSchema.optional(),
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
 * 1. DATABASE_URL (if set - typically for production/Vercel)
 * 2. DATABASE_URL_{NODE_ENV} (environment-specific URL)
 *
 * @throws {Error} If no valid database URL is configured
 */
function getDatabaseUrl(): string {
	// 1. Prefer explicit DATABASE_URL (production/Vercel)
	if (dbEnv.DATABASE_URL) {
		return dbEnv.DATABASE_URL;
	}

	// 2. Fall back to environment-specific (local development)
	const env = dbEnv.NODE_ENV;

	let url: string | undefined;
	switch (env) {
		case "production":
			url = dbEnv.DATABASE_URL_PROD;
			break;
		case "test":
			url = dbEnv.DATABASE_URL_TEST;
			break;
		default:
			url = dbEnv.DATABASE_URL_DEV;
	}

	if (!url) {
		throw new Error(
			`Database URL not configured for environment: ${env}. ` +
				`Set DATABASE_URL or DATABASE_URL_${env.toUpperCase()}`,
		);
	}

	return url;
}

export const databaseUrl = getDatabaseUrl();
