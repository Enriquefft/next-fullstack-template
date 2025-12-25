You are implementing codebase improvements in a Next.js project worktree.

# Improvement Assignment: ${GROUP_NAME}

## Files to Improve

${FILES}

## Findings to Address

${FINDINGS}

## Suggested Approach

${APPROACH}

## Instructions

1. **Read each affected file first** to understand the existing code, patterns, and context
2. After reading, pause to consider: Does the finding match what you see? Are there related areas to update?
3. Address each finding in the appropriate files
4. Run type check after changes: `bunx tsc --noEmit`
5. Commit your changes:
   ```bash
   git add . && git commit --no-verify -m "${COMMIT_PREFIX}(${GROUP_NAME}): implement ${COMPLEXITY} improvements"
   ```

## Scope

Keep changes minimal and focused:
- Focus exclusively on the listed findings
- Preserve existing code behavior and patterns
- Avoid refactoring surrounding code, even if it could be "improved"
- Avoid adding comments, docstrings, or type annotations to unchanged code
- Quality improvements should enhance the code, not change what it does

## Important

- **Preserve behavior**: These are quality improvements, not feature changes. Functionality must remain identical.
- **Verify before committing**: Always run type check to catch regressions.
- **Document significant changes**: Update `${DOCS_FILE}` for notable improvements.
- **Temporary files**: If you create any debug files, remove them before committing.

## Progress Tracking

For complex improvements, keep notes in `${QUESTIONS_FILE}` about:
- What approaches you've tried
- What's working vs. not working
- Decisions made and their rationale
- Any blockers that need human input

## Project-Specific Rules

When making changes, follow these project conventions:

1. **Tenant Isolation** (CRITICAL)
   - ALL queries on tenant-scoped tables MUST filter by `tenant_id`
   - Tables: products, categories, orders, order_items, customers, store_settings, inventory

2. **i18n Synchronization**
   - Update BOTH `messages/en.json` AND `messages/es.json`
   - Keys must match in both files

3. **Import Paths**
   - Use `@/i18n/navigation` instead of `next/navigation`
   - Use `@/lib/auth-client` instead of `better-auth/react`
   - Include `.ts`/`.tsx` extensions in imports

4. **Type Safety**
   - Never use `any` - use explicit types or `unknown`
   - Avoid `as` assertions - use type guards or zod validation
   - Prefer drizzle-zod refinement callbacks over `.extend()`

5. **Environment Variables**
   - Access env vars through `@/env.ts`, not `process.env` directly
