You are implementing the next feature from the project plan in a systematic, test-driven approach.

## Workflow

Follow these steps in order. **DO NOT skip steps**.

### Step 1: Verify Plan is Up to Date

1. Read `plan.md` from project root
2. Read `.claude/prd/01-flows/_index.md`
3. Compare plan phases with PRD implementation priority
4. Check if new flows have been added to PRD since plan was created

**If plan is outdated**:
- List detected changes for user
- Ask: "Plan is out of sync with PRD. Should I update plan.md?"
- If approved: Update plan.md to match current PRD
- If declined: Stop and wait for guidance

**If plan is current**: Continue to Step 2

### Step 2: Verify Current Implementation is Tested

1. Identify the last completed feature from TodoWrite or plan.md
2. **Check Unit Tests**:
   - Search `tests/` for tests covering implemented server actions
   - Search `tests/` for tests covering utilities/helpers
   - Run `bun test` to verify they pass
3. **Check E2E Tests** (if feature has user-facing flows):
   - Search `e2e/tests/` for tests matching PRD flows
   - Verify E2E test coverage matches flow specification
   - Run `bun run test:e2e` to verify they pass

**If tests are missing or failing**:
- Alert user with specific details:
  * "Missing unit tests for: [list server actions/utilities]"
  * "Missing E2E test for flow: [flow name from PRD]"
  * "Failing tests: [list test names and errors]"
- Ask: "Should I write the missing tests before proceeding?"
- If approved: Write tests, verify they pass, continue to Step 3
- If declined: Stop and wait for guidance

**If all tests pass**: Continue to Step 3

### Step 3: Implement Next Feature

1. Read `plan.md` to identify next feature/task
2. Read corresponding PRD flow file from `.claude/prd/01-flows/`
3. Read related technical specs (data models, API design) if referenced in flow
4. Create TodoWrite task list for this feature (if not already exists)

**Announce to user**:

```
✅ Tests verified for: [last feature name]
✅ Plan is up to date
📋 Next up: [next feature name]

Flow reference: `.claude/prd/01-flows/[file].md`

I'll now implement: [brief description of what will be built]

Tasks for this step:
- [List tasks from plan.md]
```

5. **Implement feature** following this order:
   - Database schema changes (if needed)
   - Server actions with Zod validation
   - UI components (forms, pages)
   - Unit tests for server actions
   - E2E tests based on PRD flows

6. **Update TodoWrite** as you complete each task
7. **Update plan.md**: Mark completed tasks with `[x]` (see "Updating plan.md" section below)
8. **When feature is complete**: Stop and announce completion

**Completion announcement**:

```
✅ Feature complete: [feature name]

Implemented:
- Database: [tables created/modified]
- Server Actions: [actions implemented]
- UI Components: [components/pages created]
- Unit Tests: [test files]
- E2E Tests: [test scenarios]

All tests passing:
- ✅ Unit tests: bun test
- ✅ E2E tests: bun run test:e2e
- ✅ Type check: bunx tsc --noEmit
- ✅ Linting: bun lint

📋 Updated plan.md: [Step X.X] marked complete ✅

Ready for next step. Run `/next-step` again to continue.
```

## Important Guidelines

### Never Skip Testing Verification
Always check tests before implementing next feature. This ensures:
- No regressions from previous work
- Current implementation is solid
- Tests serve as documentation

### Never Implement Without Plan
If `plan.md` doesn't exist:
- Alert user: "No plan.md found. Please run `/implement-prd` first."
- Stop and wait

### Always Reference PRD
Read flow files to understand requirements. Don't assume or add features not in PRD.

### Ask When Unsure
If plan is ambiguous or PRD is unclear, use AskUserQuestion:
- "The flow doesn't specify error message text. What should it say?"
- "Should this validation be client-side, server-side, or both?"

### One Feature at a Time
Complete current feature fully (including tests) before moving to next.

## Updating plan.md

**IMPORTANT**: After completing each task, update `plan.md` to reflect progress.

### How to Mark Tasks Complete

1. **Individual tasks**: Change `- [ ]` to `- [x]` for each completed task
2. **Test requirements**: Mark test items as complete when tests are written and passing

### When to Update

Update `plan.md` incrementally as you work:
- After completing each task in a step (e.g., creating a schema, implementing a server action)
- After writing and verifying tests pass
- Before announcing feature completion

### Example Update

**Before**:
```markdown
### Step 1.1: User Signup
**Tasks**:
- [ ] Create User table schema in `src/db/schema/user.ts`
- [ ] Implement `signUp()` server action with Zod validation
- [ ] Create SignUpForm component

**Test Requirements**:
- **Unit Tests**:
  - [ ] `tests/actions/auth.test.ts` - Test signUp() validation
- **E2E Tests**:
  - [ ] `e2e/tests/auth.spec.ts` - "user can sign up with email and password"
```

**After** (when step is complete):
```markdown
### Step 1.1: User Signup ✅
**Tasks**:
- [x] Create User table schema in `src/db/schema/user.ts`
- [x] Implement `signUp()` server action with Zod validation
- [x] Create SignUpForm component

**Test Requirements**:
- **Unit Tests**:
  - [x] `tests/actions/auth.test.ts` - Test signUp() validation
- **E2E Tests**:
  - [x] `e2e/tests/auth.spec.ts` - "user can sign up with email and password"
```

### Marking Steps and Phases Complete

- Add `✅` after step title when all tasks and tests are complete
- Add `✅` after phase title when all steps in that phase are complete

Example:
```markdown
## Phase 1: MVP ✅

### Step 1.1: User Signup ✅
...

### Step 1.2: User Login ✅
...
```

## Implementation Order (Reminder)

For each feature, always follow this sequence:

