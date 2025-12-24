#!/usr/bin/env bash
#
# merge.sh - Merge pipeline for codebase operations
#
# This file contains:
# - Merge conflict handling with Claude resolution
# - Verification failure handling
# - Documentation updates collection
# - Sequential branch merging
# - Final verification (tests/build)
#
# Requires: logging.sh, utils.sh, modes/base.sh (for prompts)
# Expects: PROJECT_DIR, GROUPS_FILE, MODE_CONFIG, CREATED_WORKTREES, TYPE_CMD, TEST_CMD, etc.

# =============================================================================
# MERGE CONFLICT HANDLING
# =============================================================================

# Handle merge conflicts by asking user how to resolve
handle_merge_conflict() {
	local branch_name="$1"

	log "WARN" "=========================================="
	log "WARN" "MERGE CONFLICT DETECTED"
	log "WARN" "=========================================="
	log "WARN" "Branch: $branch_name"
	log "WARN" ""
	log "WARN" "Conflicting files:"
	git diff --name-only --diff-filter=U | while IFS= read -r file; do
		log "WARN" "  - $file"
	done
	log "WARN" ""

	# If non-interactive shell, abort and skip
	if [[ ! -t 0 ]] && [[ "${AUTO_MERGE:-false}" != true ]]; then
		log "ERROR" "Non-interactive shell - cannot resolve conflicts automatically"
		log "ERROR" "Aborting merge and skipping branch"
		git merge --abort
		return 1
	fi

	# Auto-merge mode: automatically use Claude to resolve
	local choice
	if [[ "${AUTO_MERGE:-false}" == true ]]; then
		log "INFO" "Auto-merge mode: Using Claude to resolve merge conflict"
		choice="C"
	else
		# Ask user what to do
		echo ""
		echo -e "${YELLOW}How would you like to resolve this conflict?${NC}"
		echo "  (C) Launch Claude instance to resolve conflict [default]"
		echo "  (M) Manually resolve conflict now"
		echo "  (S) Skip this branch (abort merge)"
		echo ""
		read -p "Choose [C/M/S] (default: C): " choice
		choice=${choice:-C}
	fi

	case "${choice^^}" in
		C)
			log "INFO" "Launching Claude to resolve merge conflict..."

			# Load conflict resolution prompt from template or use default
			local conflict_prompt
			if type -t get_conflict_prompt &>/dev/null; then
				conflict_prompt=$(get_conflict_prompt "$branch_name")
			else
				# Default conflict prompt
				local conflicting_files
				conflicting_files=$(git diff --name-only --diff-filter=U)
				conflict_prompt="You are resolving a merge conflict in the main branch.

## Context

Branch '$branch_name' has conflicts when merging into main.

## Conflicting Files

$conflicting_files

## Your Task

