import NextAuth, { type NextAuthConfig } from "next-auth";
import Google from "next-auth/providers/google";

import { env } from "@/env.mjs";

export const authConfig = {
  pages: {
    signIn: "/auth/login",
  },
  callbacks: {
    authorized({ auth }) {
      return auth?.user !== undefined;
    },
  },
  providers: [
    Google({
      clientId: env.AUTH_GOOGLE_ID,
      clientSecret: env.AUTH_GOOGLE_SECRET,
    }),
  ],
} as const satisfies NextAuthConfig;

export const {
  auth,
  signIn,
  signOut,
  handlers: { GET, POST },
} = NextAuth(authConfig);
