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

👉 [Complete Development Process guide](#development-process)

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

## Development Process

This template uses **spec-driven development**, inspired by [GitHub's Spec Kit](https://github.com/github/spec-kit). Specifications guide implementation—not the other way around.

**Core workflow**: Specify → Plan → Tasks → Implement

Each phase includes quality gates and validation to ensure your implementation matches your specification.

---

### Prerequisites

Before starting, install:
- **Bun** (https://bun.sh) - Package manager and runtime
- **GitHub CLI** (https://cli.github.com) - For repository setup
- **Vercel CLI** (optional) - For deployment (`bun add -g vercel`)

Create accounts:
- **GitHub** - For repository hosting
- **Neon** (https://console.neon.tech) - For PostgreSQL databases
- **Vercel** (optional) - For deployment

---

### Phase 1: Initial Setup

#### 1. Clone and Install
```bash
git clone https://github.com/Enriquefft/next-fullstack-template.git my-project
cd my-project
bun install
```

#### 2. Create Database Branches

Go to [Neon Console](https://console.neon.tech) and create **4 database branches**:

1. Create a new project (or use existing)
2. Create branches from `main`:
   - `dev` - Local development
   - `test` - E2E tests and CI
   - `staging` - Staging environment (optional)
   - `prod` - Production

3. Copy connection string for each branch

**Why 4 databases?** Isolate data per environment. Tests shouldn't touch dev data.

#### 3. Configure Environment
```bash
cp .env.example .env
```

Edit `.env` and add:
```bash
NEXT_PUBLIC_PROJECT_NAME='my-project'

# Database URLs from Neon
DATABASE_URL_DEV='postgresql://...'    # From dev branch
DATABASE_URL_TEST='postgresql://...'   # From test branch

# Generate this in next step
BETTER_AUTH_SECRET='...'
```

See [ENVIRONMENT.md](docs/ENVIRONMENT.md) for complete variable reference.

#### 4. Generate Auth Secret
```bash
bun run auth:secret
```
Copy output to `BETTER_AUTH_SECRET` in `.env`

#### 5. Initialize Database
```bash
bun run db:push
```
This creates initial tables (auth, example post) in your dev database.

#### 6. Verify Local Setup
```bash
bun dev              # Start dev server
bun test             # Run unit tests
bun run test:e2e     # Run E2E tests
bun type             # Type check
bun lint             # Lint & format
```

Visit http://localhost:3000 to verify.

---

### Phase 2: Repository Setup

#### 7. Create GitHub Repository
```bash
# Authenticate GitHub CLI
gh auth login

# Create repository
gh repo create my-project --private --source=. --remote=origin

# Or link existing repo:
# git remote add origin https://github.com/username/my-project.git
```

#### 8. Run One-Time Repository Setup
```bash
./scripts/setup-new-repo.sh
```

This script:
- Disables default CodeQL (we use custom workflow)
- Creates `.repo-setup-complete` marker
- Optionally self-deletes after completion

#### 9. Configure Branch Protection (Optional but Recommended)
```bash
./scripts/setup-branch-protection.sh
```

Sets up `main` branch rules:
- Require PR reviews (1 approval)
- Require status checks (tests, lint, build, CodeQL)
- Prevent force pushes
- Prevent deletions

---

### Phase 3: Spec-Driven Development ⭐

**This is the core workflow for ALL feature development**, including initial template customization.

#### Understanding Spec-Driven Development

Spec-driven development ensures:
- **Clarity**: Requirements are explicit before coding
- **Quality**: Built-in validation at each phase
- **Traceability**: Every line of code traces to a requirement
- **AI Compatibility**: Structured specs enable AI-assisted implementation

The workflow has 4 phases, powered by `/speckit.*` commands:

---

#### Step 1: Define Project Principles (Optional)

For team projects or complex applications, define your "constitution":

```bash
# In Claude Code:
/speckit.constitution Create principles focused on test-driven development, minimal dependencies, type safety, and accessibility
```

This creates `.specify/memory/constitution.md` with non-negotiable rules that gate all future development.

**When to use**:
- Team projects (alignment on standards)
- Complex applications (architectural discipline)
- Regulated industries (compliance requirements)

**When to skip**:
- Solo projects
- Simple applications
- Prototypes

---

#### Step 2: Specify Your First Feature

**For template users, your FIRST spec is template customization.**

```bash
# In Claude Code:
/speckit.specify Initialize template: keep Better Auth with email/password only, remove Polar payments, keep PostHog analytics, remove Kapso messaging, update project name to "My SaaS App"
```

This creates:
- Branch: `0-template-init`
- File: `.specify/specs/0-template-init/spec.md`
- Checklist: `.specify/specs/0-template-init/checklists/requirements.md`

The spec will include user stories like:
- Configure project identity (package.json, metadata)
- Configure authentication methods
- Remove unused integrations
- Update environment variables
- Clean database schema

**Review the generated spec** to ensure it captures your needs.

---

#### Step 3: Get Environment Variables Ready

Before implementing, gather ALL required environment variables:

```bash
# Review .env.example for what's needed
cat .env.example

# Edit .env with actual values
nano .env
```

**Required variables** (based on what you're keeping):
- `NEXT_PUBLIC_PROJECT_NAME` - Project name
- `DATABASE_URL_DEV` - Neon dev branch
- `DATABASE_URL_TEST` - Neon test branch
- `BETTER_AUTH_SECRET` - Already generated
- `GOOGLE_CLIENT_ID` + `GOOGLE_CLIENT_SECRET` - If using OAuth
- `POSTHOG_API_KEY` + `POSTHOG_HOST` - If using PostHog
- Other integration tokens as needed

See [ENVIRONMENT.md](docs/ENVIRONMENT.md) for complete list.

---

#### Step 4: Transform Template into Your Project

**Use TEMPLATE_CHECKLIST.md as your implementation guide.**

The checklist covers 14 transformation areas:
1. Project identity (names, descriptions)
2. Authentication configuration
3. Payment integration
4. Analytics setup
5. Database schema cleanup
6. UI component cleanup
7. Remove unused integrations
8. Environment variable cleanup
9. Dependency cleanup
10. SEO/metadata updates
11. Documentation updates
12. Testing configuration
13. Git/CI-CD verification
14. Delete checklist when done

**Generate implementation plan**:
```bash
/speckit.plan
```

This creates:
- `plan.md` - Technical approach
- `research.md` - Decisions and rationale
- `data-model.md` - Database changes
- `quickstart.md` - Integration scenarios

**Review the plan** to verify the technical approach aligns with your needs.

**Generate tasks**:
```bash
/speckit.tasks
```

This creates `tasks.md` with dependency-ordered, parallelizable tasks organized by user story.

**Execute implementation**:
```bash
/speckit.implement
```

This:
1. Validates checklists are complete
2. Executes tasks phase-by-phase
3. Updates package.json, removes files, cleans dependencies
4. Updates CLAUDE.md to match actual project state
5. Runs tests to verify nothing broke

**Verify transformation**:
```bash
bun run build    # Must succeed
bun test         # Must pass
bun type         # No errors
bun lint         # No errors
bun dev          # Runs without errors
```

**Delete TEMPLATE_CHECKLIST.md** - transformation complete!

---

#### Step 5: Build Your First Real Feature

Now that the template is customized, build your first feature:

```bash
/speckit.specify User can sign up with email and password, receive verification email, and verify their account
```

This creates `1-user-signup` branch and spec.

**Then run the same workflow**:
```bash
/speckit.plan      # Technical architecture
/speckit.tasks     # Task breakdown
/speckit.implement # Execute implementation
```

**For every new feature**, repeat this cycle.

---

#### Spec-Driven Best Practices

**When writing specs** (`/speckit.specify`):
- Focus on WHAT users need and WHY (not technical HOW)
- Use natural language
- Be specific about edge cases
- Include acceptance criteria

**When planning** (`/speckit.plan`):
- Provide tech stack details when asked
- Reference existing patterns in codebase
- Document architectural decisions

**When implementing** (`/speckit.implement`):
- Run tests frequently
- Commit working increments
- Update docs if APIs change

**Additional commands**:
- `/speckit.clarify` - Resolve spec ambiguities
- `/speckit.analyze` - Validate consistency across spec/plan/tasks
- `/speckit.checklist` - Generate domain-specific quality checklists
- `/speckit.taskstoissues` - Convert tasks to GitHub issues

---

### Phase 4: Deployment Configuration

#### 10. Generate Database Migrations

**Important**: Production uses migrations, not `db:push`.

```bash
bun run db:generate
```

This creates versioned SQL files in `drizzle/` directory.

**Review migrations**:
```bash
ls drizzle/
cat drizzle/0000_initial.sql  # Review SQL
```

**Commit migrations**:
```bash
git add drizzle/
git commit -m "chore: add database migrations"
```

#### 11. Setup Deployment Environment

**Unified setup (recommended)**:
```bash
bun run deploy:env
```

Choose:
1. Both Vercel + GitHub
2. Vercel only
3. GitHub only

**Or setup separately**:
```bash
bun run deploy:github  # GitHub Actions secrets
bun run deploy:vercel  # Vercel environment + Git integration
```

Required CLIs:
- `gh auth login` (GitHub)
- `vercel login && vercel link` (Vercel)

This configures:
- GitHub: `DATABASE_URL_TEST`, `BETTER_AUTH_SECRET`, OAuth secrets
- Vercel: `DATABASE_URL` (prod + preview), all service tokens
- Git integration: Auto-deploy on push

#### 12. Deploy to Production
```bash
# First push
git push origin main
```

This triggers:
- **GitHub Actions**: Runs tests, linting, security scans
- **Vercel**: Runs `db:migrate`, builds, deploys to production

Visit your Vercel dashboard for deployment URL.

---

### Phase 5: Ongoing Development

For each new feature:

1. **Specify**: `/speckit.specify` - Create spec from natural language
2. **Plan**: `/speckit.plan` - Generate technical plan
3. **Tasks**: `/speckit.tasks` - Break down into tasks
4. **Implement**: `/speckit.implement` - Execute implementation
5. **Test**: `bun test && bun run test:e2e`
6. **Deploy**: `git push origin main`

**Quality checks before merging**:
```bash
bun lint          # Lint & format
bun type          # Type check
bun test          # Unit tests
bun run test:e2e  # E2E tests
bun run build     # Production build
```

**Branch protection** ensures these checks pass in CI before merge.

---

### Resources

- 📘 [Architecture & Patterns](CLAUDE.md)
- 🔧 [Environment Variables](docs/ENVIRONMENT.md)
- 🚢 [CI/CD Setup](docs/DEPLOYMENT.md)
- 🎯 [GitHub Spec Kit](https://github.com/github/spec-kit)
- 📖 [Spec-Driven Development Guide](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)

## Architecture & Development

**For detailed architecture and patterns, see [CLAUDE.md](CLAUDE.md)**

This template uses:
- **Database**: Multi-environment PostgreSQL via Neon Serverless
- **Auth**: Better Auth with Google OAuth and Drizzle adapter
- **Forms**: TanStack Form with Zod validation
- **Styling**: Tailwind CSS v4 with shadcn/ui components
- **Testing**: Happy DOM (unit tests) + Playwright (E2E tests)
- **State Management**: Server Components and Server Actions (preferred over API routes)

**Development Workflow**: This template uses the **speckit** workflow for feature development. Each feature goes through: spec → plan → tasks → implement. See [Development Process](#development-process) above for complete setup and workflow guide.

**Documentation:**
- 📘 [CLAUDE.md](CLAUDE.md) - Architecture, patterns, and development guidelines
- 🔧 [Environment Variables](docs/ENVIRONMENT.md) - Complete environment variable reference
- 🚢 [Deployment & CI/CD](docs/DEPLOYMENT.md) - Full CI/CD setup, GitHub secrets, Vercel config
- 🤖 [Automation Scripts](scripts/README.md) - codebase_ops.sh documentation

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
