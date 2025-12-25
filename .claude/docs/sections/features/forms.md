### Forms

Uses **TanStack Form** (`@tanstack/react-form`) with **Field** components from `src/components/ui/field.tsx`.

- **Validation**: Zod schemas passed directly to validators (TanStack Form supports Standard Schema spec)
- **Pattern**: `useForm()` hook with Zod schema in validators, render fields with `<form.Field>` children function
- **Examples**: See `src/components/form-example.tsx` and `src/components/AddressAutocomplete.tsx`