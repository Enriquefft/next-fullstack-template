import { neonConfig } from "@neondatabase/serverless";
import { sql } from "drizzle-orm";
import { drizzle } from "drizzle-orm/neon-serverless";
import ws from "ws";
import * as schema from "@/db/schema/index.ts";

// Configure WebSocket for Node.js environments (required for CI)
neonConfig.webSocketConstructor = ws;

/**
 * E2E-specific database instance
 * Uses neon-serverless driver for full transaction support
 */
export function createTestDb(connectionString: string) {
	return drizzle(connectionString, { schema });
}

/**
 * Dynamically discovers all tables in the current schema
 * and truncates them in reverse dependency order
 */
export async function truncateAllTables(db: ReturnType<typeof createTestDb>) {
	// Get the schema name from environment
	const schemaName = process.env["NEXT_PUBLIC_PROJECT_NAME"];

	if (!schemaName) {
		throw new Error("NEXT_PUBLIC_PROJECT_NAME is not set");
	}

	// Query to get all tables in the schema, ordered by dependencies (reverse)
	const tablesQuery = sql`
		WITH RECURSIVE table_deps AS (
			-- Get all tables in our schema
			SELECT
				t.table_name,
				0 as depth
			FROM information_schema.tables t
			WHERE t.table_schema = ${schemaName}
			AND t.table_type = 'BASE TABLE'

			UNION ALL

			-- Get tables that depend on other tables via foreign keys
			SELECT
				tc.table_name,
				td.depth + 1
			FROM information_schema.table_constraints tc
			JOIN information_schema.key_column_usage kcu
				ON tc.constraint_name = kcu.constraint_name
			JOIN information_schema.constraint_column_usage ccu
				ON ccu.constraint_name = tc.constraint_name
			JOIN table_deps td
				ON td.table_name = ccu.table_name
			WHERE tc.constraint_type = 'FOREIGN KEY'
			AND tc.table_schema = ${schemaName}
		)
		SELECT DISTINCT table_name, MAX(depth) as max_depth
		FROM table_deps
		GROUP BY table_name
		ORDER BY max_depth DESC;
	`;

	const result = await db.execute(tablesQuery);

	// Truncate tables in dependency order (deepest dependencies first)
	for (const row of result.rows) {
		const tableName = row["table_name"] as string;
		await db.execute(
			sql`TRUNCATE TABLE ${sql.identifier(schemaName)}.${sql.identifier(tableName)} CASCADE`,
		);
	}
}

/**
 * Seeds the database with baseline test data
 */
export async function seedTestData(db: ReturnType<typeof createTestDb>) {
	// Import seed data functions
	const { seedUsers } = await import("../fixtures/test-data.ts");

	await seedUsers(db);
}
