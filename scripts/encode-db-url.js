#!/usr/bin/env node
/**
 * URL-encode a PostgreSQL connection string password
 * Fixes "invalid authorization header" errors caused by special characters
 */

const readline = require("node:readline");

const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout,
});

console.log("🔧 PostgreSQL URL Password Encoder");
console.log("===================================\n");
console.log("This tool will URL-encode your database password to fix connection issues.\n");

rl.question("Paste your full DATABASE_URL: ", (url) => {
	rl.close();

	if (!url || !url.trim()) {
		console.error("\n❌ No URL provided");
		process.exit(1);
	}

	let cleanedUrl = url.trim();

	// Remove shell escape characters (e.g., \@ → @, \# → #)
	const hasEscapes = cleanedUrl.includes("\\");
	if (hasEscapes) {
		console.log("\n⚠️  Detected shell escape characters (\\), removing them...");
		cleanedUrl = cleanedUrl.replace(/\\(.)/g, "$1");
	}

	try {
		const parsed = new URL(cleanedUrl);

		// Get the raw password (might already be partially encoded)
		const rawPassword = decodeURIComponent(parsed.password);

		// Check if password needs encoding
		const needsEncoding = /[@#:\/\?&=\s]/.test(rawPassword);

		if (!needsEncoding && !hasEscapes) {
			console.log("\n✅ URL is already properly formatted:");
			console.log(cleanedUrl);
			console.log("\n💡 No changes needed!");
			return;
		}

		// Re-encode it properly
		const encodedPassword = encodeURIComponent(rawPassword);

		// Rebuild the URL with encoded password
		parsed.password = encodedPassword;
		const fixedUrl = parsed.toString();

		console.log("\n✅ Fixed URL:");
		console.log(fixedUrl);
		console.log("\n📋 Copy this URL and update your GitHub secret:");
		console.log(`   gh secret set DATABASE_URL_TEST`);
		console.log("   (paste the fixed URL above when prompted)\n");
		console.log("💡 Or run: ./scripts/setup-env.sh\n");

	} catch (err) {
		console.error(`\n❌ Invalid URL format: ${err.message}`);
		console.error("\nExpected format:");
		console.error("postgresql://username:password@host:port/database?options");
		console.error("\nIf you copied from Neon, make sure to:");
		console.error("1. Select the 'Connection string' tab (not shell command)");
		console.error("2. Copy the raw URL without any shell wrappers");
		process.exit(1);
	}
});