1. **Database Schema** - Define tables, relationships
2. **Server Actions** - Business logic with validation
3. **UI Components** - Forms, pages, layouts
4. **Unit Tests** - Test server actions in isolation
5. **E2E Tests** - Test complete user flows

## Test Requirements

### Unit Tests

Test server actions thoroughly:

```typescript
// tests/actions/[feature].test.ts
import { describe, it, expect } from "bun:test";
import { [action] } from "@/app/actions/[feature]";

describe("[action]", () => {
  it("succeeds with valid input", async () => {
    const formData = new FormData();
    formData.append("field", "value");

    const result = await [action](formData);

    expect(result.success).toBe(true);
  });

  it("fails with invalid input", async () => {
    // Test validation
  });

  it("handles edge case", async () => {
    // Test edge cases
  });
});
```

### E2E Tests

Test flows from PRD:

```typescript
// e2e/tests/[feature].spec.ts
import { test, expect } from "@playwright/test";

test("user can [action] - happy path", async ({ page }) => {
  // Follow steps from PRD flow exactly
  await page.goto("/[route]");
  // ... steps from flow

  // Verify expected DB state
  const dbUser = await getUserByEmail("test@example.com");
  expect(dbUser).toBeTruthy();

  // Verify UI state
  await expect(page).toHaveURL("/expected-route");
});

test("shows error for [error case]", async ({ page }) => {
  // Follow error flow from PRD
});
```

## Example Session

**User**: `/next-step`

**Claude**: Reading plan.md...
**Claude**: Reading .claude/prd/01-flows/_index.md...
**Claude**: ✅ Plan is up to date with PRD

**Claude**: Checking tests for last completed feature: "User Signup"...
**Claude**: Running `bun test`...
**Claude**: ✅ Unit tests passing for signUp() server action
**Claude**: Running `bun run test:e2e`...
**Claude**: ✅ E2E tests passing for signup flows (4/4 scenarios)

**Claude**:
```
✅ Tests verified for: User Signup
✅ Plan is up to date
📋 Next up: User Login

Flow reference: `.claude/prd/01-flows/auth/login-flows.md`

I'll now implement: Email/password login with session management, including error handling for invalid credentials and unverified emails.

Tasks for this step:
- [ ] Implement signIn() server action with Zod validation
- [ ] Create SignInForm component
- [ ] Add login page at /login
- [ ] Add unit tests for signIn() action
- [ ] Add E2E tests for login flows (5 scenarios)
```

**Claude**: [Proceeds to implement login feature systematically]

**Claude**: [Updates plan.md after each task - marks `- [ ]` → `- [x]`]

**Claude**: [After completing all tasks]
```
✅ Feature complete: User Login

Implemented:
- Server Actions: signIn() with email/password validation
- UI Components: SignInForm, /login page
- Unit Tests: tests/actions/auth.test.ts (signIn tests added)
- E2E Tests: e2e/tests/auth.spec.ts (5 login scenarios)

All tests passing:
- ✅ Unit tests: bun test
- ✅ E2E tests: bun run test:e2e
- ✅ Type check: bunx tsc --noEmit
- ✅ Linting: bun lint

📋 Updated plan.md: Step 1.2 marked complete ✅

Ready for next step. Run `/next-step` again to continue.
```

## Handling the UI/UX Revamp Step

The UI/UX Revamp step (Step F.1) is **iterative**. Handle it differently:

### Iteration Process

1. **Analyze current state**: Review the application's visual design
2. **Identify improvements**: List 3-5 specific UI/UX issues to fix
3. **Implement changes**: Make the improvements
4. **Evaluate**: Check if the UI meets quality standards
5. **Repeat or complete**: If not satisfactory, go back to step 1

### Evaluation Criteria

Ask yourself these questions after each iteration:
- Does the visual hierarchy guide user attention effectively?
- Is spacing consistent throughout the app?
- Are colors harmonious and accessible?
- Do interactive elements have clear affordances?
- Is the mobile experience smooth?

### When to Mark Complete

Mark the UI/UX step complete when:
- All items in the Quality Checklist are checked
- The app looks polished and professional
- No obvious visual inconsistencies remain

### Example UI/UX Iteration

```
🎨 UI/UX Revamp - Iteration 1

Current issues identified:
1. Inconsistent button padding across forms
2. Card shadows too harsh
3. Mobile nav menu lacks smooth transition
4. Form labels have inconsistent font weights
5. Empty states use plain text, need illustrations

Implementing fixes...

[Makes changes]

Evaluation: Better, but spacing in dashboard cards still inconsistent.
Continuing to iteration 2...
```

```
🎨 UI/UX Revamp - Iteration 2

Remaining issues:
1. Dashboard card spacing inconsistent
2. Table headers need better visual weight
3. Loading spinners are plain

Implementing fixes...

[Makes changes]

Evaluation: ✅ UI meets quality standards. Marking complete.
```

## Error Handling

### If Tests Fail

Don't proceed until tests pass. Fix the issues:

```
❌ Tests failing for: User Signup

Failed tests:
- tests/actions/auth.test.ts → "handles duplicate email"
- e2e/tests/auth.spec.ts → "shows error for weak password"

I need to fix these before proceeding. Working on fixes...

[Fix the issues]

✅ All tests now passing. Proceeding with next feature.
```

### If Plan is Missing Steps

```
⚠️ Warning: plan.md is missing details for next step

The plan says "Implement profile editing" but doesn't specify:
- Which flows to implement
- What database changes are needed
- What tests to write

Should I:
1. Read the PRD flows and infer the tasks?
2. Ask you to update plan.md first?
```

## Notes

- This command enforces test-driven development
- Every feature must have tests before moving on
- Follow PRD flows exactly - don't add extra features
- Keep plan.md in sync with PRD
