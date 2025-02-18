import "@/styles/globals.css";
export { metadata } from "@/metadata";

import { inter as fontSans } from "@/styles/fonts";

import { cn } from "@/lib/utils";

/**
 * @param layoutPros - The root layout component props
 * @param layoutPros.children - The layout children
 * @returns The root layout component
 */
export default function RootLayout({
	children,
}: {
	children: React.ReactNode;
}) {
	return (
		<html lang="en">
			<body
				className={cn(
					"min-h-screen bg-background font-sans antialiased",
					fontSans.className,
				)}
			>
				{children}
			</body>
		</html>
	);
}
