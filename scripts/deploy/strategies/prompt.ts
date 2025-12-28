import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";
import chalk from "chalk";
import { execa } from "execa";
import { checkGithubSecretExists, setGithubSecret } from "../cli/github.ts";
import { checkVercelVarExists, setVercelVar } from "../cli/vercel.ts";
import { promptForSecret } from "../prompts/input.ts";
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
			return match[2].replace(/^["']|["']$/g, "");
		}
	}

	return undefined;
}

/**
 * Check if variable exists in target platform
 */
async function checkIfExists(
	config: EnvVarConfig,
	platform: "vercel" | "github" | "both",
): Promise<boolean> {
	try {
		if (
			platform === "vercel" &&
			config.deployment.vercelName &&
			config.deployment.vercelScope &&
			config.deployment.vercelScope !== "none"
		) {
			const scope = config.deployment.vercelScope;
			const vercelName = config.deployment.vercelName;
			if (scope === "all") {
				// Check production as representative
				return await checkVercelVarExists(vercelName, "production");
			}
			return await checkVercelVarExists(vercelName, scope);
		}

		if (platform === "github" && config.deployment.githubName) {
			return await checkGithubSecretExists(config.deployment.githubName);
		}

		// For "both", check first available platform
		if (
			platform === "both" &&
			config.deployment.vercelName &&
			config.deployment.vercelScope &&
			config.deployment.vercelScope !== "none"
		) {
			const scope =
				config.deployment.vercelScope === "all"
					? "production"
					: config.deployment.vercelScope;
			return await checkVercelVarExists(config.deployment.vercelName, scope);
		}

		if (platform === "both" && config.deployment.githubName) {
			return await checkGithubSecretExists(config.deployment.githubName);
		}

		return false;
	} catch {
		return false;
	}
}

/**
 * Push value to platform(s)
 */
async function pushValue(
	config: EnvVarConfig,
	value: string,
	platform: "vercel" | "github" | "both",
	dryRun: boolean,
): Promise<void> {
	if (dryRun) {
		const masked = value.length > 8 ? `...${value.slice(-8)}` : "***";
		console.log(
			chalk.gray(`[DRY RUN] Would push ${config.key}=${masked} to ${platform}`),
		);
		return;
	}

	// Push to Vercel
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

	// Push to GitHub
	if (
		(platform === "github" || platform === "both") &&
		config.deployment.githubName
	) {
		await setGithubSecret(config.deployment.githubName, value);
		console.log(
			chalk.green(`✓ ${config.deployment.githubName} → GitHub Actions`),
		);
	}
}

/**
 * Execute prompt strategy
 * Prompts user for environment-specific values or auto-generates in --auto-all mode
 */
export async function executePrompt(
	config: EnvVarConfig,
	flags: CLIFlags,
	platform: "vercel" | "github" | "both",
): Promise<{ success: boolean; skipped: boolean }> {
	try {
		// --auto-all mode
		if (flags.autoAll) {
			let value: string;

			if (config.key === "BETTER_AUTH_SECRET") {
				// Auto-generate using Better Auth CLI
				const result = await execa("bunx", [
					"@better-auth/cli@latest",
					"secret",
				]);
				value = result.stdout.trim();
				console.log(
					chalk.green(
						`✓ Generated ${config.key} for ${config.deployment.vercelScope || "GitHub"}`,
					),
				);
			} else {
				// Try to load from .env.local
				value = loadFromEnvLocal(config.key) ?? "";

				if (!value && config.deployment.required) {
					console.error(
						chalk.red(`✗ Required ${config.key} not in .env.local`),
					);
					return { skipped: false, success: false };
				}

				if (!value) {
					return { skipped: true, success: true };
				}
			}

			await pushValue(config, value, platform, flags.dryRun);
			return { skipped: false, success: true };
		}

		// Interactive mode
		const exists = await checkIfExists(config, platform);
		const value = await promptForSecret({
			defaultValue:
				typeof config.deployment.defaultValue === "function"
					? config.deployment.defaultValue()
					: config.deployment.defaultValue,
			description: config.deployment.description,
			exists,
			name:
				config.deployment.vercelName ||
				config.deployment.githubName ||
				config.key,
		});

		if (!value) {
			return { skipped: true, success: true };
		}

		await pushValue(config, value, platform, flags.dryRun);
		return { skipped: false, success: true };
	} catch (error) {
		if (error instanceof Error && error.message === "Cancelled by user") {
			throw error;
		}

		console.error(
			chalk.red(`✗ Failed to configure ${config.key}:`),
			error instanceof Error ? error.message : error,
		);
		return { skipped: false, success: false };
	}
}
