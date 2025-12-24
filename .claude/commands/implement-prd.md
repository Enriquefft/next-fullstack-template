You are implementing the barebones project structure from the PRD located in `.claude/prd/`.

## Your Mission

Read the PRD, customize the template to match project requirements, and generate a complete implementation plan.

## Workflow

### Step 1: Read PRD Files

Read these files in order:

1. `.claude/prd/00-overview.md` - Project vision and template customization notes
2. `.claude/prd/01-flows/_index.md` - Flow organization and implementation priorities

**Goal**: Understand what features are needed and what template components to keep/remove/modify.

### Step 2: Generate TodoWrite Tasks from Checklist

Based on the PRD's "Template Customization Notes" section, create TodoWrite tasks for these 13 categories:

#### 1. Project Identity
- Update `package.json` → name, description, repository, author
- Update `NEXT_PUBLIC_PROJECT_NAME` in `.env`
- Update `src/metadata.ts` → project name, description, URLs
- Update `README.md` → project-specific content
- Replace OpenGraph images in `public/` (if provided)

#### 2. Authentication Configuration
**Check PRD**: What auth methods are specified?

- **If email/password only**: Remove Google OAuth config from `.env.example` and `src/auth.ts`
- **If using OAuth**: Verify providers in `src/auth.ts`, add env vars to `.env.example`
- **If NOT using auth**: Remove `src/auth.ts`, `src/lib/auth-client.ts`, auth routes, Better Auth from `package.json`
- **If different auth system**: Replace Better Auth with specified alternative

#### 3. Payment/Subscription Configuration
**Check PRD**: Payment provider specified?

- **If NOT using payments**: Remove `src/lib/polar.ts`, remove `POLAR_*` from `.env.example`, remove Polar from `package.json`
- **If using Stripe**: Replace Polar with Stripe integration
- **If using Polar**: Configure based on PRD specs (subscription tiers, etc.)

#### 4. Database Schema Cleanup
**Check PRD**: What entities are defined in `02-data-models.md`?

- Remove example `post` table from `src/db/schema/post.ts` (unless PRD uses it)
- Verify `schema.ts` namespace matches `NEXT_PUBLIC_PROJECT_NAME`
- Remove auth tables if not using authentication

#### 5. UI/Component Cleanup
**Check PRD**: UI requirements from `04-ui-components.md`

- Remove example components not in PRD
- Verify theme configuration (dark mode required?)
- Remove `ProductCard.tsx` if not e-commerce
- Configure fonts in `src/styles/fonts.ts` if specified
- Update Tailwind colors if brand guidelines provided

#### 6. Feature Flags & Analytics
**Check PRD**: Analytics provider from `05-integrations.md`?

- **If NOT using PostHog**: Remove `src/lib/posthog.ts`, `PostHogProvider.tsx`, remove from `package.json`
- **If using different analytics**: Add alternative (GA, Mixpanel, etc.)
- Configure custom events based on PRD

#### 7. API Routes & Server Actions
- Remove example API routes not in PRD
- Verify server actions match `03-api-design.md` specs

#### 8. Testing Configuration
- Update E2E test seed data to match PRD entities
- Remove example E2E tests (`e2e/tests/home.spec.ts`)
- Verify E2E helpers match PRD auth patterns

#### 9. Environment Variables
- Update `.env.example` with PRD-required vars
- Remove unused env vars from template
- Update `src/env/` validation schemas

#### 10. Dependencies
**Check PRD**: What packages are needed vs. what's in template?

- Remove unused dependencies (run `bun remove <package>`)
- Add new dependencies (run `bun add <package>`)
- Run `bun install` after changes

#### 11. Documentation
- Update `README.md` with project-specific setup
- Update `CLAUDE.md` to remove template-specific notes

#### 12. Git & CI/CD
- Verify `.gitignore` for project-specific files
- Note: Don't create initial commit yet (do after implementation complete)

#### 13. SEO & GEO Configuration
**Check PRD**: Project name, description, brand colors, and keywords from `00-overview.md`

- Update `src/metadata.ts` → siteConfig with:
  - `name`: Project/product name from PRD
  - `description`: SEO description (155 characters max recommended)
  - `keywords`: Project-specific keywords array
  - `author`: Author name and URL
  - `themeColor`: Brand primary color (hex)
  - `ogImage`: Path to custom OpenGraph image (create 1200x630px image if provided)
