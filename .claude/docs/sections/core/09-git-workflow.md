## Git Workflow

**Claude commits**: Claude Code can create commits following the conventional commit format. Always ensure `bun type`, `bun lint`, `bun run build` are successful before committing.

**PRD references in commits**: When implementing features from `.claude/prd/`, reference the specific flow file and line number in commit messages:

```bash
git commit -m "feat: implement email/password signup

Implements flow from .claude/prd/01-flows/auth/signup-flows.md:12

- Add signUp() server action with validation
- Create SignUpForm component
- Add E2E tests for happy path and error cases"
```