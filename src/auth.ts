import { checkout, polar, portal } from "@polar-sh/better-auth";
import { Polar } from "@polar-sh/sdk";
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { nextCookies } from "better-auth/next-js";
import { db } from "@/db";
import { env } from "./env.ts";

export const auth = betterAuth({
	database: drizzleAdapter(db, {
		provider: "pg",
	}),
	plugins: [
		nextCookies(),
		polar({
			client: new Polar({
				accessToken: env.POLAR_ACCESS_TOKEN,
				server: env.POLAR_MODE,
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
			clientId: env.GOOGLE_CLIENT_ID,
			clientSecret: env.GOOGLE_CLIENT_SECRET,
		},
	},
	user: {
		additionalFields: {},
	},
});
