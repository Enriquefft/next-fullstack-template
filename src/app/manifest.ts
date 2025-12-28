import type { MetadataRoute } from "next";
import { siteConfig } from "@/metadata";

/**
 * Web App Manifest
 *
 * Defines how the application appears when installed as a PWA.
 * IMPORTANT: Update these values when customizing the template:
 * - name: Full application name
 * - short_name: Short name for home screen (12 chars max recommended)
 * - description: Brief description of your app
 * - theme_color: Brand color (should match siteConfig.themeColor)
 * - background_color: Splash screen background color
 * - icons: Update with your app icons (use icon.png in this directory as a base)
 */
export default function manifest(): MetadataRoute.Manifest {
	return {
		background_color: "#ffffff",
		description: siteConfig.description,
		display: "standalone",
		icons: [
			{
				sizes: "192x192",
				src: "/icon-192.png",
				type: "image/png",
			},
			{
				sizes: "512x512",
				src: "/icon-512.png",
				type: "image/png",
			},
		],
		name: siteConfig.name,
		short_name: siteConfig.name,
		start_url: "/",
		theme_color: siteConfig.themeColor,
	};
}
