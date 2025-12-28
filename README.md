# Next Fullstack Template

[![CI](https://github.com/Enriquefft/next-fullstack-template/actions/workflows/ci.yml/badge.svg)](https://github.com/Enriquefft/next-fullstack-template/actions/workflows/ci.yml)
[![Security](https://github.com/Enriquefft/next-fullstack-template/actions/workflows/security.yml/badge.svg)](https://github.com/Enriquefft/next-fullstack-template/actions/workflows/security.yml)

A preconfigured Next.js 16 starter for solo devs and small teams. Built with TypeScript, Bun, Tailwind CSS v4, and Drizzle ORM. Includes authentication (Better Auth + Polar payments), WhatsApp integration (Kapso), analytics (PostHog), and production-ready CI/CD.

## Quick Start

**Prerequisites**: [Bun](https://bun.sh), [Neon](https://console.neon.tech) account

```bash
git clone https://github.com/Enriquefft/next-fullstack-template.git my-project
cd my-project
bun install
cp .env.example .env
bun run auth:secret        # Copy output to BETTER_AUTH_SECRET in .env
bun run db:push
bun dev
```

Visit http://localhost:3000

## Features

- **Framework**: Next.js 16 (App Router, Server Components, Server Actions)
- **Database**: Drizzle ORM + Neon Serverless PostgreSQL
- **Auth**: Better Auth with Google OAuth + Polar payments/subscriptions
- **Messaging**: Kapso WhatsApp Business API
- **Analytics**: PostHog
- **UI**: Tailwind CSS v4 + shadcn/ui
- **Testing**: Happy DOM (unit) + Playwright (E2E)
- **Quality**: Biome linting, TypeScript strict mode
- **CI/CD**: GitHub Actions + Vercel auto-deploy

## Commands

| Command | Purpose |
|---------|---------|
| `bun dev` | Start dev server |
| `bun run build` | Production build |
| `bun test` | Unit tests |
| `bun test:e2e` | E2E tests |
| `bun type` | Type check |
| `bun lint` | Lint & format |
| `bun run db:push` | Sync schema (dev) |
| `bun run db:generate` | Generate migrations |
| `bun run db:migrate` | Apply migrations (prod) |
| `bun run db:studio` | Database GUI |
| `bun run auth:gen` | Regenerate auth types |

---

## Setup Guide

### 1. Database Setup

Create a [Neon](https://console.neon.tech) project with 4 branches:

| Branch | Purpose |
|--------|---------|
| `dev` | Local development |
| `test` | E2E tests / CI |
| `staging` | Preview deployments |
| `prod` | Production |

> **Tip**: For small projects, reuse the same connection string for dev/test/staging initially.

Add connection strings to `.env`:

```bash
NEXT_PUBLIC_PROJECT_NAME='my-project'
DATABASE_URL_DEV='postgresql://...'
DATABASE_URL_TEST='postgresql://...'
BETTER_AUTH_SECRET='...'  # from bun run auth:secret
```

### 2. Optional Integrations

**Google OAuth** (if using):
```bash
GOOGLE_CLIENT_ID='...'
GOOGLE_CLIENT_SECRET='...'
```

**Polar Payments** (if using):
```bash
POLAR_ACCESS_TOKEN='...'
POLAR_MODE='sandbox'  # Switch to 'production' before launch
```

**Kapso WhatsApp** (if using):
```bash
KAPSO_API_KEY='...'
KAPSO_PHONE_NUMBER_ID='...'
```

**PostHog Analytics** (if using):
```bash
NEXT_PUBLIC_POSTHOG_KEY='...'
POSTHOG_PROJECT_ID='...'
```

**UploadThing** (if using):
```bash
UPLOADTHING_TOKEN='...'
```

### 3. Repository Setup

```bash
gh auth login
gh repo create my-project --private --source=. --remote=origin
./scripts/setup-new-repo.sh
```

**Branch protection** (optional, recommended for teams):
```bash
./scripts/setup-branch-protection.sh
```

### 4. Deployment

```bash
# Generate migrations for production
bun run db:generate
git add drizzle/ && git commit -m "chore: add migrations"

# Configure secrets
bun run deploy:env  # Interactive setup for Vercel + GitHub

# Deploy
git push origin main
```

---

## Development Workflow

This template uses **spec-driven development** via [GitHub's Spec Kit](https://github.com/github/spec-kit).

**Core cycle**: Specify → Plan → Tasks → Implement

### Template Customization (First Step)

Your first spec should customize the template:

```bash
/speckit.specify An app for automated reminders via whatsapp, start with the project barebones, structure and enough to start developing, review TEMPLATE_CHECKLIST.
```

Then run the workflow:

```bash
/init-brand         # Create project branding
/speckit.plan       # Generate technical plan
/speckit.tasks      # Break into tasks
/speckit.implement  # Execute
```

Use `TEMPLATE_CHECKLIST.md` as your guide. Delete it when done.

### Building Features

For each new feature:

```bash
/speckit.specify User can sign up with email and verify their account
/design
/speckit.plan
/speckit.tasks
/speckit.implement
```

### Speckit Commands

| Command | Purpose |
|---------|---------|
| `/speckit.specify` | Create feature spec from natural language |
| `/speckit.plan` | Generate technical architecture |
| `/speckit.tasks` | Break down into ordered tasks |
| `/speckit.implement` | Execute implementation |
| `/speckit.clarify` | Resolve ambiguities |
| `/speckit.analyze` | Validate consistency |
| `/speckit.checklist` | Generate quality checklists |
| `/speckit.constitution` | Define project principles (teams) |

### Quality Checks

```bash
bun lint && bun type && bun test && bun test:e2e && bun run build
```

---

## Architecture

For detailed patterns, code examples, and conventions, see **[CLAUDE.md](CLAUDE.md)**.

### Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Next.js 16 (App Router) |
| Database | Drizzle ORM + Neon Serverless |
| Auth | Better Auth + Polar |
| Forms | TanStack Form + Zod |
| Styling | Tailwind CSS v4 + shadcn/ui |
| Analytics | PostHog |
| Messaging | Kapso (WhatsApp) |

### Key Patterns

- **Server Components** for data fetching (not API routes)
- **Server Actions** for mutations (not API routes)
- **API Routes** only for webhooks and third-party integrations
- **Namespaced schemas** via `NEXT_PUBLIC_PROJECT_NAME`

### Project Structure

```
src/
├── app/          # Next.js App Router
├── components/   # React components (ui/ for shadcn)
├── db/           # Drizzle schemas
├── lib/          # Utilities (auth, analytics, etc.)
├── env/          # Environment validation
└── hooks/        # Custom React hooks
tests/            # Unit tests
e2e/              # Playwright E2E tests
drizzle/          # Migration files
scripts/          # Setup & automation
```

---

## Troubleshooting

**Database connection errors**:
- Verify `DATABASE_URL_DEV` in `.env`
- Ensure `?sslmode=require` in connection string

**E2E tests failing**:
- Check port 3000: `lsof -i :3000`
- Try custom port: `PORT=3001 bun test:e2e`

**Auth errors**:
- Run `bun run auth:secret` and update `.env`

**Type errors after schema changes**:
- Run `bun run db:generate`
- Restart TypeScript server

**Vercel deployment fails**:
- Run `bun run deploy:env` to configure secrets

---

## Resources

- [CLAUDE.md](CLAUDE.md) - Architecture patterns & code conventions
- [GitHub Spec Kit](https://github.com/github/spec-kit) - Spec-driven development

## Contributing

```bash
bun install
bun lint && bun type && bun test && bun test:e2e
```

## License

MIT License. See `LICENSE-MIT`.
