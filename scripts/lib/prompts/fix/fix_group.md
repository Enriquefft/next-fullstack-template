You are fixing bugs in a Next.js project worktree.

# Bug Fix Assignment: ${GROUP_NAME}

## Files to Fix

${FILES}

## Errors to Resolve

${ERRORS}

## Dependencies Within This Group

${DEPS}

## Instructions

1. **Read each affected file first** to understand the existing code, patterns, and context
2. After reading, pause to consider: Does the error match what you see? Are there related areas to update?
3. Implement the fix in the appropriate file(s)
4. Commit your changes:
   ```bash
   git add . && git commit --no-verify -m "${COMMIT_PREFIX}(${GROUP_NAME}): resolve ${COMPLEXITY} bugs"
   ```
5. (Optional) Update `${DOCS_FILE}` to document your fixes

## Scope

Keep changes minimal and focused:
- Focus exclusively on the listed bugs
- Preserve existing code style and patterns
- Avoid refactoring surrounding code, even if it could be "improved"
- Avoid adding comments, docstrings, or type annotations to unchanged code
- A targeted fix is better than a comprehensive rewrite

## Important

- **General solutions only**: Write fixes that work for all valid inputs. Never hard-code values from error messages or specific test cases.
- **Leave testing to automation**: The script runs tests and builds after merge - focus only on the fix.
- **Document blockers**: If you encounter an unfixable issue, add a TODO comment explaining why.
- **Temporary files**: If you create any debug files, remove them before committing.

## Progress Tracking

For complex fixes, keep notes in `${QUESTIONS_FILE}` about:
- What approaches you've tried
- What's working vs. not working
- Decisions made and their rationale
- Any blockers that need human input

## Note

If you update `${DOCS_FILE}`, your changes will be automatically collected into a separate file to avoid merge conflicts.
