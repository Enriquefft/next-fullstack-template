"use client";

import { useForm } from "@tanstack/react-form";
import { z } from "zod";

import { Button } from "@/components/ui/button";
import {
	Field,
	FieldControl,
	FieldDescription,
	FieldError,
	FieldLabel,
} from "@/components/ui/field";
import { Input } from "@/components/ui/input";

// This must, usually, be obtained from the db with drizzle-zod
const formSchema = z.object({
	username: z.string().min(2, {
		message: "Username must be at least 2 characters.",
	}),
});

export function ProfileForm() {
	const form = useForm({
		defaultValues: {
			username: "",
		},
		onSubmit: async ({ value }) => {
			// Do something with the form values.
			// ✅ This will be type-safe and validated.
			// This should, generally, be a call to a server action
			console.log(value);
		},
	});

	return (
		<form
			onSubmit={(e) => {
				e.preventDefault();
				e.stopPropagation();
				form.handleSubmit();
			}}
			className="space-y-8"
		>
			<form.Field
				name="username"
				validators={{
					onChange: formSchema.shape.username,
				}}
			>
				{(field) => (
					<Field data-invalid={field.state.meta.errors.length > 0}>
						<FieldLabel data-error={field.state.meta.errors.length > 0}>
							Username
						</FieldLabel>
						<FieldControl>
							<Input
								placeholder="shadcn"
								value={field.state.value}
								onBlur={field.handleBlur}
								onChange={(e) => field.handleChange(e.target.value)}
								aria-invalid={field.state.meta.errors.length > 0}
							/>
						</FieldControl>
						<FieldDescription>
							This is your public display name.
						</FieldDescription>
						{field.state.meta.errors.length > 0 ? (
							<FieldError>{field.state.meta.errors.join(", ")}</FieldError>
						) : null}
					</Field>
				)}
			</form.Field>
			<Button type="submit">Submit</Button>
		</form>
	);
}
