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
# Link project to Vercel
vercel link

# Configure secrets and connect Git repository
bun run deploy:env  # Interactive setup - connects GitHub, configures Vercel & GitHub secrets

# Generate migrations for production
bun run db:generate
git add drizzle/ && git commit -m "chore: add migrations"

# Deploy (triggers automatic deployment on Vercel)
git push origin main
```

**What `bun run deploy:env` does:**
- Checks if Vercel CLI is installed and authenticated
- Verifies project is linked to Vercel (`vercel link`)
- **Automatically connects your GitHub repository** for auto-deploy (or prompts you to connect)
- Configures environment variables on both Vercel and GitHub Actions
- Guides you through required secrets (DATABASE_URL, BETTER_AUTH_SECRET, etc.)

---

## Development Workflow

This template uses **spec-driven development** via [GitHub's Spec Kit](https://github.com/github/spec-kit) extended with UI/UX design commands.

### Overview

```
/speckit.brand (once) → Configure theme & brand colors
    ↓
/speckit.specify → Create feature specification
    ↓
/speckit.design → Generate UI component designs (for UI features)
    ↓
/speckit.plan → Generate technical architecture
    ↓
/speckit.tasks → Break down into ordered tasks
    ↓
/speckit.implement → Execute implementation
```

---

### 1. Initial Setup: Configure Your Brand

**Run once per project** to establish your application's visual identity:

```bash
/speckit.brand
```

This command:
- Detects current theme from `src/styles/globals.css`
- Offers personality-based color suggestions (Professional, Friendly, Playful, etc.)
- Provides 9 preset themes (Zinc, Slate, Stone, Red, Blue, etc.)
- Updates CSS variables with OKLCH colors (perceptually uniform, better accessibility)
- Saves configuration to `.specify/brand/brand.yaml`

**Example interaction**:
```
Choose personality: Professional + Friendly
Suggested primary: #2563EB (trustworthy blue)
Apply? Yes
✓ Brand updated - all shadcn/ui components now use your colors
```

**Update existing brand**:
```bash
/speckit.brand update Make it more playful and vibrant
```

---

### 2. Template Customization (First Feature)

Your first feature should customize the template to your needs. Use `TEMPLATE_CHECKLIST.md` as your guide.

```bash
/speckit.specify An app for automated reminders via WhatsApp, start with the project structure and enough to start developing
/speckit.plan       # Generate technical plan and architecture decisions
/speckit.tasks      # Break down into dependency-ordered tasks
/speckit.implement  # Execute tasks phase-by-phase
```

This creates:
- Feature branch: `001-project-setup`
- Specification: `.specify/specs/001-project-setup/spec.md`
- Quality checklist for requirements validation

Delete optional integrations you don't need, then delete the checklist.

---

### 3. Building Features

For each new feature, follow this workflow:

```bash
/speckit.specify [description]  # Create spec with user stories, requirements
/speckit.design                 # Generate UI designs (optional, for UI features)
/speckit.plan                   # Generate technical architecture
/speckit.tasks                  # Break down into dependency-ordered tasks
/speckit.implement              # Execute implementation
```

**What each command generates:**

**`/speckit.specify`** creates:
- Feature branch (e.g., `002-user-auth`)
- Spec file with user stories, requirements, UI Specifications section
- Clarification questions if requirements are ambiguous

**`/speckit.design`** (optional, for UI features) creates:
- Component recommendations (Table, Dialog, Button, etc.)
- Copy-paste JSX code structures
- Accessibility checklist (keyboard navigation, ARIA labels, WCAG AA contrast)
- Responsive behavior specifications
- Figma visual designs (requires Figma MCP, graceful fallback to docs-only)

Refine designs iteratively:
```bash
/speckit.design refine Use Sheet instead of Dialog for sign up form
```

**`/speckit.plan`** creates:
- Architecture decisions, file structure, database schema
- API contracts, technology stack choices
- Design integration section (references design.md components)

**`/speckit.tasks`** generates:
- Phase 1: Setup (infrastructure)
- Phase 2: Foundational (blocking prerequisites)
- Phase 3+: User story phases (P1, P2, P3 - independently implementable)
- Phase N: Polish (cross-cutting concerns)

**`/speckit.implement`** executes:
- Tasks phase-by-phase
- Installs required shadcn/ui components
- Marks completed tasks with [X]

---

### 4. Speckit Commands Reference

#### Core Workflow

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/speckit.brand` | Configure theme colors (OKLCH) | Once per project, or when updating brand |
| `/speckit.specify` | Create feature spec from natural language | Start of every feature |
| `/speckit.design` | Generate UI component designs | After specify, for UI features only |
| `/speckit.plan` | Generate technical architecture | After specify/design, before tasks |
| `/speckit.tasks` | Break plan into ordered tasks | After plan, before implement |
| `/speckit.implement` | Execute implementation | After tasks, to build the feature |

