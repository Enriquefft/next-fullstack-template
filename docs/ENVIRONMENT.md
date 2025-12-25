# Environment Variables Reference

This project uses `t3-oss/env-nextjs` for type-safe environment validation. See `.env.example` for the complete template.

## Required Variables

### Project Identity

```bash
NEXT_PUBLIC_PROJECT_NAME=  # Your project name (used for database schema namespacing)
```

### Database

Multi-environment PostgreSQL via Neon Serverless. Automatically selected via `NODE_ENV`:

```bash
DATABASE_URL_DEV=       # Development database
DATABASE_URL_TEST=      # E2E tests and CI
DATABASE_URL_STAGING=   # Staging environment (optional)
DATABASE_URL_PROD=      # Production database
```

### Authentication

```bash
GOOGLE_CLIENT_ID=       # Google OAuth client ID
GOOGLE_CLIENT_SECRET=   # Google OAuth client secret
BETTER_AUTH_SECRET=     # Generate with: bun run auth:secret
BETTER_AUTH_URL=        # Optional: Override auth URL
```

## Optional Services

### Analytics

```bash
NEXT_PUBLIC_POSTHOG_KEY=  # PostHog analytics key
POSTHOG_PROJECT_ID=       # PostHog project ID (optional)
```

### Payments

```bash
POLAR_ACCESS_TOKEN=     # Polar API token
POLAR_MODE=             # sandbox or production
```

### File Uploads

```bash
UPLOADTHING_TOKEN=      # UploadThing API token
```

## Environment-Specific Configuration

The `src/env/db.ts` file automatically selects the correct database URL based on `NODE_ENV`:

- `NODE_ENV=development` → `DATABASE_URL_DEV`
- `NODE_ENV=test` → `DATABASE_URL_TEST`
- `NODE_ENV=production` → `DATABASE_URL_PROD`

For deployment platforms (Vercel, etc.), set `DATABASE_URL` directly - it will override the environment-specific URLs.

## Setup Instructions

1. Copy `.env.example` to `.env`
2. Fill in required variables (see main README Getting Started section)
3. Generate auth secret: `bun run auth:secret`
4. Add service-specific keys as needed

For CI/CD setup, see [docs/DEPLOYMENT.md](DEPLOYMENT.md).
