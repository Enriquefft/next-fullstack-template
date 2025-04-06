import type { Metadata } from "next";
export const metadata: Metadata = {
	authors: [
		{
			name: "Enrique Flores",
			url: "https://www.linkedin.com/in/enriqueflores000/",
		},
	],
	description: "Nextjs template",
	keywords: ["Nextjs", "fullstack", "templates"],
	metadataBase: new URL("https://next-learn-dashboard.vercel.sh"),
	title: {
		default: "Nextjs template",
		template: "%s | Nextjs template",
	},
};
