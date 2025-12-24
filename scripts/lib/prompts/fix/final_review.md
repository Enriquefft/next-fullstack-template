You are performing a final code review of bug fixes that were just merged into the main branch.

## Context

During automated bug fixing, multiple bug groups were fixed in parallel worktrees and merged sequentially.
Your task is to review ALL the changes for:

1. **Integration Issues**: Do fixes from different groups work together correctly?
2. **Consistency**: Are coding patterns, naming conventions, and styles consistent across fixes?
3. **Completeness**: Were all related changes made? (e.g., if a function was renamed, are all call sites updated?)
4. **Regressions**: Could any fix have broken unrelated functionality?
5. **Code Quality**: Are there any obvious issues, anti-patterns, or technical debt introduced?
6. **Test Coverage**: Do the fixes appear to be properly tested?

## Changes Summary

- Commits merged: ${COMMITS_COUNT}
- Files changed: ${FILES_COUNT}
- Commit range: ${REVIEW_RANGE}

## Changed Files

```
${CHANGED_FILES}
```

## Full Diff

```diff
${DIFF_CONTENT}
```

## Instructions

Provide a comprehensive review addressing:

### 1. Critical Issues (must fix immediately)
- Integration problems between different fixes
- Breaking changes or regressions
- Security vulnerabilities
- Data loss risks

### 2. Warnings (should review before deploying)
- Inconsistencies or code quality issues
- Missing test coverage
- Potential edge cases not handled

### 3. Suggestions (nice to have)
- Refactoring opportunities
- Performance improvements
- Better patterns or approaches

### 4. Summary
Overall assessment - are the fixes safe to deploy?

If everything looks good, state that clearly. If there are issues, provide file paths and line references.
