import { Checkout } from "@polar-sh/nextjs";
import { env } from "@/env";

export const GET = Checkout({
	accessToken: env.POLAR_ACCESS_TOKEN,
	server: env.POLAR_MODE,
	successUrl: "/confirmation",
});
