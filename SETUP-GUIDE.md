# Complete Setup Guide: Implementing a New Project with This Template

This guide walks you through the entire process of using this Next.js fullstack template to build a new project, from initial setup through deployment.

---

## Prerequisites

Before starting, ensure you have:

- **Bun** (package manager) - https://bun.sh
- **GitHub CLI** (`gh`) - https://cli.github.com
- **Vercel CLI** (`vercel`) - `bun add -g vercel`
- **Claude CLI** (`claude`) - For AI-powered development workflows
- **Neon Account** - https://console.neon.tech (free tier available)

Optional:
- **Google Cloud Console** account (if using Google OAuth)
- **Polar** account (if using payments) - https://polar.sh
- **PostHog** account (if using analytics) - https://posthog.com

---

## Phase 1: Initial Setup

### Step 1: Clone Template

```bash
# Clone the template repository
git clone <template-repo-url> <your-project-name>
cd <your-project-name>

# Remove template's git history (optional, for fresh start)
rm -rf .git
git init
```

### Step 2: Install Dependencies

```bash
bun install
```

This installs all template dependencies including:
- Next.js 15 (App Router)
- Drizzle ORM + Neon Serverless driver
- Better Auth + Polar
- TanStack Form + Zod
- Tailwind CSS v4 + shadcn/ui
- Playwright + Happy DOM (testing)
- Biome (linting/formatting)

### Step 3: Create Neon Database Branches

1. Go to https://console.neon.tech
2. Create a new project (or use existing)
3. Create **4 database branches**:

| Branch | Purpose | Used When |
|--------|---------|-----------|
| `dev` | Local development | `NODE_ENV=development` |
| `test` | E2E test runs | `NODE_ENV=test` |
| `staging` | Preview deployments | Vercel preview |
| `prod` | Production | Vercel production |

4. Copy the connection string for each branch (found in branch dashboard → Connection Details)

**Why separate branches?**
- Isolates test data from development work
- Prevents E2E tests from polluting dev database
- Staging mirrors production for safe testing
- Each branch can have different data/schema state

### Step 4: Configure Local Environment

```bash
# Create local environment file
cp .env.example .env
```

Edit `.env` with your values:

```bash
# Project Identity (used for database schema namespace)
NEXT_PUBLIC_PROJECT_NAME='your-project-name'

# Database URLs (from Neon dashboard)
DATABASE_URL_DEV='postgresql://user:pass@ep-xxx.region.aws.neon.tech/neondb?sslmode=require'
DATABASE_URL_TEST='postgresql://user:pass@ep-xxx.region.aws.neon.tech/neondb?sslmode=require'

# Google OAuth (if using - get from Google Cloud Console)
GOOGLE_CLIENT_ID='your-client-id.apps.googleusercontent.com'
GOOGLE_CLIENT_SECRET='your-client-secret'

# Better Auth Secret (generate in next step)
BETTER_AUTH_SECRET=''

# PostHog (optional - get from PostHog dashboard)
NEXT_PUBLIC_POSTHOG_KEY=''
POSTHOG_PROJECT_ID=''

# Polar (optional - get from Polar dashboard)
POLAR_ACCESS_TOKEN=''
POLAR_MODE='sandbox'  # or 'production'

# UploadThing (optional - get from UploadThing dashboard)
UPLOADTHING_TOKEN=''
```

### Step 5: Generate Authentication Secret

```bash
bun run auth:secret
```

This outputs a cryptographically secure random string. Copy it to `BETTER_AUTH_SECRET` in your `.env` file.

**Important**: Use DIFFERENT secrets for each environment (dev, staging, prod).

### Step 6: Push Initial Database Schema

```bash
bun run db:push
```

This synchronizes your Drizzle schema with the development database. The command:
- Reads schema files from `src/db/schema/`
- Compares with current database state
- Applies changes directly (no migration files)

**Note**: `db:push` is for development only. Use `db:generate` + `db:migrate` for production.

### Step 7: Verify Setup

Run these commands to ensure everything is working:

```bash
# Start development server (should open localhost:3000)
bun dev

# In another terminal, run unit tests
bun test

# Run E2E tests (starts server automatically)
bun run test:e2e

# Type check
bun type

# Lint and format
bun lint
```

