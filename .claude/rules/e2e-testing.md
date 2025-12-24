---
paths: e2e/**/*.ts
---

# E2E Testing Guidelines

This file provides detailed guidance for working with end-to-end tests in the `e2e/` directory.

## Architecture Principles

1. **Database Isolation**: E2E tests use a dedicated Neon branch (`DATABASE_URL_TEST`)
2. **No Mocking**: Tests run against real database with real Next.js server
3. **Automatic Cleanup**: Global setup/teardown handles database state
4. **Helper-Driven**: Use helpers from `e2e/helpers/` instead of duplicating logic
5. **Seed Data Available**: Baseline users exist from `e2e/fixtures/test-data.ts`

## File Organization

- `setup/` - Global setup/teardown, database utilities
- `helpers/` - Reusable test utilities (auth, db queries, factories)
- `fixtures/` - Seed data definitions
- `tests/` - Actual test files (*.spec.ts)

## Writing Tests

### Use Helpers, Not Raw Database Access

**Good**:
```typescript
import { createAndAuthenticateUser } from "../helpers/auth.ts";
import { getUserByEmail } from "../helpers/db.ts";

const user = await createAndAuthenticateUser(page, {
  email: "test@example.com",
});
const dbUser = await getUserByEmail(user.email);
```

**Bad** (don't do this):
```typescript
import { db } from "@/db";
// Don't access db directly in tests - use helpers
```

### Test Isolation Best Practices

1. **Create unique data per test**: Use helpers to create test-specific users/data
2. **Don't rely on test execution order**: Each test should be independent
3. **Use seed data sparingly**: Only reference baseline seed users when appropriate
4. **Clean up is automatic**: Don't manually truncate tables in tests

### Available Seed Data

From `fixtures/test-data.ts`:

```typescript
// Admin user (email verified)
const admin = {
  id: "seed-user-admin",
  email: "admin@test.com",
  sessionToken: "seed-admin-session-token",
};

// Regular user (email not verified)
const user = {
  id: "seed-user-regular",
  email: "user@test.com",
  sessionToken: "seed-regular-session-token",
};

// Use with authenticatePage helper
await authenticatePage(page, admin);
```

### Authentication Patterns

**Create fresh authenticated user**:
```typescript
const user = await createAndAuthenticateUser(page, {
  email: "unique@test.com", // Unique email recommended
});
// User is created in DB with session, page has cookies set
```

**Use existing seed user**:
```typescript
import { authenticatePage } from "../helpers/auth.ts";

await authenticatePage(page, {
  id: "seed-user-admin",
  sessionToken: "seed-admin-session-token",
});
```

### Database Verification

Always verify critical operations in the database:

```typescript
test("user signup creates database record", async ({ page }) => {
  await page.goto("/signup");
  await page.fill('[name="email"]', "newuser@test.com");
  await page.fill('[name="password"]', "password123");
  await page.click('button[type="submit"]');

  // Verify in database
  const user = await getUserByEmail("newuser@test.com");
  expect(user).toBeTruthy();
  expect(user?.emailVerified).toBe(false);
});
```

## Helper Functions Reference

### Auth Helpers (`helpers/auth.ts`)

- `createAuthenticatedUser(overrides?)` - Creates user + session in DB
- `authenticatePage(page, user)` - Sets session cookies on Playwright page
- `createAndAuthenticateUser(page, overrides?)` - Combines both (most common)

### Database Helpers (`helpers/db.ts`)

- `getUserByEmail(email)` - Query user by email
- `getUserById(id)` - Query user by ID
- `getSessionByToken(token)` - Query session by token
- `deleteUser(userId)` - Delete user (cascades to sessions/accounts)
- `countUsers()` - Count total users in test database

### Test Factories (`helpers/fixtures.ts`)

Use factories for generating unique test data:

```typescript
import { createUserFactory } from "../helpers/fixtures.ts";

const createUser = createUserFactory();

const user1 = await createUser(); // Auto-generated unique email
const user2 = await createUser({ name: "Custom Name" }); // Override fields
```

## Common Patterns

### Testing Authenticated Flows

```typescript
test("authenticated user can access protected route", async ({ page }) => {
  const user = await createAndAuthenticateUser(page);

  await page.goto("/dashboard");
  await expect(page).toHaveURL("/dashboard");
  await expect(page.locator("h1")).toContainText("Dashboard");
});
```

### Testing Unauthenticated Redirects

```typescript
test("unauthenticated user redirects to login", async ({ page }) => {
  await page.goto("/dashboard");
  await expect(page).toHaveURL(/.*\/login/);
});
```

### Testing Form Submissions with DB Verification

```typescript
test("form submission persists data", async ({ page }) => {
  const user = await createAndAuthenticateUser(page);

  await page.goto("/settings");
  await page.fill('[name="displayName"]', "New Name");
  await page.click('button[type="submit"]');

  // Wait for success indicator
  await expect(page.locator(".toast")).toContainText("Updated");

  // Verify in database
  const dbUser = await getUserById(user.id);
  expect(dbUser?.name).toBe("New Name");
});
```

### Testing with Multiple Users

```typescript
test("user can see other user's public profile", async ({ page }) => {
  const createUser = createUserFactory();

  const user1 = await createUser({ name: "Alice" });
  const user2 = await createUser({ name: "Bob" });

  // Authenticate as user1
  await authenticatePage(page, user1);

  // Visit user2's profile
  await page.goto(`/profile/${user2.id}`);
  await expect(page.locator("h1")).toContainText("Bob");
});
```

## Debugging Tips

### Run Single Test
```bash
bun run test:e2e tests/your-test.spec.ts
```

### Run with UI Mode (Interactive)
```bash
bun run test:e2e:ui
```

### Run in Headed Mode (See Browser)
```bash
bun run test:e2e:headed
```

### View Test Report
```bash
bun run test:e2e:report
```

### Add Debug Breakpoint
```typescript
test("debug this test", async ({ page }) => {
  await page.pause(); // Opens Playwright inspector
  // ... rest of test
});
```

## Database Utilities (Advanced)

The `setup/db.ts` file provides utilities you generally won't need directly, but good to know:

- `createTestDb()` - Creates test database connection
- `truncateAllTables()` - Clears all tables (runs in global setup/teardown)
- `seedTestData()` - Seeds baseline data (runs in global setup)

These run automatically via `globalSetup` and `globalTeardown`.

## Important Reminders

1. **Never commit test database credentials** - Use `.env.local` for `DATABASE_URL_TEST`
2. **Use factories for unique data** - Avoid hardcoded emails that might conflict
3. **Verify critical operations in DB** - Don't trust UI alone
4. **Keep tests focused** - One primary assertion per test when possible
5. **Use descriptive test names** - "user can X when Y" not "test 1"

## CI/CD Considerations

When running in CI, ensure:
- `DATABASE_URL_TEST` is set in CI secrets
- Playwright browsers are installed (`bunx playwright install`)
- Tests run on a dedicated test database branch (never production!)
