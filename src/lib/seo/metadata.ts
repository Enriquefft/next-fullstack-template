import type { Metadata } from "next";
import { getMessages } from "next-intl/server";
import { routing } from "@/i18n/routing";
import { siteConfig } from "@/metadata";

type Messages = Record<string, unknown>;
type Locale = (typeof routing.locales)[number];

/**
 * Type guard to check if a string is a valid locale
 */
function isValidLocale(locale: string): locale is Locale {
	return routing.locales.includes(locale as Locale);
}

/**
 * Helper to safely extract string value from an object
 */
function getStringValue(obj: unknown, key: string): string | undefined {
	if (obj && typeof obj === "object" && key in obj) {
		const value = (obj as Record<string, unknown>)[key];
		return typeof value === "string" ? value : undefined;
	}
	return undefined;
}

/**
 * Locale to OpenGraph locale mapping
 * Add more mappings as needed for your supported locales
 */
const localeToOgLocale: Record<string, string> = {
	de: "de_DE",
	en: "en_US",
	es: "es_ES",
	fr: "fr_FR",
	ja: "ja_JP",
	pt: "pt_BR",
	zh: "zh_CN",
};

/**
 * Get OpenGraph locale from i18n locale
 */
export function getOgLocale(locale: string): string {
	return localeToOgLocale[locale] || "en_US";
}

/**
 * Generate canonical URL for a page
 * @param path - Path relative to site root (e.g., "/about", "/blog/post-1")
 * @param locale - Current locale
 * @param includeLocale - Whether to include locale in URL (default: true)
 */
export function getCanonicalUrl(
	path = "",
	locale: string = routing.defaultLocale,
	includeLocale = true,
): string {
	const baseUrl = siteConfig.url;
	const cleanPath = path.startsWith("/") ? path.slice(1) : path;
	const trailingSlashRemoved = cleanPath.endsWith("/")
		? cleanPath.slice(0, -1)
		: cleanPath;

	// Don't include locale for default locale in URL
	if (!includeLocale || locale === routing.defaultLocale) {
		return `${baseUrl}/${trailingSlashRemoved}`;
	}

	return `${baseUrl}/${locale}/${trailingSlashRemoved}`;
}

/**
 * Generate alternate language links for all supported locales
 * Used for hreflang tags
 */
export function getAlternateLanguages(path = "") {
	const languages: Record<string, string> = {};

	// Add all locale variants
	for (const locale of routing.locales) {
		languages[locale] = getCanonicalUrl(path, locale, true);
	}

	// Add x-default pointing to default locale
	languages["x-default"] = getCanonicalUrl(path, routing.defaultLocale, false);

	return languages;
}

/**
 * Create OpenGraph image object
 */
export function getOgImage(imagePath: string = siteConfig.ogImage) {
	return {
		alt: siteConfig.name,
		height: 630,
		type: "image/webp",
		url: new URL(imagePath, siteConfig.url).toString(),
		width: 1200,
	};
}

/**
 * Generate locale-aware metadata for a page
 * Reads title and description from message files if available
 *
 * @param options - Metadata generation options
 * @returns Next.js Metadata object
 */
export async function generatePageMetadata(options: {
	/** Current locale */
	locale: string;
	/** Page path for canonical URL (e.g., "/about", "/blog/post-1") */
	path?: string;
	/** Translation namespace (e.g., "HomePage", "AboutPage") */
	namespace?: string;
	/** Override title (takes precedence over translation) */
	title?: string;
	/** Override description (takes precedence over translation) */
	description?: string;
	/** Additional keywords to merge with site keywords */
	keywords?: string[];
	/** Custom OpenGraph image path */
	ogImage?: string;
	/** Whether this page should be indexed (default: true) */
	noIndex?: boolean;
}): Promise<Metadata> {
	const {
		locale,
		path = "",
		namespace,
		title: titleOverride,
		description: descriptionOverride,
		keywords: additionalKeywords = [],
		ogImage,
		noIndex = false,
	} = options;

	// Try to get translations if namespace is provided
	let title = titleOverride;
	let description = descriptionOverride;

	if (namespace && (!titleOverride || !descriptionOverride)) {
		if (isValidLocale(locale)) {
			try {
				const messages = (await getMessages({ locale })) as Messages;
				const namespaceData = messages[namespace];

				if (!titleOverride) {
					const titleValue = getStringValue(namespaceData, "title");
					if (titleValue) {
						title = titleValue;
					}
				}

				if (!descriptionOverride) {
					const descriptionValue = getStringValue(namespaceData, "description");
					if (descriptionValue) {
						description = descriptionValue;
					}
				}
			} catch {
				// Fallback handled below
			}
		}
	}

	const pageTitle = title || siteConfig.name;
	const pageDescription = description || siteConfig.description;
	const canonicalUrl = getCanonicalUrl(path, locale);
	const alternateLanguages = getAlternateLanguages(path);
	const ogLocale = getOgLocale(locale);
	const ogImageData = getOgImage(ogImage);
	const allKeywords = [...siteConfig.keywords, ...additionalKeywords];

	const metadata: Metadata = {
		alternates: {
			canonical: canonicalUrl,
			languages: alternateLanguages,
		},
		authors: [siteConfig.author],
		creator: siteConfig.author.name,
		description: pageDescription,
		keywords: allKeywords,
		metadataBase: new URL(siteConfig.url),
		openGraph: {
			description: pageDescription,
			images: [ogImageData],
			locale: ogLocale,
			siteName: siteConfig.name,
			title: pageTitle,
			type: "website",
			url: canonicalUrl,
		},
		title: pageTitle,
		twitter: {
			card: "summary_large_image",
			description: pageDescription,
			images: [ogImageData],
			title: pageTitle,
		},
	};

	// Add robots meta if noIndex is true
	if (noIndex) {
		metadata.robots = {
			follow: false,
			index: false,
		};
	}

	return metadata;
}

/**
 * Generate root layout metadata
 * This is used for the main layout and provides template-level defaults
 */
export async function generateRootMetadata(locale: string): Promise<Metadata> {
	return generatePageMetadata({
		locale,
		namespace: "Metadata",
		path: "",
	});
}
