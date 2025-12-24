import type { MetadataRoute } from "next";
import { generateLocalizedEntries } from "@/lib/seo/sitemap-utils";

/**
 * Multi-locale sitemap
 *
 * Automatically generates sitemap entries for all routes across all supported locales.
 *
 * How to customize:
 * 1. Add/remove static routes from the staticRoutes array
 * 2. For dynamic routes (e.g., blog posts), import db and use generateDynamicEntries
 * 3. Adjust changeFrequency and priority based on content update frequency
 *
 * @example Adding dynamic routes:
 * ```ts
 * import { db } from "@/db";
 * import { posts } from "@/db/schema";
 * import { generateDynamicEntries } from "@/lib/seo/sitemap-utils";
 *
 * const blogPosts = await db.select().from(posts);
 * const blogEntries = generateDynamicEntries(
 *   blogPosts,
 *   (post) => `/blog/${post.slug}`,
 *   { changeFrequency: 'weekly', priority: 0.7 }
 * );
 * ```
 */
export default function sitemap(): MetadataRoute.Sitemap {
	// Define all static routes in your application
	const staticRoutes = [
		{
			changeFrequency: "daily" as const,
			path: "/",
			priority: 1.0,
		},
		{
			changeFrequency: "yearly" as const,
			path: "/confirmation",
			priority: 0.3,
		},
		{
			changeFrequency: "monthly" as const,
			path: "/example-uploader",
			priority: 0.5,
		},
		// Add more routes here as your app grows:
		// { path: "/about", changeFrequency: "monthly", priority: 0.8 },
		// { path: "/contact", changeFrequency: "monthly", priority: 0.7 },
		// { path: "/pricing", changeFrequency: "weekly", priority: 0.9 },
	];

	// Generate localized entries for all static routes
	const entries = staticRoutes.flatMap((route) =>
		generateLocalizedEntries(route.path, {
			changeFrequency: route.changeFrequency,
			priority: route.priority,
		}),
	);

	// TODO: Add dynamic routes here when implementing features with dynamic content
	// Example:
	// const blogPosts = await db.select().from(posts);
	// const blogEntries = generateDynamicEntries(
	//   blogPosts,
	//   (post) => `/blog/${post.slug}`,
	//   {
	//     changeFrequency: 'weekly',
	//     priority: 0.7,
	//     lastModifiedGetter: (post) => post.updatedAt || post.createdAt,
	//   }
	// );
	// entries.push(...blogEntries);

	return entries;
}
