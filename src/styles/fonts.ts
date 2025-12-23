// Temporarily use local font to avoid Google Fonts fetch issues during build
// import { Inter } from "next/font/google";

// export const inter = Inter({
// 	subsets: ["latin"],
// 	variable: "--font-sans",
// });

// Using system fonts as fallback for builds
export const inter = {
	className: "font-sans",
	variable: "--font-sans"
};
