#!/usr/bin/env bash
#
# cleanup.sh - Cleanup functions for codebase operations
#
# This file contains:
# - Signal handler for graceful interrupt handling
# - Temp file cleanup
# - Worktree cleanup
# - Branch cleanup
#
# Requires: logging.sh (for log function)
# Expects: PIDS_FILE, CREATED_WORKTREES, CREATED_BRANCHES, PROJECT_DIR, LOG_DIR, QUESTIONS_DIR

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

# Signal handler for cleanup on interrupt
cleanup_on_interrupt() {
	log "WARN" "Caught interrupt signal, cleaning up..."

	# Kill any running Claude processes
	if [[ -f "${PIDS_FILE:-}" ]]; then
		while IFS= read -r pid; do
			if kill -0 "$pid" 2>/dev/null; then
				log "INFO" "Killing Claude process $pid"
				kill "$pid" 2>/dev/null || true
			fi
		done < "$PIDS_FILE"
	fi

	# Remove created worktrees
	for worktree in "${CREATED_WORKTREES[@]:-}"; do
		if [[ -d "$worktree" ]]; then
			log "INFO" "Removing worktree: $worktree"
			git -C "${PROJECT_DIR:-.}" worktree remove --force "$worktree" 2>/dev/null || rm -rf "$worktree"
		fi
	done

	# Delete created branches
	for branch in "${CREATED_BRANCHES[@]:-}"; do
		log "INFO" "Deleting branch: $branch"
		git -C "${PROJECT_DIR:-.}" branch -D "$branch" 2>/dev/null || true
	done

	log "INFO" "Cleanup complete"
	exit 1
}

# =============================================================================
# TEMP FILE CLEANUP
# =============================================================================

# Cleanup temp files after successful run
cleanup_temp_files() {
	local log_dir="${LOG_DIR:-}"

	if [[ -z "$log_dir" ]]; then
		return
	fi

	# Delete diagnostic output files (data is in cache/log anyway)
	rm -f "${log_dir}/test_output_"*.txt 2>/dev/null
	rm -f "${log_dir}/type_output_"*.txt 2>/dev/null
	rm -f "${log_dir}/build_output_"*.txt 2>/dev/null
	rm -f "${log_dir}/e2e_output_"*.txt 2>/dev/null
	rm -f "${log_dir}/biome_output_"*.txt 2>/dev/null
	rm -f "${log_dir}/diagnostic_output_"*.txt 2>/dev/null

	# Delete per-worktree Claude logs
	rm -f "${log_dir}/claude_"*.log 2>/dev/null

	# Delete questions directory
	rm -rf "${QUESTIONS_DIR:-}" 2>/dev/null

	log "DEBUG" "Cleaned up temp files"
}

# =============================================================================
# WORKTREE CLEANUP
# =============================================================================

# Cleanup worktrees after successful completion
# Uses MODE_CONFIG[branch_prefix] if available for safety check pattern
cleanup_worktrees() {
	log "INFO" "=========================================="
	log "INFO" "CLEANUP"
	log "INFO" "=========================================="

	local worktree_base
	worktree_base=$(dirname "${PROJECT_DIR:-.}")
	local branch_prefix="${MODE_CONFIG[branch_prefix]:-fix}"

	for worktree in "${CREATED_WORKTREES[@]:-}"; do
		if [[ -d "$worktree" ]]; then
			# Safety check before rm -rf - verify it matches expected pattern
			if [[ "$worktree" == "$worktree_base"/tiendakit-${branch_prefix}-* ]] || \
			   [[ "$worktree" == "$worktree_base"/tiendakit-fix-* ]] || \
			   [[ "$worktree" == "$worktree_base"/tiendakit-improve-* ]]; then
				log "INFO" "Removing worktree: $worktree"
				git -C "${PROJECT_DIR:-.}" worktree remove "$worktree" 2>/dev/null || rm -rf "$worktree"
			else
				log "WARN" "Skipping unexpected worktree path: $worktree"
			fi
		fi
	done

	for branch in "${CREATED_BRANCHES[@]:-}"; do
		# Only delete if merged
		if git -C "${PROJECT_DIR:-.}" branch --merged main | grep -q "$branch"; then
			log "INFO" "Deleting merged branch: $branch"
			git -C "${PROJECT_DIR:-.}" branch -d "$branch" 2>/dev/null || true
		else
			log "WARN" "Keeping unmerged branch: $branch"
		fi
	done

	# Prune worktree references
	git -C "${PROJECT_DIR:-.}" worktree prune

	log "INFO" "Cleanup complete"
}
