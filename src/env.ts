/* eslint-disable @typescript-eslint/naming-convention */
import { createEnv } from "@t3-oss/env-nextjs";
import { z } from "zod";
import { vercel } from "@t3-oss/env-core/presets";

export const env = createEnv({
  extends: [vercel()],

  server: {
    DRIZZLE_DATABASE_URL: z.string().url(),
  },
  client: {
    NEXT_PUBLIC_PROJECT_NAME: z.string(),
  },
  runtimeEnv: {
    NEXT_PUBLIC_PROJECT_NAME: process.env["NEXT_PUBLIC_PROJECT_NAME"],
    DRIZZLE_DATABASE_URL: process.env["DRIZZLE_DATABASE_URL"],
  },
  emptyStringAsUndefined: false,
});
