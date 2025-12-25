# Next Fullstack Template

[![CI](https://github.com/Enriquefft/next-fullstack-template/actions/workflows/ci.yml/badge.svg)](https://github.com/Enriquefft/next-fullstack-template/actions/workflows/ci.yml)
[![Security](https://github.com/Enriquefft/next-fullstack-template/actions/workflows/security.yml/badge.svg)](https://github.com/Enriquefft/next-fullstack-template/actions/workflows/security.yml)

A preconfigured Next.js starter built with TypeScript, Bun, Tailwind CSS and
Drizzle ORM. It includes Better Auth, shadcn/ui, PostHog analytics, production-ready CI/CD, and a basic Nix flake for development.

## Quick Start

**Prerequisites**: [Bun](https://bun.sh), [Neon](https://console.neon.tech) account

**5-Minute Setup:**

1. Clone and install: `git clone https://github.com/Enriquefft/next-fullstack-template.git my-project && cd my-project && bun install`
2. Create 4 Neon database branches (dev, test, staging, prod) - copy connection strings
3. Copy `.env.example` to `.env` and add database URLs
4. Generate auth secret: `bun run auth:secret` (copy to `.env`)
5. Run migrations: `bun run db:push`
6. Start dev server: `bun dev`

Visit http://localhost:3000

👉 [Full setup with optional features](#getting-started)

## Features

- Next.js 16 with the App Router
- Bun package manager and runtime
- Tailwind CSS with shadcn/ui components
- Drizzle ORM for PostgreSQL (Neon Serverless)
- Authentication powered by Better Auth
- PostHog analytics integration
- Unit tests with Happy DOM and Testing Library
- E2E tests with Playwright
- Biome linting and formatting
- Production-ready CI/CD with GitHub Actions
- Automated security scanning
- Multi-environment deployment

## Core Commands

- `bun dev` – Start development server
- `bun run build` – Build for production
- `bun lint` – Lint and format code
- `bun test` – Run unit tests
- `bun run test:e2e` – Run E2E tests
- `bun type` – Type-check without emitting
- `bun run db:push` – Push schema changes
- `bun run db:studio` – Open Drizzle Studio

## CI/CD Pipeline

This template includes a comprehensive GitHub Actions CI/CD pipeline optimized for Bun + Next.js + Vercel:

**GitHub Actions:**
- **CI Workflow** - Quality checks, unit tests, E2E tests, build verification
- **Security Workflow** - Dependency scanning, CodeQL analysis, secrets detection, SBOM generation

**Vercel Deployments:**
- **Preview** - Automatic preview for every PR
- **Production** - Auto-deploy on merge to `main`
- **Staging** - Auto-deploy on merge to `staging` (optional)

**Setup:** Configure GitHub secrets and Vercel environment variables for automated deployments.

👉 **[Full CI/CD setup guide](docs/DEPLOYMENT.md)** - GitHub secrets, Vercel config, branch protection, deployment flow

## Getting Started

### Prerequisites

1. **Install Bun**: Visit <https://bun.sh> for installation instructions
2. **GitHub CLI** (optional): For automated setup scripts - <https://cli.github.com>
3. **Neon Account**: For PostgreSQL databases - <https://console.neon.tech>

### Setup Steps

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

**3. Create Neon Database Branches** ⚠️ **REQUIRED!**

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

See [docs/ENVIRONMENT.md](docs/ENVIRONMENT.md) for complete variable reference.

**5. Generate Auth Secret**

```bash
bun run auth:secret
```

Copy the output to `BETTER_AUTH_SECRET` in your `.env` file.

**6. Run Database Migrations**

```bash
bun run db:push
```

**7. Install Git Hooks** (optional but recommended)

```bash
bunx lefthook install
```

**8. Start Development**

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

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for complete setup instructions.

## Architecture & Development

**For detailed architecture, patterns, and development workflow, see [CLAUDE.md](CLAUDE.md)**

This template uses:
- **Database**: Multi-environment PostgreSQL via Neon Serverless
- **Auth**: Better Auth with Google OAuth and Drizzle adapter
- **Forms**: TanStack Form with Zod validation
- **Styling**: Tailwind CSS v4 with shadcn/ui components
- **Testing**: Happy DOM (unit tests) + Playwright (E2E tests)
- **State Management**: Server Components and Server Actions (preferred over API routes)

**Development Workflow**: This template supports PRD-based development with `/implement-prd` and `/next-step` commands in Claude Code. See [CLAUDE.md](CLAUDE.md) for the complete workflow guide.

## Automated Operations

**`scripts/codebase_ops.sh`** - AI-powered script for parallel bug fixing and code improvements.

Quick commands:
- `./scripts/codebase_ops.sh --dry-run` - Preview what would be fixed
- `./scripts/codebase_ops.sh --since main` - Fix only files changed in your PR
- `./scripts/codebase_ops.sh undo` - Rollback last operation

**VSCode Integration:** Run tasks directly from VSCode with keyboard shortcuts:
- `Ctrl+Shift+F` - Fix changed files (most common workflow)
- `Ctrl+Shift+D` - Preview issues (dry run)
- `Ctrl+Shift+U` - Undo last operation

**Analytics & History:** Track your automation impact:
- `./scripts/codebase_ops.sh stats` - View statistics (operations, time saved, success rate)
- `./scripts/codebase_ops.sh history` - List recent operations
- `./scripts/codebase_ops.sh export json` - Export stats for analysis
- `./scripts/codebase_ops.sh export csv` - Export operation history

See [`.vscode/README.md`](.vscode/README.md) for all tasks and shortcuts, or [scripts/README.md](scripts/README.md) for full script documentation.

## Documentation

- 📘 [CLAUDE.md](CLAUDE.md) - Architecture, patterns, PRD workflow (for developers using Claude Code)
- 🚀 [Deployment & CI/CD](docs/DEPLOYMENT.md) - Full CI/CD setup, GitHub secrets, Vercel config
- 🤖 [Automation Scripts](scripts/README.md) - codebase_ops.sh documentation
- 🔧 [Environment Variables](docs/ENVIRONMENT.md) - Complete environment variable reference

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
