export type VercelScope =
	| "production"
	| "preview"
	| "development"
	| "all"
	| "none";

export type DeploymentStrategy =
	| "auto-push" // Auto-push from .env.local
	| "prompt" // Always prompt
	| "auto-generate" // Compute/detect
	| "optional"; // Skip if not in .env.local

export interface DeploymentMetadata {
	vercelName?: string;
	githubName?: string;
	vercelScope?: VercelScope;
	strategy: DeploymentStrategy;
	description: string;
	category: "database" | "auth" | "services" | "project";
	defaultValue?: string | (() => string);
	required?: boolean;
}

export interface EnvVarConfig {
	key: string; // From src/env/*.ts
	deployment: DeploymentMetadata;
}

export interface CLIFlags {
	autoAll: boolean;
	dryRun: boolean;
	platform?: "vercel" | "github" | "both";
	help: boolean;
}

export interface Category {
	id: string;
	title: string;
	emoji: string;
}

/**
 * Parse command-line arguments into CLIFlags
 */
export function parseArgs(args: string[]): CLIFlags {
	const flags: CLIFlags = {
		autoAll: false,
		dryRun: false,
		help: false,
		platform: undefined,
	};

	for (const arg of args) {
		switch (arg) {
			case "--auto-all":
				flags.autoAll = true;
				break;
			case "--dry-run":
				flags.dryRun = true;
				break;
			case "--vercel":
				flags.platform = "vercel";
				break;
			case "--github":
				flags.platform = "github";
				break;
			case "--both":
				flags.platform = "both";
				break;
			case "--help":
			case "-h":
				flags.help = true;
				break;
			default:
				if (arg.startsWith("-")) {
					throw new Error(`Unknown flag: ${arg}`);
				}
		}
	}

	return flags;
}
