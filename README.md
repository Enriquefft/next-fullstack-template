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

Your first feature should customize the template to your needs.

**Run brand setup first** (recommended for UI-based templates):

```bash
# 1. Configure your brand (one-time setup)
/speckit.brand
```

This establishes your visual identity before building UI. Skip it only if your template customization is purely backend (you can run it later).

**Then customize the template**:

```bash
# 2. Specify what you're building
/speckit.specify An app for automated reminders via WhatsApp, start with the project structure and enough to start developing
```

This creates:
- Feature branch: `001-project-setup`
- Specification: `.specify/specs/001-project-setup/spec.md`
- Quality checklist for requirements validation

**Complete the workflow**:

```bash
# 3. Execute the specification
/speckit.plan       # Generate technical plan and architecture decisions
/speckit.tasks      # Break down into dependency-ordered tasks
/speckit.implement  # Execute tasks phase-by-phase
```

Use `TEMPLATE_CHECKLIST.md` as your guide. Delete optional integrations you don't need, then delete the checklist.

---

### 3. Building Features

For each new feature, follow the complete workflow:

#### Example: User Authentication Feature

**Step 1: Specify the feature**
```bash
/speckit.specify User can sign up with email, verify their account, and reset password
```

Creates:
- Feature branch: `002-user-auth`
- Spec file with user stories, requirements, and **UI Specifications** section
- Clarification questions if requirements are ambiguous

**Step 2: Design the UI** (if feature has interface)
```bash
/speckit.design
```

Automatically:
- Parses `spec.md` UI Specifications section
- Recommends shadcn/ui components (Table, Dialog, Button, etc.)
- Generates copy-paste JSX code structures
- Creates `design.md` with component layouts, accessibility checklist, responsive behavior
- Generates Figma visual designs (requires Figma MCP - see setup docs, graceful fallback to docs-only if unavailable)

**Example output**:
```markdown
design.md includes:
- Screen 1: Sign Up Form (Dialog with Input, Label, Button)
- Screen 2: Verification Page (Card with Alert, Button)
- Screen 3: Password Reset (Sheet with multi-step form)
- Components to install: npx shadcn@latest add dialog input label button alert card sheet
- Accessibility: Keyboard navigation, ARIA labels, WCAG AA contrast ✓
```

**Refine design**:
```bash
/speckit.design refine Use Sheet instead of Dialog for sign up form
```

**Step 3: Generate technical plan**
```bash
/speckit.plan
```

Creates:
- Architecture decisions
- File structure
- Database schema (if needed)
- API contracts (if needed)
- **Design integration section** (references design.md components)
- Technology stack choices

**Step 4: Break down into tasks**
```bash
/speckit.tasks
```

Generates:
- Dependency-ordered tasks
- Phase 1: Setup (infrastructure)
- Phase 2: Foundational (blocking prerequisites)
- Phase 3+: User story phases (P1, P2, P3 - independently implementable)
- Phase N: Polish (cross-cutting concerns)

**Step 5: Implement**
```bash
/speckit.implement
```

Executes:
- Tasks phase-by-phase
- Uses JSX structures from `design.md` for UI components
- Installs required shadcn/ui components
- Marks completed tasks with [X]
- Reports progress and errors

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

#### Quick Feature (No UI)

For backend-only features:
```bash
/speckit.specify Add rate limiting to API endpoints
/speckit.plan
/speckit.tasks
/speckit.implement
```

#### UI-Heavy Feature

For features with complex interfaces:
```bash
/speckit.specify Dashboard for analytics with charts and filters
/speckit.design    # Essential - generates component structures
/speckit.plan      # References design.md components
/speckit.tasks     # Includes UI component implementation tasks
/speckit.implement
```

#### Iterative Design

Refine designs before implementation:
```bash
/speckit.specify Team management interface
/speckit.design
# Review design.md, make adjustments
/speckit.design refine Use card grid instead of table
/speckit.design refine Add dark mode toggle to header
# Once satisfied:
/speckit.plan
/speckit.tasks
/speckit.implement
```

#### Quality-First Feature

Add validation checkpoints:
```bash
/speckit.specify Payment processing with Stripe
/speckit.plan
/speckit.tasks
/speckit.analyze    # Validate consistency before coding
/speckit.checklist  # Generate security checklist
# Review findings, update spec/plan if issues found
/speckit.implement
```

---

### 6. Design System Integration

