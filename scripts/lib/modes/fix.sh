#!/usr/bin/env bash
#
# fix.sh - Bug Fixing Mode for codebase operations
#
# This mode automates bug detection and fixing using:
# - Test failures
# - TypeScript errors
# - Build failures
# - E2E test failures
# - Biome linting issues

# =============================================================================
# MODE CONFIGURATION
# =============================================================================

declare -gA MODE_CONFIG=(
	[name]="Bug Fixing"
	[description]="Automatically detect and fix bugs from test/type/build failures"
	[prompts_dir]="${SCRIPT_DIR}/lib/prompts/fix"
	[docs_file]="docs/10_bugs.md"
	[output_prefix]="solved_bugs"
	[commit_prefix]="fix"
	[branch_prefix]="fix"
	[default_filter]="simple"
	[diagnostic_focus]="errors"
)

# =============================================================================
# MODE-SPECIFIC FUNCTIONS
# =============================================================================

# Generate the diagnostic prompt for bug analysis
get_diagnostic_prompt() {
	local cmd_outputs="$1"

	# Try to load from template first
	if [[ -f "${MODE_CONFIG[prompts_dir]}/diagnostic.md" ]]; then
		load_prompt "diagnostic.md" \
			"CMD_OUTPUTS=${cmd_outputs}" \
			"ACTIONS_DIR=${ACTIONS_DIR:-src/actions}" \
			"LIB_DIR=${LIB_DIR:-src/lib}" \
			"COMPONENTS_DIR=${COMPONENTS_DIR:-src/components}" \
			"ROUTER_DIR=${ROUTER_DIR:-src/app}" \
			"HOOKS_DIR=${HOOKS_DIR:-src/hooks}"
		return
	fi

	# Fallback: inline prompt
	cat <<PROMPT
You are analyzing a Next.js project for bugs. Below are the outputs from diagnostic commands.

## Command Outputs

${cmd_outputs}

## Analysis Task

Analyze ALL errors found in the outputs above. Then perform deep analysis:

1. **Group errors by module/directory**:
   - ${ACTIONS_DIR:-src/actions} - Server actions (if exists)
   - ${LIB_DIR:-src/lib} - Utilities and services
   - ${COMPONENTS_DIR:-src/components} - React components
   - ${ROUTER_DIR:-src/app} - Next.js pages and routes
   - ${HOOKS_DIR:-src/hooks} - Custom React hooks
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

{
  "summary": {"total_errors": <n>, "groups_count": <n>, "commands_run": [...]},
  "groups": [{
    "name": "<kebab>", "order": <n>, "files": [...],
    "errors": [{"file": "", "line": <n|null>, "message": "", "type": "typescript|test|build|e2e|format"}],
    "independence_score": <1-10>, "estimated_complexity": "simple|medium|complex",
    "dependencies_within_group": [...]
  }]
}

Rules: ${LIB_DIR:-src/lib} + importers = same group. Analyze imports. Only JSON. No bugs: {"summary": {"total_errors": 0, ...}, "groups": []}
- The JSON must be valid and parseable by jq
PROMPT
}

