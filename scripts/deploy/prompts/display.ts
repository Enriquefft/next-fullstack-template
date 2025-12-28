import chalk from "chalk";

/**
 * Print header with emoji and title
 */
export function printHeader(title: string, emoji: string): void {
	console.log("");
	console.log(chalk.bold.blue(`${emoji} ${title}`));
	console.log(chalk.gray("=".repeat(60)));
	console.log("");
}

/**
 * Print category header
 */
export function printCategoryHeader(title: string, emoji: string): void {
	console.log("");
	console.log(chalk.bold.cyan(`${emoji}  ${title}`));
	console.log(chalk.gray("─".repeat(60)));
}

/**
 * Print success message
 */
export function printSuccess(message: string): void {
	console.log(chalk.green(`✓ ${message}`));
}

/**
 * Print error message
 */
export function printError(message: string): void {
	console.error(chalk.red(`✗ ${message}`));
}

/**
 * Print warning message
 */
export function printWarning(message: string): void {
	console.warn(chalk.yellow(`⚠ ${message}`));
}

/**
 * Print info message
 */
export function printInfo(message: string): void {
	console.log(chalk.blue(`ℹ ${message}`));
}

/**
 * Print summary of deployment results
 */
export function printSummary(stats: {
	autoPushed: number;
	prompted: number;
	skipped: number;
	failed: number;
}): void {
	console.log("");
	console.log(chalk.bold.green("✅ Setup Complete!"));
	console.log(chalk.gray("─".repeat(60)));
	console.log("");
	console.log(chalk.dim("Summary:"));
	console.log(`  Auto-pushed: ${chalk.bold(stats.autoPushed)}`);
	console.log(`  Prompted: ${chalk.bold(stats.prompted)}`);
	console.log(`  Skipped: ${chalk.bold(stats.skipped)}`);

	if (stats.failed > 0) {
		console.log(`  ${chalk.red(`Failed: ${stats.failed}`)}`);
	}

	console.log("");
}

/**
 * Print help message
 */
export function printHelp(scriptName: string): void {
	console.log("");
	console.log(chalk.bold("Usage:"));
	console.log(`  bun run scripts/${scriptName} [OPTIONS]`);
	console.log("");
	console.log(chalk.bold("Options:"));
	console.log(
		`  ${chalk.cyan("--auto-all")}     Skip prompts, auto-generate environment-specific secrets`,
	);
	console.log(
		`  ${chalk.cyan("--dry-run")}      Preview changes without pushing to platforms`,
	);
	console.log(`  ${chalk.cyan("--vercel")}       Configure Vercel only`);
	console.log(
		`  ${chalk.cyan("--github")}       Configure GitHub Actions only`,
	);
	console.log(`  ${chalk.cyan("--both")}         Configure both platforms`);
	console.log(`  ${chalk.cyan("-h, --help")}     Show this help message`);
	console.log("");
	console.log(chalk.bold("Examples:"));
	console.log(
		`  ${chalk.dim(`bun run scripts/${scriptName}`)}                    ${chalk.gray("# Interactive mode")}`,
	);
	console.log(
		`  ${chalk.dim(`bun run scripts/${scriptName} --dry-run`)}          ${chalk.gray("# Preview only")}`,
	);
	console.log(
		`  ${chalk.dim(`bun run scripts/${scriptName} --auto-all`)}         ${chalk.gray("# Skip all prompts")}`,
	);
	console.log(
		`  ${chalk.dim(`bun run scripts/${scriptName} --auto-all --dry-run`)} ${chalk.gray("# Preview auto mode")}`,
	);
	console.log("");
}
