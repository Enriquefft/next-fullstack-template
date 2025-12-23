import { PostHog } from "posthog-node";
import { clientEnv } from "@/env/client.ts";

export default function PostHogClient() {
	const posthogClient = new PostHog(clientEnv.NEXT_PUBLIC_POSTHOG_KEY, {
		flushAt: 1,
		flushInterval: 0,
		host: "https://us.i.posthog.com",
	});
	return posthogClient;
}
