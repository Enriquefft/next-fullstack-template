import type { NextConfig } from "next";

import "./src/env.ts";
const nextConfig: NextConfig = {
	eslint: {
		// Warning: This allows production builds to successfully complete even if
		// your project has ESLint errors.
		ignoreDuringBuilds: true,
	},
	experimental: {
		typedRoutes: true,
	},
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
};

export default nextConfig;
