import type { Metadata } from "next";
export const metadata: Metadata = {
	metadataBase: new URL("https://next-learn-dashboard.vercel.sh"),
	title: {
		template: "%s | Nextjs template",
		default: "Nextjs template",
	},
	description: "Nextjs template",
	keywords: ["Nextjs", "fullstack", "templates"],
	authors: [
		{
			name: "Enrique Flores",
			url: "https://www.linkedin.com/in/enriqueflores000/",
		},
	],
};
