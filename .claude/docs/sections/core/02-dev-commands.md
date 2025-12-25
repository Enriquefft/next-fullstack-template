## Development Commands

**Package Manager**: This project uses **Bun**. Always use `bun` instead of `npm` or `yarn`.

**Most Frequently Used:**
- `bun dev` – Start development server on port 3000
- `bun run build` – Build for production
- `bun lint` – Lint and format code with Biome
- `bun test` – Run unit tests with Happy DOM
- `bun run test:e2e` – Run end-to-end tests with Playwright
- `bun type` – Type-check without emitting files

**Testing Overview:**
- **Unit tests**: Configured with Happy DOM (preloaded via `bunfig.toml`). Test files live in `tests/` and use `.test.ts` or `.test.tsx` extensions. Run with `bun test`.
- **E2E tests**: Powered by Playwright (config in `e2e/playwright.config.ts`). Test files live in `e2e/tests/` and use `.spec.ts` extensions. Run with `bun run test:e2e`. Override port with `PORT=3001 bun test:e2e` if needed. See `.claude/rules/e2e-testing.md` for detailed documentation.

**Planning & Implementation:**
- **PRD workflow**: Use `/implement-prd` to scaffold from `.claude/prd/` requirements, then `/next-step` for incremental feature development
- **Test-driven**: Each feature requires unit tests and E2E tests matching PRD flows before moving to next feature
- **Plan tracking**: `plan.md` (auto-generated) tracks phases → steps → tasks with explicit test requirements