## PRD-Based Development Workflow

This template supports a structured workflow from requirements to implementation:

### 1. Generate PRD in Claude Chat

Use Claude Chat to create your Product Requirements Document from your project idea. The PRD should be structured as:

- `00-overview.md` – Project vision, success metrics, template customization notes
- `01-flows/` – User flows organized by feature domain (auth/, payments/, etc.)
- `02-data-models.md` – Database schema specifications
- `03-api-design.md` – Server actions and API design
- `04-ui-components.md` – UI/UX specifications
- `05-integrations.md` – Third-party services and APIs

See `.claude/prd/` for templates and examples.

### 2. Place PRD in `.claude/prd/`

Copy generated PRD files into `.claude/prd/` directory in your cloned template.

### 3. Run `/implement-prd`

Execute the `/implement-prd` slash command in Claude Code. This will:
- Read your PRD requirements
- Customize template (remove unused features, update configs)
- Generate `plan.md` with implementation roadmap
- **Rebuild CLAUDE.md** with only the features your project needs

### 4. Incremental Implementation with `/next-step`

Run `/next-step` repeatedly to implement features one at a time:
- Verifies previous feature has passing tests
- Implements next feature from plan.md
- Creates unit tests and E2E tests
- Validates with `bun test` and `bun run test:e2e`

For detailed guidance, see `.claude/rules/prd-implementation.md` (auto-loads when working in `src/` or `.claude/prd/`).