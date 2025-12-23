"use client";

import { useEffect } from "react";

export default function GlobalError({
	error,
	reset,
}: {
	error: Error & { digest?: string };
	reset: () => void;
}) {
	useEffect(() => {
		// TODO: Log to error reporting service (e.g., Sentry)
		if (process.env.NODE_ENV === "development") {
			console.error("Global error:", error);
		}
	}, [error]);

	return (
		<html lang="en">
			<body>
				<div
					style={{
						alignItems: "center",
						display: "flex",
						flexDirection: "column",
						fontFamily: "system-ui, sans-serif",
						gap: "1rem",
						justifyContent: "center",
						minHeight: "100vh",
						padding: "2rem",
					}}
				>
					<div style={{ textAlign: "center" }}>
						<h2
							style={{
								color: "#dc2626",
								fontSize: "1.25rem",
								fontWeight: 600,
							}}
						>
							Something went wrong
						</h2>
						<p
							style={{
								color: "#6b7280",
								fontSize: "0.875rem",
								marginTop: "0.5rem",
							}}
						>
							A critical error occurred. Please try again.
						</p>
						{process.env.NODE_ENV === "development" && (
							<pre
								style={{
									backgroundColor: "#f3f4f6",
									borderRadius: "0.375rem",
									fontSize: "0.75rem",
									marginTop: "1rem",
									maxWidth: "32rem",
									overflow: "auto",
									padding: "1rem",
									textAlign: "left",
								}}
							>
								{error.message}
							</pre>
						)}
					</div>
					<button
						onClick={reset}
						type="button"
						style={{
							backgroundColor: "white",
							border: "1px solid #d1d5db",
							borderRadius: "0.375rem",
							cursor: "pointer",
							fontSize: "0.875rem",
							fontWeight: 500,
							padding: "0.5rem 1rem",
						}}
					>
						Try again
					</button>
				</div>
			</body>
		</html>
	);
}
