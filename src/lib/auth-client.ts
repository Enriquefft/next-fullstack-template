import { createAuthClient } from "better-auth/react";
import { polarClient } from "@polar-sh/better-auth";

export const { signIn, signUp, useSession, checkout, customer } =
	createAuthClient({
		plugins: [polarClient()],
	});
