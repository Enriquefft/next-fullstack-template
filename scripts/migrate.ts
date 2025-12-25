#!/usr/bin/env bun

/**
 * Database Migration Runner
 *
 * This script applies pending migrations to the database.
 * Use this in production/staging deployment pipelines instead of `db:push`.
 *
 * Usage:
 *   bun run db:migrate
 *   NODE_ENV=production bun run db:migrate
 */

import { Pool } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-serverless";
import { migrate } from "drizzle-orm/neon-serverless/migrator";
import { databaseUrl } from "@/env/db";

async function runMigrations() {
	console.log("🔄 Starting database migrations...");
	console.log(`📍 Environment: ${process.env.NODE_ENV || "development"}`);
	console.log(`🔗 Database URL: ${databaseUrl.slice(0, 30)}...`);

	const pool = new Pool({ connectionString: databaseUrl });
	const db = drizzle(pool);

	try {
		await migrate(db, { migrationsFolder: "./drizzle" });
		console.log("✅ Migrations completed successfully");
	} catch (error) {
		console.error("❌ Migration failed:", error);
		process.exit(1);
	} finally {
		await pool.end();
	}
}

runMigrations();
