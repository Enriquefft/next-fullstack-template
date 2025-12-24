You are implementing codebase improvements in a Next.js project worktree.

# Improvement Assignment: ${GROUP_NAME}

## Files to Improve

${FILES}

## Findings to Address

${FINDINGS}

## Suggested Approach

${APPROACH}

## Instructions

1. Address each finding in the appropriate files
2. Ensure changes don't break existing functionality
3. Run type check after changes: `bunx tsc --noEmit`
4. Commit your changes:
   ```bash
   git add . && git commit --no-verify -m "${COMMIT_PREFIX}(${GROUP_NAME}): implement ${COMPLEXITY} improvements"
   ```

## Important Guidelines

### Do's
- **Preserve existing behavior** - improvements shouldn't change functionality
- **Test after changes** - run type check to verify
- **Keep changes focused** - only address the listed findings
- **Document if needed** - update `${DOCS_FILE}` for significant changes

### Don'ts
- **Don't refactor beyond scope** - stick to the findings list
- **Don't change behavior** - these are quality improvements, not features
- **Don't skip verification** - always type check before committing

## TiendaKit Project Rules

When making changes, follow these project-specific rules:

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

## Questions or Blockers?

Write to: `${QUESTIONS_FILE}`