1. Review each conflicting file using the Read tool
2. Understand both versions (HEAD vs incoming changes)
3. Resolve conflicts by editing files to keep the correct/combined code
4. Remove conflict markers (<<<<<<<, =======, >>>>>>>)
5. Ensure the code works correctly after resolution
6. Run verification: \`${TYPE_CMD:-tsc --noEmit}\` and \`${TEST_CMD:-npm test}\`
7. Stage resolved files: \`git add <file>\`
8. Complete the merge: \`git commit --no-edit\`

**IMPORTANT**:
- Don't just pick one side - understand BOTH changes and merge them intelligently
- Make sure the merged code is correct, not just conflict-free
- Test after resolving
- Commit when done"
			fi

			# Launch Claude in current directory
			cd "${PROJECT_DIR:-.}"
			if claude --model sonnet "$conflict_prompt"; then
				log "INFO" "Claude conflict resolution completed"

				# Check if merge was completed
				if git diff --quiet --staged && git diff --quiet; then
					log "ERROR" "No changes staged - conflict may not be resolved"
					return 1
				fi

				# Check if still in merge state
				if [[ -f ".git/MERGE_HEAD" ]]; then
					log "WARN" "Still in merge state - conflict may not be fully resolved"
					log "WARN" "Please complete the merge manually"
					return 1
				fi

				log "INFO" "Conflict resolved successfully"
				return 0
			else
				log "ERROR" "Claude conflict resolution failed"
				return 1
			fi
			;;
		M)
			log "INFO" "Manual conflict resolution mode"
			log "INFO" ""
			log "INFO" "Instructions:"
			log "INFO" "  1. Resolve conflicts in the files listed above"
			log "INFO" "  2. Stage resolved files: git add <file>"
			log "INFO" "  3. Complete merge: git commit --no-edit"
			log "INFO" "  4. Run tests to verify: ${TYPE_CMD:-tsc} && ${TEST_CMD:-npm test}"
			log "INFO" ""
			read -p "Press Enter when conflicts are resolved and committed..."

			# Verify merge was completed
			if [[ -f ".git/MERGE_HEAD" ]]; then
				log "ERROR" "Merge not completed - still in merge state"
				log "ERROR" "Please complete the merge before continuing"
				return 1
			fi

			log "INFO" "Manual resolution completed"
			return 0
			;;
		S)
			log "WARN" "Skipping branch $branch_name (user choice)"
			git merge --abort
			return 1
			;;
		*)
			log "ERROR" "Invalid choice - aborting merge"
			git merge --abort
			return 1
			;;
	esac
}

# =============================================================================
# VERIFICATION FAILURE HANDLING
# =============================================================================

# Handle verification failures by asking user how to fix
handle_verification_failure() {
	local branch_name="$1"
	local error_type="$2"
	local error_log="${LOG_DIR}/verification_error_${branch_name//\//_}_${TIMESTAMP}.txt"

	log "ERROR" "=========================================="
	log "ERROR" "VERIFICATION FAILED AFTER MERGE"
	log "ERROR" "=========================================="
	log "ERROR" "Branch: $branch_name"
	log "ERROR" "Issue: $error_type"
	log "ERROR" ""

	# Save error output
	if [[ "$error_type" == "TypeScript check failed" ]] && [[ -n "${TYPE_CMD:-}" ]]; then
		timeout "${COMMAND_TIMEOUT:-600}" ${TYPE_CMD} > "$error_log" 2>&1 || true
	elif [[ "$error_type" == "Unit tests failed" ]] && [[ -n "${TEST_CMD:-}" ]]; then
		timeout "${COMMAND_TIMEOUT:-600}" ${TEST_CMD} > "$error_log" 2>&1 || true
	fi

	log "ERROR" "Error details:"
	tail -30 "$error_log" | while IFS= read -r line; do
		log "ERROR" "  $line"
	done
	log "ERROR" ""
	log "ERROR" "Full error log: $error_log"
	log "ERROR" ""

	# If non-interactive shell and not auto-merge mode, keep merge but warn
	if [[ ! -t 0 ]] && [[ "${AUTO_MERGE:-false}" != true ]]; then
		log "WARN" "Non-interactive shell - keeping merge despite verification failure"
		log "WARN" "Manual review required before deploying"
		return 0
	fi

	# Auto-merge mode: automatically use Claude to fix
	local choice
	if [[ "${AUTO_MERGE:-false}" == true ]]; then
		log "INFO" "Auto-merge mode: Using Claude to fix verification issues"
		choice="C"
	else
		echo ""
		echo -e "${YELLOW}How would you like to handle this verification failure?${NC}"
		echo "  (C) Launch Claude instance to fix issues [default]"
		echo "  (M) Manually fix issues now"
		echo "  (K) Keep merge anyway (fix later)"
		echo "  (R) Revert merge (discard this branch)"
		echo ""
		read -p "Choose [C/M/K/R] (default: C): " choice
		choice=${choice:-C}
	fi

	case "${choice^^}" in
		C)
			log "INFO" "Launching Claude to fix verification issues..."

			# Create fix prompt
			local fix_prompt
			fix_prompt="You are fixing verification issues after a merge.

## Context

Branch '$branch_name' was merged into main, but verification failed.

**Error**: $error_type

## Error Output

\`\`\`
$(cat "$error_log")
\`\`\`

## Your Task

1. Read the error output to understand what's failing
2. Fix the issues by editing the relevant files
3. Run verification commands to check your fixes:
   - Type check: \`${TYPE_CMD:-tsc --noEmit}\`
   - Tests: \`${TEST_CMD:-npm test}\`
4. Commit your fixes: \`git add . && git commit -m \"fix: resolve verification issues from $branch_name merge\"\`

**IMPORTANT**:
- The merge is already complete - you're fixing post-merge issues
- Don't revert the merge - fix the problems
- Make sure all tests and type checks pass before finishing
- Commit your fixes when done"

			# Launch Claude in current directory
			cd "${PROJECT_DIR:-.}"
			if claude --model sonnet "$fix_prompt"; then
				log "INFO" "Claude fix completed"

				# Re-run verification
				log "INFO" "Re-running verification..."
				local recheck_failed=false

				if [[ -n "${TYPE_CMD:-}" ]] && ! timeout "${COMMAND_TIMEOUT:-600}" ${TYPE_CMD} >> "${LOG_FILE:-/dev/null}" 2>&1; then
					log "WARN" "Type check still failing after Claude fix"
					recheck_failed=true
				fi

				if [[ "$recheck_failed" == false ]] && [[ -n "${TEST_CMD:-}" ]] && ! timeout "${COMMAND_TIMEOUT:-600}" ${TEST_CMD} >> "${LOG_FILE:-/dev/null}" 2>&1; then
					log "WARN" "Tests still failing after Claude fix"
					recheck_failed=true
				fi

				if [[ "$recheck_failed" == true ]]; then
					log "WARN" "Verification still failing - keeping merge but flagging for review"
				else
					log "INFO" "Verification passed after Claude fix!"
				fi

				return 0
			else
				log "ERROR" "Claude fix failed"
				log "WARN" "Keeping merge anyway - manual review required"
				return 0
			fi
			;;
		M)
			log "INFO" "Manual fix mode"
			log "INFO" ""
			log "INFO" "Instructions:"
			log "INFO" "  1. Fix the issues reported above"
			log "INFO" "  2. Run verification: ${TYPE_CMD:-tsc} && ${TEST_CMD:-npm test}"
			log "INFO" "  3. Commit fixes: git add . && git commit -m 'fix: verification issues'"
			log "INFO" ""
			read -p "Press Enter when fixes are committed..."

			log "INFO" "Manual fix completed"
			return 0
			;;
		K)
			log "WARN" "Keeping merge despite verification failure"
			log "WARN" "Manual review required before deploying"
			return 0
			;;
		R)
			log "WARN" "Reverting merge of $branch_name (user choice)"
			git reset --hard HEAD~1
			return 1
			;;
		*)
			log "ERROR" "Invalid choice - keeping merge anyway"
			return 0
			;;
	esac
}

# =============================================================================
# DOCUMENTATION COLLECTION
# =============================================================================

# Collect documentation updates from a worktree
collect_doc_updates() {
	local worktree="$1"
	local branch_name="$2"
	local docs_file="${MODE_CONFIG[docs_file]:-docs/10_bugs.md}"
	local full_docs_path="${worktree}/${docs_file}"
	local original_dir="$PWD"

	# Check if docs file exists and has changes compared to main
	if [[ ! -f "$full_docs_path" ]]; then
		return 0
	fi

	cd "$worktree"

	# Check if the docs file was modified in this worktree
	if git diff --quiet main -- "$docs_file" 2>/dev/null; then
		# No changes to docs file
		cd "$original_dir"
		return 0
	fi

	log "INFO" "  Collecting doc updates from $(basename "$worktree")"

	# Extract the doc updates
	local doc_content
	doc_content=$(cat "$full_docs_path")

	# Create a section for this branch's updates
	cat >> "${LOG_DIR}/collected_docs_${TIMESTAMP}.md" <<EOF

---

## Updates from Branch: ${branch_name}

**Worktree**: $(basename "$worktree")
**Merged**: $(date '+%Y-%m-%d %H:%M:%S')

${doc_content}

EOF

	# Restore original directory
	cd "$original_dir"
}

# Reset docs file to avoid merge conflicts
reset_doc_file() {
	local worktree="$1"
	local docs_file="${MODE_CONFIG[docs_file]:-docs/10_bugs.md}"
	local full_docs_path="${worktree}/${docs_file}"
	local original_dir="$PWD"

	if [[ ! -f "$full_docs_path" ]]; then
		return 0
	fi

	cd "$worktree"

	# Check if the docs file was modified
	if git diff --quiet main -- "$docs_file" 2>/dev/null; then
		# No changes, nothing to reset
		cd "$original_dir"
		return 0
	fi

	log "INFO" "  Resetting $docs_file to avoid merge conflicts"

	# Checkout the file from main to match
	git checkout main -- "$docs_file"

	# Commit the reset if needed
	if ! git diff --quiet --cached; then
		git commit -m "chore: reset $docs_file to main version (tracked separately)"
	fi

	# Restore original directory
	cd "$original_dir"
}

# =============================================================================
# MAIN MERGE FUNCTION
# =============================================================================

merge_branches() {
	log "INFO" "=========================================="
	log "INFO" "PHASE 4: SEQUENTIAL MERGING"
	log "INFO" "=========================================="

	cd "${PROJECT_DIR:-.}"

	# Ensure we're on main
	git checkout main

	# Initialize the collected docs file
	local random_id
	random_id=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)
	local output_prefix="${MODE_CONFIG[output_prefix]:-solved_bugs}"
	local output_file="${PROJECT_DIR}/docs/${output_prefix}_${random_id}_${TIMESTAMP}.md"

	cat > "${LOG_DIR}/collected_docs_${TIMESTAMP}.md" <<EOF
# ${MODE_CONFIG[name]:-Task} Collection
**Generated**: $(date '+%Y-%m-%d %H:%M:%S')
**Session**: ${TIMESTAMP}

This file contains all documentation updates from the automated session.
Each section represents updates from a different worktree/branch.

EOF

	log "INFO" "Documentation updates will be collected to: ${output_prefix}_${random_id}_${TIMESTAMP}.md"

	# Check if main branch has changed since worktrees were created
	if [[ -n "${ORIGINAL_MAIN_HEAD:-}" ]]; then
		local current_main_head
		current_main_head=$(git rev-parse HEAD)

		if [[ "$current_main_head" != "$ORIGINAL_MAIN_HEAD" ]]; then
			log "WARN" "=========================================="
			log "WARN" "MAIN BRANCH HAS CHANGED"
			log "WARN" "=========================================="
			log "WARN" "Original HEAD: ${ORIGINAL_MAIN_HEAD:0:8}"
			log "WARN" "Current HEAD:  ${current_main_head:0:8}"
			log "WARN" ""

			local commits_ahead
			commits_ahead=$(git rev-list --count "${ORIGINAL_MAIN_HEAD}..${current_main_head}" 2>/dev/null || echo "0")

			if [[ "$commits_ahead" -gt 0 ]]; then
				log "WARN" "Main has $commits_ahead new commit(s) since worktrees were created."
				log "WARN" "This may cause merge conflicts."
				log "WARN" ""
				log "WARN" "Recent commits:"
				git log --oneline "${ORIGINAL_MAIN_HEAD}..${current_main_head}" | while IFS= read -r line; do
					log "WARN" "  $line"
				done
				log "WARN" ""

				if [[ -t 0 ]]; then
					read -p "Continue with merging anyway? (y/N): " continue_merge
					if [[ "$continue_merge" != "y" && "$continue_merge" != "Y" ]]; then
						log "INFO" "Aborting. Review changes and decide how to proceed."
						exit 0
					fi
				else
					log "WARN" "Non-interactive shell - proceeding with caution"
				fi
			fi
			log "WARN" "=========================================="
		fi
	fi

	# Get branches in order
	local groups_file="${GROUPS_FILE:-${BUG_GROUPS_FILE:-}}"
	local groups_count
	groups_count=$(jq -r '.summary.groups_count' "$groups_file")

	local branch_prefix="${MODE_CONFIG[branch_prefix]:-fix}"
	local commit_prefix="${MODE_CONFIG[commit_prefix]:-fix}"
	local worktree_base="${WORKTREE_BASE:-$(dirname "$PROJECT_DIR")}"

	local successful_merges=0
	local failed_merges=0

	for i in $(seq 1 "$groups_count"); do
		local padded_order group_name sanitized_name branch_name worktree_path
		padded_order=$(printf "%02d" "$i")

		# Find the group with this order
		group_name=$(jq -r ".groups[] | select(.order == $i) | .name" "$groups_file")

		if [[ -z "$group_name" ]]; then
			log "WARN" "No group found with order $i, skipping"
			continue
		fi

		sanitized_name=$(sanitize_group_name "$group_name")
		branch_name="${branch_prefix}/${padded_order}-${sanitized_name}"
		worktree_path="${worktree_base}/tiendakit-${branch_prefix}-${padded_order}-${sanitized_name}"

		log "INFO" "Processing branch: $branch_name"

		# Check if branch has commits ahead of main
		local commits_ahead
		commits_ahead=$(git rev-list --count main.."$branch_name" 2>/dev/null || echo "0")

		if [[ "$commits_ahead" -eq 0 ]]; then
			log "WARN" "Branch $branch_name has no commits, skipping"
			continue
		fi

		log "INFO" "Branch has $commits_ahead commit(s) to merge"

		# Collect doc updates from this worktree before merging
		if [[ -d "$worktree_path" ]]; then
			collect_doc_updates "$worktree_path" "$branch_name"
			reset_doc_file "$worktree_path"
		fi

		# Ensure we're back in PROJECT_DIR before merging
		cd "${PROJECT_DIR:-.}"

		# Attempt merge
		if ! git merge --no-verify --no-ff "$branch_name" -m "Merge branch '$branch_name' into main

Automated ${MODE_CONFIG[name]:-task} merge by codebase_ops.sh

🤖 Generated with [Claude Code](https://claude.com/claude-code)"; then
			# Merge conflict detected
			if handle_merge_conflict "$branch_name"; then
				log "INFO" "Merge conflict resolved for $branch_name"
			else
				log "WARN" "Skipping branch $branch_name due to unresolved conflict"
				((failed_merges++))
				continue
			fi
		fi

		log "INFO" "Merged $branch_name successfully"

		# Run lightweight verification after merge (type check only)
		log "INFO" "Running quick type check..."

		local verification_failed=false
		local verification_error=""

		# Run biome check if available (auto-fix formatting issues)
		if [[ -n "${BIOME_CMD:-}" ]]; then
			if ! timeout "${COMMAND_TIMEOUT:-600}" ${BIOME_CMD} >> "${LOG_FILE:-/dev/null}" 2>&1; then
				log "WARN" "  Biome check found issues (continuing anyway)"
			else
				log "INFO" "  ✓ Biome check passed"
			fi
		fi

		# Run type check if available (fast, catches most issues)
		if [[ -n "${TYPE_CMD:-}" ]]; then
			if ! timeout "${COMMAND_TIMEOUT:-600}" ${TYPE_CMD} >> "${LOG_FILE:-/dev/null}" 2>&1; then
				verification_failed=true
				verification_error="TypeScript check failed"
			else
				log "INFO" "  ✓ TypeScript check passed"
			fi
		fi

		if [[ "$verification_failed" == true ]]; then
			if handle_verification_failure "$branch_name" "$verification_error"; then
				log "INFO" "Verification issue handled for $branch_name"
				((successful_merges++))
			else
				log "WARN" "Branch $branch_name reverted due to verification failure"
				((failed_merges++))
				continue
			fi
		else
			log "INFO" "Quick verification passed for merge of $branch_name"
			((successful_merges++))
		fi
	done

	log "INFO" "Merge summary: $successful_merges successful, $failed_merges failed"

	if [[ $successful_merges -eq 0 ]]; then
		log "ERROR" "No branches were successfully merged"
		return 1
	fi

	# Finalize documentation collection
	if [[ -f "${LOG_DIR}/collected_docs_${TIMESTAMP}.md" ]]; then
		# Check if there's actual content beyond the header
		local content_lines
		content_lines=$(wc -l < "${LOG_DIR}/collected_docs_${TIMESTAMP}.md")
		if [[ $content_lines -gt 10 ]]; then
			# Copy to final location in docs/
			cp "${LOG_DIR}/collected_docs_${TIMESTAMP}.md" "$output_file"
			log "INFO" "Documentation updates saved to: $output_file"

			# Add to git
			git add "$output_file"
			if ! git diff --quiet --cached "$output_file"; then
				git commit -m "docs: add ${MODE_CONFIG[name]:-task} updates from automated session

Documentation updates from codebase_ops.sh session ${TIMESTAMP}

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
				log "INFO" "Committed documentation file to repository"
			fi
		else
			log "INFO" "No documentation updates collected"
		fi
	fi

	# Final verification - run all tests once after all merges
	log "INFO" "=========================================="
	log "INFO" "Running final verification (all tests)..."
	log "INFO" "=========================================="

	# Run unit tests
	if [[ -n "${TEST_CMD:-}" ]]; then
		log "INFO" "Running unit tests..."
		if ! timeout "${COMMAND_TIMEOUT:-600}" ${TEST_CMD} >> "${LOG_FILE:-/dev/null}" 2>&1; then
			log "ERROR" "Unit tests failed after all merges!"
			log "ERROR" "Review the test output and fix issues before proceeding"
			return 1
		fi
		log "INFO" "  ✓ Unit tests passed!"
	fi

	# Build verification
	if [[ -n "${BUILD_CMD:-}" ]]; then
		log "INFO" "Running build verification..."
		if ! timeout "${COMMAND_TIMEOUT:-600}" ${BUILD_CMD} >> "${LOG_FILE:-/dev/null}" 2>&1; then
			log "ERROR" "Build failed after all merges!"
			return 1
		fi
		log "INFO" "  ✓ Build succeeded!"
	fi

	# E2E tests as final check
	if [[ -n "${E2E_CMD:-}" ]]; then
		log "INFO" "Running E2E tests..."
		if ! timeout "${COMMAND_TIMEOUT:-600}" ${E2E_CMD} >> "${LOG_FILE:-/dev/null}" 2>&1; then
			log "WARN" "  E2E tests failed - review manually"
		else
			log "INFO" "  ✓ E2E tests passed!"
		fi
	fi

	log "INFO" "=========================================="
	log "INFO" "Final verification complete!"
	log "INFO" "=========================================="

	return 0
}
