import { createTestDb, seedTestData, truncateAllTables } from "./db.ts";

export default async function globalSetup() {
	const connectionString = process.env["DATABASE_URL_TEST"];

	if (!connectionString) {
		throw new Error(
			"DATABASE_URL_TEST is not set. Please add it to your .env.local file.",
		);
	}

	console.log("🔧 Setting up E2E test database...");

	const db = createTestDb(connectionString);

	console.log("🗑️  Truncating all tables...");
	await truncateAllTables(db);

	console.log("🌱 Seeding baseline test data...");
	await seedTestData(db);

	console.log("✅ Database prepared for E2E tests");
}