#### Support Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/speckit.clarify` | Resolve ambiguous requirements | When spec has unclear areas |
| `/speckit.analyze` | Validate spec ↔ plan ↔ tasks consistency | Before implement, quality gate |
| `/speckit.checklist` | Generate domain-specific validation checklist | For complex features (UX, security, performance) |
| `/speckit.constitution` | Define project principles and governance | Project setup, when adding standards |
| `/speckit.taskstoissues` | Convert tasks to GitHub issues | When using GitHub project boards |

---

### 5. Workflow Variations

**Backend-only features**: Skip `/speckit.design`

**UI-heavy features**: Run `/speckit.design` between specify and plan

**Iterative design**: Use `/speckit.design refine [changes]` multiple times before planning

**Quality-first features**: Add `/speckit.analyze` and `/speckit.checklist` between tasks and implement

---

### 6. Figma Integration (Optional)

`/speckit.design` can generate visual Figma designs with **Figma MCP** integration.

**Setup**: See `.claude/docs/figma-mcp-setup.md`

**With Figma MCP**:
- Automatically creates Figma file for each feature
- Generates frames for each screen from spec
- Applies brand colors from `.specify/brand/brand.yaml`
- Links Figma URL in `design.md`

**Without Figma MCP**:
- Still generates comprehensive `design.md` documentation
- Includes JSX code structures and component recommendations
- Figma URL shows as "N/A"

---

### 7. Best Practices

- **Clarify before coding**: Always specify requirements before implementation to avoid rework
- **Design for UI features**: Use `/speckit.design` for interfaces - generated JSX structures are copy-paste ready
- **Validate early**: Run `/speckit.analyze` before implementation to catch inconsistencies
- **Iterate on design**: Refine designs before coding - cheaper than refactoring later
- **Independent user stories**: P1/P2/P3 phases should be independently testable and deployable
- **Update brand thoughtfully**: Test dark mode and WCAG contrast ratios before committing color changes

---

### 8. Troubleshooting

**"No UI Specifications section"** when running `/speckit.design`:
- Update spec: `/speckit.specify update Add UI requirements for user list screen`
- Or manually add UI Specifications section to `spec.md`

**Figma MCP not connected**:
- See `.claude/docs/figma-mcp-setup.md` for setup instructions
- Or continue without Figma (documentation-only mode)

**WCAG contrast warnings** during branding:
- Choose lighter/darker shade for better accessibility
- Use `/speckit.brand update` to adjust colors
- Test with browser dev tools accessibility inspector

**Design doesn't match implementation**:
- Ensure `design.md` was referenced during `/speckit.plan`
- Check tasks in `tasks.md` include file paths from `design.md`
- Update `design.md` if requirements changed: `/speckit.design refine`

---

### 9. Resources

- **Spec Kit Docs**: [github.com/github/spec-kit](https://github.com/github/spec-kit)
- **shadcn/ui Components**: [ui.shadcn.com](https://ui.shadcn.com)
- **Tailwind CSS**: [tailwindcss.com](https://tailwindcss.com)
- **OKLCH Colors**: [oklch.com](https://oklch.com)
- **WCAG Guidelines**: [w3.org/WAI/WCAG22/quickref/](https://www.w3.org/WAI/WCAG22/quickref/)

---

### Quick Reference

```bash
# First time setup
/speckit.brand                          # Configure theme (once)

# Every feature
/speckit.specify [description]          # Create spec
/speckit.design                         # Design UI (optional, for UI features)
/speckit.plan                           # Technical plan
/speckit.tasks                          # Break down tasks
/speckit.implement                      # Build it

# Quality checks before commit
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
.specify/         # Spec-driven development artifacts
├── specs/        # Feature specifications, plans, tasks
├── brand/        # Brand configuration (brand.yaml)
└── memory/       # Project principles (constitution.md)
```

### Design System Principles

This template enforces consistency through **Constitution Principles** (see `.specify/memory/constitution.md`):

- **DS-1: Use shadcn/ui Components First** - Always use shadcn/ui over custom implementations; extend via `className`, don't fork source
- **DS-2: Brand via CSS Variables** - Use OKLCH color variables from `globals.css`; never hardcode colors (`bg-primary` not `bg-blue-500`)
- **DS-3: Design Before Implementation** - UI features require `design.md` before coding; implementation must match design specs
- **DS-4: Consistent UI Patterns** - Tables for data lists, Dialog for focused tasks, Sheet for complex forms, AlertDialog for destructive confirmations
- **DS-5: Accessibility by Default** - Keyboard navigation, visible focus states, WCAG AA contrast, semantic HTML, ARIA labels, touch targets ≥ 44px

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
bun lint && bun type && bun test && bun test:e2e && bun run build
```

## License

MIT License. See `LICENSE-MIT`.
