export { auth as middleware } from "@/auth";
import type { Route } from "next";

export const config = {
  // https://nextjs.org/docs/app/building-your-application/routing/middleware#matcher
  matcher: ["/"] satisfies Route[],
};
