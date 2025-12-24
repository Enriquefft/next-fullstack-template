# Deployment Guide

This template supports multiple deployment workflows. Choose the one that fits your needs.

## Quick Start

**Just want to deploy?** Run:
```bash
./scripts/setup-vercel-env.sh  # Sets up env vars + Git integration
git push origin main           # Auto-deploys to production (if Git connected)
```

**Want CI/CD with tests?** Run:
```bash
./scripts/setup-env.sh  # Unified setup for both Vercel and GitHub (recommended)
```

**Or configure platforms separately:**
```bash
./scripts/setup-github-secrets.sh  # For GitHub Actions only
./scripts/setup-vercel-env.sh      # For Vercel deployment only
```

## Understanding the Scripts

### `scripts/setup-env.sh` - Unified Setup (Recommended)

**What it does:** Configure both Vercel and GitHub in one go, entering values once

**Key features:**
- ✨ **Smart value sharing** - Enter each secret once, reused for both platforms
- 📌 **Existence checking** - Shows which variables already exist
- ⏭️ **Skip existing values** - Press Enter to keep current values unchanged
- ✅ **Confirmation prompts** - Confirms before skipping new (non-existing) variables

**When to use:**
- ✅ Initial project setup (both Vercel + GitHub Actions)
- ✅ Updating variables across both platforms
- ✅ You want the most efficient workflow

**Example workflow:**
```bash
./scripts/setup-env.sh
# Choose: 1. Both (values entered once, used for both platforms)
#         2. Vercel only
#         3. GitHub Actions only

# Optional: Include Vercel development environment (for 'vercel dev' command)
./scripts/setup-env.sh --include-vercel-dev
# Note: Not needed for 'bun dev' - only use if you need to test with 'vercel dev'
```

**Options:**
- `--include-vercel-dev` - Also configure Vercel's development environment (for `vercel dev`)
  - ⚠️ **Not needed for normal development** - `bun dev` uses local `.env` file
  - Only use if you need to test Vercel-specific features locally with `vercel dev`
- `-h, --help` - Show help message

---

### `scripts/setup-vercel-env.sh` - Vercel Deployment Only

**What it does:** Configures environment variables and connects your GitHub repository for automatic deployments

**When to use:**
- ✅ You're deploying to Vercel (most common)
- ✅ Your app needs runtime secrets (database, auth, APIs)
- ✅ You want preview deployments on every PR
- ✅ You want automatic deployments when pushing to GitHub

