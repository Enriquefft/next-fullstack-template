import type { ImageObject, Person, WithContext } from "./base";
import { withContext } from "./base";

/**
 * WebPage Schema
 * Represents a single page on your website
 */
export type WebPage = {
	"@type": "WebPage";
	name: string;
	url: string;
	description?: string;
	image?: string | ImageObject;
	datePublished?: string;
	dateModified?: string;
	author?: Person;
	inLanguage?: string;
	isPartOf?: {
		"@type": "WebSite";
		name: string;
		url: string;
	};
};

/**
 * Generate WebPage schema
 *
 * @example
 * ```tsx
 * const pageSchema = generateWebPageSchema({
 *   name: "About Us",
 *   url: "https://example.com/about",
 *   description: "Learn about our company",
 *   datePublished: "2024-01-01",
 *   inLanguage: "en",
 * });
 * ```
 */
export function generateWebPageSchema(options: {
	name: string;
	url: string;
	description?: string;
	image?: string | ImageObject;
	datePublished?: string;
	dateModified?: string;
	author?: Person;
	inLanguage?: string;
	websiteName?: string;
	websiteUrl?: string;
}): WithContext<WebPage> {
	const {
		name,
		url,
		description,
		image,
		datePublished,
		dateModified,
		author,
		inLanguage,
		websiteName,
		websiteUrl,
	} = options;

	const schema: WebPage = {
		"@type": "WebPage",
		author,
		dateModified,
		datePublished,
		description,
		image,
		inLanguage,
		name,
		url,
	};

	// Add website reference if provided
	if (websiteName && websiteUrl) {
		schema.isPartOf = {
			"@type": "WebSite",
			name: websiteName,
			url: websiteUrl,
		};
	}

	return withContext(schema);
}
