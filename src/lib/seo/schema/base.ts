/**
 * Base types and utilities for JSON-LD structured data
 * Schema.org compliant types for SEO and GEO optimization
 */

/**
 * Base JSON-LD type with @context and @type
 */
export type WithContext<T> = T & {
	"@context": "https://schema.org";
};

/**
 * Common schema.org types
 */
export type Thing = {
	"@type": string;
	name?: string;
	description?: string;
	url?: string;
	image?: string | ImageObject | ImageObject[];
	sameAs?: string[];
};

export type ImageObject = {
	"@type": "ImageObject";
	url: string;
	width?: number;
	height?: number;
	caption?: string;
};

export type Person = {
	"@type": "Person";
	name: string;
	url?: string;
	image?: string;
	jobTitle?: string;
	sameAs?: string[];
};

export type PostalAddress = {
	"@type": "PostalAddress";
	streetAddress?: string;
	addressLocality?: string;
	addressRegion?: string;
	postalCode?: string;
	addressCountry?: string;
};

/**
 * Helper to create an ImageObject
 */
export function createImageObject(
	url: string,
	options?: {
		width?: number;
		height?: number;
		caption?: string;
	},
): ImageObject {
	return {
		"@type": "ImageObject",
		caption: options?.caption,
		height: options?.height,
		url,
		width: options?.width,
	};
}

/**
 * Helper to create a Person object
 */
export function createPerson(
	name: string,
	options?: {
		url?: string;
		image?: string;
		jobTitle?: string;
		sameAs?: string[];
	},
): Person {
	return {
		"@type": "Person",
		image: options?.image,
		jobTitle: options?.jobTitle,
		name,
		sameAs: options?.sameAs,
		url: options?.url,
	};
}

/**
 * Helper to add @context wrapper to any schema
 */
export function withContext<T extends Thing>(schema: T): WithContext<T> {
	return {
		"@context": "https://schema.org",
		...schema,
	};
}