This template enforces design consistency through **Constitution Principles** (see `.specify/memory/constitution.md`):

**DS-1: Use shadcn/ui Components First**
- Always use shadcn/ui components over custom implementations
- Extend via `className` prop, don't fork source code

**DS-2: Brand via CSS Variables**
- Use OKLCH color variables from `globals.css`
- Never hardcode colors: `bg-primary` not `bg-blue-500`

**DS-3: Design Before Implementation**
- UI features require `design.md` before coding
- Implementation must match `design.md` structures

**DS-4: Consistent UI Patterns**
- Tables for data lists, Dialog for focused tasks, Sheet for complex forms
- AlertDialog for destructive confirmations, DropdownMenu for row actions

**DS-5: Accessibility by Default**
- Keyboard navigation, visible focus states, WCAG AA contrast
- Semantic HTML, ARIA labels, touch targets ≥ 44px

---

### 7. File Organization

Each feature creates a directory in `specs/`:

```
.specify/
├── specs/
│   ├── 001-project-setup/      # First feature (template customization)
│   │   ├── spec.md
│   │   ├── plan.md
│   │   └── tasks.md
│   └── 002-user-auth/          # Subsequent features
│       ├── spec.md             # Feature specification (from /speckit.specify)
│       ├── design.md           # UI component designs (from /speckit.design)
│       ├── plan.md             # Technical architecture (from /speckit.plan)
│       ├── tasks.md            # Implementation tasks (from /speckit.tasks)
│       ├── research.md         # Technical research (from /speckit.plan Phase 0)
│       ├── data-model.md       # Entity definitions (from /speckit.plan Phase 1)
│       ├── contracts/          # API contracts (from /speckit.plan Phase 1)
│       │   └── auth-endpoints.yaml
│       └── checklists/         # Quality checklists (from /speckit.checklist)
│           ├── requirements.md
│           ├── security.md
│           └── ux.md
├── brand/
│   └── brand.yaml              # Brand configuration (from /speckit.brand)
├── templates/                  # Speckit templates
├── scripts/                    # Speckit bash scripts
└── memory/
    └── constitution.md         # Project principles (from /speckit.constitution)
```

---

### 8. Figma Integration (Optional)

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

### 9. Best Practices

**Configure brand first**: Run `/speckit.brand` once at project start before building UI features. This establishes your visual identity and ensures all components use consistent colors.

**Start with spec**: Don't code before `/speckit.specify`. Clarify requirements first to avoid rework.

**Design UI features**: Run `/speckit.design` for any feature with user interface. It saves development time and ensures consistency. The generated JSX structures are copy-paste ready.

**Validate before implementing**: Use `/speckit.analyze` as quality gate before `/speckit.implement`. Catch inconsistencies early.

**Iterate on design**: Run `/speckit.design refine` multiple times until UI is right. Cheaper than refactoring code later.

**Independent user stories**: Each P1/P2/P3 story should be independently testable. Implement P1 for MVP, then add P2/P3 incrementally without breaking existing features.

**Update brand thoughtfully**: Changing brand colors affects all components. Test dark mode, verify WCAG contrast ratios, and review across all screens before committing.

---

### 10. Troubleshooting

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

### 11. Additional Resources

- **Spec Kit Docs**: [github.com/github/spec-kit](https://github.com/github/spec-kit)
- **shadcn/ui Components**: [ui.shadcn.com](https://ui.shadcn.com)
- **Tailwind CSS**: [tailwindcss.com](https://tailwindcss.com)
- **OKLCH Colors**: [oklch.com](https://oklch.com)
- **WCAG Guidelines**: [w3.org/WAI/WCAG22/quickref/](https://www.w3.org/WAI/WCAG22/quickref/)

---

### Quick Reference Card

```bash
# First time setup
/speckit.brand                          # Configure theme

# Every feature
/speckit.specify [description]          # Create spec
/speckit.design                         # Design UI (if needed)
/speckit.plan                           # Technical plan
/speckit.tasks                          # Break down tasks
/speckit.implement                      # Build it

# Support commands
/speckit.clarify                        # Resolve ambiguities
/speckit.analyze                        # Validate consistency
/speckit.checklist                      # Generate quality checklists
/speckit.constitution                   # Define project principles

# Refinement
/speckit.design refine [changes]        # Adjust UI design
/speckit.brand update [description]     # Tweak brand colors

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
