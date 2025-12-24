import type { MetadataRoute } from "next";
import { siteConfig } from "@/metadata";

/**
 * Dynamic robots.txt configuration
 *
 * Environment-aware behavior:
 * - Production: Allow all, include sitemap
 * - Staging/Development: Disallow all (prevent indexing)
 *
 * Can be overridden with NEXT_PUBLIC_ROBOTS_ALLOW env var
 */
export default function robots(): MetadataRoute.Robots {
	const baseUrl = siteConfig.url;
	const isProduction = process.env.NODE_ENV === "production";

	// Allow override via environment variable
	// biome-ignore lint/complexity/useLiteralKeys: TypeScript requires bracket notation for index signature
	const allowRobots = process.env["NEXT_PUBLIC_ROBOTS_ALLOW"]
		? // biome-ignore lint/complexity/useLiteralKeys: TypeScript requires bracket notation for index signature
			process.env["NEXT_PUBLIC_ROBOTS_ALLOW"] === "true"
		: isProduction;

	if (!allowRobots) {
		// Staging or development: block all crawlers
		return {
			rules: {
				disallow: "/",
				userAgent: "*",
			},
		};
	}

	// Production: allow all with standard exclusions
	return {
		rules: [
			{
				allow: "/",
				disallow: ["/api/", "/admin/", "/_next/", "/private/", "*.json"],
				userAgent: "*",
			},
		],
		sitemap: `${baseUrl}/sitemap.xml`,
	};
}
