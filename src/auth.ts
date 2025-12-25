import { checkout, polar, portal } from "@polar-sh/better-auth";
import { Polar } from "@polar-sh/sdk";
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { nextCookies } from "better-auth/next-js";
import { db } from "@/db";
import { serverEnv } from "./env/server.ts";

export const auth = betterAuth({
	baseURL: serverEnv.BETTER_AUTH_URL,
	database: drizzleAdapter(db, {
		provider: "pg",
	}),
	plugins: [
		nextCookies(),
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
	],
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
