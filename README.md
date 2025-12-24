# Next Fullstack Template

A preconfigured Next.js starter built with TypeScript, Bun, Tailwind CSS and
Drizzle ORM. It includes Better Auth, shadcn/ui, PostHog analytics and a basic
Nix flake for development.

## Features

- Next.js 16 with the App Router
- Bun package manager and runtime
- Tailwind CSS with shadcn/ui components
- Drizzle ORM for PostgreSQL
- Authentication powered by Better Auth
- PostHog analytics integration
- Unit tests with Happy DOM and Testing Library
- E2E tests with Playwright
- Biome linting and formatting


## Technology Choices

- **Bun** – Fast runtime and package manager. Install from <https://bun.sh>, then run `bun dev` to start the app, `bun test` for unit tests, and `bun run test:e2e` for e2e tests.
- **Tailwind CSS & shadcn/ui** – Utility-first styling with prebuilt UI primitives. Global styles live in `src/styles` and components in `src/components/ui`.
- **Drizzle ORM** – Type-safe database toolkit. Schemas are in `src/db/schema`; run `bun run db:push` for migrations and `bun run db:studio` to explore.
- **Better Auth** – Simple authentication using Drizzle and Google OAuth. Configuration resides in `src/auth.ts`; client helpers are in `src/lib/auth-client.ts`.
- **PostHog Analytics** – Tracks usage and page views. Initialized via `PostHogProvider` from `posthog-js`.
- **Nix Flake** – Provides a reproducible dev shell. Run `nix develop` to enter the environment.
- **Biome** – Linter and formatter. Execute `bun lint` or rely on Lefthook pre-commit hooks.
- **Happy DOM with Testing Library** – Lightweight DOM testing environment for unit tests defined in `tests/happydom.ts`.
- **Playwright** – End-to-end testing framework. Configuration in `playwright.config.ts`. Tests in `tests/e2e/`.

## Getting Started
Install **Bun** first if it isn't already available on your system. Visit
<https://bun.sh> for installation instructions. Then clone the repo and install
its dependencies:

```bash
git clone https://github.com/Enriquefft/next-fullstack-template.git
cd next-fullstack-template
bun install
```

Create a `.env` file from `.env.example` and fill in the environment variables.

Install the Git hooks (optional but recommended):

```bash
bunx lefthook install
```

Run the development server:

```bash
bun dev
```

Visit <http://localhost:3000> in your browser.

## Development Workflow

This template includes a structured PRD-based workflow powered by Claude Code. The workflow transforms your project idea into a complete implementation through automated scaffolding and incremental feature development.

### Recommended Workflow

**1. Generate PRD in Claude Chat**

Start a conversation in Claude Chat with this prompt:

```
I want to build a [project type] called [project name]. Here's what I need:

[Describe your project idea, key features, target users, and any specific requirements]

Please generate a complete Product Requirements Document (PRD) using this structure:
- 00-overview.md: Project vision, success metrics, and template customization notes
- 01-flows/: User flows organized by feature domain (auth/, payments/, etc.)
  - Each flow should include: user goal, preconditions, step-by-step scenario, expected DB state, UI state, and E2E test mapping
- 02-data-models.md: Database schema with Drizzle syntax
- 03-api-design.md: Server actions with Zod validation
- 04-ui-components.md: UI/UX specifications
- 05-integrations.md: Third-party services and configuration

Ask as many questions as needed to ensure the PRD is correct & complete

```

**Example for a SaaS product:**

```
I want to build a task management SaaS called "TaskFlow". Users can:
- Sign up with email/password and Google OAuth
- Create and organize tasks with tags and priorities
- Collaborate with team members
- Subscribe to Pro plan for unlimited tasks ($10/month via Stripe)
- Get real-time notifications

Please generate a complete PRD following the structure above.
```

**2. Copy PRD to `.claude/prd/`**

Claude Chat will generate multiple markdown files. Copy them into your cloned template's `.claude/prd/` directory:

```bash
git clone https://github.com/Enriquefft/next-fullstack-template.git my-project
cd my-project

# Copy generated files into .claude/prd/
# Your directory should look like:
# .claude/prd/
#   00-overview.md
#   01-flows/
#     _index.md
#     auth/signup-flows.md
#     auth/login-flows.md
#     tasks/create-task-flows.md
#     # ... etc
#   02-data-models.md
#   03-api-design.md
#   04-ui-components.md
#   05-integrations.md
```

**3. Run `/implement-prd` in Claude Code**

Open the project in Claude Code and run:

```
/implement-prd
```

This will:
- Read your PRD requirements
- Customize the template (remove unused features, update configs, modify dependencies)
- Generate `plan.md` with a complete implementation roadmap organized in phases → steps → tasks

