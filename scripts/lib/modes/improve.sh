#!/usr/bin/env bash
#
# improve.sh - Codebase Improvement Mode for codebase operations
#
# This mode identifies and implements improvements using:
# - Dead code detection (knip)
# - Bandaid fix detection (TODO/FIXME/@ts-ignore)
# - Project rule violations (tenant_id, i18n, imports)
# - Type safety issues (any, type assertions)
# - Code style improvements (biome)

# =============================================================================
# MODE CONFIGURATION
# =============================================================================

declare -gA MODE_CONFIG=(
	[name]="Codebase Improvement"
	[description]="Identify and implement quick wins using static analysis"
	[prompts_dir]="${SCRIPT_DIR}/lib/prompts/improve"
	[docs_file]="docs/improvements.md"
	[output_prefix]="improvements"
	[commit_prefix]="refactor"
	[branch_prefix]="improve"
	[default_filter]="quick-win"
	[diagnostic_focus]="improvements"
)

# =============================================================================
# MODE-SPECIFIC FUNCTIONS
# =============================================================================

# Generate the diagnostic prompt for improvement analysis
get_diagnostic_prompt() {
	local cmd_outputs="$1"

	# Build incremental mode context if --since was used
	local incremental_context=""
	if [[ -n "${FILTERED_CHANGED_FILES:-}" ]]; then
		local changed_count
		changed_count=$(echo "$FILTERED_CHANGED_FILES" | wc -l)
		incremental_context="
## Incremental Mode (--since)

This analysis is running in incremental mode. Only files changed since '${SINCE_REF}' are being analyzed.

Changed files ($changed_count):
\`\`\`
${FILTERED_CHANGED_FILES}
\`\`\`

**IMPORTANT**: Focus your analysis only on improvement opportunities in these changed files. Ignore unchanged files.
"
	fi

	# Try to load from template first
	if [[ -f "${MODE_CONFIG[prompts_dir]}/diagnostic.md" ]]; then
		load_prompt "diagnostic.md" \
			"CMD_OUTPUTS=${cmd_outputs}" \
			"INCREMENTAL_CONTEXT=${incremental_context}" \
			"PROJECT_DIR=${PROJECT_DIR}" \
			"LIB_DIR=${LIB_DIR:-src/lib}" \
			"COMPONENTS_DIR=${COMPONENTS_DIR:-src/components}"
		return
	fi

	# Fallback: inline prompt
	cat <<PROMPT
You are analyzing a Next.js project for improvement opportunities.
${incremental_context}

## Command Outputs

${cmd_outputs}

## Additional Analysis

Also check for these patterns in the codebase:

### 1. Dead Code & Unused (from knip output if available)
- Unused exports
- Unused files
- Unused dependencies

### 2. Bandaid Fixes
- TODO/FIXME/HACK/XXX comments
- @ts-ignore/@ts-expect-error suppressions
- eslint-disable/biome-ignore comments
- Commented-out code blocks

### 3. Project-Specific Rules
- Direct process.env access instead of using environment validation (@/env/*)
- Wrong imports: \`from "better-auth/react"\` should be \`from "@/lib/auth-client"\`
- Validation schemas that could benefit from drizzle-zod for better integration
- Missing error boundaries or proper error handling patterns

### 4. Type Safety
- Uses of \`: any\` type
- Type assertions with \`as\`
- Untyped function parameters/returns

## Output Format

Group improvements by scope and provide valid JSON:

\`\`\`json
{
  "summary": {"total_findings": <n>, "groups_count": <n>, "commands_run": [...]},
  "groups": [{
    "name": "<kebab-case-scope>",
    "order": <priority>,
    "files": ["<file1>", "<file2>"],
    "findings": [{
      "file": "<path>",
      "line": <n|null>,
      "type": "dead-code|bandaid|project-rule|type-safety",
      "severity": "critical|high|medium|low",
      "message": "<description>"
    }],
    "estimated_complexity": "quick-win|moderate|major",
    "suggested_approach": "<brief strategy>"
  }]
}
\`\`\`

## Priority Ordering

1. **CRITICAL**: Security issues (missing tenant_id) - order 1
2. **High**: Wrong imports, type safety - order 2-5
3. **Medium**: Bandaid fixes, i18n sync - order 6-10
4. **Low**: Dead code, style - order 11+

## Complexity Classification

- **quick-win**: Single file, mechanical change, no risk (e.g., remove unused import)
- **moderate**: Multiple files, needs testing, low risk
- **major**: Architectural change, significant refactoring, discuss first

Output ONLY valid JSON (no markdown code blocks).
PROMPT
}

# Generate the task prompt for implementing improvements
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

	local complexity files findings approach
	complexity=$(echo "$group_json" | jq -r '.estimated_complexity')
	files=$(echo "$group_json" | jq -r '.files[]' | sed 's/^/- /')
	findings=$(echo "$group_json" | jq -r '.findings[] | "### " + .file + (if .line then ":" + (.line | tostring) else "" end) + "\n**Type**: " + .type + "\n**Severity**: " + .severity + "\n**Issue**: " + .message + "\n"')
	approach=$(echo "$group_json" | jq -r '.suggested_approach // "Address each finding systematically"')

	# Try template first
	if [[ -f "${MODE_CONFIG[prompts_dir]}/improve_group.md" ]]; then
		load_prompt "improve_group.md" \
			"GROUP_NAME=${group_name}" \
			"COMPLEXITY=${complexity}" \
			"FILES=${files}" \
			"FINDINGS=${findings}" \
			"APPROACH=${approach}" \
			"QUESTIONS_FILE=${questions_file}" \
			"DOCS_FILE=${MODE_CONFIG[docs_file]}" \
			"COMMIT_PREFIX=${MODE_CONFIG[commit_prefix]}"
		return
	fi

	# Fallback: inline prompt
	cat <<PROMPT
You are implementing codebase improvements in a Next.js project worktree.

# Improvement Assignment: ${group_name}

## Files to Improve

${files}

## Findings to Address

${findings}

## Suggested Approach

${approach}

## Instructions

1. Address each finding in the appropriate files
2. Ensure changes don't break existing functionality
3. Run type check after changes: \`bunx tsc --noEmit\`
4. Commit your changes:
   \`\`\`bash
   git add . && git commit --no-verify -m "${MODE_CONFIG[commit_prefix]}(${group_name}): implement ${complexity} improvements"
   \`\`\`

## Important Guidelines

- **Preserve existing behavior** - these are improvements, not feature changes
- **Test after changes** - make sure nothing breaks
- **Keep changes focused** - only address the listed findings
- **Document significant changes** - update ${MODE_CONFIG[docs_file]} if needed

## Project-Specific Rules (TiendaKit)

- Always filter tenant-scoped tables by tenant_id
- Update BOTH messages/en.json AND messages/es.json for i18n
- Use \`@/i18n/navigation\` instead of \`next/navigation\`
- Use \`@/lib/auth-client\` instead of \`better-auth/react\`
- Avoid \`any\` type - use explicit types or \`unknown\`
- Avoid \`as\` type assertions - use type guards

**Questions?** Write to \`${questions_file}\`
PROMPT
}

# Generate final review prompt for improvements
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
You are reviewing codebase improvements that were just merged into the main branch.

## Context

Multiple improvement groups were implemented in parallel worktrees and merged sequentially.
Review ALL changes for:

1. **Behavioral Changes**: Did any "improvement" accidentally change functionality?
2. **Consistency**: Are patterns consistent across all improvements?
3. **Completeness**: Were related changes made together? (e.g., all usages updated)
4. **Safety**: Could any change introduce bugs or security issues?

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
$(if [[ $diff_size -gt 100000 ]]; then echo "... [TRUNCATED] ..."; fi)
\`\`\`

## Review Checklist

### Critical (must verify)
- [ ] No accidental behavioral changes
- [ ] No security regressions (especially tenant_id filtering)
- [ ] No broken imports or missing dependencies

### Warnings (review before deploy)
- [ ] Type changes are correct
- [ ] Removed code was truly unused
- [ ] i18n keys match in both language files

### Improvements Made
Summarize the improvements implemented:
- Dead code removed
- Type safety improved
- Project rules enforced
- Bandaid fixes addressed

**Verdict**: Are these improvements safe to deploy?
PROMPT
}

# Filter groups to quick-win only (mode-specific implementation)
_mode_filter_groups() {
	local input_file="$1"
	local filter_type="${2:-quick-win}"

	if [[ "$filter_type" == "all" ]]; then
		cat "$input_file"
		return
	fi

	# Filter by complexity == quick-win (for improve mode)
	jq '{
		summary: {
			total_findings: ([.groups[] | select(.estimated_complexity == "quick-win") | .findings | length] | add // 0),
			groups_count: ([.groups[] | select(.estimated_complexity == "quick-win")] | length),
			commands_run: .summary.commands_run,
			filtered_from: {
				original_total: .summary.total_findings,
				original_groups: .summary.groups_count
			}
		},
		groups: [.groups[] | select(.estimated_complexity == "quick-win")]
	}' "$input_file"
}

# Report skipped improvements (non-quick-win)
report_skipped_groups() {
	local full_file="$1"

	local skipped_count
	skipped_count=$(jq '[.groups[] | select(.estimated_complexity != "quick-win")] | length' "$full_file")

	if [[ "$skipped_count" -gt 0 ]]; then
		log "WARN" "=========================================="
		log "WARN" "SKIPPED NON-QUICK-WIN IMPROVEMENTS"
		log "WARN" "=========================================="

		jq -r '.groups[] | select(.estimated_complexity != "quick-win") |
			"  [\(.estimated_complexity)] \(.name) - \(.findings | length) findings"' "$full_file" | \
		while read -r line; do
			log "WARN" "$line"
		done

		log "WARN" ""
		log "WARN" "Total skipped: $skipped_count groups"
		log "WARN" "Full analysis saved to: $full_file"
		log "WARN" "Use --all to process all improvements including complex ones"
	fi
}
