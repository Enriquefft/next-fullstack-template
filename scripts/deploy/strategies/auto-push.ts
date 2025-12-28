import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";
import chalk from "chalk";
import { setGithubSecret } from "../cli/github.ts";
import { setVercelVar } from "../cli/vercel.ts";
import type { CLIFlags, EnvVarConfig } from "../types.ts";

/**
 * Load environment variable from .env.local file
 */
function loadFromEnvLocal(key: string): string | undefined {
	const envPath = resolve(process.cwd(), ".env.local");

	if (!existsSync(envPath)) {
		return undefined;
	}

	const content = readFileSync(envPath, "utf-8");

	for (const line of content.split("\n")) {
		const trimmed = line.trim();
		if (!trimmed || trimmed.startsWith("#")) continue;

		const match = trimmed.match(/^([A-Z_][A-Z0-9_]*)=(.*)$/);
		if (match && match[1] === key && match[2] !== undefined) {
			// Remove surrounding quotes if present
			return match[2].replace(/^["']|["']$/g, "");
		}
	}

	return undefined;
}

/**
 * Execute auto-push strategy
 * Reads value from .env.local and pushes to platforms
 */
export async function executeAutoPush(
	config: EnvVarConfig,
	flags: CLIFlags,
	platform: "vercel" | "github" | "both",
): Promise<{ success: boolean; skipped: boolean }> {
	let value = loadFromEnvLocal(config.key);

	// Handle missing value
	if (!value) {
		// Try default value
		if (config.deployment.defaultValue) {
			value =
				typeof config.deployment.defaultValue === "function"
					? config.deployment.defaultValue()
					: config.deployment.defaultValue;
		} else if (config.deployment.required) {
			console.error(chalk.red(`✗ Required ${config.key} not in .env.local`));
			return { skipped: false, success: false };
		} else {
			// Optional variable not present - skip
			return { skipped: true, success: true };
		}
	}

	// Dry run mode
	if (flags.dryRun) {
		const masked = value.length > 8 ? `...${value.slice(-8)}` : "***";
		console.log(
			chalk.gray(`[DRY RUN] Would push ${config.key}=${masked} to ${platform}`),
		);
		return { skipped: false, success: true };
	}

	// Push to platforms
	try {
		if (
			(platform === "vercel" || platform === "both") &&
			config.deployment.vercelName &&
			config.deployment.vercelScope &&
			config.deployment.vercelScope !== "none"
		) {
			const vercelScope = config.deployment.vercelScope;
			await setVercelVar(config.deployment.vercelName, value, vercelScope);
			console.log(
				chalk.green(
					`✓ ${config.deployment.vercelName} → Vercel (${vercelScope})`,
				),
			);
		}

		if (
			(platform === "github" || platform === "both") &&
			config.deployment.githubName
		) {
			await setGithubSecret(config.deployment.githubName, value);
			console.log(
				chalk.green(`✓ ${config.deployment.githubName} → GitHub Actions`),
			);
		}

		return { skipped: false, success: true };
	} catch (error) {
		console.error(
			chalk.red(`✗ Failed to push ${config.key}:`),
			error instanceof Error ? error.message : error,
		);
		return { skipped: false, success: false };
	}
}
