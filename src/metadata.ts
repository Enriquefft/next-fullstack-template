import type { Metadata } from "next";
import { getBaseUrl } from "@/lib/utils";

const siteName = "Next Fullstack Template";
const description =
	"A fullstack Next.js starter powered by Bun, Tailwind CSS and Drizzle ORM.";
const url = getBaseUrl();
const keywords = ["Next.js", "fullstack", "Bun", "Drizzle ORM", "template"];

const webpImage = {
	alt: siteName,
	height: 630,
	type: "image/webp",
	url: new URL("/opengraph-image.webp", url).toString(),
	width: 1200,
};

export const metadata: Metadata = {
	authors: [
		{
			name: "Enrique Flores",
			url: "https://www.linkedin.com/in/enriqueflores000/",
		},
	],
	creator: "Enrique Flores",
	description,
	icons: {
		icon: "/icon.png",
	},
	keywords,
	metadataBase: new URL(url),

	openGraph: {
		description,
		images: [
			// webpImage is preferred for WhatsApp
			webpImage,
		],
		locale: "en_US",
		siteName,
		title: siteName,
		type: "website",
		url,
	},

	title: {
		default: siteName,
		template: `%s | ${siteName}`,
	},
	twitter: {
		card: "summary_large_image",
		description,
		images: [webpImage],
		title: siteName,
	},
};
