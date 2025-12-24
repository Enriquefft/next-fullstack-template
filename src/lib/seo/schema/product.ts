import type { ImageObject, WithContext } from "./base";
import { withContext } from "./base";

/**
 * Product Schema
 * For e-commerce and product pages
 */
export type Product = {
	"@type": "Product";
	name: string;
	description?: string;
	image?: string | ImageObject | ImageObject[];
	brand?: {
		"@type": "Brand";
		name: string;
	};
	offers?: Offer | Offer[];
	aggregateRating?: AggregateRating;
	review?: Review[];
	sku?: string;
	mpn?: string;
	gtin?: string;
};

export type Offer = {
	"@type": "Offer";
	url?: string;
	priceCurrency: string;
	price: string | number;
	priceValidUntil?: string;
	availability?: string;
	itemCondition?: string;
	seller?: {
		"@type": "Organization";
		name: string;
	};
};

export type AggregateRating = {
	"@type": "AggregateRating";
	ratingValue: number;
	reviewCount: number;
	bestRating?: number;
	worstRating?: number;
};

export type Review = {
	"@type": "Review";
	author: {
		"@type": "Person";
		name: string;
	};
	datePublished: string;
	reviewBody?: string;
	reviewRating: {
		"@type": "Rating";
		ratingValue: number;
		bestRating?: number;
		worstRating?: number;
	};
};

/**
 * Generate Product schema
 *
 * @example
 * ```tsx
 * const productSchema = generateProductSchema({
 *   name: "Wireless Headphones",
 *   description: "High-quality wireless headphones with noise cancellation",
 *   image: "https://example.com/headphones.jpg",
 *   brand: "TechBrand",
 *   sku: "WH-1000XM4",
 *   offers: {
 *     priceCurrency: "USD",
 *     price: 349.99,
 *     availability: "https://schema.org/InStock",
 *     url: "https://example.com/products/headphones",
 *   },
 *   aggregateRating: {
 *     ratingValue: 4.5,
 *     reviewCount: 128,
 *   },
 * });
 * ```
 */
export function generateProductSchema(options: {
	name: string;
	description?: string;
	image?: string | ImageObject | ImageObject[];
	brand?: string;
	offers?: Offer | Offer[];
	aggregateRating?: AggregateRating;
	review?: Review[];
	sku?: string;
	mpn?: string;
	gtin?: string;
}): WithContext<Product> {
	const {
		name,
		description,
		image,
		brand,
		offers,
		aggregateRating,
		review,
		sku,
		mpn,
		gtin,
	} = options;

	const schema: Product = {
		"@type": "Product",
		aggregateRating,
		description,
		gtin,
		image,
		mpn,
		name,
		offers,
		review,
		sku,
	};

	// Add brand if provided
	if (brand) {
		schema.brand = {
			"@type": "Brand",
			name: brand,
		};
	}

	return withContext(schema);
}
