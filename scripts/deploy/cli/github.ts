import { execa } from "execa";

/**
 * Check if GitHub CLI is installed and user is authenticated
 */
export async function checkGithubCli(): Promise<boolean> {
	try {
		await execa("gh", ["auth", "status"]);
		return true;
	} catch {
		return false;
	}
}

/**
 * Check if a GitHub secret exists
 */
export async function checkGithubSecretExists(name: string): Promise<boolean> {
	try {
		const result = await execa("gh", ["secret", "list"]);
		// Check if secret name appears in output (exact match at start of line)
		const regex = new RegExp(`^${name}\\s`, "m");
		return regex.test(result.stdout);
	} catch {
		return false;
	}
}

/**
 * Set GitHub Actions secret
 */
export async function setGithubSecret(
	name: string,
	value: string,
): Promise<void> {
	await execa("gh", ["secret", "set", name], {
		input: value,
	});
}
