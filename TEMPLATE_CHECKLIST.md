# Template Customization Checklist

**Purpose**: Transform this template repository into your project repository.

**When to use**: After running `/speckit.specify` for template initialization (branch `0-template-init`).

**When to delete**: After completing all transformations and verifying your customized app runs successfully.

---

## Instructions

This checklist guides the implementation of your `0-template-init` spec. Use it alongside the spec-driven workflow:

1. ✅ Created spec with `/speckit.specify`
2. ✅ Generated plan with `/speckit.plan`
3. ✅ Generated tasks with `/speckit.tasks`
4. → **Use this checklist during `/speckit.implement`**
5. → Delete this file when transformation is complete

---

## 1. Project Identity

Configure project-specific names and metadata:

- [ ] Update `package.json`:
  - [ ] `name` field
  - [ ] `description` field
  - [ ] `repository.url` field
  - [ ] `author` field (if applicable)
  - [ ] `keywords` field (if applicable)
- [ ] Update `NEXT_PUBLIC_PROJECT_NAME` in `.env` and `.env.example`
- [ ] Update `src/metadata.ts`:
  - [ ] `title` template and default
  - [ ] `description` text
  - [ ] `applicationName`
  - [ ] Update `metadataBase` URL when domain is known
- [ ] Update `README.md`:
  - [ ] Project title (line 1)
  - [ ] Description paragraph
  - [ ] Repository URLs in Quick Start section
  - [ ] Badge URLs (if keeping badges)
- [ ] Update `CLAUDE.md` if project-specific context is needed

---

## 2. Authentication Configuration

Keep only the authentication methods you need:

- [ ] **Review** what to keep:
  - Email/password (Better Auth core)
  - Google OAuth (`GOOGLE_CLIENT_ID` + `GOOGLE_CLIENT_SECRET`)
  - GitHub OAuth (if added)
  - Magic links (if added)
- [ ] **Remove unwanted auth providers**:
  - [ ] Delete OAuth configuration from `src/lib/auth.ts`
  - [ ] Remove corresponding environment variables from `.env.example`
  - [ ] Remove OAuth setup instructions from `CLAUDE.md`
  - [ ] Update `src/env/server.ts` validation schema
- [ ] **Verify auth works**:
  - [ ] Run `bun dev` and test sign up
  - [ ] Test sign in
  - [ ] Test sign out
  - [ ] Verify database session storage

---

## 3. Payment Integration

Choose payment provider or remove payments entirely:

### Option A: Keep Polar

- [ ] Verify `POLAR_ACCESS_TOKEN` in `.env`
- [ ] Verify `POLAR_MODE` in `.env` (sandbox or production)
- [ ] Keep `src/lib/polar.ts`
- [ ] Keep Polar-related components
- [ ] Keep `src/app/api/polar/webhook/route.ts`

### Option B: Switch to Stripe

- [ ] Remove `src/lib/polar.ts`
- [ ] Remove Polar webhook route
- [ ] Remove `POLAR_*` environment variables from `.env.example`
- [ ] Remove `polar-sdk` from `package.json`
- [ ] Add Stripe SDK to `package.json`
- [ ] Implement Stripe integration (checkout, webhooks)
- [ ] Add `STRIPE_*` environment variables to `.env.example`
- [ ] Update `src/env/server.ts` validation

### Option C: Remove payments entirely

- [ ] Delete `src/lib/polar.ts`
- [ ] Delete `src/app/api/polar/` directory
- [ ] Remove `polar-sdk` from `package.json`
- [ ] Remove all `POLAR_*` environment variables from `.env.example`
- [ ] Remove payment-related sections from `CLAUDE.md`
- [ ] Update `src/env/server.ts` to remove Polar validation

---

## 4. Analytics Setup

Choose analytics provider or remove analytics:

### Option A: Keep PostHog

- [ ] Verify `NEXT_PUBLIC_POSTHOG_KEY` in `.env`
- [ ] Verify `NEXT_PUBLIC_POSTHOG_HOST` in `.env`
- [ ] Keep `src/lib/posthog.ts`
- [ ] Keep `src/components/PostHogProvider.tsx`
- [ ] Keep PostHog provider in `src/app/layout.tsx`

### Option B: Switch to Google Analytics / Mixpanel / etc.

