#!/usr/bin/env node
/**
 * Debug script to validate DATABASE_URL_TEST format
 * Run in CI to diagnose connection string issues
 */

const urlToTest = process.env.DATABASE_URL_TEST;

console.log("🔍 DATABASE_URL_TEST Diagnostic");
console.log("================================\n");

if (!urlToTest) {
	console.error("❌ DATABASE_URL_TEST is not set or is empty");
	console.error("   Make sure the GitHub secret is configured");
	process.exit(1);
}

console.log("✅ Variable exists");
console.log(`   Length: ${urlToTest.length} characters\n`);

// Try to parse as URL
try {
	const parsed = new URL(urlToTest);
	console.log("✅ URL is parseable");
	console.log(`   Protocol: ${parsed.protocol}`);
	console.log(`   Username: ${parsed.username || "(missing)"}`);
	console.log(
		`   Password: ${parsed.password ? `${parsed.password.length} chars (ends with: ***${parsed.password.slice(-4)})` : "(missing)"}`,
	);
	console.log(`   Hostname: ${parsed.hostname || "(missing)"}`);
	console.log(`   Port: ${parsed.port || "(default)"}`);
	console.log(`   Database: ${parsed.pathname.slice(1) || "(missing)"}`);
	console.log(`   Query params: ${parsed.search || "(none)"}\n`);

	// Check for required parts
	const issues = [];

	if (!parsed.protocol.startsWith("postgres")) {
		issues.push("Protocol must be postgresql:// or postgres://");
	}

	if (!parsed.username) {
		issues.push("Missing username");
	}

	if (!parsed.password) {
		issues.push("Missing password");
	}

	if (!parsed.hostname) {
		issues.push("Missing hostname");
	}

	if (!parsed.pathname || parsed.pathname === "/") {
		issues.push("Missing database name");
	}

	// Check for potentially problematic characters in password
	if (parsed.password) {
		const problematicChars = /[@#:\/\?&=\s]/;
		if (problematicChars.test(parsed.password)) {
			console.log("⚠️  WARNING: Password contains special characters");
			console.log(
				"   These may need URL encoding: @ → %40, # → %23, etc.",
			);
			console.log(
				"   Consider regenerating password without special chars\n",
			);
		}
	}

	if (issues.length > 0) {
		console.error("❌ URL has issues:");
		for (const issue of issues) {
			console.error(`   - ${issue}`);
		}
		process.exit(1);
	}

	console.log("✅ All validation checks passed");
	console.log("\n💡 If you still get connection errors, the issue may be:");
	console.log("   1. Incorrect database credentials");
	console.log("   2. Database is not accessible from GitHub Actions IPs");
	console.log("   3. Neon project is paused or deleted");
} catch (err) {
	console.error("❌ Failed to parse URL:");
	console.error(`   ${err.message}\n`);
	console.error("   Expected format:");
	console.error(
		"   postgresql://username:password@host:port/database?options",
	);
	process.exit(1);
}
