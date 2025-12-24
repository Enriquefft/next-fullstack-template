import { siteConfig } from "@/metadata";
import type { WithContext } from "./base";
import { withContext } from "./base";

/**
 * WebSite Schema with SearchAction
 * Enables search box in Google search results
 */
export type WebSite = {
	"@type": "WebSite";
	name: string;
	url: string;
	description?: string;
	potentialAction?: SearchAction;
	inLanguage?: string | string[];
};

export type SearchAction = {
	"@type": "SearchAction";
	target: {
		"@type": "EntryPoint";
		urlTemplate: string;
	};
	"query-input": string;
};

/**
 * Generate WebSite schema with optional search functionality
 *
 * @example
 * ```tsx
 * const websiteSchema = generateWebSiteSchema({
 *   searchUrl: "/search?q={search_term_string}",
 *   inLanguage: ["es", "en"],
 * });
 * ```
 */
export function generateWebSiteSchema(
	options: {
		name?: string;
		url?: string;
		description?: string;
		/** Search URL template with {search_term_string} placeholder */
		searchUrl?: string;
		inLanguage?: string | string[];
	} = {},
): WithContext<WebSite> {
	const {
		name = siteConfig.name,
		url = siteConfig.url,
		description = siteConfig.description,
		searchUrl,
		inLanguage,
	} = options;

	const schema: WebSite = {
		"@type": "WebSite",
		description,
		inLanguage,
		name,
		url,
	};

	// Add search action if search URL is provided
	if (searchUrl) {
		schema.potentialAction = {
			"@type": "SearchAction",
			"query-input": "required name=search_term_string",
			target: {
				"@type": "EntryPoint",
				urlTemplate: `${url}${searchUrl}`,
			},
		};
	}

	return withContext(schema);
}