Example output:
```
✅ Barebones implementation complete!

Completed:
- Project identity updated (name: taskflow)
- Authentication: Kept Better Auth + Google OAuth
- Payments: Replaced Polar with Stripe
- Analytics: Kept PostHog
- Dependencies: Removed polar-sh/sdk, added @stripe/stripe-js
- Database schema: Removed example post table

📋 Implementation plan created: plan.md

Next steps:
1. Review plan.md to understand implementation phases
2. Run `/next-step` to begin implementing Phase 1, Step 1
```

**4. Implement with `/next-step`**

Run `/next-step` repeatedly to implement features one by one:

```
/next-step
```

Each execution:
- Verifies previous feature has passing unit tests and E2E tests
- Implements next feature from `plan.md` (database → server actions → UI → tests)
- Validates with `bun test` and `bun run test:e2e`
- Reports completion and waits for next command

Example session:
```
✅ Tests verified for: User Signup
✅ Plan is up to date
📋 Next up: User Login

Flow reference: .claude/prd/01-flows/auth/login-flows.md

I'll now implement: Email/password login with session management

Tasks for this step:
- [ ] Implement signIn() server action with Zod validation
- [ ] Create SignInForm component
- [ ] Add login page at /login
- [ ] Add unit tests for signIn() action
- [ ] Add E2E tests for login flows (5 scenarios)

[Claude implements feature systematically]

✅ Feature complete: User Login

All tests passing:
- ✅ Unit tests: bun test
- ✅ E2E tests: bun run test:e2e
- ✅ Type check: bunx tsc --noEmit
- ✅ Linting: bun lint

Ready for next step. Run `/next-step` again to continue.
```

### PRD Templates

The `.claude/prd/` directory includes templates and examples to guide PRD generation:
- See `.claude/prd/01-flows/auth/signup-flows.md` for flow document examples
- See `.claude/prd/_template-flow.md` for the reusable flow template
- See `docs/plan-template.md` for the expected plan.md structure

### Additional Resources

- **Implementation guidance**: `.claude/rules/prd-implementation.md` (auto-loads when working in `src/` or `.claude/prd/`)
- **E2E testing guide**: `.claude/rules/e2e-testing.md` (auto-loads when working in `e2e/`)
- **Full workflow documentation**: See `CLAUDE.md` section "PRD-Based Development Workflow"

## Available Scripts

The following commands rely on Bun and the packages installed with `bun install`:

- `bun dev` – start the dev server
- `bun run build` – build for production
- `bun start` – run the production build
- `bun lint` – lint and format code with Biome
- `bun test` – execute unit tests
- `bun run test:e2e` – execute end-to-end tests with Playwright
- `bun run test:e2e:ui` – run e2e tests with Playwright UI mode
- `bunx tsc --noEmit` – type‑check the project
- `bun run db:push` – run Drizzle migrations
- `bun run db:studio` – open Drizzle Studio

## Project Structure

- `src/app` – Next.js routes and pages
- `src/components` – shared React components and `ui` primitives
- `src/db` – database schemas and utilities
- `src/styles` – global CSS and fonts
- `tests` – unit tests (Happy DOM)
- `tests/e2e` – end-to-end tests (Playwright)
- `playwright.config.ts` – Playwright configuration
- `docs` – project documentation

## Environment Variables

The `t3-oss/env-nextjs` package provides type‑safe access to env vars. Set the
values below in your `.env` file:

```bash
NEXT_PUBLIC_PROJECT_NAME=
DRIZZLE_DATABASE_URL=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
BETTER_AUTH_SECRET=
NEXT_PUBLIC_POSTHOG_KEY=
POLAR_ACCESS_TOKEN=
POLAR_MODE=
# Optional
BETTER_AUTH_URL=
```

See `.env.example` for details.

## Metadata and Social Sharing

Page metadata lives in `src/metadata.ts`. Customize the title, description and
authors to fit your project. Edit the `metadataBase` field so absolute URLs are
generated. This ensures the `og:image` preview works on platforms like
WhatsApp. Replace `public/opengraph-image.png` (and the
`opengraph-image.webp` variant) with your own social card if desired.

Next.js reads `src/app/icon.png` to generate the favicon and other metadata
icons. Swap this file for your own icon or add additional sizes following
Next.js file conventions. The exported `metadata` object in `src/metadata.ts`
imports these images. Update its `title`, `description`, `authors` and any other
fields to reflect your project. Ensure `metadataBase` points to your deployed
domain so that absolute URLs for icons and OpenGraph images resolve correctly.

## Contributing

Before opening a pull request, make sure Bun and the project dependencies are
installed with `bun install`. Then lint, type-check the code and run tests:

```bash
bun lint
bunx tsc --noEmit
bun test
bun run test:e2e
```

Keep commits focused and include a clear message.

## License

This project is available under the MIT License. See `LICENSE-MIT` for details.
