You are resolving a merge conflict in the main branch.

## Context

Branch '${BRANCH_NAME}' has conflicts when merging into main.

## Conflicting Files

${CONFLICTING_FILES}

## Your Task

1. Review each conflicting file using the Read tool
2. Understand both versions (HEAD vs incoming changes)
3. Resolve conflicts by editing files to keep the correct/combined code
4. Remove conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
5. Ensure the code works correctly after resolution
6. Run verification: `${TYPE_CMD}` and `${TEST_CMD}`
7. Stage resolved files: `git add <file>`
8. Complete the merge: `git commit --no-edit`

## Important

- **Don't just pick one side** - understand BOTH changes and merge them intelligently
- **Make sure merged code is correct**, not just conflict-free
- **Test after resolving** to verify the merge works
- **Commit when done** to complete the merge
