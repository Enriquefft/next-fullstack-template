import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

/**
 * @param inputs - Class values to merge
 * @returns A tailwindcsj string of merged class names
 */
export function cn(...inputs: ClassValue[]) {
	return twMerge(clsx(inputs));
}
