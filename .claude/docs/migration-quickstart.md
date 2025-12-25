# Database Migration Quick Reference

## Commands Added

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `bun run db:generate` | Generate migration files from schema changes | After modifying `src/db/schema/` files |
| `bun run db:migrate` | Apply pending migrations to database | During production/staging deployment |
| `bun run db:push` | Directly sync schema (no migrations) | **Development only** - rapid iteration |
| `bun run db:studio` | Open Drizzle Studio GUI | Inspect database visually |

## Development Workflow

```bash
# 1. Modify schema files
# Edit files in src/db/schema/

# 2. Push changes directly (development only)
bun run db:push

# 3. Test your changes
bun dev
```

## Production Deployment Workflow

```bash
# 1. Modify schema files
# Edit files in src/db/schema/

# 2. Generate migration files
bun run db:generate

# 3. Review the generated SQL
cat drizzle/0001_*.sql

# 4. Test migration on test database
NODE_ENV=test bun run db:migrate

# 5. Commit migration files
git add drizzle/
git commit -m "feat: add user_preferences table"

# 6. Push to trigger deployment
git push

# 7. Migrations run automatically via platform config
# (See .claude/docs/deployment.md for platform setup)
```

## File Structure

```
├── drizzle/                    # Generated migration files (commit these!)
│   ├── 0000_initial.sql
│   ├── 0001_add_users.sql
│   └── meta/                   # Migration metadata
├── scripts/
│   └── migrate.ts              # Migration runner script
├── src/
│   ├── db/
│   │   └── schema/             # Your schema definitions
│   │       ├── schema.ts       # Base schema object
│   │       ├── auth.ts         # Better Auth tables
│   │       └── *.ts            # Your custom tables
│   └── env/
│       └── db.ts               # Database URL logic
└── drizzle.config.ts           # Drizzle configuration
```

## Environment Variables

### Development
```bash
DATABASE_URL_DEV='postgresql://...'    # For NODE_ENV=development
DATABASE_URL_TEST='postgresql://...'   # For NODE_ENV=test
```

### Production
```bash
DATABASE_URL='postgresql://...'        # Set by hosting platform
NODE_ENV='production'
```

## Platform Setup

See `.claude/docs/deployment.md` for detailed guides:
- **Vercel**: Pre-build script or GitHub Actions
- **Railway**: `release` command in Procfile
- **Render**: Pre-deploy command
- **Fly.io**: `release_command` in fly.toml
- **Docker**: Entrypoint script

## Common Issues

### "Migration already applied"
- Check `drizzle.__drizzle_migrations` table
- Ensure migration files are in sync with database state

### "Cannot find module './drizzle'"
- Ensure `drizzle/` folder is committed to git
- Check deployment includes migration files

### Concurrent migrations
- Use platform-specific release commands
- Migrations run once before deployment, not per instance

## Best Practices

✅ **DO**
- Generate migrations before deploying
- Review generated SQL files
- Test on staging first
- Commit migration files to git
- Use `db:migrate` in production

❌ **DON'T**
- Use `db:push` in production
- Edit migration files manually
- Delete old migration files
- Skip migration review
- Run migrations concurrently

## Example: Adding a New Table

```typescript
// src/db/schema/preferences.ts
import { pgTable, text, timestamp, uuid } from "drizzle-orm/pg-core";
import { schema } from "./schema.ts";

export const userPreferences = schema.table("user_preferences", {
	id: uuid("id").defaultRandom().primaryKey(),
	userId: uuid("user_id").notNull(),
	theme: text("theme").notNull().default("light"),
	createdAt: timestamp("created_at").defaultNow().notNull(),
});
```

```bash
# Generate migration
bun run db:generate

# Review output
cat drizzle/0001_*.sql

# Commit
git add src/db/schema/preferences.ts drizzle/
git commit -m "feat: add user preferences table"
git push
```

## Migration Script Details

The `scripts/migrate.ts` file:
- Uses `drizzle-orm/neon-serverless` driver
- Reads from `databaseUrl` (environment-aware)
- Applies migrations from `./drizzle` folder
- Exits with error code 1 on failure
- Safe for concurrent calls (Drizzle handles locking)

## Next Steps

1. ✅ Schema changes → `bun run db:generate`
2. ✅ Review SQL → `cat drizzle/*.sql`
3. ✅ Test → `NODE_ENV=test bun run db:migrate`
4. ✅ Commit → `git add drizzle/ && git commit`
5. ✅ Deploy → Platform runs `bun run db:migrate` automatically

For detailed platform configuration, see `.claude/docs/deployment.md`.
