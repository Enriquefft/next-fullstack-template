import { getBaseUrl } from "@/lib/utils";

/**
 * Site Configuration
 *
 * IMPORTANT: When using /implement-prd, customize these values to match your project:
 * - name: Your project/product name
 * - description: Brief description for SEO
 * - url: Production URL (or keep getBaseUrl() for automatic detection)
 * - ogImage: Path to your OpenGraph image (1200x630px recommended)
 * - author: Your name and URL
 * - keywords: Relevant keywords for your project
 * - themeColor: Brand color for mobile browsers
 */
export const siteConfig = {
	author: {
		name: "Enrique Flores",
		url: "https://www.linkedin.com/in/enriqueflores000/",
	},
	description:
		"A fullstack Next.js starter powered by Bun, Tailwind CSS and Drizzle ORM.",
	keywords: ["Next.js", "fullstack", "Bun", "Drizzle ORM", "template"],
	name: "Next Fullstack Template",
	ogImage: "/opengraph-image.webp",
	themeColor: "#000000",
	url: getBaseUrl(),
} as const;
