import { createTestDb, truncateAllTables } from "./db.ts";

export default async function globalTeardown() {
	const connectionString = process.env["DATABASE_URL_TEST"];

	if (!connectionString) {
		// Skip cleanup if no connection string (tests didn't run)
		return;
	}

	console.log("🧹 Cleaning up E2E test database...");

	const db = createTestDb(connectionString);

	await truncateAllTables(db);

	console.log("✅ Database cleaned after E2E tests");
}
