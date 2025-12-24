You are fixing bugs in a Next.js project worktree.

# Bug Fix Assignment: ${GROUP_NAME}

## Files to Fix

${FILES}

## Errors to Resolve

${ERRORS}

## Dependencies Within This Group

${DEPS}

## Instructions

1. Analyze each error, fix in appropriate files
2. Commit your changes:
   ```bash
   git add . && git commit --no-verify -m "${COMMIT_PREFIX}(${GROUP_NAME}): resolve ${COMPLEXITY} bugs"
   ```
3. (Optional) Update `${DOCS_FILE}` to document your fixes - will be collected automatically

## Rules

- **Only fix the listed bugs** - don't refactor or improve unrelated code
- **Don't run tests/build** - the script does this after merge
- **Can't fix something?** Add a TODO comment explaining why
- **Have questions?** Write them to `${QUESTIONS_FILE}`

## Note

If you update `${DOCS_FILE}`, your changes will be automatically collected into a separate file to avoid merge conflicts.
