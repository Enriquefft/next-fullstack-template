<!-- This file is customized during /implement-prd based on PRD choices in .claude/prd/00-overview.md -->

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**For new projects**: Run `/implement-prd` to customize this template based on your requirements. See "PRD-Based Development Workflow" below.

**Additional context-specific rules** are in `.claude/rules/` and load automatically based on file paths.

**Product requirements and user flows** are documented in `.claude/prd/` for feature specifications and implementation planning.

## Development Commands

**Package Manager**: This project uses **Bun**. Always use `bun` instead of `npm` or `yarn`.

**Most Frequently Used:**
- `bun dev` – Start development server on port 3000
- `bun run build` – Build for production
- `bun lint` – Lint and format code with Biome
- `bun test` – Run unit tests with Happy DOM
- `bun run test:e2e` – Run end-to-end tests with Playwright
- `bun type` – Type-check without emitting files
- `bun run db:push` – Push Drizzle schema changes to database

**Testing Overview:**
- **Unit tests**: Configured with Happy DOM (preloaded via `bunfig.toml`). Test files live in `tests/` and use `.test.ts` or `.test.tsx` extensions. Run with `bun test`.
- **E2E tests**: Powered by Playwright (config in `e2e/playwright.config.ts`). Test files live in `e2e/tests/` and use `.spec.ts` extensions. Run with `bun run test:e2e`. Override port with `PORT=3001 bun test:e2e` if needed. See `.claude/rules/e2e-testing.md` for detailed documentation.

**Planning & Implementation:**
- **PRD workflow**: Use `/implement-prd` to scaffold from `.claude/prd/` requirements, then `/next-step` for incremental feature development
- **Test-driven**: Each feature requires unit tests and E2E tests matching PRD flows before moving to next feature
- **Plan tracking**: `plan.md` (auto-generated) tracks phases → steps → tasks with explicit test requirements

## Architecture Overview

### Database Architecture

Multi-environment PostgreSQL via **Neon Serverless**:

- **Deployed environments**: `DATABASE_URL` set by Vercel (different value for production vs preview)
- **Local development**: `DATABASE_URL_DEV` in `.env.local`
- **E2E tests**: `DATABASE_URL_TEST` in `.env.local` (and GitHub Actions secret)

**Key Points**:
- Configuration logic in `src/env/db.ts` with automatic selection
- No Docker or local PostgreSQL required—uses Neon branches
- See `.env.example` for setup template
- **Driver**: Uses `drizzle-orm/neon-serverless` for full transaction support
- **E2E Tests**: WebSocket configured with `ws` package for Node.js/CI environments (see `e2e/setup/db.ts`)
- **Schema Management**: E2E global setup automatically pushes schema via `drizzle-kit push` before each test run

#### Database Migration Workflow

**Development (Local)**:
- Use `bun run db:push` for rapid iteration—directly syncs schema changes without migration files
- Ideal for prototyping and quick schema adjustments

**Production/Staging Deployment**:
```bash
# 1. Generate migration files from schema changes
bun run db:generate

# 2. Review generated SQL in drizzle/ folder
# Commit migration files to git

# 3. In deployment: Run migrations before starting the app
bun run db:migrate
```

**Key Differences**:
- `db:push`: Direct schema sync, no history, **development only**
- `db:generate` + `db:migrate`: Version-controlled migrations with rollback capability, **required for production**

**Migration files** are stored in `drizzle/` and provide:
- Complete schema change history
- Peer review via git commits
- Safe rollback capability
- Protection against data loss

**IMPORTANT**: Never use `db:push` in CI/CD or deployment pipelines. Always use migration-based workflow for production/staging environments.

### Authentication System

Authentication is handled by **Better Auth** with **Polar** integration for payment/subscription features.

- Uses Drizzle adapter with PostgreSQL for session storage
- Google OAuth configured via `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`
- Polar integration for checkout and customer portal (configured via `POLAR_ACCESS_TOKEN` and `POLAR_MODE`)

### Next.js Patterns

**IMPORTANT**: Prefer **Server Actions** and **Server Components** over API routes for data mutations and fetching.

- **Server Actions**: Use for form submissions, mutations, and server-side logic called from client components
- **Server Components**: Default for data fetching; they run on the server and can directly access the database
- **API Routes**: Reserve for external webhooks, third-party integrations, or when you need a public REST endpoint. Server Actions & Server Components are preferred.

Server Actions / Server Components provide better type safety, automatic request deduplication, and simpler data flow compared to API routes.

### Forms

Uses **TanStack Form** (`@tanstack/react-form`) with **Field** components from `src/components/ui/field.tsx`.

- **Validation**: Zod schemas passed directly to validators (TanStack Form supports Standard Schema spec)
- **Pattern**: `useForm()` hook with Zod schema in validators, render fields with `<form.Field>` children function
- **Examples**: See `src/components/form-example.tsx` and `src/components/AddressAutocomplete.tsx`