All commands should complete successfully before proceeding.

---

## Phase 2: Repository Setup

### Step 8: Create GitHub Repository

```bash
# Create new private repository
gh repo create your-project-name --private --source=. --remote=origin

# Or if repo already exists
git remote add origin https://github.com/username/your-project-name.git
```

### Step 9: Run Repository Setup Script

This one-time script configures repository-specific settings:

```bash
./scripts/setup-new-repo.sh
```

**What it does:**
- Verifies GitHub CLI is authenticated
- Disables default CodeQL (template uses custom workflow)
- Creates `.repo-setup-complete` marker file
- Optionally self-deletes and commits

**After completion, the script reminds you of remaining setup steps.**

### Step 10: Configure CI/CD Secrets

The unified setup script configures both Vercel and GitHub Actions:

```bash
bun run deploy:env
```

**Features:**
- **Hybrid strategy**: Auto-pushes shared secrets (OAuth, analytics), prompts for environment-specific ones (DATABASE_URL, BETTER_AUTH_SECRET)
- **Auto-generates secrets**: In `--auto-all` mode, runs `bun run auth:secret` to generate unique secrets per environment
- **Type-safe**: TypeScript-based with full validation

**Options:**
```bash
# Interactive mode (recommended)
bun run deploy:env

# Skip all prompts, auto-generate environment-specific secrets
bun run deploy:env --auto-all

# Preview what would be deployed without making changes
bun run deploy:env --dry-run

# Configure platforms separately
bun run deploy:github   # GitHub Actions only
bun run deploy:vercel   # Vercel only
```

**What gets configured:**

| Category | Auto-Pushed | Prompted |
|----------|-------------|----------|
| **Database** | - | DATABASE_URL (production, preview, test) |
| **Authentication** | GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET | BETTER_AUTH_SECRET (production, preview, test) |
| **Services** | POSTHOG_*, POLAR_*, UPLOADTHING_TOKEN | - |
| **Project** | NEXT_PUBLIC_PROJECT_NAME (auto-detected) | - |

**Git Integration:**
After deployment setup, connect Vercel to your GitHub repo for automatic deployments:
- Push to `main` → deploys to production
- Push to feature branch → creates preview deployment
- Open PR → creates preview deployment with unique URL

---

## Phase 3: Deployment

### Step 11: Generate Production Migrations

**Development** uses `db:push` for rapid iteration. **Production** requires versioned migrations:

```bash
# Generate migration files from schema changes
bun run db:generate
```

This creates SQL files in `drizzle/` directory:
```
drizzle/
├── 0000_initial_schema.sql
├── 0001_add_user_preferences.sql
└── meta/
    └── _journal.json
```

**Review the generated SQL:**
```bash
# View migration files
cat drizzle/*.sql
```

**Commit migrations to git:**
```bash
git add drizzle/
git commit -m "chore: add database migrations"
```

### Step 12: Push and Deploy

```bash
# Push to main branch (triggers Vercel auto-deploy)
git push origin main
```

**Vercel deployment process:**
1. Detects push to `main` branch
2. Runs `bun run build`
3. Runs `bun run db:migrate` (applies migrations)
4. Deploys to production URL

**For preview deployments:**
```bash
# Push feature branch
git push origin feature/new-feature

# Or open a PR - Vercel creates preview automatically
```

---

## Phase 4: Maintenance & Operations

The template includes an AI-powered automation script for ongoing maintenance:

### Preview Issues (Safe)
```bash
./scripts/codebase_ops.sh --dry-run
```
Shows what issues exist without making changes.

### Fix PR Changes Only (Fast)
```bash
./scripts/codebase_ops.sh --since main
```
Only analyzes/fixes files changed in your branch. ~90% faster than full scan.

### Safe Automated Fixes
```bash
./scripts/codebase_ops.sh --safe
```
Only applies zero-risk, automated fixes (formatting, simple type fixes).

### Interactive Selection
```bash
./scripts/codebase_ops.sh
```
Shows grouped issues, lets you choose which to fix.

### Rollback Changes
```bash
# Undo last operation
./scripts/codebase_ops.sh undo

# View history
./scripts/codebase_ops.sh history

# Rollback to specific operation
./scripts/codebase_ops.sh rollback 2
```

