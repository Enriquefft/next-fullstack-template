# Deployment & CI/CD Guide

This guide covers the complete CI/CD pipeline setup for production deployments.

## CI/CD Pipeline

This template includes a comprehensive GitHub Actions CI/CD pipeline optimized for Bun + Next.js + Vercel.

### GitHub Actions Workflows

**CI Workflow** (`ci.yml`) - Runs on all PRs and pushes:
- Quality checks (typecheck, lint, unused dependencies)
- Unit tests with Happy DOM
- E2E tests with Playwright
- Production build verification
- All checks must pass before PR can be merged

**Security Workflow** (`security.yml`) - Weekly scans + on PRs:
- Dependency vulnerability scanning
- CodeQL static analysis (SQL injection, XSS, etc.)
- Secrets detection with TruffleHog
- License compliance checking
- SBOM generation (CycloneDX)

### Vercel Automatic Deployments

Vercel handles all deployments automatically when connected to your GitHub repository:

- **Preview Deployments**: Automatic preview for every PR (posted as comment by Vercel bot)
- **Production Deployments**: Automatic deployment when merging to `main` branch
- **Staging Deployments**: Automatic deployment when merging to `staging` branch (if configured)

**No additional workflow files needed** - Vercel's GitHub integration handles building, deploying, and environment management.

## Environment Setup

**Prerequisites**: Before setting up CI/CD, ensure you've completed the Getting Started steps in the main README, especially creating Neon database branches.

### Quick Setup

Two helper scripts are provided for faster setup:

```bash
# 1. Set GitHub secrets (interactive prompts - secure)
./scripts/setup-github-secrets.sh

# 2. Set Vercel environment variables
./scripts/setup-vercel-env.sh
```

**Security Note**: The secrets script uses interactive prompts - values won't appear in your terminal or shell history. Never commit `.env` files or hardcode secrets in scripts.

### Required GitHub Secrets

Add these secrets in **Settings → Secrets and variables → Actions** (or use `./scripts/setup-github-secrets.sh`):

**Database** (these should already exist in your `.env` from Getting Started):
- `DATABASE_URL_TEST` - Test database connection string
- `DATABASE_URL_STAGING` - Staging database connection string
- `DATABASE_URL_PROD` - Production database connection string

**Authentication** (copy from `.env` or generate new):
- `BETTER_AUTH_SECRET_TEST` - Generate: `bun run auth:secret`
- `BETTER_AUTH_SECRET_STAGING` - Generate: `bun run auth:secret`
- `BETTER_AUTH_SECRET_PROD` - Generate: `bun run auth:secret`
- `GOOGLE_CLIENT_ID` - Google OAuth client ID
- `GOOGLE_CLIENT_SECRET` - Google OAuth client secret

**Third-Party Services** (copy from `.env`):
- `NEXT_PUBLIC_POSTHOG_KEY` - PostHog analytics key
- `POSTHOG_PROJECT_ID` - PostHog project ID
- `POLAR_ACCESS_TOKEN` - Polar API token (sandbox)
- `POLAR_ACCESS_TOKEN_PROD` - Polar API token (production, optional)
- `UPLOADTHING_TOKEN` - UploadThing token
- `UPLOADTHING_TOKEN_PROD` - UploadThing production token (optional)
- `NEXT_PUBLIC_PROJECT_NAME` - Your project name
- `CODECOV_TOKEN` - Codecov upload token (optional)

### Vercel Environment Variables

Configure these in **Vercel Dashboard → Project Settings → Environment Variables**:

**All Environments** (Preview, Staging, Production):
- `NEXT_PUBLIC_PROJECT_NAME` - Your project name
- `GOOGLE_CLIENT_ID` - Google OAuth client ID
- `GOOGLE_CLIENT_SECRET` - Google OAuth client secret
- `NEXT_PUBLIC_POSTHOG_KEY` - PostHog analytics key
- `POSTHOG_PROJECT_ID` - PostHog project ID
- `POLAR_ACCESS_TOKEN` - Polar API token
- `POLAR_MODE` - Set to `sandbox` for preview/staging, `production` for production
- `UPLOADTHING_TOKEN` - UploadThing token

**Environment-Specific**:
- `DATABASE_URL` - Set per environment (preview → test DB, staging → staging DB, production → prod DB)
- `BETTER_AUTH_SECRET` - Different secret per environment (generate with `bun run auth:secret`)

### Branch Protection

Configure in **Settings → Branches → Add rule** for `main`:
- ✅ Require status checks to pass before merging
  - `quality (typecheck)`
  - `quality (lint)`
  - `quality (deps)`
  - `unit-tests`
  - `e2e-tests`
  - `build`
  - `codeql`
- ✅ Require 1 approval
- ✅ Require branches to be up to date before merging

## Deployment Flow

1. **Development**: Work in feature branches
2. **Pull Request**: Open PR → CI/Security checks run → Vercel creates preview deployment
3. **Review**: All checks pass → Get approval → Merge
4. **Staging** (optional): Merge to `staging` → Vercel auto-deploys to staging environment
5. **Production**: Merge to `main` → Vercel auto-deploys to production

### Database Migrations

Run manually or via GitHub Actions workflow after verifying deployment:

```bash
# After production deployment
DATABASE_URL=$PROD_DB_URL bun run db:push
```

## Monitoring & Rollback

### Built-in Monitoring

- PostHog analytics for page views and events
- Vercel Analytics for Core Web Vitals (optional)
- GitHub Actions for CI/CD metrics

### Rollback Procedure

**Vercel Dashboard**: **Deployments** → Find last stable deployment → **Promote to Production**
- Instant rollback in < 1 minute

## Additional Resources

For detailed CI/CD implementation planning, see `.claude/plans/vivid-hopping-pillow.md`.
