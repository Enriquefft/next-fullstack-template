import type { MetadataRoute } from "next";
import { routing } from "@/i18n/routing";
import { siteConfig } from "@/metadata";

/**
 * Generate sitemap entries for a route across all locales
 *
 * @param path - Route path without locale prefix (e.g., "/about", "/blog/post-1")
 * @param options - Sitemap entry options
 * @returns Array of sitemap entries (one per locale)
 */
export function generateLocalizedEntries(
	path: string,
	options: {
		changeFrequency?:
			| "always"
			| "hourly"
			| "daily"
			| "weekly"
			| "monthly"
			| "yearly"
			| "never";
		priority?: number;
		lastModified?: string | Date;
	} = {},
): MetadataRoute.Sitemap {
	const { changeFrequency = "weekly", priority = 0.5, lastModified } = options;

	const baseUrl = siteConfig.url;
	const cleanPath = path.startsWith("/") ? path : `/${path}`;

	return routing.locales.map((locale) => {
		// For default locale, use root URL without locale prefix
		const url =
			locale === routing.defaultLocale
				? `${baseUrl}${cleanPath}`
				: `${baseUrl}/${locale}${cleanPath}`;

		return {
			changeFrequency,
			lastModified: lastModified || new Date(),
			priority,
			url,
		};
	});
}

/**
 * Generate sitemap entry for a single URL (no localization)
 *
 * @param path - Full path
 * @param options - Sitemap entry options
 * @returns Single sitemap entry
 */
export function generateSingleEntry(
	path: string,
	options: {
		changeFrequency?:
			| "always"
			| "hourly"
			| "daily"
			| "weekly"
			| "monthly"
			| "yearly"
			| "never";
		priority?: number;
		lastModified?: string | Date;
	} = {},
): MetadataRoute.Sitemap[number] {
	const { changeFrequency = "weekly", priority = 0.5, lastModified } = options;

	const baseUrl = siteConfig.url;
	const cleanPath = path.startsWith("/") ? path : `/${path}`;

	return {
		changeFrequency,
		lastModified: lastModified || new Date(),
		priority,
		url: `${baseUrl}${cleanPath}`,
	};
}

/**
 * Helper to get dynamic routes from database
 * Example usage for blog posts, products, etc.
 *
 * @example
 * const posts = await db.select().from(postsTable);
 * const entries = generateDynamicEntries(
 *   posts,
 *   (post) => `/blog/${post.slug}`,
 *   { changeFrequency: 'monthly', priority: 0.7 }
 * );
 */
export function generateDynamicEntries<T>(
	items: T[],
	pathGetter: (item: T) => string,
	options: {
		changeFrequency?:
			| "always"
			| "hourly"
			| "daily"
			| "weekly"
			| "monthly"
			| "yearly"
			| "never";
		priority?: number;
		lastModifiedGetter?: (item: T) => string | Date;
	} = {},
): MetadataRoute.Sitemap {
	const {
		changeFrequency = "weekly",
		priority = 0.5,
		lastModifiedGetter,
	} = options;

	return items.flatMap((item) => {
		const path = pathGetter(item);
		const lastModified = lastModifiedGetter
			? lastModifiedGetter(item)
			: new Date();

		return generateLocalizedEntries(path, {
			changeFrequency,
			lastModified,
			priority,
		});
	});
}
