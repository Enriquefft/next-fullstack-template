import { execa } from "execa";
import type { VercelScope } from "../types.ts";

/**
 * Check if Vercel CLI is installed and user is authenticated
 */
export async function checkVercelCli(): Promise<boolean> {
	try {
		await execa("vercel", ["whoami"]);
		return true;
	} catch {
		return false;
	}
}

/**
 * Check if project is linked to Vercel
 */
export async function checkVercelProject(): Promise<boolean> {
	try {
		await execa("vercel", ["env", "ls"]);
		return true;
	} catch {
		return false;
	}
}

/**
 * Check if a Vercel environment variable exists
 */
export async function checkVercelVarExists(
	name: string,
	scope: Exclude<VercelScope, "all" | "none">,
): Promise<boolean> {
	try {
		const result = await execa("vercel", ["env", "ls", "--environment", scope]);
		// Check if variable name appears in output (exact match at start of line)
		const regex = new RegExp(`^${name}\\s`, "m");
		return regex.test(result.stdout);
	} catch {
		return false;
	}
}

/**
 * Set Vercel environment variable for specific scope(s)
 */
export async function setVercelVar(
	name: string,
	value: string,
	scope: VercelScope | "all",
): Promise<void> {
	const scopes: Array<Exclude<VercelScope, "all" | "none">> =
		scope === "all"
			? ["production", "preview", "development"]
			: [scope as Exclude<VercelScope, "all" | "none">];

	for (const env of scopes) {
		// Remove existing first (prevents duplicates)
		await execa("vercel", ["env", "rm", name, env, "--yes"], {
			reject: false,
		});

		// Add new value via stdin
		await execa("vercel", ["env", "add", name, env], {
			input: value,
		});
	}
}
