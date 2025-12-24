---
paths: ["src/**", ".claude/prd/**"]
---

# PRD Implementation Guidelines

This rule auto-loads when working in `src/` or `.claude/prd/` to guide PRD-based implementation.

## Finding Relevant PRD Files

**IMPORTANT**: Do NOT read all PRD files at once. Follow this efficient process:

### Step 1: Always Read Index First

```
1. Read `.claude/prd/01-flows/_index.md`
2. Use "Quick Reference" table to find relevant flow file
3. Check "File Relationships" for dependencies
```

### Step 2: Read Only Necessary Files

Based on the feature you're implementing:

```
Feature: User Signup
→ Read: .claude/prd/01-flows/auth/signup-flows.md
→ Read: .claude/prd/02-data-models.md (User/Session tables only)
→ Read: .claude/prd/03-api-design.md (signUp() action only)
```

**Avoid**: Reading entire `01-flows/` directory or all technical specs

### Step 3: Check Dependencies

The index file lists which data models and integrations each flow depends on. Only read those specific sections.

## Implementation Order

Follow this sequence for each feature:

### 1. Database Schema

**First**, implement data layer:
- Read relevant tables from `02-data-models.md`
- Create/update schema files in `src/db/schema/`
- Use the `schema` object from `schema.ts` (namespace)
- Run `bun run db:push` to apply changes

### 2. Server Actions

**Second**, implement business logic:
- Read server action specs from `03-api-design.md`
- Create actions in `src/app/actions/`
- Add Zod validation schemas
- Implement error handling
- Test with unit tests in `tests/`

### 3. UI Components

**Third**, build the interface:
- Read component specs from `04-ui-components.md`
- Create forms using TanStack Form
- Create page components
- Add proper loading and error states

### 4. Unit Tests

**Fourth**, test business logic:
- Write tests for server actions in `tests/`
- Test validation schemas
- Test error handling
- Run `bun test` to verify

### 5. E2E Tests

**Finally**, test complete flows:
- Read E2E test mapping from flow file
- Create/update E2E tests in `e2e/tests/`
- Follow flow steps exactly as documented
- Verify database state changes
- Run `bun run test:e2e` to verify

## Validation Checklist

Before marking a feature complete, verify:

- [ ] **Database schema** matches PRD data models
- [ ] **Server actions** have Zod validation
- [ ] **Error handling** covers all error cases from flows
- [ ] **Forms** use TanStack Form with proper validation
- [ ] **Unit tests** exist for server actions
- [ ] **E2E tests** cover all flows (happy path + errors)
- [ ] **Type checking** passes (`bunx tsc --noEmit`)
- [ ] **Linting** passes (`bun lint`)
- [ ] **Build** succeeds (`bun run build`)

## Referencing PRD in Code

### In Commits

Reference the specific flow when committing:

```bash
git commit -m "feat: implement email/password signup

Implements flow from .claude/prd/01-flows/auth/signup-flows.md:12

- Add signUp() server action with validation
- Create SignUpForm component
- Add E2E tests for happy path and error cases"
```

### In Pull Requests

Link to PRD flows in PR descriptions:

```markdown
## Changes

Implements user signup feature as specified in:
- Flow: `.claude/prd/01-flows/auth/signup-flows.md` (Flows 1-4)
- Data Models: `.claude/prd/02-data-models.md` (User, Session tables)

## Test Coverage

- ✅ Unit tests: `tests/actions/auth.test.ts`
- ✅ E2E tests: `e2e/tests/auth.spec.ts` (3 new scenarios)
```

### In Code Comments

For complex business logic, reference the flow:

```typescript
/**
 * Creates new user account with email/password
 *
 * Flow: .claude/prd/01-flows/auth/signup-flows.md:12 (Flow 1)
 *
 * @param formData - Email and password from signup form
 * @returns Success/error result with user data
 */
export async function signUp(formData: FormData) {
  // Implementation
}
```

## Handling Ambiguities

If the PRD is unclear or missing details, use `AskUserQuestion`:

```
❌ Don't assume implementation details
✅ Ask: "The PRD doesn't specify if usernames must be unique. Should I enforce this?"

❌ Don't add features not in PRD
✅ Ask: "Should I add a 'Remember me' checkbox, or just use 30-day sessions?"

❌ Don't skip error handling
✅ Ask: "How should we handle the case where email sending fails?"
```

## Common Patterns

### Reading Multiple Related Flows

If implementing a feature that spans multiple flows:

```
1. Read index to identify all related flow files
2. Read flows in implementation priority order
3. Note dependencies between flows
4. Implement in phases, testing each phase
```

### Updating Existing Features

When modifying existing features:

```
1. Read original flow that was implemented
2. Check if PRD has been updated
3. Identify what changed
4. Update code, tests, and documentation
5. Revalidate against updated flow
```

### Adding New Flows

When requirements change and new flows are added:

```
1. Claude Code can add new flow files
2. Update .claude/prd/01-flows/_index.md
3. Add to "Quick Reference" table
4. Update "Implementation Priority"
5. Add to "E2E Test Coverage Matrix"
```

## Example Workflow

### Task: "Implement user signup feature"

```
Step 1: Read Index
→ Read .claude/prd/01-flows/_index.md
→ Find "User Signup" → auth/signup-flows.md

Step 2: Read Flow File
→ Read .claude/prd/01-flows/auth/signup-flows.md
→ Note: 6 flows total (1 happy path, 4 errors, 1 verification)
→ Note: Depends on User/Session tables

Step 3: Read Data Models
→ Read .claude/prd/02-data-models.md
→ Focus on User and Session table specs only
→ Note schema namespace requirement

Step 4: Read API Design
→ Read .claude/prd/03-api-design.md
→ Focus on signUp() action spec only
→ Note validation requirements

Step 5: Implement
→ Create user/session tables (if not exist)
→ Implement signUp() with Zod validation
→ Create SignUpForm component
→ Write unit tests
→ Write E2E tests for all 6 flows

Step 6: Validate
→ Run bun test (unit tests pass)
→ Run bun run test:e2e (all flows pass)
→ Run bunx tsc --noEmit (types pass)
→ Run bun lint (linting passes)
→ Run bun run build (build succeeds)
```

## Performance Tips

### Context Efficiency

- **Don't**: Read all PRD files at start
- **Do**: Read index + specific files as needed

- **Don't**: Re-read files you've already read
- **Do**: Keep track of what you've read in session

- **Don't**: Read entire technical spec files
- **Do**: Search for specific sections (e.g., "### signUp()")

### File Size Management

- Flow files should stay under 600 lines (12-15 flows)
- If a flow file grows too large, split into sub-features
- Technical spec files can be longer (shared reference)

## Notes

- PRD files are the source of truth for requirements
- Code should match PRD specifications exactly
- Deviations from PRD should be documented and approved
- Update PRD if requirements change, don't just update code
