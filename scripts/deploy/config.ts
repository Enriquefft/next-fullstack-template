import { basename } from "node:path";
import type { Category, DeploymentMetadata, EnvVarConfig } from "./types.ts";

/**
 * Auto-detect project name from package.json
 */
const getProjectName = (): string => {
	try {
		const pkg = require("../../package.json");
		return pkg.name || basename(process.cwd());
	} catch {
		return basename(process.cwd());
	}
};

/**
 * Category definitions for grouping environment variables
 */
export const CATEGORIES: Category[] = [
	{ emoji: "📦", id: "database", title: "DATABASE CONFIGURATION" },
	{ emoji: "🔐", id: "auth", title: "AUTHENTICATION" },
	{ emoji: "🔌", id: "services", title: "THIRD-PARTY SERVICES" },
	{ emoji: "⚙️", id: "project", title: "PROJECT CONFIGURATION" },
];

/**
 * Deployment metadata mapping
 *
 * This is the ONLY place where deployment configuration is defined.
 * Variable names are automatically validated against src/env/*.ts at runtime.
 *
 * Each key is an environment variable name from src/env/*.ts
 * Each value is deployment metadata (or array of metadata for multi-scope vars)
 */
const DEPLOYMENT_METADATA: Record<
	string,
	DeploymentMetadata | DeploymentMetadata[]
> = {
	// ============================================================================
	// AUTHENTICATION (from src/env/server.ts)
	// ============================================================================

	BETTER_AUTH_SECRET: [
		{
			category: "auth",
			description:
				"Better Auth Secret for PRODUCTION [Auto-generated in --auto-all mode]",
			required: true,
			strategy: "prompt",
			vercelName: "BETTER_AUTH_SECRET",
			vercelScope: "production",
		},
		{
			category: "auth",
			description:
				"Better Auth Secret for PREVIEW [Auto-generated in --auto-all mode]",
			required: true,
			strategy: "prompt",
			vercelName: "BETTER_AUTH_SECRET",
			vercelScope: "preview",
		},
		{
			category: "auth",
			description:
				"Better Auth Secret for TEST [Auto-generated in --auto-all mode]",
			githubName: "BETTER_AUTH_SECRET_TEST",
			required: true,
			strategy: "prompt",
			vercelScope: "none",
		},
	],
	// ============================================================================
	// DATABASE (from src/env/db.ts)
	// ============================================================================

	DATABASE_URL: [
		{
			category: "database",
			description:
				"Production Database URL (Neon main branch) [Get free DB: https://neon.tech]",
			required: false,
			strategy: "prompt",
			vercelName: "DATABASE_URL",
			vercelScope: "production",
		},
		{
			category: "database",
			description:
				"Preview Database URL (Neon preview branch) [Get free DB: https://neon.tech]",
			required: false,
			strategy: "prompt",
			vercelName: "DATABASE_URL",
			vercelScope: "preview",
		},
	],

	DATABASE_URL_TEST: {
		category: "database",
		description:
			"Test Database URL (for E2E tests) [Get free DB: https://neon.tech]",
		githubName: "DATABASE_URL_TEST",
		required: false,
		strategy: "prompt",
		vercelScope: "none",
	},

	GOOGLE_CLIENT_ID: {
		category: "auth",
		description:
			"Google OAuth Client ID [Setup at: https://console.cloud.google.com]",
		githubName: "GOOGLE_CLIENT_ID",
		required: true,
		strategy: "auto-push",
		vercelName: "GOOGLE_CLIENT_ID",
		vercelScope: "all",
	},

	GOOGLE_CLIENT_SECRET: {
		category: "auth",
		description:
			"Google OAuth Client Secret [Setup at: https://console.cloud.google.com]",
		githubName: "GOOGLE_CLIENT_SECRET",
		required: true,
		strategy: "auto-push",
		vercelName: "GOOGLE_CLIENT_SECRET",
		vercelScope: "all",
	},

	KAPSO_API_KEY: {
		category: "services",
		description: "Kapso WhatsApp API Key (optional) [Get at: https://kapso.ai]",
		githubName: "KAPSO_API_KEY",
		required: false,
		strategy: "optional",
		vercelName: "KAPSO_API_KEY",
		vercelScope: "all",
	},

	KAPSO_PHONE_NUMBER_ID: {
		category: "services",
		description:
			"Kapso WhatsApp Phone Number ID (optional) [Get at: https://kapso.ai]",
		githubName: "KAPSO_PHONE_NUMBER_ID",
		required: false,
		strategy: "optional",
		vercelName: "KAPSO_PHONE_NUMBER_ID",
		vercelScope: "all",
	},

	META_APP_SECRET: {
		category: "services",
		description:
			"Meta App Secret for webhook verification (optional) [Get at: https://developers.facebook.com]",
		githubName: "META_APP_SECRET",
		required: false,
		strategy: "optional",
		vercelName: "META_APP_SECRET",
		vercelScope: "all",
	},

	// ============================================================================
	// SERVICES (from src/env/server.ts and client.ts)
	// ============================================================================

	NEXT_PUBLIC_POSTHOG_KEY: {
		category: "services",
		description: "PostHog API Key (public) [Get at: https://posthog.com]",
		githubName: "NEXT_PUBLIC_POSTHOG_KEY",
		required: true,
		strategy: "auto-push",
		vercelName: "NEXT_PUBLIC_POSTHOG_KEY",
		vercelScope: "all",
	},

	// ============================================================================
	// PROJECT (from src/env/client.ts)
	// ============================================================================

	NEXT_PUBLIC_PROJECT_NAME: {
		category: "project",
		defaultValue: getProjectName,
		description:
			"Project Name (used for DB schema) [Default: auto-detected from package.json]",
		githubName: "NEXT_PUBLIC_PROJECT_NAME",
		required: true,
		strategy: "auto-generate",
		vercelName: "NEXT_PUBLIC_PROJECT_NAME",
		vercelScope: "all",
	},

	POLAR_ACCESS_TOKEN: {
		category: "services",
		description: "Polar Access Token [Get at: https://polar.sh/settings]",
		githubName: "POLAR_ACCESS_TOKEN",
		required: true,
		strategy: "auto-push",
		vercelName: "POLAR_ACCESS_TOKEN",
		vercelScope: "all",
	},

	POLAR_MODE: {
		category: "services",
		defaultValue: "sandbox",
		description: "Polar Mode (production or sandbox)",
		required: false,
		strategy: "auto-push",
		vercelName: "POLAR_MODE",
		vercelScope: "all",
	},

	POSTHOG_PROJECT_ID: {
		category: "services",
		description: "PostHog Project ID [Get at: https://posthog.com]",
		githubName: "POSTHOG_PROJECT_ID",
		required: true,
		strategy: "auto-push",
		vercelName: "POSTHOG_PROJECT_ID",
		vercelScope: "all",
	},

	UPLOADTHING_TOKEN: {
		category: "services",
		description:
			"UploadThing Token [Get at: https://uploadthing.com/dashboard]",
		githubName: "UPLOADTHING_TOKEN",
		required: true,
		strategy: "auto-push",
		vercelName: "UPLOADTHING_TOKEN",
		vercelScope: "all",
	},
};

