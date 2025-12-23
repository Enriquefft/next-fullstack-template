# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

**Package Manager**: This project uses **Bun**. Always use `bun` instead of `npm` or `yarn`.

- `bun dev` – Start development server on port 3000
- `bun run build` – Build for production
- `bun start` – Run production build
- `bun test` – Run all tests with Happy DOM
- `bun run format` – Format code with Biome (uses tabs, double quotes)
- `bunx tsc --noEmit` – Type-check without emitting files
- `bun run db:push` – Push Drizzle schema changes to database
- `bun run db:studio` – Open Drizzle Studio for database exploration
- `bun run auth:gen` – Generate Better Auth types
- `bun run auth:secret` – Generate Better Auth secret
- `bun run check:deps` – Check for unused dependencies with Knip
- `bunx lefthook install` – Install git hooks (run after cloning)

**Testing**: Tests are configured with Happy DOM (preloaded via `bunfig.toml`). Test files live in `tests/` and use `.test.ts` or `.test.tsx` extensions.

## Architecture Overview

### Authentication System

Authentication is handled by **Better Auth** with **Polar** integration for payment/subscription features.

- **Server config**: `src/auth.ts` exports the `auth` object using Drizzle adapter with PostgreSQL
- **Client helpers**: `src/lib/auth-client.ts` exports `signIn`, `signUp`, `useSession`, `checkout`, `customer`
- **API route**: `src/app/api/auth/[...all]/route.ts` handles all auth endpoints
- **Database schema**: Auth tables (user, session, account, verification) are in `src/db/schema/auth.ts`
- **OAuth provider**: Google OAuth configured via `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`
- **Polar integration**: Enables checkout and customer portal; uses `POLAR_ACCESS_TOKEN` and `POLAR_MODE` (sandbox/production)

### Next.js Patterns

**IMPORTANT**: Prefer **Server Actions** and **Server Components** over API routes for data mutations and fetching.

- **Server Actions**: Use for form submissions, mutations, and server-side logic called from client components
- **Server Components**: Default for data fetching; they run on the server and can directly access the database
- **API Routes**: Reserve for external webhooks, third-party integrations, or when you need a public REST endpoint. Server Actions & Server Components are prefered.
- The only API route in this template is `src/app/api/auth/[...all]/route.ts` for Better Auth (required by the library)

Server Actions / Server Components provide better type safety, automatic request deduplication, and simpler data flow compared to API routes.

### Forms

This project uses **TanStack Form** with the shadcn/ui **Field** component for form management and validation.

- **Form library**: `@tanstack/react-form` - Modern form state management
- **Validation**: `@tanstack/zod-form-adapter` - Zod schema validation adapter
- **UI components**: `src/components/ui/field.tsx` - Field, FieldLabel, FieldControl, FieldDescription, FieldError
- **Example form**: `src/components/form-example.tsx` - Shows basic usage pattern
- **Example autocomplete**: `src/components/AddressAutocomplete.tsx` - Reusable form field component

**IMPORTANT**: Do NOT use `react-hook-form`. The old Form component has been deprecated. Always use TanStack Form with the Field component.

**Basic form pattern**:
```tsx
import { useForm } from "@tanstack/react-form";
import { zodValidator } from "@tanstack/zod-form-adapter";
import { Field, FieldControl, FieldError, FieldLabel } from "@/components/ui/field";

const form = useForm({
  defaultValues: { username: "" },
  onSubmit: async ({ value }) => {
    // Call server action here
  },
  validatorAdapter: zodValidator(),
});

<form onSubmit={(e) => { e.preventDefault(); form.handleSubmit(); }}>
  <form.Field name="username" validators={{ onChange: schema.shape.username }}>
    {(field) => (
      <Field data-invalid={field.state.meta.errors.length > 0}>
        <FieldLabel>Username</FieldLabel>
        <FieldControl>
          <Input
            value={field.state.value}
            onBlur={field.handleBlur}
            onChange={(e) => field.handleChange(e.target.value)}
          />
        </FieldControl>
        {field.state.meta.errors.length > 0 && (
          <FieldError>{field.state.meta.errors.join(", ")}</FieldError>
        )}
      </Field>
    )}
  </form.Field>
</form>
```

See `TANSTACK_FORM_MIGRATION.md` for detailed migration guide and examples.

### Database Layer

Uses **Drizzle ORM** with **Neon Serverless** driver for PostgreSQL.

- **Connection**: `src/db/index.ts` exports `db` instance connected via `DRIZZLE_DATABASE_URL`
- **Schema organization**: All schemas live in `src/db/schema/` directory
  - `schema.ts` creates the base schema using `pgSchema(env.NEXT_PUBLIC_PROJECT_NAME)` – this means all tables are namespaced by project name
  - `index.ts` re-exports all schemas for convenient imports
  - `auth.ts` contains Better Auth tables (user, session, account, verification)
  - `post.ts` is an example schema file
