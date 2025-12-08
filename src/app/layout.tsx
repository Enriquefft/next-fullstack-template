import "@/styles/globals.css";

export { metadata } from "@/metadata";

import { NextSSRPlugin } from "@uploadthing/react/next-ssr-plugin";
import { extractRouterConfig } from "uploadthing/server";
import { ourFileRouter } from "@/app/api/uploadthing/core";
import { PostHogProvider } from "@/components/PostHogProvider";
import { ThemeProvider } from "@/components/theme-provider";
import { cn } from "@/lib/utils";
import { inter as fontSans } from "@/styles/fonts";

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
		<html lang="en" suppressHydrationWarning>
			<body
				className={cn(
					"min-h-screen bg-background font-sans antialiased",
					fontSans.className,
				)}
			>
				<ThemeProvider
					attribute="class"
					defaultTheme="system"
					enableSystem
					disableTransitionOnChange
				>
					<PostHogProvider>
						<NextSSRPlugin
							/**
							 * The `extractRouterConfig` will extract **only** the route configs
							 * from the router to prevent additional information from being
							 * leaked to the client. The data passed to the client is the same
							 * as if you were to fetch `/api/uploadthing` directly.
							 */
							routerConfig={extractRouterConfig(ourFileRouter)}
						/>

						{children}
					</PostHogProvider>
				</ThemeProvider>
			</body>
		</html>
	);
}
