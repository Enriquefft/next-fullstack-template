### Code Organization

- `src/app/` – Next.js 15 App Router pages and routes
- `src/components/` – React components
  - `ui/` – shadcn/ui primitives (excluded from Biome linting)
  - Root level: Custom components
- `src/db/` – Database client and schemas
- `src/lib/` – Utilities and shared logic
- `src/hooks/` – Custom React hooks
- `src/styles/` – Global CSS and fonts
- `src/metadata.ts` – Centralized Next.js metadata (title, description, OG images)
- `tests/` – Unit tests (Happy DOM)
- `e2e/` – End-to-end tests (Playwright)
  - `setup/` – Global setup/teardown and database utilities
  - `helpers/` – Auth, database, and fixture helpers
  - `fixtures/` – Seed data definitions
  - `tests/` – Test files (*.spec.ts)
  - `playwright.config.ts` – Playwright configuration