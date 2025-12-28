#!/usr/bin/env bun

import chalk from "chalk";
import { checkGithubCli } from "./deploy/cli/github.ts";
import { CATEGORIES, getVariablesByCategory } from "./deploy/config.ts";
import {
	printCategoryHeader,
	printError,
	printHeader,
	printHelp,
	printInfo,
	printSummary,
} from "./deploy/prompts/display.ts";
import { executeAutoPush } from "./deploy/strategies/auto-push.ts";
import { executePrompt } from "./deploy/strategies/prompt.ts";
import { parseArgs } from "./deploy/types.ts";

async function main() {
	const flags = parseArgs(process.argv.slice(2));

	if (flags.help) {
		printHelp("setup-github-secrets.ts");
		process.exit(0);
	}

	printHeader("GitHub Actions Secrets Setup", "🔒");

	if (flags.dryRun) {
		printInfo("DRY RUN MODE - No changes will be made");
		console.log("");
	}

	if (flags.autoAll) {
		printInfo("AUTO-ALL MODE - Skipping prompts, auto-generating secrets");
		console.log("");
	}

	// Check GitHub CLI
	if (!(await checkGithubCli())) {
		printError("GitHub CLI not found");
		console.log("");
		console.log("Install: brew install gh (macOS)");
		console.log("Authenticate: gh auth login");
		process.exit(1);
	}

	console.log(chalk.green("✓ GitHub CLI ready"));
	console.log("");

	const stats = {
		autoPushed: 0,
		failed: 0,
		prompted: 0,
		skipped: 0,
	};

	for (const category of CATEGORIES) {
		printCategoryHeader(category.title, category.emoji);

		const variables = getVariablesByCategory(category.id);

		for (const varConfig of variables) {
			// Skip if not for GitHub
			if (!varConfig.deployment.githubName) {
				continue;
			}

			try {
				let result: { success: boolean; skipped: boolean };
				const { strategy } = varConfig.deployment;

				if (strategy === "auto-push" || strategy === "auto-generate") {
					result = await executeAutoPush(varConfig, flags, "github");
					if (!result.skipped) stats.autoPushed++;
				} else if (strategy === "prompt") {
					result = await executePrompt(varConfig, flags, "github");
					if (!result.skipped) stats.prompted++;
				} else if (strategy === "optional") {
					result = await executeAutoPush(varConfig, flags, "github");
					if (!result.skipped) stats.autoPushed++;
				} else {
					continue;
				}

				if (result.skipped) stats.skipped++;
				if (!result.success) stats.failed++;
			} catch (error) {
				if (error instanceof Error && error.message === "Cancelled by user") {
					throw error;
				}

				printError(
					`Failed: ${error instanceof Error ? error.message : String(error)}`,
				);
				stats.failed++;
			}
		}
	}

	printSummary(stats);

	if (stats.failed > 0) {
		process.exit(1);
	}
}

main().catch((error) => {
	if (error.message === "Cancelled by user") {
		console.log("");
		console.log(chalk.yellow("Setup cancelled by user"));
		process.exit(0);
	}

	console.error("");
	printError(`Unexpected error: ${error.message}`);
	console.error(error);
	process.exit(1);
});
