import { createEnv } from "@t3-oss/env-nextjs";
import { z } from "zod";

export const dbEnv = createEnv({
	client: {},
	emptyStringAsUndefined: true,
	experimental__runtimeEnv: process.env,
	server: {
		DRIZZLE_DATABASE_URL: z.url(),
	},
});
