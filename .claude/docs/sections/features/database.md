### Database Architecture

Multi-environment PostgreSQL via **Neon Serverless**:

- **Production/Deployment**: Use `DATABASE_URL` environment variable (set by hosting platform)
- **Local Development**: Environment-specific URLs automatically selected via `NODE_ENV`:
  - `NODE_ENV=development` → `DATABASE_URL_DEV`
  - `NODE_ENV=test` → `DATABASE_URL_TEST`
  - `NODE_ENV=production` → `DATABASE_URL_PROD`

**Key Points**:
- Configuration logic in `src/env/db.ts` with automatic selection
- No Docker or local PostgreSQL required—uses Neon branches
- See `.env.example` for setup template
- **Driver**: Uses `drizzle-orm/neon-serverless` for full transaction support
- **E2E Tests**: WebSocket configured with `ws` package for Node.js/CI environments (see `e2e/setup/db.ts`)
- **Schema Management**: E2E global setup automatically pushes schema via `drizzle-kit push` before each test run

#### Database Migration Workflow

**Development (Local)**:
- Use `bun run db:push` for rapid iteration—directly syncs schema changes without migration files
- Ideal for prototyping and quick schema adjustments

**Production/Staging Deployment**:
```bash
# 1. Generate migration files from schema changes
bun run db:generate

# 2. Review generated SQL in drizzle/ folder
# Commit migration files to git

# 3. In deployment: Run migrations before starting the app
bun run db:migrate
```

**Key Differences**:
- `db:push`: Direct schema sync, no history, **development only**
- `db:generate` + `db:migrate`: Version-controlled migrations with rollback capability, **required for production**

**Migration files** are stored in `drizzle/` and provide:
- Complete schema change history
- Peer review via git commits
- Safe rollback capability
- Protection against data loss

**IMPORTANT**: Never use `db:push` in CI/CD or deployment pipelines. Always use migration-based workflow for production/staging environments.

### Database Layer

Uses **Drizzle ORM** with **Neon Serverless** driver for PostgreSQL.

- **Connection**: `src/db/index.ts` exports `db` instance using `databaseUrl` from `src/env/db.ts`
- **Schema organization**: All schemas live in `src/db/schema/` directory
  - `schema.ts` creates the base schema using `pgSchema(env.NEXT_PUBLIC_PROJECT_NAME)` – this means all tables are namespaced by project name
  - `index.ts` re-exports all schemas for convenient imports
  - `auth.ts` contains Better Auth tables (user, session, account, verification)
  - `post.ts` is an example schema file
- **Schema filter**: `drizzle.config.ts` uses `schemaFilter` to isolate this project's tables by `NEXT_PUBLIC_PROJECT_NAME`
- **Important**: When creating new tables, always use the `schema` object from `schema.ts`, not `pgSchema` directly

**Important Pattern - Database schemas must use the namespaced schema object**:
```ts
import { schema } from "./schema.ts";
export const myTable = schema.table("my_table", { ... });
```