### Find Improvements
```bash
./scripts/codebase_ops.sh --mode improve
```
Finds dead code, bandaid fixes, type safety issues.

---

## Quick Reference

### Essential Commands

| Stage | Command | Purpose |
|-------|---------|---------|
| **Setup** | `bun install` | Install dependencies |
| **Setup** | `bun run auth:secret` | Generate auth secret |
| **Setup** | `bun run db:push` | Push schema to dev DB |
| **Setup** | `./scripts/setup-new-repo.sh` | One-time repo config |
| **Setup** | `bun run deploy:env` | Configure CI/CD secrets |
| **Dev** | `bun dev` | Start dev server (port 3000) |
| **Test** | `bun test` | Run unit tests |
| **Test** | `bun run test:e2e` | Run E2E tests |
| **Test** | `bun type` | Type check |
| **Test** | `bun lint` | Lint and format |
| **Deploy** | `bun run db:generate` | Create migration files |
| **Deploy** | `bun run db:migrate` | Apply migrations |
| **Deploy** | `git push origin main` | Deploy to production |

### Database Commands

| Command | Environment | Purpose |
|---------|-------------|---------|
| `bun run db:push` | Development | Direct schema sync (no migration files) |
| `bun run db:generate` | Pre-deploy | Generate SQL migration files |
| `bun run db:migrate` | Production | Apply migration files |
| `bun run db:studio` | Development | Open Drizzle Studio GUI |

### Testing Commands

| Command | Type | Files |
|---------|------|-------|
| `bun test` | Unit | `tests/**/*.test.ts` |
| `bun run test:e2e` | E2E | `e2e/tests/**/*.spec.ts` |
| `PORT=3001 bun run test:e2e` | E2E | Run on custom port |

### Script Locations

| Script | Purpose |
|--------|---------|
| `scripts/setup-new-repo.sh` | One-time repository configuration |
| `scripts/setup-env.ts` | Unified Vercel + GitHub secrets setup (TypeScript) |
| `scripts/setup-github-secrets.ts` | GitHub Actions secrets only |
| `scripts/setup-vercel-env.ts` | Vercel environment only |

### Directory Structure

```
├── .claude/
│   ├── commands/           # Custom slash commands
│   ├── prd/                # Product requirements (optional)
│   └── rules/              # Context-specific Claude instructions
├── drizzle/                # Generated migration files
├── e2e/
│   ├── fixtures/           # Test seed data
│   ├── helpers/            # Auth, DB, fixture helpers
│   ├── setup/              # Global setup/teardown
│   └── tests/              # E2E test files (*.spec.ts)
├── scripts/                # Setup and maintenance scripts
├── src/
│   ├── app/                # Next.js App Router
│   ├── components/         # React components
│   │   └── ui/             # shadcn/ui primitives
│   ├── db/                 # Database client and schemas
│   ├── env/                # Environment validation
│   ├── hooks/              # Custom React hooks
│   ├── lib/                # Utilities (auth, analytics, etc.)
│   └── styles/             # Global CSS and fonts
├── tests/                  # Unit tests (*.test.ts)
├── .env.example            # Environment template
├── CLAUDE.md               # Claude Code instructions
├── plan.md                 # Generated implementation plan
└── package.json
```

---

## Troubleshooting

### Database Connection Errors

```
Error: Connection refused
```
- Verify DATABASE_URL_DEV is correct in `.env`
- Check Neon dashboard for branch status
- Ensure SSL mode is enabled (`?sslmode=require`)

### E2E Tests Failing

```
Error: Server not started
```
- Check if port 3000 is already in use: `lsof -i :3000`
- Use custom port: `PORT=3001 bun run test:e2e`
- Verify DATABASE_URL_TEST is configured

### Auth Secret Errors

```
Error: BETTER_AUTH_SECRET is required
```
- Run `bun run auth:secret` and copy output to `.env`
- Ensure no quotes around the secret value

### Type Errors After Schema Changes

```
Error: Property 'x' does not exist
```
- Run `bun run db:generate` to sync types
- Restart TypeScript server in editor

### Vercel Deployment Failures

```
Error: DATABASE_URL not found
```
- Run `bun run deploy:env` to configure Vercel env vars
- Or manually set in Vercel dashboard → Settings → Environment Variables
