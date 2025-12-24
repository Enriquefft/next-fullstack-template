import { siteConfig } from "@/metadata";
import type { ImageObject, PostalAddress, WithContext } from "./base";
import { withContext } from "./base";

/**
 * Organization Schema
 * Represents your company/organization for search engines
 */
export type Organization = {
	"@type": "Organization";
	name: string;
	url: string;
	logo?: ImageObject | string;
	description?: string;
	address?: PostalAddress;
	contactPoint?: ContactPoint[];
	sameAs?: string[];
	founder?: string;
	foundingDate?: string;
};

export type ContactPoint = {
	"@type": "ContactPoint";
	telephone?: string;
	contactType: string;
	email?: string;
	areaServed?: string;
	availableLanguage?: string[];
};

/**
 * Generate Organization schema
 *
 * @example
 * ```tsx
 * const orgSchema = generateOrganizationSchema({
 *   description: "We build amazing software",
 *   sameAs: ["https://twitter.com/yourcompany", "https://linkedin.com/company/yourcompany"],
 *   contactPoint: [{
 *     contactType: "Customer Support",
 *     email: "support@example.com",
 *   }],
 * });
 * ```
 */
export function generateOrganizationSchema(
	options: {
		name?: string;
		url?: string;
		logo?: ImageObject | string;
		description?: string;
		address?: PostalAddress;
		contactPoint?: ContactPoint[];
		sameAs?: string[];
		founder?: string;
		foundingDate?: string;
	} = {},
): WithContext<Organization> {
	const {
		name = siteConfig.name,
		url = siteConfig.url,
		logo = siteConfig.ogImage,
		description = siteConfig.description,
		address,
		contactPoint,
		sameAs,
		founder,
		foundingDate,
	} = options;

	// Convert logo string to ImageObject if needed
	const logoObject =
		typeof logo === "string"
			? {
					"@type": "ImageObject" as const,
					url: new URL(logo, url).toString(),
				}
			: logo;

	return withContext({
		"@type": "Organization",
		address,
		contactPoint,
		description,
		founder,
		foundingDate,
		logo: logoObject,
		name,
		sameAs,
		url,
	});
}
