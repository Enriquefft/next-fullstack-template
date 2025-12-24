import type { ImageObject, Person, WithContext } from "./base";
import { withContext } from "./base";

/**
 * Article Schema (including BlogPosting, NewsArticle)
 * Critical for GEO - helps AI search engines understand and cite your content
 */
export type Article = {
	"@type": "Article" | "BlogPosting" | "NewsArticle" | "TechArticle";
	headline: string;
	description?: string;
	image?: string | ImageObject | ImageObject[];
	datePublished: string;
	dateModified?: string;
	author: Person | Person[];
	publisher?: {
		"@type": "Organization";
		name: string;
		logo?: ImageObject;
	};
	url?: string;
	articleBody?: string;
	wordCount?: number;
	keywords?: string[];
	articleSection?: string;
	inLanguage?: string;
};

/**
 * Generate Article schema
 *
 * @example
 * ```tsx
 * const articleSchema = generateArticleSchema({
 *   headline: "10 Tips for Better SEO",
 *   description: "Learn how to optimize your content for search engines",
 *   image: "https://example.com/article-image.jpg",
 *   datePublished: "2024-01-15",
 *   dateModified: "2024-01-20",
 *   author: {
 *     "@type": "Person",
 *     name: "John Doe",
 *     url: "https://example.com/authors/john-doe",
 *   },
 *   publisher: {
 *     name: "My Blog",
 *     logo: { "@type": "ImageObject", url: "https://example.com/logo.png" },
 *   },
 *   keywords: ["SEO", "optimization", "content"],
 * });
 * ```
 */
export function generateArticleSchema(options: {
	type?: "Article" | "BlogPosting" | "NewsArticle" | "TechArticle";
	headline: string;
	description?: string;
	image?: string | ImageObject | ImageObject[];
	datePublished: string;
	dateModified?: string;
	author: Person | Person[];
	publisher?: {
		name: string;
		logo?: ImageObject;
	};
	url?: string;
	articleBody?: string;
	wordCount?: number;
	keywords?: string[];
	articleSection?: string;
	inLanguage?: string;
}): WithContext<Article> {
	const {
		type = "Article",
		headline,
		description,
		image,
		datePublished,
		dateModified,
		author,
		publisher,
		url,
		articleBody,
		wordCount,
		keywords,
		articleSection,
		inLanguage,
	} = options;

	const schema: Article = {
		"@type": type,
		articleBody,
		articleSection,
		author,
		dateModified: dateModified || datePublished,
		datePublished,
		description,
		headline,
		image,
		inLanguage,
		keywords,
		url,
		wordCount,
	};

	// Add publisher if provided
	if (publisher) {
		schema.publisher = {
			"@type": "Organization",
			logo: publisher.logo,
			name: publisher.name,
		};
	}

	return withContext(schema);
}
