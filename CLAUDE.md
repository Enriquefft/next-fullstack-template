# CLAUDE.md

Guidance for Claude Code when working in this repository.

Additional context-specific rules load automatically from `.claude/rules/`.

## Commands

**Package Manager**: Bun only. Never use npm or yarn.

```bash
bun dev                # Dev server (port 3000)
bun run build          # Production build
bun test               # Unit tests
bun test:e2e           # E2E tests (PORT=3001 bun test:e2e for custom port)
bun type               # Type check
bun lint               # Lint & format
bun run db:push        # Sync schema (dev only)
bun run db:generate    # Generate migrations
bun run db:migrate     # Apply migrations (prod)
bun run db:studio      # Database GUI
bun run auth:secret    # Generate auth secret
bun run auth:gen       # Regenerate auth types after config changes
```

## File Locations

| Path | Purpose |
|------|---------|
| `src/app/` | Next.js App Router pages |
| `src/components/` | React components |
| `src/components/ui/` | shadcn/ui (excluded from linting) |
| `src/db/` | Database client & schemas |
| `src/db/schema/` | All Drizzle schemas |
| `src/lib/` | Utilities (auth, analytics, kapso, etc.) |
| `src/env/` | Environment validation (client.ts, server.ts, db.ts) |
| `src/hooks/` | Custom React hooks |
| `tests/` | Unit tests (*.test.ts) |
| `e2e/tests/` | E2E tests (*.spec.ts) |
| `scripts/seed/` | Database seed scripts |
| `drizzle/` | Migration files |

## Database

### Schema Pattern

Always use the namespaced schema object:

```ts
import { schema } from "./schema.ts";

export const myTable = schema.table("my_table", {
  id: serial("id").primaryKey(),
  // ...
});
```

Never use `pgSchema` directly. The schema is namespaced by `NEXT_PUBLIC_PROJECT_NAME`.

### Environment Selection

- `DATABASE_URL_DEV` → local development
- `DATABASE_URL_TEST` → E2E tests and CI
- `DATABASE_URL` → Vercel (production/preview)

Logic in `src/env/db.ts`.

### Migrations

- **Development**: `bun run db:push` (direct sync, no history)
- **Production**: `bun run db:generate` → commit → `bun run db:migrate`

Never use `db:push` in CI/CD.

### Seeding

Use scripts in `scripts/seed/`. Never insert data manually except for debugging.

## Code Patterns

### Server Actions (preferred for mutations)

```ts
"use server";

import { db } from "@/db";
import { revalidatePath } from "next/cache";
import { z } from "zod";

const schema = z.object({ title: z.string().min(1) });

export async function createPost(formData: FormData) {
  const parsed = schema.parse({ title: formData.get("title") });
  await db.insert(posts).values(parsed);
  revalidatePath("/posts");
}
```

### Client Auth

```ts
import { useSession } from "@/lib/auth-client";
const { data: session } = useSession();
```

### Forms (TanStack Form + Zod)

```ts
import { useForm } from "@tanstack/react-form";

const form = useForm({
  defaultValues: { email: "" },
  validators: { onChange: emailSchema },
  onSubmit: async ({ value }) => { /* ... */ },
});
```

### Utilities

```ts
import { cn } from "@/lib/utils";
```

### Test Selectors

```tsx
const headingId = useId();

<section aria-labelledby={headingId} data-testid="my-section">
  <h2 id={headingId}>Title</h2>
</section>
```

- `useId()` for accessibility IDs
- `data-testid` for E2E selectors
- `aria-labelledby` only on landmarks (`<section>`, `<nav>`, `<aside>`)

## Type Safety Rules

- Strict mode enabled
- No implicit any
- No `@ts-ignore` — fix the error
- No `as` casting — use type guards or refactor
- Use `@/` path alias for imports from `src/`
- avoid typing return types, prefer infered return types

## Style Rules (Biome)

- Tabs for indentation
- Double quotes
- ~80 char lines
- `PascalCase` for components/types
- `camelCase` for variables/functions
- `kebab-case` for files
- No default exports (except Next.js route files)

## Git

Claude can commit using conventional commit format. Before committing:

```bash
bun type && bun lint && bun run build
```

## Integrations

### Polar (Payments)

- Config: `POLAR_ACCESS_TOKEN`, `POLAR_MODE`
- Use `POLAR_MODE='sandbox'` during development

### Kapso (WhatsApp)

```ts
import { sendTextMessage, sendButtonMessage } from "@/lib/kapso";

await sendTextMessage("+1234567890", "Hello!");
await sendButtonMessage("+1234567890", "Choose:", [
  { id: "a", title: "Option A" },
  { id: "b", title: "Option B" },
]);
```

Webhook: `https://yourdomain.com/api/whatsapp/webhook`

### PostHog (Analytics)

- Server: `src/lib/posthog.ts`
- Client: `src/components/PostHogProvider.tsx`

## Speckit Commands

```bash
/speckit.specify    # Create spec from natural language
/speckit.plan       # Generate technical plan
/speckit.tasks      # Break into tasks
/speckit.implement  # Execute implementation
/speckit.clarify    # Resolve ambiguities
/speckit.analyze    # Validate consistency
/speckit.checklist  # Generate quality checklists
/speckit.constitution  # Define project principles
/speckit.taskstoissues # Convert to GitHub issues
```

Commands defined in `.claude/commands/speckit.*.md`.

## Template Customization

1. Run `/speckit.specify` to configure what to keep/remove
2. Follow `TEMPLATE_CHECKLIST.md`
3. Delete checklist when done

See [README.md](README.md) for full setup instructions.
