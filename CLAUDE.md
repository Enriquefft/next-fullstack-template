# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Additional context-specific rules** are in `.claude/rules/` and load automatically based on file paths.

## Development Commands

**Package Manager**: This project uses **Bun**. Always use `bun` instead of `npm` or `yarn`.

**Most Frequently Used:**
- `bun dev` – Start development server on port 3000
- `bun run build` – Build for production
- `bun lint` – Lint and format code with Biome
- `bun test` – Run unit tests with Happy DOM
- `bun run test:e2e` – Run end-to-end tests with Playwright
- `bunx tsc --noEmit` – Type-check without emitting files
- `bun run db:push` – Push Drizzle schema changes to database

**Testing Overview:**
- **Unit tests**: Configured with Happy DOM (preloaded via `bunfig.toml`). Test files live in `tests/` and use `.test.ts` or `.test.tsx` extensions. Run with `bun test`.
- **E2E tests**: Powered by Playwright (config in `e2e/playwright.config.ts`). Test files live in `e2e/tests/` and use `.spec.ts` extensions. Run with `bun run test:e2e`. See `.claude/rules/e2e-testing.md` for detailed documentation.

## Architecture Overview

### E2E Testing & Database Architecture

This project uses a **multi-database architecture** with separate Neon branches for different environments:

1. **Single Entry Point**: Application code (`src/db/index.ts`) reads only `DRIZZLE_DATABASE_URL`
2. **Environment Selection**: Scripts inject the appropriate database URL (`DATABASE_URL_DEV`, `DATABASE_URL_TEST`, etc.)
3. **E2E Isolation**: All E2E-specific code lives in the `e2e/` folder—no test logic in application code
4. **Infrastructure-Free**: No Docker or local PostgreSQL required—Neon branches are always available

**For detailed E2E testing guide**, see `.claude/rules/e2e-testing.md` (loads automatically when working in `e2e/`).

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

Server Actions / Server Components provide better type safety, automatic request deduplication, and simpler data flow compared to API routes.

### Forms

Uses **TanStack Form** (`@tanstack/react-form`) with **Field** components from `src/components/ui/field.tsx`.

- **Validation**: Zod schemas via `@tanstack/zod-form-adapter` and `zodValidator()`
- **Pattern**: `useForm()` hook with `validatorAdapter`, render fields with `<form.Field>` children function
- **Examples**: See `src/components/form-example.tsx` and `src/components/AddressAutocomplete.tsx`

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

Type-safe environment validation using **@t3-oss/env-nextjs** in `src/env/[client|server|db].ts`.

- **Client vars** (prefixed with `NEXT_PUBLIC_`): Available in browser
- **Server vars**: Backend-only, validated at build time
- **Database URLs**: Multi-environment setup using Neon branches (`DATABASE_URL_DEV`, `DATABASE_URL_TEST`, etc.). Application code reads only `DRIZZLE_DATABASE_URL`, which is set automatically by scripts.

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
- `tests/` – Unit tests (Happy DOM)
- `e2e/` – End-to-end tests (Playwright)
  - `setup/` – Global setup/teardown and database utilities
  - `helpers/` – Auth, database, and fixture helpers
  - `fixtures/` – Seed data definitions
  - `tests/` – Test files (*.spec.ts)
  - `playwright.config.ts` – Playwright configuration

### Styling System

- **Tailwind CSS v4** with **shadcn/ui** components
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

**Claude commits**: Claude Code can create commits following the conventional commit format. Always ensure `bun type`, `bun lint`, `bun run build` are successful before committing.

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
