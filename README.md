# Next Fullstack Template

[![CI](https://github.com/Enriquefft/next-fullstack-template/actions/workflows/ci.yml/badge.svg)](https://github.com/Enriquefft/next-fullstack-template/actions/workflows/ci.yml)
[![Security](https://github.com/Enriquefft/next-fullstack-template/actions/workflows/security.yml/badge.svg)](https://github.com/Enriquefft/next-fullstack-template/actions/workflows/security.yml)

A preconfigured Next.js starter built with TypeScript, Bun, Tailwind CSS and
Drizzle ORM. It includes Better Auth, shadcn/ui, PostHog analytics, production-ready CI/CD, and a basic Nix flake for development.

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
- Production-ready CI/CD with GitHub Actions
- Automated security scanning (CodeQL, secrets, dependencies)
- Multi-environment deployment (Preview, Staging, Production)

## CI/CD Pipeline

This template includes a comprehensive GitHub Actions CI/CD pipeline optimized for Bun + Next.js + Vercel.

### GitHub Actions Workflows

**CI Workflow** (`ci.yml`) - Runs on all PRs and pushes:
- Quality checks (typecheck, lint, unused dependencies)
- Unit tests with Happy DOM
- E2E tests with Playwright
- Production build verification
- All checks must pass before PR can be merged

**Security Workflow** (`security.yml`) - Weekly scans + on PRs:
- Dependency vulnerability scanning
- CodeQL static analysis (SQL injection, XSS, etc.)
- Secrets detection with TruffleHog
- License compliance checking
- SBOM generation (CycloneDX)

### Vercel Automatic Deployments

Vercel handles all deployments automatically when connected to your GitHub repository:

- **Preview Deployments**: Automatic preview for every PR (posted as comment by Vercel bot)
- **Production Deployments**: Automatic deployment when merging to `main` branch
- **Staging Deployments**: Automatic deployment when merging to `staging` branch (if configured)

**No additional workflow files needed** - Vercel's GitHub integration handles building, deploying, and environment management.

### Environment Setup

**Prerequisites**: Before setting up CI/CD, ensure you've completed the [Getting Started](#getting-started) steps, especially creating Neon database branches.

#### Quick Setup

Two helper scripts are provided for faster setup:

```bash
# 1. Set GitHub secrets (interactive prompts - secure)
./scripts/setup-github-secrets.sh

# 2. Set Vercel environment variables
./scripts/setup-vercel-env.sh
```

**Security Note**: The secrets script uses interactive prompts - values won't appear in your terminal or shell history. Never commit `.env` files or hardcode secrets in scripts.

#### Required GitHub Secrets

Add these secrets in **Settings → Secrets and variables → Actions** (or use `./scripts/setup-github-secrets.sh`):

**Database** (these should already exist in your `.env` from [Getting Started](#getting-started)):
- `DATABASE_URL_TEST` - Test database connection string
- `DATABASE_URL_STAGING` - Staging database connection string
- `DATABASE_URL_PROD` - Production database connection string

**Authentication** (copy from `.env` or generate new):
- `BETTER_AUTH_SECRET_TEST` - Generate: `bun run auth:secret`
- `BETTER_AUTH_SECRET_STAGING` - Generate: `bun run auth:secret`
- `BETTER_AUTH_SECRET_PROD` - Generate: `bun run auth:secret`
- `GOOGLE_CLIENT_ID` - Google OAuth client ID
- `GOOGLE_CLIENT_SECRET` - Google OAuth client secret

**Third-Party Services** (copy from `.env`):
- `NEXT_PUBLIC_POSTHOG_KEY` - PostHog analytics key
- `POSTHOG_PROJECT_ID` - PostHog project ID
- `POLAR_ACCESS_TOKEN` - Polar API token (sandbox)
- `POLAR_ACCESS_TOKEN_PROD` - Polar API token (production, optional)
- `UPLOADTHING_TOKEN` - UploadThing token
- `UPLOADTHING_TOKEN_PROD` - UploadThing production token (optional)
- `NEXT_PUBLIC_PROJECT_NAME` - Your project name
- `CODECOV_TOKEN` - Codecov upload token (optional)

#### Vercel Environment Variables

Configure these in **Vercel Dashboard → Project Settings → Environment Variables**:

**All Environments** (Preview, Staging, Production):
- `NEXT_PUBLIC_PROJECT_NAME` - Your project name
- `GOOGLE_CLIENT_ID` - Google OAuth client ID
- `GOOGLE_CLIENT_SECRET` - Google OAuth client secret
- `NEXT_PUBLIC_POSTHOG_KEY` - PostHog analytics key
- `POSTHOG_PROJECT_ID` - PostHog project ID
- `POLAR_ACCESS_TOKEN` - Polar API token
- `POLAR_MODE` - Set to `sandbox` for preview/staging, `production` for production
- `UPLOADTHING_TOKEN` - UploadThing token

**Environment-Specific**:
- `DATABASE_URL` - Set per environment (preview → test DB, staging → staging DB, production → prod DB)
- `BETTER_AUTH_SECRET` - Different secret per environment (generate with `bun run auth:secret`)

#### Branch Protection

Configure in **Settings → Branches → Add rule** for `main`:
- ✅ Require status checks to pass before merging
  - `quality (typecheck)`
  - `quality (lint)`
  - `quality (deps)`
  - `unit-tests`
  - `e2e-tests`
  - `build`
  - `codeql`
- ✅ Require 1 approval
- ✅ Require branches to be up to date before merging

### Deployment Flow

1. **Development**: Work in feature branches
2. **Pull Request**: Open PR → CI/Security checks run → Vercel creates preview deployment
3. **Review**: All checks pass → Get approval → Merge
4. **Staging** (optional): Merge to `staging` → Vercel auto-deploys to staging environment
5. **Production**: Merge to `main` → Vercel auto-deploys to production

**Database Migrations**: Run manually or via GitHub Actions workflow after verifying deployment:
```bash
# After production deployment
DATABASE_URL=$PROD_DB_URL bun run db:push
```

### Monitoring & Rollback

**Built-in Monitoring**:
- PostHog analytics for page views and events
- Vercel Analytics for Core Web Vitals (optional)
- GitHub Actions for CI/CD metrics

**Rollback Procedure**:
- Vercel Dashboard: **Deployments** → Find last stable deployment → **Promote to Production**
- Instant rollback in < 1 minute

For detailed CI/CD documentation, see the comprehensive plan at `.claude/plans/vivid-hopping-pillow.md`.

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

### Prerequisites

1. **Install Bun**: Visit <https://bun.sh> for installation instructions
2. **GitHub CLI** (optional): For automated setup scripts - <https://cli.github.com>
3. **Neon Account**: For PostgreSQL databases - <https://console.neon.tech>

### Setup Steps (in order!)

**1. Clone and Install**

```bash
git clone https://github.com/Enriquefft/next-fullstack-template.git my-project
cd my-project
bun install
```

**2. Run Post-Template Setup** (configures repository settings)

```bash
./scripts/setup-new-repo.sh
```

This disables GitHub's default CodeQL (we use a custom workflow) and is only needed once.

**3. Create Neon Database Branches** ⚠️ **REQUIRED BEFORE NEXT STEPS!**

Go to <https://console.neon.tech> and create **4 database branches**:
- `dev` - Local development
- `test` - E2E tests and CI
- `staging` - Staging environment (optional)
- `prod` - Production

Copy the connection string for each branch. You'll need these in step 4.

**Why 4 databases?** Each environment needs isolated data. Tests shouldn't touch dev data, and dev shouldn't touch production data.

**4. Configure Local Environment**

```bash
cp .env.example .env
```

Edit `.env` and add (minimum required to run locally):

```bash
NEXT_PUBLIC_PROJECT_NAME='my-project'

# Database URLs from Neon (step 3)
DATABASE_URL_DEV='postgresql://...'    # From dev branch
DATABASE_URL_TEST='postgresql://...'   # From test branch
DATABASE_URL_STAGING='postgresql://...' # From staging branch
DATABASE_URL_PROD='postgresql://...'   # From prod branch

# Generate auth secret (run: bun run auth:secret)
BETTER_AUTH_SECRET='...'

# Optional: Add Google OAuth, PostHog, etc. later
```

**5. Generate Auth Secret**

```bash
bun run auth:secret
```

Copy the output to `BETTER_AUTH_SECRET` in your `.env` file.

**6. Install Git Hooks** (optional but recommended)

```bash
bunx lefthook install
```

**7. Start Development**

```bash
bun dev
```

Visit <http://localhost:3000> in your browser.

### Optional: CI/CD Setup

After local development works, set up automated deployments:

**GitHub Secrets** (for CI/CD workflows):
```bash
./scripts/setup-github-secrets.sh
```

**Vercel Environment Variables** (for deployments):
```bash
./scripts/setup-vercel-env.sh
```

See the [CI/CD Pipeline](#cicd-pipeline) section below for details.

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
- ✅ Type check: bun type
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
- `bun run test:e2e` – execute end-to-end tests with Playwright (use `PORT=3001 bun test:e2e` to override port)
- `bun run test:e2e:ui` – run e2e tests with Playwright UI mode
- `bun type` – type‑check the project
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
# Database URLs for different environments
DATABASE_URL_DEV=
DATABASE_URL_TEST=
DATABASE_URL_STAGING=
DATABASE_URL_PROD=
# Authentication
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
BETTER_AUTH_SECRET=
# Analytics
NEXT_PUBLIC_POSTHOG_KEY=
# Payments
POLAR_ACCESS_TOKEN=
POLAR_MODE=
# File uploads
UPLOADTHING_TOKEN=
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
bun type
bun test
bun run test:e2e
```

Keep commits focused and include a clear message.

## License

This project is available under the MIT License. See `LICENSE-MIT` for details.
