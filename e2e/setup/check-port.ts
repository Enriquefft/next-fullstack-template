import { createServer } from "node:net";

/**
 * Check if a port is available
 * This script runs before Playwright to ensure the port is free
 * @throws Error if port is already in use
 */
async function checkPortAvailable(port: number): Promise<void> {
	return new Promise((resolve, reject) => {
		const server = createServer();

		server.once("error", (err: NodeJS.ErrnoException) => {
			if (err.code === "EADDRINUSE") {
				reject(
					new Error(
						`Port ${port} is already in use. Either:\n` +
							`  1. Stop the process using port ${port}\n` +
							`  2. Use a different port: PORT=3001 bun run test:e2e`,
					),
				);
			} else {
				reject(err);
			}
		});

		server.once("listening", () => {
			server.close(() => {
				// Add a small delay to ensure the OS fully releases the port
				// This prevents EADDRINUSE errors when Playwright starts the dev server
				setTimeout(() => {
					resolve();
				}, 150);
			});
		});

		server.listen(port);
	});
}

const port = Number.parseInt(process.env["PORT"] || "3000", 10);
console.log(`🔍 Checking if port ${port} is available...`);

checkPortAvailable(port)
	.then(() => {
		console.log(`✅ Port ${port} is available`);
		process.exit(0);
	})
	.catch((error) => {
		console.error(`❌ ${error.message}`);
		process.exit(1);
	});
