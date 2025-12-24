You are fixing verification issues after a merge.

## Context

Branch '${BRANCH_NAME}' was merged into main, but verification failed.

**Error**: ${ERROR_TYPE}

## Error Output

```
${ERROR_OUTPUT}
```

## Your Task

1. Read the error output to understand what's failing
2. Fix the issues by editing the relevant files
3. Run verification commands to check your fixes:
   - Type check: `${TYPE_CMD}`
   - Tests: `${TEST_CMD}`
4. Commit your fixes:
   ```bash
   git add . && git commit -m "fix: resolve verification issues from ${BRANCH_NAME} merge"
   ```

## Important

- **The merge is already complete** - you're fixing post-merge issues
- **Don't revert the merge** - fix the problems instead
- **Make sure all tests and type checks pass** before finishing
- **Commit your fixes** when done