- [ ] Remove PostHog imports from `src/app/layout.tsx`
- [ ] Delete `src/lib/posthog.ts`
- [ ] Delete `src/components/PostHogProvider.tsx`
- [ ] Remove `posthog-js` from `package.json`
- [ ] Remove `NEXT_PUBLIC_POSTHOG_*` from `.env.example`
- [ ] Implement new analytics provider
- [ ] Add new analytics environment variables
- [ ] Update `src/env/client.ts` validation

### Option C: Remove analytics entirely

- [ ] Remove PostHog imports from `src/app/layout.tsx`
- [ ] Delete `src/lib/posthog.ts`
- [ ] Delete `src/components/PostHogProvider.tsx`
- [ ] Remove `posthog-js` from `package.json`
- [ ] Remove `NEXT_PUBLIC_POSTHOG_*` from `.env.example`
- [ ] Remove analytics section from `CLAUDE.md`
- [ ] Update `src/env/client.ts` to remove PostHog validation

---

## 5. Database Schema Cleanup

Remove example tables and keep only what you need:

- [ ] **Review** `src/db/schema/`:
  - [ ] `auth.ts` - Keep (required for Better Auth)
  - [ ] `post.ts` - Example table, likely remove
  - [ ] Other example schemas - Remove if not needed
- [ ] **Delete** example schema files
- [ ] **Remove** example schema imports from `src/db/schema/index.ts`
- [ ] **Run** `bun run db:push` to sync schema
- [ ] **Verify** only necessary tables exist in database

**If removing auth** (not recommended):
- [ ] Delete `src/db/schema/auth.ts`
- [ ] Remove auth import from `src/db/schema/index.ts`
- [ ] Remove Better Auth entirely (see Authentication section)

---

## 6. UI Component Cleanup

Remove example components and keep only essential UI:

- [ ] **Review** `src/components/`:
  - [ ] `ui/` - Keep (shadcn/ui primitives)
  - [ ] `sign-in.tsx` / `sign-up.tsx` - Keep if using auth
  - [ ] `ProductCard.tsx` - Example component, likely remove
  - [ ] `form-example.tsx` - Example, remove
  - [ ] `AddressAutocomplete.tsx` - Keep if using Google Places
  - [ ] Other example components - Remove if not needed
- [ ] **Delete** unused component files
- [ ] **Remove** example pages from `src/app/`:
  - [ ] Example routes or pages that showcase removed components
  - [ ] Remove imports of deleted components
- [ ] **Verify** `bun dev` runs without errors
- [ ] **Verify** `bun type` passes (no broken imports)

---

## 7. Remove Unused Integrations

Remove integrations you don't need:

### Kapso (WhatsApp Messaging)

If not using Kapso:
- [ ] Delete `src/lib/kapso.ts`
- [ ] Delete `src/app/api/whatsapp/` directory
- [ ] Remove `KAPSO_*` and `META_APP_SECRET` from `.env.example`
- [ ] Remove `@kapsoai/sdk` from `package.json`
- [ ] Remove Kapso section from `CLAUDE.md`
- [ ] Update `src/env/server.ts` to remove Kapso validation

### Google Places (Address Autocomplete)

If not using Google Places:
- [ ] Delete `src/hooks/use-google-places.tsx`
- [ ] Delete `src/components/AddressAutocomplete.tsx`
- [ ] Remove `NEXT_PUBLIC_GOOGLE_MAPS_API_KEY` from `.env.example`
- [ ] Update `src/env/client.ts` to remove Google Maps validation
- [ ] Remove `@googlemaps/js-api-loader` from `package.json` (if not used elsewhere)

### Other Third-Party Services

Review and remove any other integrations not needed for your project.

---

## 8. Environment Variable Cleanup

Ensure `.env.example` only lists variables for integrations you're keeping:

- [ ] **Review** `.env.example` line by line
- [ ] **Remove** variables for deleted integrations
- [ ] **Add** variables for new integrations (if any)
- [ ] **Verify** all kept variables are documented with comments
- [ ] **Update** `src/env/client.ts` schema
- [ ] **Update** `src/env/server.ts` schema
- [ ] **Run** `bun dev` to verify environment validation works
- [ ] **Verify** `.env` (local) has all required values

---

## 9. Dependency Cleanup

Remove unused packages to reduce bundle size:

- [ ] **Review** `package.json` `dependencies`
- [ ] **Remove** packages for deleted integrations:
  - [ ] `@kapsoai/sdk` (if removed Kapso)
  - [ ] `polar-sdk` (if removed Polar)
  - [ ] `posthog-js` (if removed PostHog)
  - [ ] Other unused SDKs
