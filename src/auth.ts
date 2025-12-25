import { checkout, polar, portal } from "@polar-sh/better-auth";
import { Polar } from "@polar-sh/sdk";
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { nextCookies } from "better-auth/next-js";
import { db } from "@/db";
import { serverEnv } from "./env/server.ts";

// Build plugins array conditionally
const plugins = [nextCookies()];

// Only add Polar plugin if token is valid (skip in test environments with dummy tokens)
const isPolarEnabled =
	serverEnv.POLAR_ACCESS_TOKEN &&
	!serverEnv.POLAR_ACCESS_TOKEN.startsWith("dummy");

if (isPolarEnabled) {
	plugins.push(
		polar({
			client: new Polar({
				accessToken: serverEnv.POLAR_ACCESS_TOKEN,
				server: serverEnv.POLAR_MODE,
			}),
			createCustomerOnSignUp: true,
			use: [
				checkout({
					authenticatedUsersOnly: true,
					successUrl: "/confirmation",
				}),
				portal(),
			],
		}),
	);
}

export const auth = betterAuth({
	database: drizzleAdapter(db, {
		provider: "pg",
	}),
	plugins,
	socialProviders: {
		google: {
			clientId: serverEnv.GOOGLE_CLIENT_ID,
			clientSecret: serverEnv.GOOGLE_CLIENT_SECRET,
		},
	},
	user: {
		additionalFields: {},
	},
});
