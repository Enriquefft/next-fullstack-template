import createNextIntlPlugin from "next-intl/plugin";

import "./src/env/client";
import type { NextConfig } from "next";

const withNextIntl = createNextIntlPlugin();

const nextConfig: NextConfig = {
	// Image optimization configuration
	images: {
		// Define device sizes for responsive images
		// These match common breakpoints: mobile, tablet, desktop, large desktop
		deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
		// Enable modern image formats (AVIF, WebP)
		formats: ["image/avif", "image/webp"],

		// Define image sizes for srcset generation
		imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],

		// Minimum cache TTL for optimized images (in seconds)
		minimumCacheTTL: 60 * 60 * 24 * 7, // 7 days
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
	typedRoutes: true,
};

export default withNextIntl(nextConfig);
