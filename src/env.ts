/** biome-ignore-all lint/complexity/useLiteralKeys: On this file, we need to use string keys for the env object. */
/** biome-ignore-all lint/style/useNamingConvention: <explanation> */

import { vercel } from "@t3-oss/env-core/presets-zod";
import { createEnv } from "@t3-oss/env-nextjs";
import { z } from "zod";
import { getBaseUrl } from "./lib/utils.ts";

const url = getBaseUrl();

export const env = createEnv({
	client: {
		NEXT_PUBLIC_APP_URL: z.string().optional(),
		NEXT_PUBLIC_POSTHOG_KEY: z.string(),
		NEXT_PUBLIC_PROJECT_NAME: z.string(),
	},

	emptyStringAsUndefined: false,
	extends: [vercel()],
	runtimeEnv: {
		BETTER_AUTH_URL: process.env["BETTER_AUTH_URL"],
		DRIZZLE_DATABASE_URL: process.env["DRIZZLE_DATABASE_URL"],
		GOOGLE_CLIENT_ID: process.env["GOOGLE_CLIENT_ID"],
		GOOGLE_CLIENT_SECRET: process.env["GOOGLE_CLIENT_SECRET"],
		NEXT_PUBLIC_APP_URL: process.env["NEXT_PUBLIC_APP_URL"],
		NEXT_PUBLIC_POSTHOG_KEY: process.env["NEXT_PUBLIC_POSTHOG_KEY"],
		NEXT_PUBLIC_PROJECT_NAME: process.env["NEXT_PUBLIC_PROJECT_NAME"],
		POLAR_ACCESS_TOKEN: process.env["POLAR_ACCESS_TOKEN"],
		POLAR_MODE: process.env["POLAR_MODE"],
	},
	server: {
		BETTER_AUTH_URL: z.string().default(url),
		DRIZZLE_DATABASE_URL: z.string().url(),
		GOOGLE_CLIENT_ID: z.string(),
		GOOGLE_CLIENT_SECRET: z.string(),
		POLAR_ACCESS_TOKEN: z.string(),
		POLAR_MODE: z.enum(["sandbox", "production"]).default("sandbox"),
	},
});
