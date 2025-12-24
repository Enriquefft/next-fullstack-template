import "@/styles/globals.css";

import { NextSSRPlugin } from "@uploadthing/react/next-ssr-plugin";
import type { Viewport } from "next";
import { notFound } from "next/navigation";
import { hasLocale, NextIntlClientProvider } from "next-intl";
import { setRequestLocale } from "next-intl/server";
import { extractRouterConfig } from "uploadthing/server";
import { ourFileRouter } from "@/app/api/uploadthing/core";
import { PostHogProvider } from "@/components/PostHogProvider";
import { SchemaScript } from "@/components/seo/schema-script";
import { ThemeProvider } from "@/components/theme-provider";
import { routing } from "@/i18n/routing";
import { generateRootMetadata } from "@/lib/seo/metadata";
import {
	generateOrganizationSchema,
	generateWebSiteSchema,
} from "@/lib/seo/schema";
import { cn } from "@/lib/utils";
import { siteConfig } from "@/metadata";
import { inter as fontSans } from "@/styles/fonts";

// biome-ignore lint/style/useComponentExportOnlyModules: Next.js requires viewport export in layout
export const viewport: Viewport = {
	initialScale: 1,
	themeColor: siteConfig.themeColor,
	width: "device-width",
};

type Props = {
	children: React.ReactNode;
	params: Promise<{ locale: string }>;
};

export function generateStaticParams() {
	return routing.locales.map((locale) => ({ locale }));
}

export async function generateMetadata({ params }: Props) {
	const { locale } = await params;
	return generateRootMetadata(locale);
}

export default async function LocaleLayout({ children, params }: Props) {
	const { locale } = await params;

	if (!hasLocale(routing.locales, locale)) {
		notFound();
	}

	setRequestLocale(locale);

	// Generate JSON-LD schemas for Organization and WebSite
	// These schemas appear on all pages
	const organizationSchema = generateOrganizationSchema();
	const websiteSchema = generateWebSiteSchema({
		inLanguage: [...routing.locales],
	});

	return (
		<html lang={locale} suppressHydrationWarning>
			<head>
				<SchemaScript schema={[organizationSchema, websiteSchema]} />
			</head>
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
						<NextSSRPlugin routerConfig={extractRouterConfig(ourFileRouter)} />
						<NextIntlClientProvider>{children}</NextIntlClientProvider>
					</PostHogProvider>
				</ThemeProvider>
			</body>
		</html>
	);
}
