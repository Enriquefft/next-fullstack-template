#!/usr/bin/env bun

import chalk from "chalk";
import prompts from "prompts";
import { checkGithubCli } from "./deploy/cli/github.ts";
import {
	checkVercelCli,
	checkVercelGitConnection,
	checkVercelProject,
	connectVercelGit,
} from "./deploy/cli/vercel.ts";
import { CATEGORIES, getVariablesByCategory } from "./deploy/config.ts";
import {
	printCategoryHeader,
	printError,
	printHeader,
	printHelp,
	printInfo,
	printSummary,
} from "./deploy/prompts/display.ts";
import { promptPlatform } from "./deploy/prompts/input.ts";
import { executeAutoPush } from "./deploy/strategies/auto-push.ts";
import { executePrompt } from "./deploy/strategies/prompt.ts";
import { parseArgs } from "./deploy/types.ts";

async function main() {
	// Parse command-line arguments
	const flags = parseArgs(process.argv.slice(2));

	if (flags.help) {
		printHelp("setup-env.ts");
		process.exit(0);
	}

	// Welcome message
	printHeader("Environment Variables Setup", "🔐");

	if (flags.dryRun) {
		printInfo("DRY RUN MODE - No changes will be made");
		console.log("");
	}

	if (flags.autoAll) {
		printInfo("AUTO-ALL MODE - Skipping prompts, auto-generating secrets");
		console.log("");
	}

	// Determine platform (auto-select 'both' in auto-all mode)
	const platform =
		flags.platform || (flags.autoAll ? "both" : await promptPlatform());

	console.log("");

	// Check required CLIs
	if (platform === "vercel" || platform === "both") {
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

		// Check if Git repository is connected
		if (!(await checkVercelGitConnection())) {
			console.log("");
			console.log(chalk.yellow("⚠ Git repository not connected to Vercel"));
			console.log(
				chalk.dim(
					"  Connecting your Git repository enables automatic deployments on push",
				),
			);
			console.log("");

			const response = await prompts(
				{
					initial: true,
					message: "Connect GitHub repository for auto-deploy?",
					name: "value",
					type: "confirm",
				},
				{
					onCancel: () => {
						throw new Error("Cancelled by user");
					},
				},
			);

			if (response.value) {
				try {
					await connectVercelGit();
					console.log(chalk.green("✓ Git repository connected"));
				} catch (error) {
					printError(
						`Failed to connect Git repository: ${error instanceof Error ? error.message : String(error)}`,
					);
					console.log("");
					console.log(
						chalk.yellow(
							"You can connect manually later with: vercel git connect",
						),
					);
				}
			} else {
				console.log("");
				console.log(
					chalk.yellow(
						"⚠ Skipped - you can connect later with: vercel git connect",
					),
				);
			}
		} else {
			console.log(chalk.green("✓ Git repository connected"));
		}
	}

	if (platform === "github" || platform === "both") {
		if (!(await checkGithubCli())) {
			printError("GitHub CLI not found");
			console.log("");
			console.log("Install: brew install gh (macOS)");
			console.log("Authenticate: gh auth login");
			process.exit(1);
		}

		console.log(chalk.green("✓ GitHub CLI ready"));
	}

	// Track statistics
	const stats = {
		autoPushed: 0,
		failed: 0,
		prompted: 0,
		skipped: 0,
	};

	// Process all categories
	for (const category of CATEGORIES) {
		printCategoryHeader(category.title, category.emoji);

		const variables = getVariablesByCategory(category.id);

		for (const varConfig of variables) {
			const { strategy } = varConfig.deployment;

			// Skip variables not applicable to this platform
			if (platform === "vercel" && !varConfig.deployment.vercelName) {
				continue;
			}

			if (platform === "github" && !varConfig.deployment.githubName) {
				continue;
			}

			try {
				let result: { success: boolean; skipped: boolean };

				if (strategy === "auto-push" || strategy === "auto-generate") {
					result = await executeAutoPush(varConfig, flags, platform);
					if (!result.skipped) stats.autoPushed++;
				} else if (strategy === "prompt") {
					result = await executePrompt(varConfig, flags, platform);
					if (!result.skipped) stats.prompted++;
				} else if (strategy === "optional") {
					result = await executeAutoPush(varConfig, flags, platform);
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
					`Failed to configure ${varConfig.key}: ${error instanceof Error ? error.message : String(error)}`,
				);
				stats.failed++;
			}
		}
	}

	// Print summary
	printSummary(stats);

	// Exit with error if any failures
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
