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

4. **Output format**: Return ONLY a JSON object (no surrounding text, no markdown code fences).

Example structure:

{"summary": {"total_errors": 3, "groups_count": 2, "commands_run": ["bun type", "bun test"]}, "groups": [{"name": "auth-helpers", "order": 1, "files": ["src/lib/auth.ts"], "errors": [{"file": "src/lib/auth.ts", "line": 42, "message": "Property 'userId' does not exist on type 'Session'", "type": "typescript"}], "independence_score": 9, "estimated_complexity": "simple", "dependencies_within_group": []}]}

## Grouping Rules

- **Library files and their importers belong together**: If `${LIB_DIR}/auth.ts` has an error and `src/app/login/page.tsx` imports it and also has errors, put them in the SAME group. Fixing the library file often resolves the importer's errors.
- **Use import statements to detect dependencies**: Check which files import which, and group accordingly.
- **Groups should be independent**: Each group should be fixable without touching files in other groups.

## Output Requirements

- Return ONLY the JSON object - no explanatory text, no markdown code blocks
- The JSON must be valid and parseable by `jq`
- If no bugs are found, return: {"summary": {"total_errors": 0, "groups_count": 0, "commands_run": [...]}, "groups": []}
