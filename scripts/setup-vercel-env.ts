#!/usr/bin/env bun

import chalk from "chalk";
import { checkVercelCli, checkVercelProject } from "./deploy/cli/vercel.ts";
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
		printHelp("setup-vercel-env.ts");
		process.exit(0);
	}

	printHeader("Vercel Environment Variables Setup", "▲");

	if (flags.dryRun) {
		printInfo("DRY RUN MODE - No changes will be made");
		console.log("");
	}

	if (flags.autoAll) {
		printInfo("AUTO-ALL MODE - Skipping prompts, auto-generating secrets");
		console.log("");
	}

	// Check Vercel CLI
	if (!(await checkVercelCli())) {
		printError("Vercel CLI not found");
		console.log("");
		console.log("Install: npm i -g vercel");
		console.log("Authenticate: vercel login");
		process.exit(1);
	}

	if (!(await checkVercelProject())) {
		printError("Project not linked to Vercel");
		console.log("");
		console.log("Link your project: vercel link");
		process.exit(1);
	}

	console.log(chalk.green("✓ Vercel CLI ready"));
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
			// Skip if not for Vercel
			if (!varConfig.deployment.vercelName) {
				continue;
			}

			try {
				let result: { success: boolean; skipped: boolean };
				const { strategy } = varConfig.deployment;

				if (strategy === "auto-push" || strategy === "auto-generate") {
					result = await executeAutoPush(varConfig, flags, "vercel");
					if (!result.skipped) stats.autoPushed++;
				} else if (strategy === "prompt") {
					result = await executePrompt(varConfig, flags, "vercel");
					if (!result.skipped) stats.prompted++;
				} else if (strategy === "optional") {
					result = await executeAutoPush(varConfig, flags, "vercel");
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
