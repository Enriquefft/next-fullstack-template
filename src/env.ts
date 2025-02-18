import { vercel } from "@t3-oss/env-core/presets-zod";
import { createEnv } from "@t3-oss/env-nextjs";
import { z } from "zod";

export const env = createEnv({
	extends: [vercel()],

	server: {
		// biome-ignore lint/style/useNamingConvention: <explanation>
		DRIZZLE_DATABASE_URL: z.string().url(),
	},
	client: {
		// biome-ignore lint/style/useNamingConvention: <explanation>
		NEXT_PUBLIC_PROJECT_NAME: z.string(),
	},
	runtimeEnv: {
		// biome-ignore lint/style/useNamingConvention: <explanation>
		// biome-ignore lint/complexity/useLiteralKeys: <explanation>
		NEXT_PUBLIC_PROJECT_NAME: process.env["NEXT_PUBLIC_PROJECT_NAME"],
		// biome-ignore lint/style/useNamingConvention: <explanation>
		// biome-ignore lint/complexity/useLiteralKeys: <explanation>
		DRIZZLE_DATABASE_URL: process.env["DRIZZLE_DATABASE_URL"],
	},
	emptyStringAsUndefined: false,
});
