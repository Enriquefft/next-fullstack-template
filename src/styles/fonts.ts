// Using system fonts due to network restrictions preventing Google Fonts access
// To re-enable Inter font from Google Fonts when network allows:
// import { Inter } from "next/font/google";
// export const inter = Inter({ subsets: ["latin"], variable: "--font-sans" });

export const inter = {
	className: "font-sans",
	variable: "--font-sans",
	style: {
		fontFamily: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif"
	}
};
