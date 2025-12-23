"use client";

import type { ErrorInfo, ReactNode } from "react";
import { Component } from "react";
import { Button } from "@/components/ui/button";

interface ErrorBoundaryProps {
	children: ReactNode;
	fallback?: ReactNode;
}

interface ErrorBoundaryState {
	hasError: boolean;
	error: Error | null;
}

export class ErrorBoundary extends Component<
	ErrorBoundaryProps,
	ErrorBoundaryState
> {
	constructor(props: ErrorBoundaryProps) {
		super(props);
		this.state = { error: null, hasError: false };
	}

	static getDerivedStateFromError(error: Error): ErrorBoundaryState {
		return { error, hasError: true };
	}

	override componentDidCatch(error: Error, errorInfo: ErrorInfo): void {
		// TODO: Log to error reporting service (e.g., Sentry)
		if (process.env.NODE_ENV === "development") {
			console.error("ErrorBoundary caught an error:", error, errorInfo);
		}
	}

	handleReset = (): void => {
		this.setState({ error: null, hasError: false });
	};

	override render(): ReactNode {
		if (this.state.hasError) {
			if (this.props.fallback) {
				return this.props.fallback;
			}

			return (
				<div className="flex min-h-[400px] flex-col items-center justify-center gap-4 p-8">
					<div className="text-center">
						<h2 className="text-xl font-semibold text-destructive">
							Something went wrong
						</h2>
						<p className="mt-2 text-sm text-muted-foreground">
							An unexpected error occurred. Please try again.
						</p>
						{process.env.NODE_ENV === "development" && this.state.error && (
							<pre className="mt-4 max-w-lg overflow-auto rounded-md bg-muted p-4 text-left text-xs">
								{this.state.error.message}
							</pre>
						)}
					</div>
					<Button onClick={this.handleReset} variant="outline">
						Try again
					</Button>
				</div>
			);
		}

		return this.props.children;
	}
}
