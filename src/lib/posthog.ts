import { PostHog } from "posthog-node";
import { env } from "@/env";

export default function PostHogClient() {
	const posthogClient = new PostHog(env.NEXT_PUBLIC_POSTHOG_KEY, {
		flushAt: 1,
		flushInterval: 0,
		host: "https://us.i.posthog.com",
	});
	return posthogClient;
}