# Generate the task prompt for fixing a bug group
get_task_prompt() {
	local group_name="$1"
	local questions_file="$2"

	local groups_file="${GROUPS_FILE:-${BUG_GROUPS_FILE:-}}"

	# Look up group by name
	local group_json
	group_json=$(jq -r ".groups[] | select(.name == \"$group_name\")" "$groups_file")

	if [[ -z "$group_json" ]]; then
		log "ERROR" "Group not found: $group_name"
		return 1
	fi

	local complexity files errors deps
	complexity=$(echo "$group_json" | jq -r '.estimated_complexity')
	files=$(echo "$group_json" | jq -r '.files[]' | sed 's/^/- /')
	errors=$(echo "$group_json" | jq -r '.errors[] | "### " + .file + (if .line then ":" + (.line | tostring) else "" end) + "\n**Type**: " + .type + "\n**Message**: " + .message + "\n"')
	deps=$(echo "$group_json" | jq -r '.dependencies_within_group[]? // "None identified"' | sed 's/^/- /')

	# Try template first
	if [[ -f "${MODE_CONFIG[prompts_dir]}/fix_group.md" ]]; then
		load_prompt "fix_group.md" \
			"GROUP_NAME=${group_name}" \
			"COMPLEXITY=${complexity}" \
			"FILES=${files}" \
			"ERRORS=${errors}" \
			"DEPS=${deps}" \
			"QUESTIONS_FILE=${questions_file}" \
			"DOCS_FILE=${MODE_CONFIG[docs_file]}" \
			"COMMIT_PREFIX=${MODE_CONFIG[commit_prefix]}"
		return
	fi

	# Fallback: inline prompt
	cat <<PROMPT
You are fixing bugs in a Next.js project worktree.

# Bug Fix Assignment: ${group_name}

## Files to Fix

${files}

## Errors to Resolve

${errors}

## Dependencies Within This Group

${deps}

## Instructions

1. Analyze each error, fix in appropriate files
2. Commit: \`git add . && git commit --no-verify -m "${MODE_CONFIG[commit_prefix]}(${group_name}): resolve ${complexity} bugs"\`
3. (Optional) Update \`${MODE_CONFIG[docs_file]}\` to document your fixes - will be collected automatically

**Rules**: Only fix listed bugs. Don't run tests/build (script does after merge). Can't fix? Add TODO. Questions? Write to \`${questions_file}\`

**Note**: If you update \`${MODE_CONFIG[docs_file]}\`, your changes will be automatically collected into a separate file to avoid merge conflicts.
PROMPT
}

# Generate final review prompt
get_final_review_prompt() {
	local diff_file="$1"
	local changed_files="$2"
	local commits_count="$3"
	local review_range="$4"

	local diff_content
	diff_content=$(head -c 100000 "$diff_file")
	local diff_size
	diff_size=$(wc -c < "$diff_file")

	# Try template first
	if [[ -f "${MODE_CONFIG[prompts_dir]}/final_review.md" ]]; then
		load_prompt "final_review.md" \
			"COMMITS_COUNT=${commits_count}" \
			"FILES_COUNT=$(echo "$changed_files" | wc -l)" \
			"REVIEW_RANGE=${review_range}" \
			"CHANGED_FILES=${changed_files}" \
			"DIFF_CONTENT=${diff_content}" \
			"DIFF_SIZE=${diff_size}"
		return
	fi

	# Fallback: inline prompt
	cat <<PROMPT
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

- Commits merged: ${commits_count}
- Files changed: $(echo "$changed_files" | wc -l)
- Commit range: ${review_range}

## Changed Files

\`\`\`
${changed_files}
\`\`\`

## Full Diff

\`\`\`diff
${diff_content}
$(if [[ $diff_size -gt 100000 ]]; then echo "... [DIFF TRUNCATED - Total size: $diff_size bytes] ..."; fi)
\`\`\`

## Instructions

Provide a comprehensive review addressing:

1. **Critical Issues** (must fix immediately):
   - Integration problems between different fixes
   - Breaking changes or regressions
   - Security vulnerabilities
   - Data loss risks

2. **Warnings** (should review before deploying):
   - Inconsistencies or code quality issues
   - Missing test coverage
   - Potential edge cases not handled

3. **Suggestions** (nice to have):
   - Refactoring opportunities
   - Performance improvements
   - Better patterns or approaches

4. **Summary**: Overall assessment - are the fixes safe to deploy?

If everything looks good, state that clearly. If there are issues, provide file paths and line references.
PROMPT
}

# Filter groups to simple-only (mode-specific implementation)
_mode_filter_groups() {
	local input_file="$1"
	local filter_type="${2:-simple}"

	if [[ "$filter_type" == "all" ]]; then
		cat "$input_file"
		return
	fi

	# Filter by complexity == simple (for bug fixing mode)
	jq '{
		summary: {
			total_errors: ([.groups[] | select(.estimated_complexity == "simple") | .errors | length] | add // 0),
			groups_count: ([.groups[] | select(.estimated_complexity == "simple")] | length),
			commands_run: .summary.commands_run,
			filtered_from: {
				original_total: .summary.total_errors,
				original_groups: .summary.groups_count
			}
		},
		groups: [.groups[] | select(.estimated_complexity == "simple")]
	}' "$input_file"
}

# Report skipped bugs (non-simple)
report_skipped_groups() {
	local full_file="$1"

	local skipped_count
	skipped_count=$(jq '[.groups[] | select(.estimated_complexity != "simple")] | length' "$full_file")

	if [[ "$skipped_count" -gt 0 ]]; then
		log "WARN" "=========================================="
		log "WARN" "SKIPPED NON-SIMPLE BUGS (default mode)"
		log "WARN" "=========================================="

		jq -r '.groups[] | select(.estimated_complexity != "simple") |
			"  [\(.estimated_complexity)] \(.name) - \(.errors | length) errors"' "$full_file" | \
		while read -r line; do
			log "WARN" "$line"
		done

		log "WARN" ""
		log "WARN" "Total skipped: $skipped_count groups"
		log "WARN" "Full analysis saved to: $full_file"
		log "WARN" "Use --all to fix all bugs including complex ones"
	fi
}
