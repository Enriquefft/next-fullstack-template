import type { KnipConfig } from "knip";

const config: KnipConfig = {
	compilers: {
		css: (text: string) => [...text.matchAll(/(?<=@)import[^;]+/g)].join("\n"),
	},
	entry: [
		"{tests,scripts}/**/*.{js,cjs,mjs,jsx,ts,cts,mts,tsx}",
		"src/metadata.ts",
	],
	// Files to exclude from Knip analysis
	ignore: ["unlighthouse.config.ts", "src/components/ui/**/*"],
	// Binaries to ignore during analysis
	ignoreBinaries: [],
	// Dependencies to ignore during analysis
	ignoreDependencies: [],
	paths: {
		"@/*": ["./src/*"],
	},
};

export default config;
