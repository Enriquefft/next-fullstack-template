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
DATABASE_URL_STAGING='postgresql://user:pass@ep-xxx.region.aws.neon.tech/neondb?sslmode=require'
DATABASE_URL_PROD='postgresql://user:pass@ep-xxx.region.aws.neon.tech/neondb?sslmode=require'

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
./scripts/setup-env.sh
```

**Interactive prompts will ask for:**

| Category | Variables |
|----------|-----------|
| Database | `DATABASE_URL` (for Vercel production/preview) |
| Authentication | `BETTER_AUTH_SECRET`, `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` |
| Third-party | `NEXT_PUBLIC_POSTHOG_KEY`, `POLAR_ACCESS_TOKEN`, etc. |
| Project | `NEXT_PUBLIC_PROJECT_NAME` |

**Security features:**
- Interactive prompts (secrets never in shell history)
- Never reads from `.env` directly
- Requires manual paste for each secret
- Supports configuring both platforms with single entry

**Options:**
```bash
# Include Vercel development environment (rarely needed)
./scripts/setup-env.sh --include-vercel-dev

# Or configure platforms separately
./scripts/setup-github-secrets.sh   # GitHub Actions only
./scripts/setup-vercel-env.sh       # Vercel only
```

**Git Integration:**
The script also offers to connect Vercel to your GitHub repo for automatic deployments:
- Push to `main` → deploys to production
- Push to feature branch → creates preview deployment
- Open PR → creates preview deployment with unique URL

---

## Phase 3: PRD-Based Customization

### Step 11: Generate PRD (Product Requirements Document)

**Option A: Use `/discover-prd` in Claude Code (Recommended)**

Run the discovery command for a guided interview:

```
/discover-prd
```

This uses a dual-agent interview approach:
- **🎯 PM Agent**: Explores vision, users, value ("What?", "Why?", "Who?")
- **🔧 ENG Agent**: Challenges assumptions, finds gaps ("How?", "What if?")

The agents alternate, asking 20-40 questions total before generating your PRD. Takes 15-30 minutes but produces highly specific documentation.

**Option B: Use Claude Chat**

Use Claude Chat with the prompts in Appendix A to create a structured PRD.

**PRD Structure:**

```
.claude/prd/
├── 00-overview.md              # Project vision, success metrics, customization notes
├── 01-flows/                   # User flows organized by domain
│   ├── _index.md               # Implementation priorities (ordered list)
│   ├── auth/                   # Authentication flows
│   │   ├── signup-flows.md     # Email signup, OAuth signup
│   │   ├── login-flows.md      # Email login, OAuth login
│   │   └── password-flows.md   # Reset, change password
│   ├── payments/               # Payment flows (if applicable)
│   │   ├── checkout-flows.md
│   │   └── subscription-flows.md
│   └── [feature]/              # Your feature domains
│       └── [feature]-flows.md
├── 02-data-models.md           # Database schema specifications
├── 03-api-design.md            # Server actions and API design
├── 04-ui-components.md         # UI/UX specifications
└── 05-integrations.md          # Third-party services configuration
```

**Key sections in `00-overview.md`:**

```markdown
## Template Customization Notes

### Authentication
- [ ] Email/password
- [ ] Google OAuth
- [ ] Magic links

### Payments
- Payment Provider: [Polar / Stripe / None]
- Subscription Tiers: [Yes / No]

### Analytics
- Provider: [PostHog / None]

