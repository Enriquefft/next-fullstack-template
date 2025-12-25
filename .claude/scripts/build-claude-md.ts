#!/usr/bin/env bun
/**
 * Dynamic CLAUDE.md Builder
 *
 * This script generates a customized CLAUDE.md file based on the features
 * actually present in the project. It:
 * 1. Detects which features are being used (via packages, files, env vars)
 * 2. Assembles the appropriate documentation sections
 * 3. Generates the final CLAUDE.md file
 *
 * Usage:
 *   bun .claude/scripts/build-claude-md.ts
 *   bun .claude/scripts/build-claude-md.ts --verbose
 */

import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

interface FeatureDetectors {
	packages?: string[];
	files?: string[];
	directories?: string[];
	envVars?: string[];
}

interface Feature {
	name: string;
	section: string;
	detectors: FeatureDetectors;
}

interface FeatureManifest {
	features: Record<string, Feature>;
	coreSections: string[];
}

const ROOT_DIR = join(import.meta.dir, "../..");
const DOCS_DIR = join(ROOT_DIR, ".claude/docs");
const SECTIONS_DIR = join(DOCS_DIR, "sections");
const MANIFEST_PATH = join(DOCS_DIR, "feature-manifest.json");
const OUTPUT_PATH = join(ROOT_DIR, "CLAUDE.md");

const verbose = process.argv.includes("--verbose");

function log(message: string) {
	if (verbose) {
		console.log(message);
	}
}

/**
 * Load package.json to check for installed packages
 */
function getInstalledPackages(): Set<string> {
	const packageJsonPath = join(ROOT_DIR, "package.json");
	if (!existsSync(packageJsonPath)) {
		return new Set();
	}

	const packageJson = JSON.parse(readFileSync(packageJsonPath, "utf-8"));
	const deps = {
		...packageJson.dependencies,
		...packageJson.devDependencies,
	};

	return new Set(Object.keys(deps));
}

/**
 * Load .env.example to check for environment variables
 */
function getConfiguredEnvVars(): Set<string> {
	const envExamplePath = join(ROOT_DIR, ".env.example");
	if (!existsSync(envExamplePath)) {
		return new Set();
	}

	const envContent = readFileSync(envExamplePath, "utf-8");
	const envVars = new Set<string>();

	for (const line of envContent.split("\n")) {
		const match = line.match(/^([A-Z_][A-Z0-9_]*)=/);
		if (match) {
			envVars.add(match[1]);
		}
	}

	return envVars;
}

/**
 * Check if a file exists relative to project root
 */
function fileExists(relativePath: string): boolean {
	return existsSync(join(ROOT_DIR, relativePath));
}

/**
 * Detect if a feature is present in the project
 */
function detectFeature(
	featureId: string,
	feature: Feature,
	installedPackages: Set<string>,
	envVars: Set<string>,
): boolean {
	const { detectors } = feature;
	let score = 0;
	let maxScore = 0;

	// Check packages
	if (detectors.packages && detectors.packages.length > 0) {
		maxScore++;
		const hasPackage = detectors.packages.some((pkg) =>
			installedPackages.has(pkg),
		);
		if (hasPackage) {
			score++;
			log(`  ✓ Package detected for ${featureId}`);
		}
	}

	// Check files
	if (detectors.files && detectors.files.length > 0) {
		maxScore++;
		const hasFile = detectors.files.some((file) => fileExists(file));
		if (hasFile) {
			score++;
			log(`  ✓ File detected for ${featureId}`);
		}
	}

	// Check directories
	if (detectors.directories && detectors.directories.length > 0) {
		maxScore++;
		const hasDir = detectors.directories.some((dir) => fileExists(dir));
		if (hasDir) {
			score++;
			log(`  ✓ Directory detected for ${featureId}`);
		}
	}

	// Check environment variables
	if (detectors.envVars && detectors.envVars.length > 0) {
		maxScore++;
		const hasEnv = detectors.envVars.some((envVar) => envVars.has(envVar));
		if (hasEnv) {
			score++;
			log(`  ✓ Env var detected for ${featureId}`);
		}
	}

	// Feature is detected if at least 50% of detectors match
	const threshold = Math.max(1, Math.ceil(maxScore * 0.5));
	return score >= threshold;
}

/**
 * Read a documentation section file
 */
function readSection(sectionPath: string): string {
	const fullPath = join(SECTIONS_DIR, sectionPath);
	if (!existsSync(fullPath)) {
		console.warn(`⚠️  Section not found: ${sectionPath}`);
		return "";
	}
	return readFileSync(fullPath, "utf-8");
}

/**
 * Main builder function
 */
function buildClaudeMd() {
	console.log("🔨 Building dynamic CLAUDE.md...\n");

	// Load manifest
	if (!existsSync(MANIFEST_PATH)) {
		console.error("❌ Feature manifest not found!");
		process.exit(1);
	}

	const manifest: FeatureManifest = JSON.parse(
		readFileSync(MANIFEST_PATH, "utf-8"),
	);

	// Gather project information
	log("Scanning project...");
	const installedPackages = getInstalledPackages();
	const envVars = getConfiguredEnvVars();

	log(`  Found ${installedPackages.size} packages`);
	log(`  Found ${envVars.size} environment variables\n`);

	// Detect features
	console.log("Detecting features:");
	const detectedFeatures: string[] = [];

	for (const [featureId, feature] of Object.entries(manifest.features)) {
		const isDetected = detectFeature(
			featureId,
			feature,
			installedPackages,
			envVars,
		);

		if (isDetected) {
			console.log(`  ✅ ${feature.name}`);
			detectedFeatures.push(featureId);
		} else {
			console.log(`  ⊘  ${feature.name} (not detected)`);
		}
	}

	console.log(
		`\nDetected ${detectedFeatures.length}/${Object.keys(manifest.features).length} features\n`,
	);

	// Assemble CLAUDE.md
	console.log("Assembling CLAUDE.md...");
	const sections: string[] = [];

	// Add core sections
	log("Adding core sections:");
	for (const coreSection of manifest.coreSections) {
		const content = readSection(coreSection);
		if (content) {
			sections.push(content);
			log(`  + ${coreSection}`);
		}
	}

	// Add feature sections
	if (detectedFeatures.length > 0) {
		log("\nAdding feature sections:");
		for (const featureId of detectedFeatures) {
			const feature = manifest.features[featureId];
			const content = readSection(feature.section);
			if (content) {
				sections.push(content);
				log(`  + ${feature.section}`);
			}
		}
	}

	// Generate final content
	const finalContent = sections.join("\n\n");

	// Write to CLAUDE.md
	writeFileSync(OUTPUT_PATH, finalContent, "utf-8");

	console.log(`\n✅ CLAUDE.md generated successfully!`);
	console.log(`   ${sections.length} sections included`);
	console.log(`   ${finalContent.split("\n").length} lines`);
	console.log(`   Output: ${OUTPUT_PATH}\n`);
}

// Run the builder
buildClaudeMd();
