"use client";

import { useForm } from "@tanstack/react-form";
import { useState } from "react";
import { z } from "zod";

import {
	createKapsoCustomer,
	createSetupLink,
} from "@/app/actions/kapso-platform.ts";
import { Button } from "@/components/ui/button";
import {
	Field,
	FieldControl,
	FieldDescription,
	FieldError,
	FieldLabel,
} from "@/components/ui/field";
import { Input } from "@/components/ui/input";

const formSchema = z.object({
	email: z.string().email({
		message: "Please enter a valid email address.",
	}),
	name: z.string().min(1, {
		message: "Customer name is required.",
	}),
});

/**
 * Kapso Platform Customer Onboarding
 *
 * This component demonstrates the Kapso Platform API workflow:
 * 1. Create a customer in your system
 * 2. Generate a setup link for them to connect their WhatsApp Business account
 * 3. Customer completes onboarding through the hosted page
 *
 * This is ideal for multi-tenant scenarios where each customer manages
 * their own WhatsApp account while you provide the automation.
 */
export function KapsoPlatformExample() {
	const [status, setStatus] = useState<{
		type: "success" | "error" | "loading" | null;
		message: string;
		setupLink?: string;
	}>({ message: "", type: null });

	const form = useForm({
		defaultValues: {
			email: "",
			name: "",
		},
		onSubmit: async ({ value }) => {
			setStatus({ message: "Creating customer...", type: "loading" });

			// Step 1: Create a customer
			const customerResult = await createKapsoCustomer({
				email: value.email,
				name: value.name,
			});

			if (!customerResult.success) {
				setStatus({
					message: customerResult.error || "Failed to create customer",
					type: "error",
				});
				return;
			}

			setStatus({
				message: "Generating setup link...",
				type: "loading",
			});

			// Step 2: Generate setup link
			const setupLinkResult = await createSetupLink(
				customerResult.data.customer_id,
			);

			if (!setupLinkResult.success) {
				setStatus({
					message: setupLinkResult.error || "Failed to generate setup link",
					type: "error",
				});
				return;
			}

			setStatus({
				message: "Setup link generated! Share this link with your customer.",
				setupLink: setupLinkResult.data.setup_link,
				type: "success",
			});

			// Reset form
			form.reset();
		},
	});

	return (
		<div className="w-full max-w-md space-y-4">
			<div>
				<h2 className="text-2xl font-bold">Kapso Platform Onboarding</h2>
				<p className="text-sm text-muted-foreground">
					Create a customer and generate their WhatsApp onboarding link
				</p>
			</div>

			<form
				onSubmit={(e) => {
					e.preventDefault();
					e.stopPropagation();
					form.handleSubmit();
				}}
				className="space-y-4"
			>
				<form.Field
					name="name"
					validators={{
						onChange: formSchema.shape.name,
					}}
				>
					{(field) => (
						<Field data-invalid={field.state.meta.errors.length > 0}>
							<FieldLabel data-error={field.state.meta.errors.length > 0}>
								Customer Name
							</FieldLabel>
							<FieldControl>
								<Input
									placeholder="John Doe"
									value={field.state.value}
									onBlur={field.handleBlur}
									onChange={(e) => field.handleChange(e.target.value)}
									aria-invalid={field.state.meta.errors.length > 0}
								/>
							</FieldControl>
							<FieldDescription>Your customer's full name</FieldDescription>
							{field.state.meta.errors.length > 0 ? (
								<FieldError>{field.state.meta.errors.join(", ")}</FieldError>
							) : null}
						</Field>
					)}
				</form.Field>

				<form.Field
					name="email"
					validators={{
						onChange: formSchema.shape.email,
					}}
				>
					{(field) => (
						<Field data-invalid={field.state.meta.errors.length > 0}>
							<FieldLabel data-error={field.state.meta.errors.length > 0}>
								Customer Email
							</FieldLabel>
							<FieldControl>
								<Input
									type="email"
									placeholder="[email protected]"
									value={field.state.value}
									onBlur={field.handleBlur}
									onChange={(e) => field.handleChange(e.target.value)}
									aria-invalid={field.state.meta.errors.length > 0}
								/>
							</FieldControl>
							<FieldDescription>
								Email for customer identification
							</FieldDescription>
							{field.state.meta.errors.length > 0 ? (
								<FieldError>{field.state.meta.errors.join(", ")}</FieldError>
							) : null}
						</Field>
					)}
				</form.Field>

				{status.type && (
					<div
						className={`rounded-md p-4 ${
							status.type === "success"
								? "bg-green-50 text-green-800 dark:bg-green-900/20 dark:text-green-200"
								: status.type === "error"
									? "bg-red-50 text-red-800 dark:bg-red-900/20 dark:text-red-200"
									: "bg-blue-50 text-blue-800 dark:bg-blue-900/20 dark:text-blue-200"
						}`}
					>
						<p className="font-medium">{status.message}</p>
						{status.setupLink && (
							<div className="mt-2">
								<a
									href={status.setupLink}
									target="_blank"
									rel="noopener noreferrer"
									className="break-all text-sm underline"
								>
									{status.setupLink}
								</a>
								<Button
									type="button"
									variant="outline"
									size="sm"
									className="mt-2"
									onClick={() => {
										navigator.clipboard.writeText(status.setupLink || "");
									}}
								>
									Copy Link
								</Button>
							</div>
						)}
					</div>
				)}

				<Button
					type="submit"
					className="w-full"
					disabled={status.type === "loading"}
				>
					{status.type === "loading" ? "Processing..." : "Create Customer"}
				</Button>
			</form>
		</div>
	);
}
