"use client";

import { useEffect } from "react";
import { Button } from "@/components/ui/button";

export default function Error({
	error,
	reset,
}: {
	error: Error & { digest?: string };
	reset: () => void;
}) {
	useEffect(() => {
		// TODO: Log to error reporting service (e.g., Sentry)
		if (process.env.NODE_ENV === "development") {
			console.error("Page error:", error);
		}
	}, [error]);

	return (
		<div className="flex min-h-[50vh] flex-col items-center justify-center gap-4 p-8">
			<div className="text-center">
				<h2 className="text-xl font-semibold text-destructive">
					Something went wrong
				</h2>
				<p className="mt-2 text-sm text-muted-foreground">
					An unexpected error occurred. Please try again.
				</p>
				{process.env.NODE_ENV === "development" && (
					<pre className="mt-4 max-w-lg overflow-auto rounded-md bg-muted p-4 text-left text-xs">
						{error.message}
					</pre>
				)}
			</div>
			<Button onClick={reset} variant="outline">
				Try again
			</Button>
		</div>
	);
}
