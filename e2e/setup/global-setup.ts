import { execSync } from "node:child_process";
import { createTestDb, seedTestData, truncateAllTables } from "./db.ts";

export default async function globalSetup() {
	const connectionString = process.env["DATABASE_URL_TEST"];

	if (!connectionString) {
		throw new Error(
			"DATABASE_URL_TEST is not set. Please add it to your .env.local file.",
		);
	}

	console.log("🔧 Setting up E2E test database...");

	// Push latest schema to test database
	console.log("📦 Pushing database schema...");
	try {
		execSync("bun run db:push", {
			env: {
				...process.env,
				NODE_ENV: "test",
				DATABASE_URL_TEST: connectionString,
				NEXT_PUBLIC_PROJECT_NAME:
					process.env["NEXT_PUBLIC_PROJECT_NAME"] || "next-fullstack-template",
			},
			stdio: "pipe",
		});
		console.log("✅ Schema pushed successfully");
	} catch (error) {
		console.error("❌ Failed to push schema:", error);
		throw error;
	}

	const db = createTestDb(connectionString);

	console.log("🗑️  Truncating all tables...");
	await truncateAllTables(db);

	console.log("🌱 Seeding baseline test data...");
	await seedTestData(db);

	console.log("✅ Database prepared for E2E tests");
}
