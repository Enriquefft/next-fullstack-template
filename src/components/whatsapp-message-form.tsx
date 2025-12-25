"use client";

import { useForm } from "@tanstack/react-form";
import { useState } from "react";
import { z } from "zod";

import { sendWhatsAppMessage } from "@/app/actions/whatsapp.ts";
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
	message: z.string().min(1, {
		message: "Message cannot be empty.",
	}),
	phoneNumberId: z.string().min(1, {
		message: "Phone number ID is required.",
	}),
	to: z.string().min(1, {
		message: "Recipient phone number is required.",
	}),
});

/**
 * WhatsApp Message Form
 *
 * Example component demonstrating how to send WhatsApp messages using Kapso.
 *
 * To use this component:
 * 1. Set KAPSO_API_KEY in your .env file
 * 2. Get your phone number ID from Kapso dashboard
 * 3. Use the recipient's phone number with country code (e.g., "1234567890")
 */
export function WhatsAppMessageForm() {
	const [status, setStatus] = useState<{
		type: "success" | "error" | null;
		message: string;
	}>({ message: "", type: null });

	const form = useForm({
		defaultValues: {
			message: "",
			phoneNumberId: "",
			to: "",
		},
		onSubmit: async ({ value }) => {
			setStatus({ message: "", type: null });

			try {
				const result = await sendWhatsAppMessage(
					value.phoneNumberId,
					value.to,
					value.message,
				);

				if (result.success) {
					setStatus({
						message: "Message sent successfully!",
						type: "success",
					});
					// Reset form
					form.reset();
				} else {
					setStatus({
						message: result.error || "Failed to send message",
						type: "error",
					});
				}
			} catch (error) {
				setStatus({
					message:
						error instanceof Error
							? error.message
							: "An unknown error occurred",
					type: "error",
				});
			}
		},
	});

	return (
		<div className="w-full max-w-md space-y-4">
			<div>
				<h2 className="text-2xl font-bold">Send WhatsApp Message</h2>
				<p className="text-sm text-muted-foreground">
					Send a message via Kapso WhatsApp integration
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
					name="phoneNumberId"
					validators={{
						onChange: formSchema.shape.phoneNumberId,
					}}
				>
					{(field) => (
						<Field data-invalid={field.state.meta.errors.length > 0}>
							<FieldLabel data-error={field.state.meta.errors.length > 0}>
								Phone Number ID
							</FieldLabel>
							<FieldControl>
								<Input
									placeholder="Your WhatsApp phone number ID"
									value={field.state.value}
									onBlur={field.handleBlur}
									onChange={(e) => field.handleChange(e.target.value)}
									aria-invalid={field.state.meta.errors.length > 0}
								/>
							</FieldControl>
							<FieldDescription>
								Get this from your Kapso dashboard
							</FieldDescription>
							{field.state.meta.errors.length > 0 ? (
								<FieldError>{field.state.meta.errors.join(", ")}</FieldError>
							) : null}
						</Field>
					)}
				</form.Field>

				<form.Field
					name="to"
					validators={{
						onChange: formSchema.shape.to,
					}}
				>
					{(field) => (
						<Field data-invalid={field.state.meta.errors.length > 0}>
							<FieldLabel data-error={field.state.meta.errors.length > 0}>
								Recipient Phone Number
							</FieldLabel>
							<FieldControl>
								<Input
									placeholder="1234567890 (with country code)"
									value={field.state.value}
									onBlur={field.handleBlur}
									onChange={(e) => field.handleChange(e.target.value)}
									aria-invalid={field.state.meta.errors.length > 0}
								/>
							</FieldControl>
							<FieldDescription>
								Include country code without + or spaces
							</FieldDescription>
							{field.state.meta.errors.length > 0 ? (
								<FieldError>{field.state.meta.errors.join(", ")}</FieldError>
							) : null}
						</Field>
					)}
				</form.Field>

				<form.Field
					name="message"
					validators={{
						onChange: formSchema.shape.message,
					}}
				>
					{(field) => (
						<Field data-invalid={field.state.meta.errors.length > 0}>
							<FieldLabel data-error={field.state.meta.errors.length > 0}>
								Message
							</FieldLabel>
							<FieldControl>
								<Input
									placeholder="Your message here..."
									value={field.state.value}
									onBlur={field.handleBlur}
									onChange={(e) => field.handleChange(e.target.value)}
									aria-invalid={field.state.meta.errors.length > 0}
								/>
							</FieldControl>
							<FieldDescription>The message to send</FieldDescription>
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
								: "bg-red-50 text-red-800 dark:bg-red-900/20 dark:text-red-200"
						}`}
					>
						{status.message}
					</div>
				)}

				<Button type="submit" className="w-full">
					Send Message
				</Button>
			</form>
		</div>
	);
}
