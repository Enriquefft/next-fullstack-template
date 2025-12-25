#!/usr/bin/env node
/**
 * Test actual database connection
 * Goes beyond URL validation to check if we can connect
 */

import { neon } from "@neondatabase/serverless";

const url = process.env.DATABASE_URL_TEST;

console.log("🔌 Database Connection Test");
console.log("============================\n");

if (!url) {
	console.error("❌ DATABASE_URL_TEST not set");
	process.exit(1);
}

console.log("✅ Environment variable exists");
console.log(`   Length: ${url.length} characters\n`);

// Try to parse URL first
try {
	const parsed = new URL(url);
	console.log("✅ URL parses correctly");
	console.log(`   Host: ${parsed.hostname}`);
	console.log(`   Database: ${parsed.pathname.slice(1)}\n`);
} catch (err) {
	console.error(`❌ Invalid URL: ${err.message}`);
	process.exit(1);
}

// Now try to actually connect
console.log("🔄 Attempting database connection...\n");

try {
	const sql = neon(url);

	// Simple query to test connection
	const result = await sql`SELECT 1 as test`;

	console.log("✅ Connection successful!");
	console.log(`   Query result: ${JSON.stringify(result)}\n`);

	console.log("🎉 Database is accessible and working!");

} catch (err) {
	console.error("❌ Connection failed!");
	console.error(`   Error: ${err.message}\n`);

	if (err.message.includes("invalid authorization header")) {
		console.error("💡 Troubleshooting 'invalid authorization header':");
		console.error("   1. Check for trailing whitespace/newlines in secret");
		console.error("   2. Verify password doesn't have un-encoded special chars");
		console.error("   3. Try regenerating the Neon connection string");
		console.error("   4. Make sure you copied the URL, not a shell command\n");
	} else if (err.message.includes("timeout") || err.message.includes("ECONNREFUSED")) {
		console.error("💡 Connection timeout/refused:");
		console.error("   1. Database might be paused (Neon auto-pauses after 5min inactivity)");
		console.error("   2. Check if GitHub Actions IPs are allowed");
		console.error("   3. Verify the database branch exists in Neon Console\n");
	} else if (err.message.includes("authentication") || err.message.includes("password")) {
		console.error("💡 Authentication failed:");
		console.error("   1. Verify username and password are correct");
		console.error("   2. Regenerate password in Neon Console");
		console.error("   3. Get fresh connection string from Neon\n");
	}

	process.exit(1);
}
