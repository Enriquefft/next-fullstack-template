You are analyzing a Next.js project for improvement opportunities.

## Command Outputs

${CMD_OUTPUTS}

## Additional Analysis Required

Scan the codebase for these improvement patterns:

### 1. Dead Code & Unused (Priority: Low)
- Unused exports (functions, types, constants)
- Unused files
- Unused dependencies in package.json

### 2. Bandaid Fixes (Priority: Medium)
Search for these patterns:
- `TODO`, `FIXME`, `HACK`, `XXX`, `TEMP` comments
- `@ts-ignore`, `@ts-expect-error`, `@ts-nocheck` suppressions
- `eslint-disable`, `biome-ignore` comments
- Large blocks of commented-out code

### 3. Project-Specific Rules (Priority: High/Critical)
- **CRITICAL**: Database queries on tenant-scoped tables (`products`, `categories`, `orders`, `customers`) without `tenant_id` filter
- Missing translations: keys in `messages/en.json` not in `messages/es.json` or vice versa
- Wrong navigation import: `from "next/navigation"` should be `from "@/i18n/navigation"`
- Wrong auth import: `from "better-auth/react"` should be `from "@/lib/auth-client"`
- Validation schemas using `.extend()` instead of drizzle-zod refinement callbacks
- Direct `process.env.` access outside of `src/env.ts`

### 4. Type Safety (Priority: High)
- Uses of `: any` type annotation
- Type assertions with `as` keyword
- Missing return types on exported functions
- Untyped function parameters

## Output Format

Group findings by scope and return ONLY a JSON object (no surrounding text, no markdown code fences).

Example structure:

{"summary": {"total_findings": 5, "groups_count": 2, "commands_run": ["biome", "tsc", "knip"]}, "groups": [{"name": "type-safety-auth", "order": 2, "files": ["src/lib/auth.ts"], "findings": [{"file": "src/lib/auth.ts", "line": 15, "type": "type-safety", "severity": "high", "message": "Uses 'any' type annotation"}], "estimated_complexity": "quick-win", "suggested_approach": "Replace 'any' with explicit Session type"}]}

## Priority Ordering (order field)

1. **CRITICAL** (order 1): Security issues like missing tenant_id filters
2. **High** (order 2-5): Wrong imports, type safety issues
3. **Medium** (order 6-10): Bandaid fixes, i18n desync
4. **Low** (order 11+): Dead code, style improvements

## Complexity Classification

- **quick-win**: Single file change, mechanical/safe, no risk
  - Remove unused import
  - Fix a typo
  - Add missing type annotation

- **moderate**: Multiple files, needs verification, low risk
  - Update import paths across files
  - Add tenant_id filter to query
  - Sync i18n keys

- **major**: Architectural impact, significant refactoring
  - Remove widely-used but incorrect pattern
  - Restructure validation schemas

## Output Requirements

- Return ONLY the JSON object - no explanatory text, no markdown code blocks
- The JSON must be valid and parseable by `jq`
- If no improvements are found, return: {"summary": {"total_findings": 0, "groups_count": 0, "commands_run": [...]}, "groups": []}