### Database Layer

Uses **Drizzle ORM** with **Neon Serverless** driver for PostgreSQL.

- **Connection**: `src/db/index.ts` exports `db` instance using `databaseUrl` from `src/env/db.ts`
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

### WhatsApp Messaging (Kapso)

**Kapso** provides WhatsApp Business API integration for sending messages, templates, and handling webhooks.

- `src/lib/kapso.ts` – Server-side Kapso client with helper functions
- `src/app/api/whatsapp/webhook/route.ts` – Webhook handler for incoming messages and status updates

**Environment Variables** (optional):
- `KAPSO_API_KEY` – API key from [kapso.ai](https://kapso.ai)
- `KAPSO_PHONE_NUMBER_ID` – WhatsApp phone number ID
- `META_APP_SECRET` – For webhook signature verification

**Usage Example**:
```ts
import { sendTextMessage, sendButtonMessage } from "@/lib/kapso";

// Send a text message
await sendTextMessage("+1234567890", "Hello from WhatsApp!");

// Send interactive buttons
await sendButtonMessage(
  "+1234567890",
  "Choose an option:",
  [
    { id: "opt1", title: "Option 1" },
    { id: "opt2", title: "Option 2" },
  ]
);
```

**Webhook Setup**: Configure your webhook URL in Meta Business Suite as `https://yourdomain.com/api/whatsapp/webhook` with `META_APP_SECRET` as the verify token.

### SEO & GEO (Generative Engine Optimization)

Comprehensive SEO infrastructure for traditional and AI search engines:

- Locale-aware metadata utilities (`src/lib/seo/metadata.ts`)
- JSON-LD structured data schemas (`src/lib/seo/schema/`)
- Environment-aware robots.txt and multi-locale sitemap
- Customized during `/implement-prd` from PRD requirements

**Note**: Detailed usage documentation loads automatically when working in SEO-related files.

### Performance Optimization

- **Turbopack**: Enabled for faster dev server and production builds
- **Image Optimization**: AVIF/WebP formats with responsive srcset (configured in `next.config.ts`)
- Use Next.js `<Image>` component with `width`/`height` or `fill` + `sizes` prop
- External images require `images.remotePatterns` configuration in `next.config.ts`

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

**PRD references in commits**: When implementing features from `.claude/prd/`, reference the specific flow file and line number in commit messages:

```bash
git commit -m "feat: implement email/password signup

Implements flow from .claude/prd/01-flows/auth/signup-flows.md:12

- Add signUp() server action with validation
- Create SignUpForm component
- Add E2E tests for happy path and error cases"
```

## Type Safety Notes

- **Strict mode**: TypeScript is configured with all strict checks enabled
- **No implicit any**: All types must be explicit
- **No `@ts-ignore`**: Never use `@ts-ignore` comments. Fix type errors properly instead of suppressing them
- **No `as` casting**: Avoid type assertions with `as`. Use proper type guards, validation, or refactor to eliminate the need for casting
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

3. **Utility imports**:
   ```ts
   import { cn } from "@/lib/utils";
   ```

4. **Server Actions with proper validation**:
   ```ts
   "use server";

   import { db } from "@/db";
   import { revalidatePath } from "next/cache";
   import { z } from "zod";

   const createPostSchema = z.object({
     title: z.string().min(1),
   });

   export async function createPost(formData: FormData) {
     const parsed = createPostSchema.parse({
       title: formData.get("title"),
     });

     await db.insert(posts).values(parsed);

     revalidatePath("/posts");
   }
   ```

## PRD-Based Development Workflow

This template supports a structured workflow from requirements to implementation:

### 1. Generate PRD in Claude Chat

Use Claude Chat to create your Product Requirements Document from your project idea. The PRD should be structured as:

- `00-overview.md` – Project vision, success metrics, template customization notes
- `01-flows/` – User flows organized by feature domain (auth/, payments/, etc.)
- `02-data-models.md` – Database schema specifications
- `03-api-design.md` – Server actions and API design
- `04-ui-components.md` – UI/UX specifications
- `05-integrations.md` – Third-party services and APIs

See `.claude/prd/` for templates and examples.

### 2. Place PRD in `.claude/prd/`

Copy generated PRD files into `.claude/prd/` directory in your cloned template.

### 3. Run `/implement-prd`

Execute the `/implement-prd` slash command in Claude Code. This will:
- Read your PRD requirements
- Customize template (remove unused features, update configs)
- Generate `plan.md` with implementation roadmap

### 4. Incremental Implementation with `/next-step`

Run `/next-step` repeatedly to implement features one at a time:
- Verifies previous feature has passing tests
- Implements next feature from plan.md
- Creates unit tests and E2E tests
- Validates with `bun test` and `bun run test:e2e`

For detailed guidance, see `.claude/rules/prd-implementation.md` (auto-loads when working in `src/` or `.claude/prd/`).