- [ ] **Run** `bun install` to update `bun.lock`
- [ ] **Run** `bun run build` to verify build succeeds
- [ ] **Run** `bun test` to verify tests pass

**Don't remove core dependencies**:
- Next.js, React, Tailwind, shadcn/ui
- Drizzle ORM, Neon driver
- Better Auth (if keeping authentication)
- Testing tools (Happy DOM, Playwright)
- Development tools (TypeScript, Biome, Lefthook)

---

## 10. SEO & Metadata Updates

Update SEO metadata to reflect your project:

- [ ] **Update** `src/metadata.ts`:
  - [ ] Default title
  - [ ] Site description
  - [ ] OG image URLs (when available)
  - [ ] Theme color
  - [ ] Application name
- [ ] **Update** `src/app/manifest.ts`:
  - [ ] App name
  - [ ] Short name
  - [ ] Description
  - [ ] Theme colors
  - [ ] Icons (when available)
- [ ] **Update** `public/` assets:
  - [ ] Replace favicon.ico
  - [ ] Replace icon images (icon-192.png, icon-512.png, etc.)
  - [ ] Replace OG images (if using custom ones)

---

## 11. Documentation Updates

Update documentation to reflect your customized template:

- [ ] **Update** `README.md`:
  - [ ] Remove mentions of removed integrations
  - [ ] Update feature list
  - [ ] Update environment variables section
  - [ ] Verify all commands still work
- [ ] **Update** `CLAUDE.md`:
  - [ ] Remove sections for deleted integrations
  - [ ] Update architecture overview
  - [ ] Update environment variables section
  - [ ] Add project-specific patterns/rules

---

## 12. Testing Configuration

Ensure tests still pass after customization:

- [ ] **Run** `bun test` (unit tests)
  - [ ] Fix any broken tests due to removed components
  - [ ] Delete test files for removed features
- [ ] **Run** `bun run test:e2e` (E2E tests)
  - [ ] Update `e2e/fixtures/` if schema changed
  - [ ] Update `e2e/helpers/` if auth changed
  - [ ] Fix broken E2E tests
  - [ ] Delete E2E tests for removed features
- [ ] **Run** `bun type` (type checking)
  - [ ] Fix any type errors from deleted components
- [ ] **Run** `bun lint` (linting)
  - [ ] Fix any linting errors
  - [ ] Remove lint suppressions for deleted files

---

## 13. Git & CI/CD Verification

Verify the customized template works in CI/CD:

- [ ] **Commit** all changes:
  ```bash
  git add .
  git commit -m "feat: customize template for project"
  ```
- [ ] **Push** to GitHub:
  ```bash
  git push origin 0-template-init
  ```
- [ ] **Verify** GitHub Actions pass:
  - [ ] Tests job succeeds
  - [ ] Lint job succeeds
  - [ ] Build job succeeds
  - [ ] CodeQL job succeeds
- [ ] **Create PR** for `0-template-init` → `main`
- [ ] **Review** diff to ensure only intended changes
- [ ] **Merge** PR after approval
- [ ] **Verify** main branch CI passes

---

## 14. Final Verification & Cleanup

Verify everything works and clean up:

- [ ] **Run** complete verification:
  ```bash
  bun install        # Fresh install
  bun run build      # Production build
  bun dev            # Dev server starts
  bun test           # Unit tests pass
  bun run test:e2e   # E2E tests pass
  bun type           # No type errors
  bun lint           # No lint errors
  ```
- [ ] **Test** core features manually:
  - [ ] Visit http://localhost:3000
  - [ ] Sign up / sign in (if keeping auth)
  - [ ] Test remaining integrations
  - [ ] Verify no console errors
- [ ] **Generate** database migrations:
  ```bash
  bun run db:generate  # Create migration files
  git add drizzle/
  git commit -m "chore: add database migrations"
  ```
- [ ] **Deploy** to staging/production:
  ```bash
  git push origin main  # Triggers deployment
  ```
- [ ] **Verify** deployment succeeds
- [ ] **Delete** this checklist:
  ```bash
  rm TEMPLATE_CHECKLIST.md
  git add TEMPLATE_CHECKLIST.md
  git commit -m "chore: remove template checklist"
  git push
  ```

---

## 🎉 Transformation Complete!

Your template is now customized for your project. Continue with feature development using the spec-driven workflow:

```bash
/speckit.specify "Your next feature description"
/speckit.plan
/speckit.tasks
/speckit.implement
```

See [README.md](README.md#development-process) for the complete development workflow.
