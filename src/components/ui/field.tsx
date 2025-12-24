"use client";

import * as LabelPrimitive from "@radix-ui/react-label";
import { Slot } from "@radix-ui/react-slot";
import * as React from "react";
import { Label } from "@/components/ui/label";
import { cn } from "@/lib/utils";

function Field({
	className,
	...props
}: React.ComponentProps<"div"> & { "data-invalid"?: boolean }) {
	return (
		<div data-slot="field" className={cn("grid gap-2", className)} {...props} />
	);
}

function FieldLabel({
	className,
	...props
}: React.ComponentProps<typeof LabelPrimitive.Root> & {
	"data-error"?: boolean;
}) {
	return (
		<Label
			data-slot="field-label"
			className={cn("data-[error=true]:text-destructive", className)}
			{...props}
		/>
	);
}

function FieldControl({ ...props }: React.ComponentProps<typeof Slot>) {
	return <Slot data-slot="field-control" {...props} />;
}

function FieldDescription({ className, ...props }: React.ComponentProps<"p">) {
	return (
		<p
			data-slot="field-description"
			className={cn("text-muted-foreground text-sm", className)}
			{...props}
		/>
	);
}

function FieldError({ className, ...props }: React.ComponentProps<"p">) {
	const body = props.children;

	if (!body) {
		return null;
	}

	return (
		<p
			data-slot="field-error"
			className={cn("text-destructive text-sm", className)}
			{...props}
		>
			{body}
		</p>
	);
}

export { Field, FieldLabel, FieldControl, FieldDescription, FieldError };
