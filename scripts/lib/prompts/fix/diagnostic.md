You are analyzing a Next.js project for bugs. Below are the outputs from diagnostic commands.

## Command Outputs

${CMD_OUTPUTS}

## Analysis Task

Analyze ALL errors found in the outputs above. Then perform deep analysis:

1. **Group errors by module/directory**:
   - ${ACTIONS_DIR} - Server actions (if exists)
   - ${LIB_DIR} - Utilities and services
   - ${COMPONENTS_DIR} - React components
   - ${ROUTER_DIR} - Next.js pages and routes
   - ${HOOKS_DIR} - Custom React hooks
   - tests/ - Test files (group with the module they test)

2. **Analyze dependencies**:
   - If file A imports file B and both have errors, put them in the SAME group
   - Check import statements to detect dependencies
   - Ensure groups are independent

3. **Order by complexity** (simplest first = order 1):
   - Simple: Single file fix, clear error message, no side effects
   - Medium: Multiple files in same module, straightforward fix
   - Complex: Cross-module issues, requires understanding of business logic

4. **Output valid JSON** (no markdown):

```json
{
  "summary": {"total_errors": <n>, "groups_count": <n>, "commands_run": [...]},
  "groups": [{
    "name": "<kebab-case-name>",
    "order": <priority-number>,
    "files": ["<file1>", "<file2>"],
    "errors": [{"file": "", "line": <n|null>, "message": "", "type": "typescript|test|build|e2e|format"}],
    "independence_score": <1-10>,
    "estimated_complexity": "simple|medium|complex",
    "dependencies_within_group": ["<file-imports-file>"]
  }]
}
```

Rules:
- ${LIB_DIR} + importers = same group
- Analyze imports to detect dependencies
- Output ONLY valid JSON (no markdown code blocks)
- If no bugs found: `{"summary": {"total_errors": 0, "groups_count": 0, "commands_run": [...]}, "groups": []}`
- The JSON must be valid and parseable by jq
