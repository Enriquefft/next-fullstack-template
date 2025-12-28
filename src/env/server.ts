/** biome-ignore-all lint/complexity/useLiteralKeys: to access the nextjs env variables, we use process.env, which needs to be typed */

import { createEnv } from "@t3-oss/env-nextjs";
import { z } from "zod";

const getBaseUrl = () => {
	const customUrl = z
		.string()
		.min(1)
		.safeParse(process.env["NEXT_PUBLIC_APP_URL"]).data;
	if (customUrl) {
		return customUrl;
	}

	if (
		process.env["VERCEL_ENV"] === "production" &&
		process.env["VERCEL_PROJECT_PRODUCTION_URL"]
	) {
		return `https://${process.env["VERCEL_PROJECT_PRODUCTION_URL"]}`;
	}

	if (process.env["VERCEL_URL"]) {
		return `https://${process.env["VERCEL_URL"]}`;
	}

	return "http://localhost:3000";
};

const url = getBaseUrl();

export const serverEnv = createEnv({
	client: {},
	emptyStringAsUndefined: true,
	experimental__runtimeEnv: process.env,
	// Explicitly mark as server-side - this module should never run on the client.
	// Without this, test environments with Happy DOM (which creates a `window` global)
	// are incorrectly detected as client environments by t3-env.
	isServer: true,
	server: {
		BETTER_AUTH_SECRET: z.string().min(32, {
			message:
				"BETTER_AUTH_SECRET must be at least 32 chars. Use: bun run auth:secret",
		}),
		BETTER_AUTH_URL: z.string().default(url),
		GOOGLE_CLIENT_ID: z.string(),
		GOOGLE_CLIENT_SECRET: z.string(),
		// Kapso WhatsApp API (optional)
		KAPSO_API_KEY: z.string().optional(),
		KAPSO_PHONE_NUMBER_ID: z.string().optional(),
		META_APP_SECRET: z.string().optional(),
		POLAR_ACCESS_TOKEN: z.string(),
		POLAR_MODE: z.enum(["sandbox", "production"]).default("sandbox"),
		// PostHog analytics
		POSTHOG_PROJECT_ID: z.string(),
		// UploadThing file uploads
		UPLOADTHING_TOKEN: z.string(),
	},
});
