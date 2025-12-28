import chalk from "chalk";
import prompts from "prompts";

/**
 * Prompt for a secret value with existence check and confirmation
 */
export async function promptForSecret(options: {
	name: string;
	description: string;
	exists: boolean;
	defaultValue?: string;
}): Promise<string | null> {
	console.log("");
	console.log(chalk.gray("─".repeat(60)));
	console.log(chalk.bold(`Variable: ${options.name}`));
	console.log(chalk.dim(options.description));

	if (options.exists) {
		console.log(chalk.yellow("Status: Already exists (will be updated)"));
	} else {
		console.log(chalk.red("Status: Does not exist (will be created)"));
	}

	const response = await prompts(
		{
			message: options.defaultValue
				? "Paste value (or Enter for default):"
				: "Paste value (or Enter to skip):",
			name: "value",
			type: "password",
		},
		{
			onCancel: () => {
				throw new Error("Cancelled by user");
			},
		},
	);

	// Handle empty input
	if (!response.value || response.value.trim() === "") {
		if (options.defaultValue) {
			console.log(chalk.green(`Using default: ${options.defaultValue}`));
			return options.defaultValue;
		}

		if (options.exists) {
			console.log(chalk.yellow("Skipping - keeping existing"));
			return null;
		}

		// Confirm skip for non-existing variables
		const confirm = await prompts(
			{
				initial: false,
				message: "Variable does not exist. Skip anyway?",
				name: "skip",
				type: "confirm",
			},
			{
				onCancel: () => {
					throw new Error("Cancelled by user");
				},
			},
		);

		return confirm.skip ? null : await promptForSecret(options);
	}

	return response.value.trim();
}

/**
 * Prompt for platform selection (Vercel, GitHub, or both)
 */
export async function promptPlatform(): Promise<"vercel" | "github" | "both"> {
	const response = await prompts(
		{
			choices: [
				{
					title: "Both (recommended - values entered once, reused)",
					value: "both",
				},
				{ title: "Vercel only", value: "vercel" },
				{ title: "GitHub Actions only", value: "github" },
			],
			initial: 0,
			message: "Which platform(s) would you like to configure?",
			name: "platform",
			type: "select",
		},
		{
			onCancel: () => {
				throw new Error("Cancelled by user");
			},
		},
	);

	return response.platform;
}