- **Schema filter**: `drizzle.config.ts` uses `schemaFilter` to isolate this project's tables by `NEXT_PUBLIC_PROJECT_NAME`
- **Important**: When creating new tables, always use the `schema` object from `schema.ts`, not `pgSchema` directly

### Environment Variables

Type-safe environment validation using **@t3-oss/env-nextjs** in `src/env.ts`.

- **Client vars** (prefixed with `NEXT_PUBLIC_`): Available in browser
- **Server vars**: Backend-only, validated at build time
- **Base URL logic**: `getBaseUrl()` in `src/lib/utils.ts` handles URL detection for Vercel deployments and local dev
- **Required vars**: See `.env.example` for complete list. Most critical:
  - `DRIZZLE_DATABASE_URL` – PostgreSQL connection string
  - `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` – OAuth credentials
  - `NEXT_PUBLIC_POSTHOG_KEY` – Analytics
  - `POLAR_ACCESS_TOKEN`, `POLAR_MODE` – Payment integration
  - `BETTER_AUTH_SECRET` – Generated via `bun run auth:secret`

### Code Organization

- `src/app/` – Next.js 15 App Router pages and routes
- `src/components/` – React components
  - `ui/` – shadcn/ui primitives (excluded from Biome linting)
  - Root level: Custom components like `sign-in.tsx`, `ProductCard.tsx`, theme provider
- `src/db/` – Database client and schemas
- `src/lib/` – Utilities (`utils.ts`, `auth-client.ts`, `posthog.ts`, `polar.ts`, `handle-error.ts`)
- `src/hooks/` – Custom React hooks (e.g., `use-google-places.tsx`, `use-mobile.tsx`)
- `src/styles/` – Global CSS and fonts
- `src/metadata.ts` – Centralized Next.js metadata (title, description, OG images)
- `tests/` – Unit tests

### Styling System

- **Tailwind CSS** with **shadcn/ui** components
- **Global styles**: `src/styles/` directory
- **Theme**: Dark mode support via `next-themes` (see `theme-provider.tsx`)
- **Utility**: `cn()` function in `src/lib/utils.ts` for class merging with `clsx` and `tailwind-merge`

### Analytics

**PostHog** is integrated for analytics and feature flags.

- `src/lib/posthog.ts` – Server-side PostHog client
- `src/components/PostHogProvider.tsx` – Client-side provider wrapper

## Code Style Guidelines

These rules are enforced by Biome (see `biome.jsonc`):

- **Indentation**: Tabs (not spaces)
- **Quotes**: Double quotes for JavaScript/TypeScript
- **Line length**: Keep under 80 characters when practical
- **Naming conventions**:
  - Components and types: `PascalCase`
  - Variables and functions: `camelCase`
  - Files: `kebab-case`
- **Imports**: Auto-organized and sorted via Biome
- **No default exports**: Except in Next.js route files (page.tsx, layout.tsx, error.tsx)
- **shadcn/ui files**: Components in `src/components/ui/` are excluded from linting

## Git Workflow

**Lefthook** provides pre-commit and pre-push hooks (see `lefthook.yml`):

- **Pre-commit**: Runs Biome linter/formatter on staged files + type-check
- **Pre-push**: Runs build + tests in parallel
- **Commit messages**: Use conventional commit prefixes (`feat:`, `fix:`, `chore:`, `style:`)

## Type Safety Notes

- **Strict mode**: TypeScript is configured with all strict checks enabled
- **No implicit any**: All types must be explicit
- **Path aliases**: Use `@/` prefix for imports from `src/` (e.g., `@/db`, `@/lib/utils`)
- **File extensions**: Import statements should include `.ts`/`.tsx` extensions (e.g., `from "./schema.ts"`)
- **Better Auth types**: Run `bun run auth:gen` after modifying auth configuration

## Important Patterns

1. **Database schemas must use the namespaced schema object**:
   ```ts
   import { schema } from "./schema.ts";
   export const myTable = schema.table("my_table", { ... });
   ```

2. **Client-side auth usage**:
   ```ts
   import { useSession } from "@/lib/auth-client";
   const { data: session } = useSession();
   ```

3. **Environment variable access**:
   ```ts
   import { env } from "@/env.ts";
   // Type-safe access: env.GOOGLE_CLIENT_ID
   ```

4. **Utility imports**:
   ```ts
   import { cn } from "@/lib/utils";
   ```

5. **Server Actions**:
   ```ts
   "use server";

   import { db } from "@/db";
   import { revalidatePath } from "next/cache";

   export async function createPost(formData: FormData) {
     const title = formData.get("title") as string;

     await db.insert(posts).values({ title });

     revalidatePath("/posts");
   }
   ```

## Template Customization

This is a template repository. When adapting for a new project:

1. Update `package.json` name and repository URLs
2. Modify `src/metadata.ts` with project-specific metadata
3. Replace OpenGraph images in `public/` directory
4. Update `NEXT_PUBLIC_PROJECT_NAME` in `.env` (affects database schema namespace)
5. Customize `docs/brand.md` if using brand guidelines
6. Delete template-specific content from README.md and this file
