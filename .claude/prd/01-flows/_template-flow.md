# [Feature] Flows

**Related PRD Files**:
- Data Models: `02-data-models.md` → [List relevant tables]
- API Design: `03-api-design.md` → [List relevant server actions]
- UI Components: `04-ui-components.md` → [List relevant components/pages]

**Contents**:
1. [Flow 1 Name - Happy Path](#flow-1-flow-name-happy-path)
2. [Flow 2 Name - Error Case](#flow-2-flow-name-error-case)
3. [Flow 3 Name - Alternative Path](#flow-3-flow-name-alternative-path)

---

## Flow 1: [Flow Name] (Happy Path)

**User Goal**: As a [user type/persona], I want to [action/goal] so that [benefit/outcome]

**Preconditions**:
- [Initial state requirement 1]
- [Initial state requirement 2 - e.g., user is authenticated, data exists, etc.]

**Steps**:
1. User [action - e.g., navigates to /page]
2. System [response - e.g., displays form, loads data]
3. User [action - e.g., fills out field with value]
4. System [validation/processing]
5. User [action - e.g., clicks submit button]
6. System [state change - e.g., saves to database, sends email]
7. User sees [confirmation/outcome - e.g., success message, redirect]

**Expected DB State**:
- Table X: Record created with fields [field1, field2, field3]
- Table Y: Field `status` updated to `[new value]`
- Table Z: Foreign key relationship established

**UI State**:
- User redirected to [page/route]
- Toast/notification shows "[message]"
- Form cleared / Form populated with [data]
- Loading state: [describe loading UX]

**E2E Test Mapping**: `e2e/tests/[feature].spec.ts` → "[test description]"

---

## Flow 2: [Same Flow] (Error: [Error Type])

**User Goal**: Same as Flow 1

**Preconditions**:
- [Different initial state that causes error]
- [e.g., user already exists, invalid data, missing requirements]

**Steps**:
1. User [same initial action]
2. System [validation]
3. System detects [error condition]
4. User sees [error message]
5. User remains on [current page]

**Expected DB State**:
- No changes to database
- Or: [specific rollback/cleanup actions]

**UI State**:
- Error message displayed: "[exact error text]"
- Form fields: [keep values / clear certain fields]
- Focus: [which field should be focused]

**E2E Test Mapping**: `e2e/tests/[feature].spec.ts` → "[error test description]"

---

## Flow 3: [Alternative Flow Name]

**User Goal**: As a [user type], I want to [alternative action] so that [different benefit]

**Preconditions**:
- [Different starting conditions]

**Steps**:
1. [Alternative path steps]
2. [Different user actions]
3. [Different system responses]

**Expected DB State**:
- [Database changes for alternative path]

**UI State**:
- [UI changes for alternative path]

**E2E Test Mapping**: `e2e/tests/[feature].spec.ts` → "[alternative test description]"

---

## Additional Flows

Add more flows as needed, following the same structure:
- Flow 4: [Another Error Case]
- Flow 5: [Edge Case]
- Flow 6: [Alternative Scenario]

## Notes

[Any additional context, constraints, or important considerations for this feature]
