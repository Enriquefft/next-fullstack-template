# TanStack Form Migration Guide

This project has been migrated from `react-hook-form` to **TanStack Form** following shadcn/ui's recommendation. This document explains the migration and how to use forms going forward.

## Why TanStack Form?

According to shadcn/ui:
> We are not actively developing the Form component anymore. The Form component is an abstraction over the react-hook-form library. Going forward, we recommend using the `<Field />` component to build forms.

## What Changed

### Dependencies
- **Added**: `@tanstack/react-form` - Core form management library
- **Added**: `@tanstack/zod-form-adapter` - Zod validation adapter for TanStack Form
- **Removed**: `@hookform/devtools` - No longer needed

### Components
- **New**: `src/components/ui/field.tsx` - Field components for TanStack Form
  - `Field` - Container for form fields
  - `FieldLabel` - Label component
  - `FieldControl` - Control wrapper
  - `FieldDescription` - Description text
  - `FieldError` - Error message display

- **Deprecated**: `src/components/ui/form.tsx` - Old react-hook-form components (kept for reference, will be removed in future)

### Updated Components
- `src/components/form-example.tsx` - Example form using TanStack Form
- `src/components/AddressAutocomplete.tsx` - Address autocomplete using TanStack Form

## Migration Examples

### Before (react-hook-form)

\`\`\`tsx
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";

const form = useForm({
  resolver: zodResolver(formSchema),
  defaultValues: { username: "" },
});

return (
  <Form {...form}>
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <FormField
        control={form.control}
        name="username"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Username</FormLabel>
            <FormControl>
              <Input {...field} />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
    </form>
  </Form>
);
\`\`\`

### After (TanStack Form)

\`\`\`tsx
import { useForm } from "@tanstack/react-form";
import { zodValidator } from "@tanstack/zod-form-adapter";
import {
  Field,
  FieldControl,
  FieldError,
  FieldLabel,
} from "@/components/ui/field";

const form = useForm({
  defaultValues: { username: "" },
  onSubmit: async ({ value }) => {
    console.log(value);
  },
  validatorAdapter: zodValidator(),
});

return (
  <form onSubmit={(e) => {
    e.preventDefault();
    form.handleSubmit();
  }}>
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
              value={field.state.value}
              onBlur={field.handleBlur}
              onChange={(e) => field.handleChange(e.target.value)}
              aria-invalid={field.state.meta.errors.length > 0}
            />
          </FieldControl>
          {field.state.meta.errors.length > 0 && (
            <FieldError>{field.state.meta.errors.join(", ")}</FieldError>
          )}
        </Field>
      )}
    </form.Field>
  </form>
);
\`\`\`

## Key Differences

### Form Setup
- **react-hook-form**: Use `zodResolver` in `useForm({ resolver: zodResolver(schema) })`
- **TanStack Form**: Use `validatorAdapter: zodValidator()` in `useForm` and validators per field

### Field Validation
- **react-hook-form**: Validation happens through the resolver
- **TanStack Form**: Validation defined in `validators` prop of `form.Field`

### Field Rendering
- **react-hook-form**: Uses `render` prop with `FormField` wrapper
- **TanStack Form**: Uses children function directly on `form.Field`

### Error Handling
- **react-hook-form**: Errors available via `field.error`
- **TanStack Form**: Errors in `field.state.meta.errors` array

### Field State
- **react-hook-form**: `field` object with `value`, `onChange`, `onBlur`
- **TanStack Form**: `field.state.value`, `field.handleChange()`, `field.handleBlur()`

### Form Submission
- **react-hook-form**: `form.handleSubmit(onSubmit)` where `onSubmit` is separate
- **TanStack Form**: `onSubmit` defined in `useForm`, call `form.handleSubmit()`

## Reusable Field Components

For components like `AddressAutocomplete`, the API has changed:

### Before
\`\`\`tsx
<AddressAutocomplete
  control={form.control}
  name="address"
  apiKey="..."
/>
\`\`\`

### After
\`\`\`tsx
<AddressAutocomplete
  form={form}
  name="address"
  apiKey="..."
/>
\`\`\`

The component now receives the entire `form` object instead of just `control`.

## Validation Strategies

TanStack Form supports multiple validation strategies:

\`\`\`tsx
<form.Field
  name="email"
  validators={{
    onChange: emailSchema,  // Validate on every change
    onBlur: emailSchema,    // Validate on blur
    onSubmit: emailSchema,  // Validate on submit
  }}
>
\`\`\`

## Resources

- [shadcn/ui TanStack Form Documentation](https://ui.shadcn.com/docs/forms/tanstack-form)
- [shadcn/ui Field Component](https://ui.shadcn.com/docs/components/field)
- [TanStack Form Documentation](https://tanstack.com/form)
- [Example Form](./src/components/form-example.tsx)
- [Example Address Autocomplete](./src/components/AddressAutocomplete.tsx)