### Features to Remove from Template
- [ ] Example `post` schema
- [ ] Polar integration (if not using payments)
- [ ] PostHog integration (if not using analytics)
```

### Step 12: Place PRD in Project

Copy your generated PRD files into the `.claude/prd/` directory:

```bash
# Copy PRD files
cp -r /path/to/your/prd/* .claude/prd/
```

### Step 13: Run `/implement-prd`

In Claude Code, run the slash command:

```
/implement-prd
```

**This command:**

1. **Reads PRD files** in order:
   - `00-overview.md` - Project vision and customization notes
   - `01-flows/_index.md` - Implementation priorities

2. **Creates TodoWrite checklist** with 13 categories:

   | # | Category | Actions |
   |---|----------|---------|
   | 1 | Project Identity | Update package.json, metadata.ts, README |
   | 2 | Authentication | Configure/remove auth providers |
   | 3 | Payments | Configure Polar/Stripe or remove |
   | 4 | Database Schema | Remove example tables, add PRD tables |
   | 5 | UI/Components | Remove unused components, configure theme |
   | 6 | Analytics | Configure PostHog or remove |
   | 7 | API Routes | Remove example routes |
   | 8 | Testing | Update seed data, remove example tests |
   | 9 | Environment | Update .env.example, env validation |
   | 10 | Dependencies | Remove unused, add required packages |
   | 11 | Documentation | Update README, CLAUDE.md |
   | 12 | Git & CI/CD | Verify .gitignore, workflows |
   | 13 | SEO & GEO | Configure metadata, locales, structured data |

3. **Executes each task** - Actually makes the changes (file edits, dependency changes)

4. **Asks clarifying questions** when PRD is ambiguous

5. **Generates `plan.md`** - Implementation roadmap based on PRD priorities

**Output example:**
```
✅ Barebones implementation complete!

Completed:
- Project identity updated (name: my-saas-app)
- Authentication: kept Better Auth + Google OAuth
- Payments: removed Polar integration
- Analytics: kept PostHog
- Dependencies: removed 3, added 2
- Database schema: removed post table, added user preferences

📋 Implementation plan created: plan.md

Next steps:
1. Review plan.md to understand implementation phases
2. Run `/next-step` to begin implementing Phase 1, Step 1
```

---

## Phase 4: Feature Implementation

### Step 14: Implement Features Incrementally

Run `/next-step` repeatedly to implement each feature:

```
/next-step
```

**Each invocation follows this workflow:**

#### A. Verify Plan is Current
```
Reading plan.md...
Reading .claude/prd/01-flows/_index.md...
✅ Plan is up to date with PRD
```

If plan is outdated, Claude asks permission to update it.

#### B. Verify Previous Feature is Tested
```
Checking tests for last completed feature: "User Signup"...
Running `bun test`...
✅ Unit tests passing (12/12)
Running `bun run test:e2e`...
✅ E2E tests passing (4/4 scenarios)
```

If tests are missing or failing:
- Lists specific missing/failing tests
- Offers to write missing tests
- Fixes failing tests before proceeding

#### C. Implement Next Feature
```
✅ Tests verified for: User Signup
✅ Plan is up to date
📋 Next up: User Login

Flow reference: `.claude/prd/01-flows/auth/login-flows.md`

I'll now implement: Email/password login with session management

Tasks for this step:
- [ ] Implement signIn() server action with Zod validation
- [ ] Create SignInForm component
- [ ] Add login page at /login
- [ ] Add unit tests for signIn() action
- [ ] Add E2E tests for login flows
```

**Implementation order (always followed):**

1. **Database Schema** - Tables, relationships, indexes
2. **Server Actions** - Business logic with Zod validation
3. **UI Components** - Forms, pages, layouts
4. **Unit Tests** - Test server actions in isolation
5. **E2E Tests** - Test complete user flows from PRD

#### D. Completion Announcement
```
✅ Feature complete: User Login

Implemented:
- Server Actions: signIn() with email/password validation
- UI Components: SignInForm, /login page
- Unit Tests: tests/actions/auth.test.ts (5 tests added)
- E2E Tests: e2e/tests/auth.spec.ts (5 login scenarios)

All tests passing:
- ✅ Unit tests: bun test
- ✅ E2E tests: bun run test:e2e
- ✅ Type check: bun type
- ✅ Linting: bun lint

Ready for next step. Run `/next-step` again to continue.
```

### Repeat Until Complete

Continue running `/next-step` until all phases in `plan.md` are complete:

```
Phase 1: MVP
├── Step 1.1: User Signup ✅
├── Step 1.2: User Login ✅
├── Step 1.3: User Profile ✅
└── Step 1.4: Dashboard ✅

Phase 2: Enhancement
├── Step 2.1: Settings Page ✅
└── Step 2.2: Notifications ✅

Phase 3: Polish
├── Step 3.1: Error Handling ✅
└── Step 3.2: Performance ✅
```

---

## Phase 5: Deployment

### Step 15: Generate Production Migrations

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

### Step 16: Push and Deploy

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

## Maintenance: Codebase Operations

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
| **Setup** | `./scripts/setup-env.sh` | Configure CI/CD secrets |
| **PRD** | `/implement-prd` | Customize template from PRD |
| **Dev** | `/next-step` | Implement next feature |
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
| `scripts/setup-env.sh` | Unified Vercel + GitHub secrets setup |
| `scripts/setup-github-secrets.sh` | GitHub Actions secrets only |
| `scripts/setup-vercel-env.sh` | Vercel environment only |
| `scripts/codebase_ops.sh` | AI-powered code maintenance |
| `scripts/run-e2e.sh` | E2E test runner with server management |

### Directory Structure

```
├── .claude/
│   ├── commands/           # Slash commands (/implement-prd, /next-step)
│   ├── prd/                # Product requirements documents
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
- Run `./scripts/setup-env.sh` to configure Vercel env vars
- Or manually set in Vercel dashboard → Settings → Environment Variables

---

## Appendix A: PRD Generation Prompts

This section provides a multi-step prompt system for generating a complete, implementation-ready PRD using Claude Chat. The prompts are designed using best practices from prompt engineering research:

- **Layered prompting**: Role + structure + reasoning combined
- **Chain-of-thought**: Step-by-step reasoning for complex decisions
- **Few-shot examples**: Concrete output examples
- **XML tags**: Clear structure boundaries
- **Iterative refinement**: Build the PRD progressively

**Sources**: [Anthropic Prompt Engineering](https://claude.com/blog/best-practices-for-prompt-engineering), [Claude 4 Best Practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices), [OpenAI Guide](https://platform.openai.com/docs/guides/prompt-engineering), [Lakera 2025 Guide](https://www.lakera.ai/blog/prompt-engineering-guide), [Product School PRD Template](https://productschool.com/blog/product-strategy/product-template-requirements-document-prd), [Aakash's Modern PRD Guide](https://www.news.aakashg.com/p/product-requirements-documents-prds)

---

### Claude 4 Optimization Notes

These prompts are optimized for Claude 4.x models (Opus 4.5, Sonnet 4.5) which have specific characteristics:

| Claude 4 Behavior | How We Address It |
|-------------------|-------------------|
| **Precise instruction following** | Prompts are explicit about expected output format and detail level |
| **Requires explicit "above and beyond"** | Each prompt includes phrases like "Be exhaustive", "Include all edge cases" |
| **Prefers reasoning context** | We explain WHY each section matters, not just WHAT to generate |
| **Action-oriented responses** | We use "Generate", "Create", "Define" instead of "Can you help with" |
| **Format matching** | Prompts use the same structure we expect in output (tables, headers, code blocks) |

**Key patterns used in these prompts:**

```xml
<!-- Tell Claude to investigate before answering -->
<investigate_before_answering>
Think step by step through each section before writing.
</investigate_before_answering>

<!-- Explicit about going beyond basics -->
<go_beyond_basics>
Be exhaustive about error cases. Include exact validation rules,
error messages, and edge cases for every flow.
</go_beyond_basics>

<!-- Positive instructions (what TO do, not what NOT to do) -->
<output_guidance>
Use markdown tables for quick reference.
Provide complete, copy-paste ready code.
Include TypeScript types for all schemas.
</output_guidance>
```

**If Claude gives minimal output**, add these reinforcement phrases:
- "Include as many relevant details as possible"
- "Go beyond the basics to create fully-specified documentation"
- "This must be detailed enough that a developer can implement without asking questions"

---

### Overview: The 6-Step PRD Generation Process

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        PRD GENERATION WORKFLOW                              │
└─────────────────────────────────────────────────────────────────────────────┘

STEP 1: Project Discovery
        ↓
        Prompt 1 → Outputs: Problem, users, value proposition, success metrics
        ↓
STEP 2: Feature Mapping
        ↓
        Prompt 2 → Outputs: Feature list, implementation phases, priorities
        ↓
STEP 3: User Flows
        ↓
        Prompt 3 → Outputs: Detailed flows for each feature (happy path + errors)
        ↓
STEP 4: Data Architecture
        ↓
        Prompt 4 → Outputs: Database tables, relationships, migrations
        ↓
STEP 5: Technical Specifications
        ↓
        Prompt 5 → Outputs: Server actions, API design, UI components
        ↓
STEP 6: Integration & Review
        ↓
        Prompt 6 → Outputs: Third-party services, final review, template config
```

---

### Before You Start

**Prepare these inputs:**

1. **Your project idea** - 2-3 sentences describing what you're building
2. **Target users** - Who will use this product?
3. **Key differentiator** - What makes this unique?
4. **Technical constraints** (optional) - Any specific requirements?

**Tips for best results:**

- Be specific, not vague ("task management for freelancers" > "productivity app")
- Provide context about your domain expertise
- Mention any existing products you want to improve upon
- Share revenue model if known (SaaS, freemium, one-time)

---

### Step 1: Project Discovery Prompt

**Purpose**: Extract problem statement, target users, value proposition, and success metrics.

**Copy this prompt into Claude Chat:**

```
<role>
You are a senior product manager with 15+ years of experience defining products
for successful startups. You specialize in translating vague ideas into clear,
actionable product requirements. You think in terms of user problems, not features.
</role>

<context>
I'm building a web application using a Next.js fullstack template. I need to create
a Product Requirements Document (PRD) that will guide AI-assisted implementation.
The PRD must be specific enough that an AI can implement features with minimal ambiguity.
</context>

<why_this_matters>
This foundation document drives all subsequent technical decisions. Vague problem
statements lead to feature creep. Unclear personas lead to unfocused UX. Missing
success metrics make it impossible to know if we've succeeded. Every section you
generate will be referenced by developers during implementation.
</why_this_matters>

<my_project_idea>
[PASTE YOUR PROJECT IDEA HERE - 2-3 sentences describing what you're building]
</my_project_idea>

<task>
Generate the foundation of my product specification. Think step by step through
each section before writing. If my idea is too vague, ask 2-3 specific clarifying
questions before proceeding.

Create these sections with full detail:

1. **Problem Statement** (2-3 sentences)
   - State the specific pain point this solves
   - Explain why current solutions fail or are inadequate
   - Quantify the problem if possible (time wasted, money lost, frustration level)

2. **Target Users** (define 1-2 primary personas with depth)
   - Name, role, and demographic context
   - Current behavior and workarounds they use today
   - Top 3 frustrations with current solutions
   - What success looks like for them

3. **Value Proposition** (1 sentence, precisely formatted)
   - Use format: "For [target user], [product] is a [category] that [key benefit].
     Unlike [alternatives], our product [key differentiator]."

4. **Success Metrics** (3-5 SMART metrics for v1)
   - Include specific numbers (e.g., "500 signups in first month")
   - Cover: acquisition, activation, engagement, retention
   - Include at least one business metric if monetized

5. **Out of Scope for v1** (3-5 items with reasoning)
   - List features explicitly excluded from initial release
   - For each, explain: why it's deferred, and what would trigger adding it later
</task>

<output_format>
Use markdown with clear headers. Write in complete sentences, not fragments.
Be specific rather than generic - include concrete examples where possible.

Show your reasoning in <thinking> tags before each section to demonstrate
you've considered the implications of each decision.
</output_format>

<quality_bar>
The output should be detailed enough that someone unfamiliar with the project
could understand exactly what we're building and why. Include specific examples,
numbers, and scenarios rather than abstract descriptions.
</quality_bar>
```

**After receiving the response:**
- Review and refine the outputs
- Ask follow-up questions if anything feels off
- Save the final version for the next step

---

### Step 2: Feature Mapping Prompt

**Purpose**: Define features, prioritize them, and organize into implementation phases.

```
<role>
You are a product strategist who excels at prioritizing features using the
MoSCoW method (Must have, Should have, Could have, Won't have) and organizing
work into logical implementation phases.
</role>

<context>
We're continuing to build the PRD for my project. Here's what we defined in Step 1:

<previous_output>
[PASTE THE OUTPUT FROM STEP 1 HERE]
</previous_output>
</context>

<task>
Based on the problem statement and target users, define the feature set and
organize it into implementation phases.

Think step by step:
1. First, brainstorm ALL possible features (don't filter yet)
2. Then, categorize using MoSCoW
3. Finally, organize "Must have" and "Should have" into phases

Generate the following:

## Feature List with Priorities

| Feature | Category | MoSCoW | Rationale |
|---------|----------|--------|-----------|
| [Feature name] | [auth/core/admin/etc] | [M/S/C/W] | [Why this priority] |

## Implementation Phases

### Phase 1: MVP (Must Have)
**Goal**: [Single sentence describing what success looks like]

**Features**:
1. [Feature] - [Brief description]
2. [Feature] - [Brief description]
...

### Phase 2: Enhancement (Should Have)
**Goal**: [Single sentence describing what success looks like]

**Features**:
1. [Feature] - [Brief description]
...

### Phase 3: Polish (Could Have)
**Goal**: [Single sentence describing what success looks like]

**Features**:
1. [Feature] - [Brief description]
...

## Feature Dependencies

```
[Feature A] ──depends on──> [Feature B]
[Feature C] ──depends on──> [Feature A]
```
</task>

<constraints>
- Phase 1 should have 3-5 features maximum (true MVP)
- Each feature should be implementable in 1-3 days
- Consider authentication as a dependency for protected features
- Think about data model implications
</constraints>

<output_format>
Use markdown tables and diagrams. Be specific about what each feature includes.
Show your prioritization reasoning in <thinking> tags.
</output_format>
```

---

### Step 3: User Flows Prompt

**Purpose**: Generate detailed user flows for each Phase 1 feature.

```
<role>
You are a UX designer and technical writer who creates precise user flow
documentation. Your flows are detailed enough that developers can implement
them without asking clarifying questions. You think about happy paths,
error cases, and edge cases.
</role>

<context>
We're building a PRD for implementation by AI. Here's what we have so far:

<project_overview>
[PASTE PROBLEM STATEMENT, TARGET USERS, VALUE PROPOSITION FROM STEP 1]
</project_overview>

<implementation_phases>
[PASTE PHASE 1 FEATURES FROM STEP 2]
</implementation_phases>
</context>

<task>
For EACH feature in Phase 1, create detailed user flows following this structure.

For each feature, generate:

## [Feature Name] Flows

### Flow 1: [Action] (Happy Path)

**User Goal**: As a [persona], I want to [action] so that [benefit]

**Preconditions**:
- [State requirement 1]
- [State requirement 2]

**Steps**:
1. User [action - be specific about UI element]
2. System [response - include timing if relevant]
3. User [action - include input validation rules]
4. System [processing - mention what happens server-side]
5. User sees [outcome - exact message or state change]

**Expected Database State**:
- Table: [table_name]
  - Record created/updated with fields: [field1, field2, ...]
  - Or: "No changes" if read-only

**UI State**:
- Current page: [route]
- Changes: [what the user sees change]
- Notifications: "[exact notification text]" (success/error/info)

**E2E Test Mapping**: `e2e/tests/[feature].spec.ts` → "[test name]"

---

### Flow 2: [Same Action] (Error: [Error Type])

[Same structure, but for error case]

---

### Flow 3: [Alternative Path]

[Same structure, for alternative ways to achieve the goal]
</task>

<why_this_matters>
User flows are the primary input for implementation. Developers will read these flows
and translate each step directly into code. Vague flows lead to incorrect implementations
and require back-and-forth clarification. Specific flows with exact validation rules,
error messages, and state changes enable autonomous implementation.
</why_this_matters>

<constraints>
Every Phase 1 feature needs at minimum:
- 1 happy path flow (complete success scenario)
- 2 error flows (validation failure, business logic failure)
- 1 alternative flow if applicable (different path to same goal)

For each flow, you MUST specify:
- Exact validation rules with specific values (e.g., "min 8 chars" not "strong password")
- Exact error message text in quotes (developers will copy these directly)
- Specific UI components by type (Button, Input, Modal, Toast, etc.)
- Loading state behavior (what shows during server processing)
- Database changes with field names and values
- The E2E test name that will verify this flow
</constraints>

<quality_bar>
A developer should be able to implement each flow without asking a single
clarifying question. If you find yourself writing "appropriate error message"
or "relevant validation" - stop and be specific instead.
</quality_bar>

<example>
## User Signup Flows

### Flow 1: Email Signup (Happy Path)

**User Goal**: As a new visitor, I want to create an account so that I can access the app

**Preconditions**:
- User is not logged in
- User has a valid email address

**Steps**:
1. User navigates to `/signup`
2. System displays signup form with email and password fields
3. User enters email "user@example.com" (valid email format)
4. User enters password "SecurePass123!" (min 8 chars, 1 uppercase, 1 number)
5. User clicks "Create Account" button
6. System validates input (client-side then server-side)
7. System creates user record with hashed password
8. System sends verification email
9. User sees success message: "Account created! Check your email to verify."
10. User is redirected to `/verify-email`

**Expected Database State**:
- Table: user
  - Record created: { id: uuid, email: "user@example.com", emailVerified: false, createdAt: now }
- Table: verification
  - Record created: { token: random, userId: user.id, expiresAt: now + 24h }

**UI State**:
- Redirect to: `/verify-email`
- Toast: "Account created! Check your email to verify." (success)
- Form: cleared

**E2E Test Mapping**: `e2e/tests/auth.spec.ts` → "user can sign up with email and password"

---

### Flow 2: Email Signup (Error: Email Already Exists)

**User Goal**: Same as Flow 1

**Preconditions**:
- User with email "existing@example.com" already exists in database

**Steps**:
1. User navigates to `/signup`
2. System displays signup form
3. User enters email "existing@example.com"
4. User enters password "SecurePass123!"
5. User clicks "Create Account" button
6. System validates input
7. System detects email already exists
8. User sees error: "An account with this email already exists. Try logging in."

**Expected Database State**:
- No changes

**UI State**:
- Remain on: `/signup`
- Error message below email field: "An account with this email already exists."
- Link to login page displayed
- Form values preserved (email filled, password cleared)

**E2E Test Mapping**: `e2e/tests/auth.spec.ts` → "shows error when email already exists"
</example>

<output_format>
Generate flows for ALL Phase 1 features. Group by feature domain.
Use consistent formatting. Be exhaustive about error cases.
</output_format>
```

---

### Step 4: Data Architecture Prompt

**Purpose**: Generate database schema with relationships, indexes, and validation rules.

```
<role>
You are a database architect specializing in PostgreSQL. You design schemas that
are normalized, performant, and support the application's query patterns. You
think about indexes, constraints, and data integrity.
</role>

<context>
We're building a PRD that will be implemented using:
- PostgreSQL (via Neon Serverless)
- Drizzle ORM
- TypeScript

Here's the project context:

<user_flows>
[PASTE ALL USER FLOWS FROM STEP 3]
</user_flows>

The database uses a project-specific schema namespace. All tables should be
defined using this pattern:

```typescript
import { schema } from "./schema.ts";  // pgSchema(env.NEXT_PUBLIC_PROJECT_NAME)

export const tableName = schema.table("table_name", {
  id: text("id").primaryKey(),
  // ... fields
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});
```
</context>

<task>
Analyze the user flows and design the complete database schema.

Generate the following:

## Tables Overview

| Table | Purpose | Related Flows |
|-------|---------|---------------|
| [table] | [what it stores] | [flow files] |

## Table Definitions

### [Table Name]

**File**: `src/db/schema/[table].ts`

**Purpose**: [What this table stores]

```typescript
// Complete Drizzle schema definition
import { schema } from "./schema.ts";
import { text, timestamp, boolean, integer } from "drizzle-orm/pg-core";

export const [tableName] = schema.table("[table_name]", {
  // Primary key
  id: text("id").primaryKey(),

  // Fields with types and constraints
  field1: text("field_1").notNull(),
  field2: integer("field_2").default(0),

  // Foreign keys
  userId: text("user_id").references(() => user.id).notNull(),

  // Timestamps
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});
```

**Indexes**:
- [index name]: [columns] - [purpose]

**Constraints**:
- [constraint type]: [description]

**Relationships**:
- [relationship type] with [table]

**Validation Rules** (application-level):
- field1: [constraints, e.g., "min 3 chars, max 100 chars"]

---

## Relationships Diagram

```
User (1) ────< (N) Session
User (1) ────< (N) [YourTable]
[Table1] (N) ────< (N) [Table2]  via [JoinTable]
```

## Enum Types (if needed)

```typescript
import { pgEnum } from "drizzle-orm/pg-core";

export const statusEnum = pgEnum("status", ["pending", "active", "completed"]);
```

## Query Patterns

For each major query pattern in the flows, document:

| Query | Tables | Indexes Used | Expected Performance |
|-------|--------|--------------|---------------------|
| Get user by email | user | email (unique) | O(1) |
| List user's items | item | userId | O(log n) |
</task>

<constraints>
- Use text type for IDs (UUIDs)
- Include createdAt/updatedAt on all tables
- Define foreign key relationships explicitly
- Consider soft deletes (deletedAt) for important records
- Think about indexes for query performance
- Use enums for fixed sets of values
</constraints>

<output_format>
Provide complete, copy-paste ready Drizzle schema definitions.
Include all imports. Use proper TypeScript types.
</output_format>
```

---

### Step 5: Technical Specifications Prompt

**Purpose**: Generate server actions, API design, and UI component specifications.

```
<role>
You are a senior full-stack engineer who writes clean, type-safe code.
You specialize in Next.js Server Actions, Zod validation, and TanStack Form.
You prioritize security, error handling, and user experience.
</role>

<context>
We're building specifications for a Next.js 15 application with:
- Server Actions (preferred over API routes)
- Zod for validation
- TanStack Form for form state
- shadcn/ui components
- Tailwind CSS v4

Here's what we have:

<user_flows>
[PASTE USER FLOWS FROM STEP 3]
</user_flows>

<database_schema>
[PASTE DATABASE SCHEMA FROM STEP 4]
</database_schema>
</context>

<task>
Generate technical specifications for implementing the features.

## Part A: Server Actions

For each action identified in the flows:

### [actionName]()

**Purpose**: [What this action does]

**File**: `src/app/actions/[domain].ts`

**Related Flow**: `[flow-file].md` → [Flow name]

**Signature**:
```typescript
"use server";

import { z } from "zod";
import { db } from "@/db";
import { [tables] } from "@/db/schema";
import { revalidatePath } from "next/cache";

// Input validation schema
const [actionName]Schema = z.object({
  field1: z.string().min(3).max(100),
  field2: z.string().email(),
});

type [ActionName]Result =
  | { success: true; data: { [fields] } }
  | { success: false; error: string };

export async function [actionName](
  formData: FormData
): Promise<[ActionName]Result> {
  // 1. Parse and validate
  const validation = [actionName]Schema.safeParse({
    field1: formData.get("field1"),
    field2: formData.get("field2"),
  });

  if (!validation.success) {
    return { success: false, error: validation.error.issues[0].message };
  }

  // 2. Authentication check (if needed)

  // 3. Business logic

  // 4. Database operations

  // 5. Cache invalidation
  revalidatePath("/[path]");

  // 6. Return result
  return { success: true, data: { ... } };
}
```

**Validation Rules**:
| Field | Type | Constraints | Error Message |
|-------|------|-------------|---------------|
| field1 | string | min: 3, max: 100 | "Must be 3-100 characters" |

**Authentication**: [Required / Optional / None]

**Error Responses**:
| Condition | Error Message |
|-----------|---------------|
| [condition] | "[message]" |

---

## Part B: UI Components

For each major UI component:

### [ComponentName]

**Purpose**: [What this component does]

**File**: `src/components/[domain]/[ComponentName].tsx`

**Type**: [Client Component / Server Component]

**Props**:
```typescript
interface [ComponentName]Props {
  prop1: string;
  prop2?: number;
  onSuccess?: () => void;
}
```

**Form Fields** (if form component):
| Field | Type | Label | Placeholder | Validation |
|-------|------|-------|-------------|------------|
| email | email | "Email" | "you@example.com" | required, email format |

**States**:
- Default: [description]
- Loading: [description]
- Error: [description]
- Success: [description]

**Accessibility**:
- [ARIA labels, keyboard navigation, focus management]

---

## Part C: Page Routes

| Route | Component | Data Loading | Auth Required |
|-------|-----------|--------------|---------------|
| `/signup` | SignUpPage | None | No (redirect if logged in) |
| `/dashboard` | DashboardPage | Server: getUserData() | Yes |
</task>

<constraints>
- All form validation must use Zod schemas
- Server Actions must return typed results (success/error)
- Use TanStack Form patterns for form components
- Include loading and error states
- Follow accessibility best practices
</constraints>

<output_format>
Provide complete, implementation-ready specifications.
Include TypeScript types and Zod schemas.
Use tables for quick reference.
</output_format>
```

---

### Step 6: Integration & Review Prompt

**Purpose**: Define third-party integrations and generate the final PRD files.

```
<role>
You are a technical project manager who ensures all pieces of a project fit
together coherently. You catch inconsistencies, missing pieces, and ensure
the documentation is implementation-ready.
</role>

<context>
We've built a complete PRD through the previous steps. Now we need to:
1. Define third-party integrations
2. Generate template customization notes
3. Create the final file structure

Here's everything we have:

<project_overview>
[PASTE FROM STEP 1]
</project_overview>

<features_and_phases>
[PASTE FROM STEP 2]
</features_and_phases>

<user_flows>
[PASTE FROM STEP 3]
</user_flows>

<database_schema>
[PASTE FROM STEP 4]
</database_schema>

<technical_specs>
[PASTE FROM STEP 5]
</technical_specs>
</context>

<task>
Complete the PRD with integrations and template configuration.

## Part A: Third-Party Integrations

Based on the features, identify required integrations:

### Required Integrations

| Service | Purpose | Required For |
|---------|---------|--------------|
| [Service] | [Purpose] | [Feature] |

For each integration, specify:

### [Service Name]

**Purpose**: [Why needed]

**Environment Variables**:
```env
SERVICE_API_KEY=
SERVICE_SECRET=
```

**Configuration Notes**:
- [Setup steps]
- [Webhook endpoints if needed]

---

## Part B: Template Customization Notes

Based on the features, what should be kept/removed from the template:

### Authentication
- [x] Email/password (keep/remove)
- [ ] Google OAuth (keep/remove)
- [ ] Magic links (keep/remove)

### Payments
- Payment Provider: [Polar / Stripe / None]
- Subscription Tiers: [Yes / No]

### Analytics
- Provider: [PostHog / None]
- Custom Events: [list]

### Features to Remove
- [ ] Example `post` schema - [reason]
- [ ] [Other template features]

### Dependencies to Add
- [package] - [purpose]

### Dependencies to Remove
- [package] - [reason]

---

## Part C: Final PRD File Structure

Generate the content for each file:

### File: `.claude/prd/00-overview.md`
```markdown
[COMPLETE FILE CONTENT]
```

### File: `.claude/prd/01-flows/_index.md`
```markdown
[COMPLETE FILE CONTENT]
```

### File: `.claude/prd/01-flows/[domain]/[feature]-flows.md`
```markdown
[COMPLETE FILE CONTENT - ONE PER FEATURE DOMAIN]
```

### File: `.claude/prd/02-data-models.md`
```markdown
[COMPLETE FILE CONTENT]
```

### File: `.claude/prd/03-api-design.md`
```markdown
[COMPLETE FILE CONTENT]
```

### File: `.claude/prd/04-ui-components.md`
```markdown
[COMPLETE FILE CONTENT]
```

### File: `.claude/prd/05-integrations.md`
```markdown
[COMPLETE FILE CONTENT]
```

---

## Part D: Consistency Check

Review all sections for:

### Cross-Reference Validation
| Check | Status | Notes |
|-------|--------|-------|
| All flows reference valid DB tables | ✅/❌ | |
| All server actions have corresponding flows | ✅/❌ | |
| All UI components have specs | ✅/❌ | |
| All Phase 1 features have flows | ✅/❌ | |
| E2E test mappings are complete | ✅/❌ | |

### Missing Pieces
- [List any gaps found]

### Recommendations
- [Suggestions for improvement]
</task>

<output_format>
Generate complete, copy-paste ready file contents for each PRD file.
Use proper markdown formatting.
Ensure all cross-references are valid.
</output_format>
```

---

### Tips for Best Results

**During the conversation:**

1. **Review each step's output** before moving to the next
2. **Ask clarifying questions** if something feels incomplete
3. **Iterate on sections** that need refinement
4. **Save outputs** after each step (copy to a document)

**Common refinement prompts:**

```
"The [feature] flow is missing error handling for [case]. Please add it."

"The database schema doesn't account for [requirement]. How should we model this?"

"Can you make the [section] more specific? I need exact error messages and validation rules."

"The UI spec for [component] is vague. Please specify exact props, states, and accessibility requirements."
```

**After completing all steps:**

1. Create the files in `.claude/prd/` directory
2. Review for consistency
3. Run `/implement-prd` in Claude Code
4. Let Claude ask clarifying questions if PRD is ambiguous

---

### Quick Start: Single-Prompt Option

If you want a faster (but less detailed) approach, use this consolidated prompt:

```
<role>
You are a senior product manager and technical architect. You create detailed
Product Requirements Documents (PRDs) for AI-assisted implementation. You are
known for being extremely specific - you include exact error messages, exact
validation rules, and exact database field types rather than vague descriptions.
</role>

<my_project>
[DESCRIBE YOUR PROJECT IN 3-5 SENTENCES]

Target users: [WHO]
Problem solved: [WHAT PAIN POINT]
Key differentiator: [WHY THIS VS ALTERNATIVES]
</my_project>

<why_specificity_matters>
This PRD will be used by an AI to implement features autonomously. Every vague
statement ("appropriate validation", "relevant error message") will require
clarification and slow down implementation. Be precise enough that a developer
could implement each feature without asking a single question.
</why_specificity_matters>

<task>
Generate a complete PRD with these sections. Go beyond the basics to create
a fully-specified document:

1. **Overview** (problem, users, value prop, success metrics, out of scope)
   - Include specific numbers for success metrics
   - Name personas with roles and frustrations

2. **Features** (prioritized list with MoSCoW, organized into 3 phases)
   - Phase 1: 3-5 features maximum
   - Include feature dependencies

3. **User Flows** (for each Phase 1 feature: happy path + 2 error cases)
   - Include exact validation rules (e.g., "min 8 chars, 1 uppercase, 1 number")
   - Include exact error messages in quotes
   - Include exact database state changes
   - Include E2E test name for each flow

4. **Data Models** (Drizzle ORM schemas with relationships)
   - Complete TypeScript code blocks
   - Include indexes and constraints
   - Include relationships diagram

5. **Server Actions** (Zod validation, typed responses)
   - Complete function signatures
   - Validation schemas with exact constraints
   - Error response table

6. **UI Components** (props, states, accessibility)
   - TypeScript interfaces for props
   - All states: default, loading, error, success
   - ARIA labels for accessibility

7. **Template Config** (what to keep/remove from Next.js template)
   - Checkbox list for auth methods
   - Dependencies to add/remove
</task>

<output_format>
Generate as markdown files that can be placed in .claude/prd/ directory.
Structure the output with these exact file headers:

### File: .claude/prd/00-overview.md
[content]

### File: .claude/prd/01-flows/_index.md
[content]

### File: .claude/prd/01-flows/[domain]/[feature]-flows.md
[content for each feature domain]

### File: .claude/prd/02-data-models.md
[content]

### File: .claude/prd/03-api-design.md
[content]

### File: .claude/prd/04-ui-components.md
[content]

### File: .claude/prd/05-integrations.md
[content]

Use code blocks for all schemas and function signatures.
Include E2E test mappings for every flow.
</output_format>
```

**Note**: The single-prompt option produces less detailed output than the 6-step process. Use the 6-step process for complex projects or when you need maximum specificity.

---

### Optional: Multi-Agent Refinement (Step 7)

Research shows that [multi-agent debate](https://composable-models.github.io/llm_debate/) significantly improves output quality by having different perspectives critique and refine the work. After completing Steps 1-6, use this optional refinement step.

**When to use this:**
- Complex projects with many features
- Projects where security/reliability is critical
- When you want maximum confidence in PRD completeness

**The approach:** Role-switching critique within a single conversation, followed by synthesis.

```
<context>
I've completed a PRD for my project. I need you to review it from multiple
expert perspectives to find gaps, inconsistencies, and missing details.

Here's the complete PRD:

<prd>
[PASTE YOUR COMPLETE PRD FROM STEPS 1-6 HERE]
</prd>
</context>

<task>
Conduct a multi-perspective review of this PRD. For each role below, adopt
that persona completely and critique the PRD from that viewpoint. Be adversarial -
your job is to find problems, not validate the work.

After all critiques, synthesize the findings into actionable improvements.

## Role 1: QA Engineer Critique

<role>
You are a senior QA engineer who has seen countless PRDs that looked complete
but led to buggy implementations. You're known for finding edge cases that
developers miss. You're skeptical and thorough.
</role>

Review the PRD and identify:
- Missing error cases in user flows
- Edge cases not covered (empty states, max limits, concurrent operations)
- Flows that lack E2E test coverage
- Validation rules that are incomplete or ambiguous
- Race conditions or timing issues

Format: List each issue with severity (Critical/High/Medium/Low) and specific fix.

---

## Role 2: Security Engineer Critique

<role>
You are a security engineer who reviews PRDs before implementation to catch
vulnerabilities early. You think like an attacker.
</role>

Review the PRD and identify:
- Authentication/authorization gaps
- Input validation vulnerabilities (injection, XSS, etc.)
- Missing rate limiting
- Sensitive data handling issues
- Session management weaknesses
- OWASP Top 10 risks

Format: List each issue with severity and specific fix.

---

## Role 3: Backend Engineer Critique

<role>
You are a senior backend engineer who has to implement this PRD. You're
frustrated by vague specs that require guessing. You want precision.
</role>

Review the PRD and identify:
- Data model gaps (missing fields, wrong types, missing indexes)
- Server action specs that are ambiguous
- Missing database constraints or relationships
- Performance concerns (N+1 queries, missing pagination)
- Unclear error handling

Format: List each issue with specific fix.

---

## Role 4: Frontend Engineer Critique

<role>
You are a frontend engineer who builds the UI. You need exact specs to
implement correctly without back-and-forth clarification.
</role>

Review the PRD and identify:
- UI components missing state specifications
- Unclear loading/error state behavior
- Missing accessibility requirements
- Ambiguous form validation feedback
- Missing responsive design requirements

Format: List each issue with specific fix.

---

## Role 5: Product Manager Review

<role>
You are a senior PM reviewing this PRD before development. You ensure the
product solves the right problem and scope is appropriate.
</role>

Review the PRD and identify:
- Features that don't align with the problem statement
- Scope creep (features that should be Phase 2+)
- Missing success metrics for features
- Unclear user value for specific features
- Dependencies that could block launch

Format: List each issue with specific fix.

---

## Synthesis: Consolidated Improvements

After completing all role critiques, synthesize the findings:

1. **Critical Issues** (must fix before implementation)
   - [Issue + Fix]

2. **High Priority Issues** (fix before Phase 1 complete)
   - [Issue + Fix]

3. **Medium Priority Issues** (fix if time permits)
   - [Issue + Fix]

4. **Recommended Additions**
   - [Additions that would significantly improve quality]

Finally, output the SPECIFIC sections of the PRD that need to be updated,
with the corrected content ready to copy-paste.
</task>

<output_format>
Structure your response as:

## QA Engineer Critique
[findings]

## Security Engineer Critique
[findings]

## Backend Engineer Critique
[findings]

## Frontend Engineer Critique
[findings]

## Product Manager Review
[findings]

## Synthesis: Consolidated Improvements
[prioritized list]

## Updated PRD Sections
[corrected content for each section that needs changes]
</output_format>
```

**After receiving the critique:**

1. Review the findings - some may be overly cautious
2. Apply the critical and high-priority fixes
3. Update your PRD files in `.claude/prd/`
4. Optionally run another critique pass on the updated sections

**Alternative: Inline Critique (Faster)**

If you don't want a separate step, add this to each of the 6 prompts:

```
<self_critique>
After generating the output, pause and critique it from these perspectives:
- QA: What error cases am I missing?
- Security: What vulnerabilities exist?
- Implementation: What's ambiguous?

List 3-5 issues you found, then revise the output to address them.
</self_critique>
```

**Alternative: Claude Code Multi-Agent**

In Claude Code, you can use the Task tool to spawn parallel critique agents:

```
Use the Task tool to launch these agents in parallel:
1. "Review this PRD as a QA engineer, find missing test cases"
2. "Review this PRD as a security engineer, find vulnerabilities"
3. "Review this PRD as a backend engineer, find data model gaps"

Then synthesize their findings.
```

This leverages Claude Code's ability to run multiple specialized agents simultaneously.

---

### When Multi-Agent Is Overkill

Skip the multi-agent refinement for:
- Simple CRUD apps with straightforward flows
- MVPs where speed matters more than perfection
- Projects where you'll iterate based on user feedback anyway

The 6-step process alone produces good results. Multi-agent refinement adds ~30 minutes but catches issues that would take hours to fix during implementation.

---

## Next Steps After Setup

1. **Review `plan.md`** - Understand the implementation phases
2. **Run `/next-step`** - Start implementing features
3. **Commit regularly** - Small, focused commits with conventional format
4. **Test continuously** - Run tests before each commit
5. **Deploy early** - Get a preview deployment running early

For detailed architecture documentation, see:
- `CLAUDE.md` - Development patterns and conventions
- `.claude/rules/` - Context-specific guidelines
- `scripts/README.md` - Codebase operations documentation
