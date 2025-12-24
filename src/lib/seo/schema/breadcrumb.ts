import type { WithContext } from "./base";
import { withContext } from "./base";

/**
 * BreadcrumbList Schema
 * Helps search engines understand site structure
 */
export type BreadcrumbList = {
	"@type": "BreadcrumbList";
	itemListElement: ListItem[];
};

export type ListItem = {
	"@type": "ListItem";
	position: number;
	name: string;
	item?: string;
};

/**
 * Generate BreadcrumbList schema
 *
 * @example
 * ```tsx
 * const breadcrumbSchema = generateBreadcrumbSchema([
 *   { name: "Home", url: "https://example.com" },
 *   { name: "Products", url: "https://example.com/products" },
 *   { name: "Wireless Headphones" }, // Current page, no URL
 * ]);
 * ```
 */
export function generateBreadcrumbSchema(
	items: Array<{ name: string; url?: string }>,
): WithContext<BreadcrumbList> {
	const itemListElement: ListItem[] = items.map((item, index) => {
		const listItem: ListItem = {
			"@type": "ListItem",
			name: item.name,
			position: index + 1,
		};

		// Only add item URL if it's not the last item (current page)
		if (item.url) {
			listItem.item = item.url;
		}

		return listItem;
	});

	return withContext({
		"@type": "BreadcrumbList",
		itemListElement,
	});
}
