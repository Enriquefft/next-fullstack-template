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

Based on the PRD's "Template Customization Notes" section, create TodoWrite tasks for these 14 categories:

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

#### 14. CLAUDE.md Customization

Regenerate `CLAUDE.md` based on PRD choices to ensure documentation matches the actual project state.

**Read Current CLAUDE.md**: Use as reference for section content and structure.

**Apply Section Rules for 4 Major Features**:

1. **Authentication Section**:
   - **If NOT using auth**: Remove entire "Authentication System" section
   - **If email/password only**: Remove OAuth provider mentions, remove Polar integration mention
   - **If using OAuth**: List configured providers (Google, GitHub, etc.)
   - **If using payments**: Keep Polar integration mention; otherwise remove it

2. **Analytics Section**:
   - **If NOT using analytics**: Remove entire "Analytics" section (PostHog)
   - **If using PostHog**: Keep section as-is
   - **If using different provider** (GA, Mixpanel): Replace PostHog content with provider-specific guidance

3. **Payments (Polar references)**:
   - **If NOT using payments**: Remove Polar mentions from Authentication section and any other references
   - **If using Polar**: Keep references
   - **If using Stripe**: Replace Polar references with Stripe guidance

4. **Messaging Section (WhatsApp/Kapso)**:
   - **If NOT using messaging**: Remove entire "WhatsApp Messaging (Kapso)" section
   - **If using Kapso**: Keep section as-is

**Auto-Generate New Sections**:
- If `05-integrations.md` defines integrations NOT in template (e.g., Stripe, Twilio, custom APIs):
  - Generate new documentation section following existing format
  - Include: purpose, key files, environment variables, usage examples
  - Place after existing integration sections

**Write Updated CLAUDE.md**: Generate final version reflecting actual project state.

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
  - [ ] `tests/actions/auth.test.ts` - Test signUp() validation
  - [ ] Test password hashing
  - [ ] Test duplicate email handling
- **E2E Tests**:
  - [ ] `e2e/tests/auth.spec.ts` - "user can sign up with email and password"
  - [ ] `e2e/tests/auth.spec.ts` - "shows error when email already exists"
  - [ ] `e2e/tests/auth.spec.ts` - "shows error for invalid email"
  - [ ] `e2e/tests/auth.spec.ts` - "shows error for weak password"

[Continue for all steps in all phases]

---

## Final Phase: Polish & Cleanup

> **Note**: This phase runs after all feature implementation is complete.

### Step F.1: UI/UX Revamp (Iterative)
**Goal**: Analyze and improve the application's visual design and user experience.

This step is **iterative** - repeat until the UI meets quality standards.

**Tasks**:
- [ ] Audit current UI against modern design principles
- [ ] Review spacing, typography, and visual hierarchy
- [ ] Ensure consistent color usage and contrast ratios
- [ ] Improve component aesthetics (buttons, cards, forms, etc.)
- [ ] Add subtle animations/transitions where appropriate
- [ ] Verify responsive design across breakpoints
- [ ] Run visual regression check

**Iteration Cycle**:
1. Take screenshots or review current state
2. Identify 3-5 specific UI/UX improvements
3. Implement improvements
4. Evaluate result - if not satisfactory, repeat from step 1
5. Mark complete when UI is polished and attractive

**Quality Checklist**:
- [ ] Visual hierarchy is clear and guides user attention
- [ ] Consistent spacing (padding, margins, gaps)
- [ ] Typography is readable and well-structured
- [ ] Colors are harmonious and accessible (WCAG AA)
- [ ] Interactive elements have clear affordances
- [ ] Loading/empty/error states are well-designed
- [ ] Mobile experience is smooth and intuitive

### Step F.2: CI/CD Cleanup
**Goal**: Finalize CI configuration and ensure clean builds.

**Tasks**:
- [ ] Remove `continue-on-error: true` from deps check in `.github/workflows/ci.yaml`
- [ ] Run `bun cleanup` and fix any issues
- [ ] Verify CI pipeline passes without errors
- [ ] Run full test suite: `bun test && bun run test:e2e`
- [ ] Run type check: `bun type`
- [ ] Run linter: `bun lint`

**Verification**:
- [ ] All CI checks pass without `continue-on-error`
- [ ] `bun cleanup` completes successfully
- [ ] No TypeScript errors
- [ ] No linting errors
- [ ] All tests pass
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
- Messaging: [kept/removed]
- Dependencies: [removed X, added Y]
- Database schema: [cleaned up]
- CLAUDE.md: [customized - removed/modified sections]
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

[Works through 14 categories systematically]

Claude: ✅ Task 1/14 complete: Project identity updated
Claude: ✅ Task 2/14 complete: Authentication configured (kept Better Auth + Google)
Claude: ✅ Task 3/14 complete: Removed Polar integration
...
Claude: ✅ Task 13/14 complete: SEO configuration updated
Claude: ✅ Task 14/14 complete: CLAUDE.md customized (removed Polar/Kapso sections)

Generating plan.md based on implementation priorities...

✅ Barebones complete! Implementation plan created at plan.md

Next: Run `/next-step` to begin Phase 1, Step 1 (User Signup)
