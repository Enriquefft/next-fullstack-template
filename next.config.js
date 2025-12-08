import { fileURLToPath } from "node:url";
import { createJiti } from "jiti";

const jiti = createJiti(fileURLToPath(import.meta.url));

await jiti.import("./src/env.ts");

/** @type {import('next').NextConfig} */
const nextConfig = {
	async rewrites() {
		return [
			{
				destination: "https://us-assets.i.posthog.com/static/:path*",
				source: "/ingest/static/:path*",
			},
			{
				destination: "https://us.i.posthog.com/:path*",
				source: "/ingest/:path*",
			},
			{
				destination: "https://us.i.posthog.com/decide",
				source: "/ingest/decide",
			},
		];
	},
	skipTrailingSlashRedirect: true,
	// This is required to support PostHog trailing slash API requests
	transpilePackages: ["@t3-oss/env-nextjs", "@t3-oss/env-core"],
	typedRoutes: true,
};

export default nextConfig;
