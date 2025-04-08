"server-only";
import { Polar } from "@polar-sh/sdk";
import { env } from "@/env";

console.log("Access token", env.POLAR_ACCESS_TOKEN);
export const polarApi = new Polar({
	accessToken: env.POLAR_ACCESS_TOKEN,
	server: env.POLAR_MODE,
});

export const getAllProducts = async () =>
	polarApi.products.list({
		isArchived: false,
	});
