# Database Migration Deployment Guide

This guide covers how to run database migrations in production/staging environments across different hosting platforms.

## Table of Contents

- [General Principles](#general-principles)
- [Platform-Specific Guides](#platform-specific-guides)
  - [Vercel](#vercel)
  - [Railway](#railway)
  - [Render](#render)
  - [Fly.io](#flyio)
  - [Docker/Custom](#dockercustom)
- [CI/CD Integration](#cicd-integration)
- [Troubleshooting](#troubleshooting)

## General Principles

### ✅ DO

- **Run migrations before starting the app** in production
- **Use `bun run db:migrate`** in deployment scripts
- **Commit migration files** to version control
- **Test migrations** on staging/test database first
- **Review generated SQL** before deploying
- **Set `DATABASE_URL`** environment variable in production

### ❌ DON'T

- **Never use `db:push`** in production/staging
- **Never skip migration review** before deploying
- **Don't run migrations concurrently** from multiple instances
- **Don't manually edit the database** without migrations
- **Don't delete old migration files** (breaks history)

## Migration Workflow

```bash
# 1. Make schema changes in src/db/schema/
# Edit your tables...

# 2. Generate migration files
bun run db:generate

# 3. Review the generated SQL
cat drizzle/0001_migration_name.sql

# 4. Commit to git
git add drizzle/
git commit -m "feat: add user_preferences table"
git push

# 5. Deploy (migrations run automatically via platform config)
```

---

## Platform-Specific Guides

### Vercel

Vercel doesn't support build-time database operations by default. Use a separate deploy hook or script.

#### Option 1: Pre-build Script (Recommended)

Create a pre-build script that runs migrations:

```json
// package.json
{
  "scripts": {
    "vercel-build": "bun run db:migrate && bun run build"
  }
}
```

**Environment Variables** (Vercel Dashboard):
```bash
DATABASE_URL=postgresql://your-production-url
NODE_ENV=production
```

#### Option 2: Deploy Hook (Advanced)

For zero-downtime deployments, use a separate service to run migrations:

1. Create a GitHub Action that runs migrations on push to main
2. Wait for migrations to complete
3. Trigger Vercel deployment

```yaml
# .github/workflows/deploy.yml
name: Deploy with Migrations

on:
  push:
    branches: [main]

jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v1
      - run: bun install
      - run: bun run db:migrate
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}

  deploy:
    needs: migrate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
```

---

### Railway

Railway supports build-time scripts and has excellent PostgreSQL integration.

#### Configuration

**railway.json** (create in project root):
```json
{
  "build": {
    "builder": "nixpacks"
  },
  "deploy": {
    "startCommand": "bun run start",
    "restartPolicyType": "on-failure",
    "restartPolicyMaxRetries": 10
  }
}
```

**Procfile** (create in project root):
```procfile
release: bun run db:migrate
web: bun run start
```

**Environment Variables** (Railway Dashboard):
```bash
DATABASE_URL=${{ POSTGRES.DATABASE_URL }}  # Auto-set if using Railway Postgres
NODE_ENV=production
```

The `release` command runs before each deployment and is perfect for migrations.

---

### Render

Render supports pre-deploy commands in the dashboard or `render.yaml`.

#### render.yaml

```yaml
services:
  - type: web
    name: my-app
    env: node
    buildCommand: bun install && bun run build
    startCommand: bun run start
    preDeployCommand: bun run db:migrate
    envVars:
      - key: NODE_ENV
        value: production
      - key: DATABASE_URL
        fromDatabase:
          name: my-postgres-db
          property: connectionString
```

#### Dashboard Configuration

1. Go to your service settings
2. Add **Pre-Deploy Command**: `bun run db:migrate`
3. Ensure `DATABASE_URL` is set in Environment Variables

---

### Fly.io

Fly.io uses `fly.toml` for configuration and supports release commands.

#### fly.toml

```toml
app = "my-app"
primary_region = "sjc"

[build]
  builder = "nixpacks"

[deploy]
  release_command = "bun run db:migrate"

[env]
  NODE_ENV = "production"

[[services]]
  internal_port = 3000
  protocol = "tcp"

  [[services.ports]]
    port = 80
    handlers = ["http"]

  [[services.ports]]
    port = 443
    handlers = ["tls", "http"]
```

**Set Database URL**:
```bash
fly secrets set DATABASE_URL="postgresql://..."
```

The `release_command` runs migrations on every deployment before starting new instances.

---

### Docker/Custom

For Docker or custom deployment environments, run migrations in the entrypoint script.

#### Dockerfile

```dockerfile
FROM oven/bun:1

WORKDIR /app

COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile

COPY . .
RUN bun run build

# Entrypoint script runs migrations
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bun", "run", "start"]
```

#### docker-entrypoint.sh

```bash
#!/bin/bash
set -e

echo "Running database migrations..."
bun run db:migrate

echo "Starting application..."
exec "$@"
```

#### Docker Compose

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/mydb
      - NODE_ENV=production
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16
    environment:
      POSTGRES_DB: mydb
      POSTGRES_PASSWORD: password
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
```

---

## CI/CD Integration

### GitHub Actions

Run migrations in CI for testing, but not for production deployment:

```yaml
name: CI

on: [pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v1

      - run: bun install

      - name: Run migrations
        run: bun run db:migrate
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test
          NODE_ENV: test

      - run: bun test
      - run: bun run test:e2e
      - run: bun type
      - run: bun lint
```

**Note**: This runs migrations in CI for testing. Production migrations should run via platform-specific deploy hooks.

---

## Troubleshooting

### Migration Fails: "relation already exists"

**Cause**: Migration was partially applied or database state doesn't match migration history.

**Solution**:
1. Check `drizzle.__drizzle_migrations` table to see which migrations ran
2. Manually fix database state or reset to match
3. For development databases, you can drop and recreate (NEVER do this in production)

```sql
-- Check migration history
SELECT * FROM drizzle.__drizzle_migrations ORDER BY created_at DESC;
```

### Multiple Deployments Running Migrations Concurrently

**Cause**: Multiple instances trying to apply migrations at the same time.

**Solution**:
- Use platform-specific release commands (Railway, Fly.io) that run once before deployment
- Implement a migration lock mechanism
- Run migrations manually before deployment, then deploy

### Migration Succeeds But App Crashes

**Cause**: Application code expects schema that hasn't been migrated yet (deployment race condition).

**Solution**:
- Ensure migrations run **before** the app starts
- Use pre-deploy or release commands
- For zero-downtime deployments, make migrations backward-compatible

### "Cannot find module './drizzle'"

**Cause**: Migration files not included in build or deployment.

**Solution**:
- Ensure `drizzle/` folder is committed to git
- Check `.gitignore` doesn't exclude `drizzle/`
- Verify build process copies migration files

---

## Best Practices

1. **Always test on staging first**: Run migrations on a staging environment with production-like data
2. **Backup before major migrations**: Take a database snapshot before destructive changes
3. **Make migrations backward-compatible**: Allow old code to run during deployment
4. **Monitor migration duration**: Long-running migrations can cause downtime
5. **Use transactions**: Drizzle migrations run in transactions by default—don't disable this
6. **Review generated SQL**: Always check what Drizzle generates before deploying

---

## Quick Reference

| Environment | Command | When |
|-------------|---------|------|
| **Development** | `bun run db:push` | Rapid iteration |
| **Pre-deployment** | `bun run db:generate` | After schema changes |
| **Production/Staging** | `bun run db:migrate` | During deployment |
| **Review** | `cat drizzle/*.sql` | Before committing |

---

For more information, see:
- [Drizzle Migrations Documentation](https://orm.drizzle.team/docs/migrations)
- [Neon Branching Guide](https://neon.tech/docs/guides/branching)
- Project `CLAUDE.md` - Database Architecture section
