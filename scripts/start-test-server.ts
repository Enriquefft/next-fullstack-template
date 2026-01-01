#!/usr/bin/env bun

/**
 * Start Next.js dev server for E2E tests with validated environment variables.
 * Bun automatically loads .env.test and .env.test.local files.
 */

import { existsSync } from "node:fs";

// Set test defaults
(process.env as { NODE_ENV: string })["NODE_ENV"] = "test";
process.env["PORT"] ||= "3000";

// On NixOS, add library paths for Next.js native modules
if (existsSync("/nix/store")) {
    const proc = Bun.spawn([
        "sh",
        "-c",
        'ls -d /nix/store/*-gcc-*-lib/lib 2>/dev/null | tr "\\n" ":" | sed "s/:$//"',
    ]);
    const libPaths = (await new Response(proc.stdout).text()).trim();
    await proc.exited; // Wait for process to complete

    if (libPaths) {
        process.env["LD_LIBRARY_PATH"] =
            `${libPaths}:${process.env["LD_LIBRARY_PATH"] || ""}`;
        console.log(
            `✓ Set LD_LIBRARY_PATH with ${libPaths.split(":").length} library paths`,
        );
    }
}

// Validate all env vars using existing validation (throws if invalid)
await import("../src/env/db.ts");
await import("../src/env/server.ts");
await import("../src/env/client.ts");

console.log("✓ Environment variables validated");
console.log(`Starting Next.js dev server on port ${process.env["PORT"]}...`);

// Start Next.js dev server
const server = Bun.spawn(["bunx", "--bun", "next", "dev", "--turbopack"], {
    env: process.env,
    stderr: "inherit",
    stdin: "inherit",
    stdout: "inherit",
});

process.exit(await server.exited);
