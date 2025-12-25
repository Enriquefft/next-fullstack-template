import "server-only";
import { Polar } from "@polar-sh/sdk";
import { serverEnv } from "@/env/server.ts";

export const polarApi = new Polar({
	accessToken: serverEnv.POLAR_ACCESS_TOKEN,
	server: serverEnv.POLAR_MODE,
});

export const getAllProducts = async () =>
	polarApi.products.list({
		isArchived: false,
	});
