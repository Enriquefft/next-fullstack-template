import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";
import { z } from "zod";

/**
 * @param inputs - Class values to merge
 * @returns A tailwindcsj string of merged class names
 */
export function cn(...inputs: ClassValue[]) {
	return twMerge(clsx(inputs));
}

/** biome-ignore-start lint/complexity/useLiteralKeys: On this file, we need to use string keys for the env object. */
export const getBaseUrl = () => {
	const customUrl = z
		.string()
		.min(1)
		.safeParse(process.env["NEXT_PUBLIC_APP_URL"]).data;
	if (customUrl) {
		return customUrl;
	}

	if (
		process.env["VERCEL_ENV"] === "production" &&
		process.env["VERCEL_PROJECT_PRODUCTION_URL"]
	) {
		return `https://${process.env["VERCEL_PROJECT_PRODUCTION_URL"]}`;
	}

	if (process.env["VERCEL_URL"]) {
		return `https://${process.env["VERCEL_URL"]}`;
	}

	return "http://localhost:3000";
};
/** biome-ignore-end lint/complexity/useLiteralKeys: On this file, we need to use string keys for the env object. */