/**
 * Generate EnvVarConfig array from deployment metadata
 * This flattens the metadata map into the format expected by deployment scripts
 */
function generateEnvVars(): EnvVarConfig[] {
	const envVars: EnvVarConfig[] = [];

	for (const [key, metadata] of Object.entries(DEPLOYMENT_METADATA)) {
		if (Array.isArray(metadata)) {
			// Multiple entries for same variable (different scopes)
			for (const meta of metadata) {
				envVars.push({ deployment: meta, key });
			}
		} else {
			// Single entry
			envVars.push({ deployment: metadata, key });
		}
	}

	return envVars;
}

/**
 * Complete environment variable configuration for deployment
 * Variable names come from src/env/*.ts (single source of truth)
 * Deployment metadata is defined in DEPLOYMENT_METADATA above
 */
export const ENV_VARS: EnvVarConfig[] = generateEnvVars();

/**
 * Get variables by category
 */
export function getVariablesByCategory(categoryId: string): EnvVarConfig[] {
	return ENV_VARS.filter((v) => v.deployment.category === categoryId);
}

/**
 * Get variables by strategy
 */
export function getVariablesByStrategy(strategy: string): EnvVarConfig[] {
	return ENV_VARS.filter((v) => v.deployment.strategy === strategy);
}

/**
 * Validate deployment config against actual env files
 * This ensures we haven't forgotten any variables
 */
export function validateDeploymentConfig(): {
	valid: boolean;
	missing: string[];
	extra: string[];
} {
	// Get all keys from deployment metadata
	const deploymentKeys = new Set(Object.keys(DEPLOYMENT_METADATA));

	// Define expected variables from env files
	// (manually maintained but only for validation)
	const expectedVars = new Set([
		// From src/env/db.ts
		"DATABASE_URL",
		"DATABASE_URL_DEV",
		"DATABASE_URL_TEST",
		"NODE_ENV",

		// From src/env/server.ts
		"BETTER_AUTH_SECRET",
		"BETTER_AUTH_URL",
		"GOOGLE_CLIENT_ID",
		"GOOGLE_CLIENT_SECRET",
		"KAPSO_API_KEY",
		"KAPSO_PHONE_NUMBER_ID",
		"META_APP_SECRET",
		"POLAR_ACCESS_TOKEN",
		"POLAR_MODE",
		"POSTHOG_PROJECT_ID",
		"UPLOADTHING_TOKEN",

		// From src/env/client.ts
		"NEXT_PUBLIC_APP_URL",
		"NEXT_PUBLIC_POSTHOG_KEY",
		"NEXT_PUBLIC_PROJECT_NAME",
	]);

	// Find deployment-only variables (not auto-deployed)
	const skipDeployment = new Set([
		"DATABASE_URL_DEV", // Local only
		"NODE_ENV", // Runtime only
		"BETTER_AUTH_URL", // Has default, not deployed
		"NEXT_PUBLIC_APP_URL", // Optional override
	]);

	// Check for missing variables (in env files but not in deployment)
	const missing: string[] = [];
	for (const varName of expectedVars) {
		if (!deploymentKeys.has(varName) && !skipDeployment.has(varName)) {
			missing.push(varName);
		}
	}

	// Check for extra variables (in deployment but not in env files)
	const extra: string[] = [];
	for (const varName of deploymentKeys) {
		if (!expectedVars.has(varName)) {
			extra.push(varName);
		}
	}

	return {
		extra,
		missing,
		valid: missing.length === 0 && extra.length === 0,
	};
}