**Sets up:**
- Production environment (main branch → https://yourdomain.com)
- Preview environment (PRs → https://pr-123.vercel.app)
- Development environment (local `vercel dev`)
- **Git integration** (automatic deployments on push)

**Variables configured:**
- `DATABASE_URL` - Neon database connection (prod/staging/dev)
- `BETTER_AUTH_SECRET` - Auth secret per environment
- `GOOGLE_CLIENT_ID/SECRET` - OAuth credentials
- `NEXT_PUBLIC_POSTHOG_KEY` - Analytics
- `POLAR_ACCESS_TOKEN` - Payments
- `UPLOADTHING_TOKEN` - File uploads
- `NEXT_PUBLIC_PROJECT_NAME` - Project identifier

**Git Integration:**
- Automatically detects your GitHub repository
- Connects Vercel to enable automatic deployments
- `git push origin main` → deploys to production
- `git push origin feature` → creates preview deployment

### `scripts/setup-github-secrets.sh` - GitHub Actions Only

**What it does:** Configures secrets for GitHub Actions workflows

**When to use:**
- ✅ You want automated tests on every PR
- ✅ You want E2E tests before merging
- ✅ You want automated database migrations
- ✅ You're deploying from GitHub Actions (not Vercel)

**Sets up:**
- GitHub repository secrets (one set for all workflows)
- Enables GitHub Actions to run tests with real credentials

**Variables configured:**
- `DATABASE_URL_TEST` - For running E2E tests in CI
- `DATABASE_URL_STAGING` - For staging deployments
- `DATABASE_URL_PROD` - For production deployments (if deploying from GH Actions)
- `BETTER_AUTH_SECRET_*` - Per-environment auth secrets
- All third-party service tokens (same as Vercel script)

## Deployment Workflows

### Workflow 1: Vercel-Only (Simplest)

**Best for:** Solo developers, MVPs, projects without extensive testing

```bash
# One-time setup
vercel login
vercel link
./scripts/setup-vercel-env.sh  # Configures env vars + Git integration

# Deploy (automatic after Git integration)
git push origin main              # Auto-deploys to production
git push origin feature-branch    # Auto-deploys preview

# Or deploy manually (if Git integration skipped)
vercel --prod
```

**Pros:**
- Fastest setup (5 minutes)
- Automatic deployments on every push (if Git connected)
- Automatic preview deployments for PRs
- Built-in analytics and monitoring

**Cons:**
- No automated testing before deployment
- No custom CI/CD workflows

**Scripts needed:**
- ✅ `scripts/setup-vercel-env.sh` (includes Git integration setup)
- ❌ `scripts/setup-github-secrets.sh` (not needed)

---

### Workflow 2: GitHub Actions + Vercel (Recommended)

**Best for:** Teams, production apps, quality-focused projects

```bash
# One-time setup (Option 1: Unified - Recommended)
gh auth login
vercel login
vercel link
./scripts/setup-env.sh  # Configure both platforms at once

# One-time setup (Option 2: Separate)
gh auth login
./scripts/setup-github-secrets.sh  # Configure CI/CD
vercel login
vercel link
./scripts/setup-vercel-env.sh      # Configure runtime

# Development workflow
git checkout -b feature/new-thing
# ... make changes ...
git push origin feature/new-thing
# → GitHub Actions runs tests
# → Vercel deploys preview (if tests pass)
# → Merge PR
# → Production deployment
```

**GitHub Actions Configuration:**

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install
      - run: bun run type
      - run: bun lint
      - run: bun test

  e2e:
    runs-on: ubuntu-latest
    env:
      DATABASE_URL: ${{ secrets.DATABASE_URL_TEST }}
      BETTER_AUTH_SECRET: ${{ secrets.BETTER_AUTH_SECRET_TEST }}
      GOOGLE_CLIENT_ID: ${{ secrets.GOOGLE_CLIENT_ID }}
      GOOGLE_CLIENT_SECRET: ${{ secrets.GOOGLE_CLIENT_SECRET }}
      NEXT_PUBLIC_POSTHOG_KEY: ${{ secrets.NEXT_PUBLIC_POSTHOG_KEY }}
      POSTHOG_PROJECT_ID: ${{ secrets.POSTHOG_PROJECT_ID }}
      POLAR_ACCESS_TOKEN: ${{ secrets.POLAR_ACCESS_TOKEN }}
      UPLOADTHING_TOKEN: ${{ secrets.UPLOADTHING_TOKEN }}
      NEXT_PUBLIC_PROJECT_NAME: ${{ secrets.NEXT_PUBLIC_PROJECT_NAME }}
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install
      - run: bunx playwright install --with-deps
      - run: bun run test:e2e
```

**Pros:**
- Automated testing on every PR
- Quality gates before production
- Can run custom workflows (migrations, linting, etc.)
- Best for team collaboration

**Cons:**
- More complex setup (15-20 minutes)
- Requires managing two sets of secrets

**Scripts needed:**
- ✅ `scripts/setup-env.sh` (unified - recommended)
- OR ✅ `scripts/setup-github-secrets.sh` + `scripts/setup-vercel-env.sh` (separate)

---

### Workflow 3: GitHub Actions Only (Self-Hosted)

**Best for:** Custom infrastructure, non-Vercel deployments, enterprise

```bash
# One-time setup
gh auth login
./scripts/setup-github-secrets.sh

# Create deployment workflow
# .github/workflows/deploy.yml
```

**Example deployment workflow:**

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    env:
      DATABASE_URL: ${{ secrets.DATABASE_URL_PROD }}
      BETTER_AUTH_SECRET: ${{ secrets.BETTER_AUTH_SECRET_PROD }}
      # ... other secrets
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install
      - run: bun run build
      - name: Deploy to custom server
        run: |
          # Your custom deployment logic
          # rsync, Docker, Kubernetes, etc.
```

**Pros:**
- Full control over deployment process
- Deploy anywhere (AWS, GCP, your own servers)
- Can integrate with any tools

**Cons:**
- Most complex setup
- You manage infrastructure
- No automatic preview deployments (unless you build it)

**Scripts needed:**
- ✅ `scripts/setup-github-secrets.sh`
- ❌ `scripts/setup-vercel-env.sh` (not needed)

## Environment Variable Reference

### Database URLs

**Local Development (`.env` file):**
```env
DATABASE_URL_DEV='postgresql://...'     # Your dev branch
DATABASE_URL_TEST='postgresql://...'    # Your test branch
DATABASE_URL_STAGING='postgresql://...' # Your staging branch
DATABASE_URL_PROD='postgresql://...'    # Your prod branch
```

**Vercel (via `setup-vercel-env.sh`):**
```bash
DATABASE_URL (production)  → Neon prod branch
DATABASE_URL (preview)     → Neon staging branch
DATABASE_URL (development) → Neon dev branch
```

**GitHub Actions (via `setup-github-secrets.sh`):**
```bash
DATABASE_URL_TEST     → Used by E2E tests in CI
DATABASE_URL_STAGING  → Used by staging deployments
DATABASE_URL_PROD     → Used by production deployments (if deploying from GH)
```

### Better Auth Secrets

**CRITICAL:** Use different secrets for each environment!

```bash
# Generate new secrets
bun run auth:secret  # Run 3 times, use different values

# Set in Vercel
BETTER_AUTH_SECRET (production)  → First generated secret
BETTER_AUTH_SECRET (preview)     → Second generated secret
BETTER_AUTH_SECRET (development) → Third generated secret

# Set in GitHub
BETTER_AUTH_SECRET_PROD     → Same as Vercel production
BETTER_AUTH_SECRET_STAGING  → Same as Vercel preview
BETTER_AUTH_SECRET_TEST     → New secret for CI tests
```

### Public Variables

These are safe to expose in the browser:

- `NEXT_PUBLIC_PROJECT_NAME` - Your project name (used for DB schema namespacing)
- `NEXT_PUBLIC_POSTHOG_KEY` - Analytics key
- `NEXT_PUBLIC_APP_URL` - Your app URL (optional, auto-detected by Vercel)

## Updating Environment Variables

### New Features ✨

All setup scripts now include:
- **Existence checking** - Shows which variables already exist before prompting
- **Skip with Enter** - Press Enter to keep existing values unchanged
- **Blank confirmation** - Confirms before skipping new (non-existing) variables

**Recommended workflow for updating a single variable:**

```bash
# Run the appropriate script and press Enter for all variables except the one you want to update
./scripts/setup-vercel-env.sh      # For Vercel only
./scripts/setup-github-secrets.sh  # For GitHub only
./scripts/setup-env.sh             # For both platforms
```

### Vercel

```bash
# View all variables
vercel env ls

# View specific environment
vercel env ls production
vercel env ls preview

# Update variables (shows which exist, allows skipping with Enter)
./scripts/setup-vercel-env.sh

# Or manually remove and re-add
vercel env rm DATABASE_URL production
./scripts/setup-vercel-env.sh

# Pull current env to local file
vercel env pull .env.local
```

### GitHub Actions

```bash
# View all secrets
gh secret list

# Update variables (shows which exist, allows skipping with Enter)
./scripts/setup-github-secrets.sh

# Or update a single secret manually
gh secret set DATABASE_URL_PROD
```

## Troubleshooting

### "Database connection failed" in Vercel deployment

**Cause:** `DATABASE_URL` not set or incorrect for that environment

**Fix:**
```bash
vercel env ls production         # Check if DATABASE_URL exists
vercel env rm DATABASE_URL production
./scripts/setup-vercel-env.sh   # Re-run setup
```

### "E2E tests fail in GitHub Actions but pass locally"

**Cause:** Missing or incorrect GitHub secrets

**Fix:**
```bash
gh secret list                        # Verify all secrets are set
./scripts/setup-github-secrets.sh    # Re-run if needed

# Check which secret is missing in .github/workflows/ci.yml
# Compare against the env: section
```

### "vercel: command not found"

**Fix:**
```bash
bun add -g vercel
# or
npm i -g vercel
```

### "gh: command not found"

**Fix:**
```bash
# macOS
brew install gh

# Linux (Ubuntu/Debian)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

### "Project not linked to Vercel"

**Fix:**
```bash
vercel link  # Follow prompts to link project
```

### "Git integration failed" or "Deployments not triggered on push"

**Cause:** Git repository not connected to Vercel project, or incorrect permissions

**Fix:**
```bash
# Check current Git connection
vercel project ls

# Reconnect Git repository
vercel git connect $(git remote get-url origin)

# Or set up manually in dashboard:
# 1. Visit https://vercel.com/dashboard
# 2. Select your project → Settings → Git
# 3. Click "Connect Git Repository"
# 4. Authorize Vercel to access your GitHub repo
```

**Verify Git integration is working:**
```bash
# Check Vercel project info
vercel project ls

# Make a test commit and push
git commit --allow-empty -m "test: trigger deployment"
git push origin main

# Check deployments
vercel ls
```

## Security Best Practices

1. **Never commit `.env` files** - Already in `.gitignore`
2. **Use different secrets per environment** - Limits blast radius if compromised
3. **Rotate secrets regularly** - Especially for production
4. **Use secret managers for teams** - 1Password, Bitwarden, AWS Secrets Manager
5. **Audit access** - Regularly check who has access to Vercel/GitHub

## Recommended Setup for New Projects

1. **Initial Development** (Day 1):
   ```bash
   # Just get something running
   cp .env.example .env
   # Fill in .env manually
   bun dev
   ```

2. **First Deployment** (Day 2-7):
   ```bash
   vercel login
   vercel link
   ./scripts/setup-vercel-env.sh  # Sets up env vars + Git integration
   git push origin main           # Auto-deploys (if Git connected)
   # Or manually: vercel --prod
   ```

3. **Add CI/CD** (Week 2):
   ```bash
   gh auth login
   vercel login
   vercel link
   ./scripts/setup-env.sh  # Configure both platforms (unified approach)
   # Or separately:
   # ./scripts/setup-github-secrets.sh
   # Create .github/workflows/ci.yml
   ```

## Next Steps

- **Vercel Dashboard:** https://vercel.com/dashboard
- **GitHub Actions:** https://github.com/YOUR_ORG/YOUR_REPO/actions
- **Neon Database:** https://console.neon.tech

For questions or issues, see the main README.md or open an issue.
