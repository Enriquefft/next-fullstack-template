import { polarClient } from "@polar-sh/better-auth";
import { createAuthClient } from "better-auth/react";

export const { signIn, signUp, useSession, checkout, customer } =
	createAuthClient({
		plugins: [polarClient()],
	});