- Update message files (`messages/en.json`, `messages/es.json`, etc.) → `Metadata` namespace:
  - `title`: Localized project name
  - `description`: Localized SEO description
- Verify `src/lib/seo/metadata.ts` has correct locale mappings (add locales if needed)
- **Important**: The SEO system is locale-aware and will automatically generate:
  - Canonical URLs for each page
  - Hreflang links for all supported locales
  - Locale-specific OpenGraph tags
  - Viewport and theme-color meta tags

### Step 3: Ask User Questions

For ambiguous items in the PRD, use AskUserQuestion:

**Examples**:
- "The PRD doesn't specify if we should keep PostHog. Should I remove it or keep it?"
- "Should I remove the Google OAuth integration or keep it for future use?"
- "The PRD mentions analytics but doesn't specify a provider. Which should I use?"

### Step 4: Execute TodoWrite Tasks

Work through the checklist systematically:

1. Mark current task as `in_progress`
2. Complete the task
3. Mark as `completed`
4. Move to next task

**Important**: Actually perform the work. Read files, make edits, remove dependencies, etc.

### Step 5: Generate plan.md

Once barebones customization is complete, generate `plan.md` in project root based on:

1. Read `.claude/prd/01-flows/_index.md` → Implementation Priority section
2. For each phase, create steps from flow files
3. For each step, define:
   - Flow reference
   - Tasks (DB, server actions, UI, tests)
   - Test requirements (unit + E2E)

**Format** (see `docs/plan-template.md` for full structure):

```markdown
# Project Implementation Plan

**Generated from**: `.claude/prd/` on [date]
**Project**: [project name from PRD]

## Phase 1: MVP

### Step 1.1: User Signup
**Flow Reference**: `.claude/prd/01-flows/auth/signup-flows.md`

**Tasks**:
- [ ] Create User table schema in `src/db/schema/user.ts`
- [ ] Implement `signUp()` server action with Zod validation
- [ ] Create SignUpForm component
- [ ] Add signup page at `/signup`

**Test Requirements**:
- **Unit Tests**:
  - `tests/actions/auth.test.ts` - Test signUp() validation
  - Test password hashing
  - Test duplicate email handling
- **E2E Tests**:
  - `e2e/tests/auth.spec.ts` - "user can sign up with email and password"
  - `e2e/tests/auth.spec.ts` - "shows error when email already exists"
  - `e2e/tests/auth.spec.ts` - "shows error for invalid email"
  - `e2e/tests/auth.spec.ts` - "shows error for weak password"

[Continue for all steps in all phases]
```

### Step 6: Report to User

Announce completion:

```
✅ Barebones implementation complete!

Completed:
- Project identity updated (name: [project-name])
- Authentication: [kept/removed/modified]
- Payments: [kept/removed]
- Analytics: [kept/removed]
- Dependencies: [removed X, added Y]
- Database schema: [cleaned up]
- [Other customizations]

📋 Implementation plan created: plan.md

Next steps:
1. Review plan.md to understand implementation phases
2. Run `/next-step` to begin implementing Phase 1, Step 1
3. Or specify which feature to start with
```

## Important Guidelines

- **Read PRD first**: Don't assume what's needed
- **Follow PRD exactly**: Template customization notes tell you what to do
- **Ask when unclear**: Use AskUserQuestion for ambiguities
- **Actually do the work**: Don't just list tasks, execute them
- **Generate real plan.md**: Base it on PRD's implementation priorities
- **One task at a time**: Mark in_progress, complete, then move to next

## Example Session

User: `/implement-prd`

Claude: Reading `.claude/prd/00-overview.md`...
Claude: Reading `.claude/prd/01-flows/_index.md`...

Claude: Understood! This is a [project type] with:
- Authentication: Email/password + Google OAuth
- Payments: Not using (will remove Polar)
- Analytics: PostHog (keeping)
- Key features: [list from flows]

Creating TodoWrite checklist...

[Works through 12 categories systematically]

Claude: ✅ Task 1/12 complete: Project identity updated
Claude: ✅ Task 2/12 complete: Authentication configured (kept Better Auth + Google)
Claude: ✅ Task 3/12 complete: Removed Polar integration
...
Claude: ✅ Task 12/12 complete: Documentation updated

Generating plan.md based on implementation priorities...

✅ Barebones complete! Implementation plan created at plan.md

Next: Run `/next-step` to begin Phase 1, Step 1 (User Signup)
