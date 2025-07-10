import { getBaseUrl } from "@/lib/utils";
import type { Metadata } from "next";

const siteName = "Next Fullstack Template";
const description =
	"A fullstack Next.js starter powered by Bun, Tailwind CSS and Drizzle ORM.";
const url = getBaseUrl();

export const metadata: Metadata = {
	metadataBase: new URL(url),
	title: {
		default: siteName,
		template: `%s | ${siteName}`,
	},
	description,
	keywords: ["Next.js", "fullstack", "Bun", "Drizzle ORM", "template"],
	authors: [
		{
			name: "Enrique Flores",
			url: "https://www.linkedin.com/in/enriqueflores000/",
		},
	],
	creator: "Enrique Flores",
	openGraph: {
		type: "website",
		url,
		title: siteName,
		description,
		siteName,
		images: [
			{
				url: new URL("/opengraph-image.png", url).toString(),
				width: 1200,
				height: 630,
				alt: siteName,
			},
		],
		locale: "en_US",
	},
	twitter: {
		card: "summary_large_image",
		title: siteName,
		description,
		images: [new URL("/opengraph-image.png", url).toString()],
	},
	icons: {
		icon: "/icon.png",
	},
};
