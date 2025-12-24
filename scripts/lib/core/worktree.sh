#!/usr/bin/env bash
#
# worktree.sh - Git worktree management for codebase operations
#
# This file contains:
# - Worktree creation with parallel dependency installation
# - Branch management
# - Environment file copying
#
# Requires: logging.sh, utils.sh
# Expects: PROJECT_DIR, WORKTREE_BASE, GROUPS_FILE, MODE_CONFIG, COMMAND_TIMEOUT, INSTALL_CMD
# Modifies: CREATED_WORKTREES, CREATED_BRANCHES arrays

# =============================================================================
# WORKTREE CREATION
# =============================================================================

# Create git worktrees for each group in the groups file
# Uses MODE_CONFIG[branch_prefix] for branch naming
create_worktrees() {
	log "INFO" "=========================================="
	log "INFO" "PHASE 2: WORKTREE CREATION"
	log "INFO" "=========================================="

	local groups_file="${GROUPS_FILE:-${BUG_GROUPS_FILE:-}}"
	local groups_count
	groups_count=$(jq -r '.summary.groups_count' "$groups_file")

	if [[ "$groups_count" -eq 0 ]]; then
		log "INFO" "No groups to create worktrees for"
		return 0
	fi

	cd "${PROJECT_DIR:-.}"

	# Ensure we're on a clean main branch
	local current_branch
	current_branch=$(git rev-parse --abbrev-ref HEAD)

	if [[ "$current_branch" != "main" ]]; then
		log "WARN" "Not on main branch (currently on $current_branch)"
		log "INFO" "Switching to main branch..."
		git checkout main
	fi

	# Check for uncommitted changes (both staged and unstaged)
	if ! git diff-index --quiet HEAD -- 2>/dev/null || ! git diff --quiet 2>/dev/null; then
		if [[ "${ALLOW_DIRTY:-false}" == false ]]; then
			git status --short
			show_error_guidance "dirty_working_directory"
			exit 3
		else
			log "WARN" "Proceeding with uncommitted changes (--allow-dirty enabled)"
			log "WARN" "Note: Uncommitted changes will NOT be included in worktrees"
			git status --short
		fi
	fi

	# Store the original main HEAD to detect changes later
	ORIGINAL_MAIN_HEAD=$(git rev-parse HEAD)
	log "INFO" "Storing main branch HEAD: ${ORIGINAL_MAIN_HEAD:0:8}"

	# Save original HEAD to file for --continue mode
	echo "$ORIGINAL_MAIN_HEAD" > "${LOG_DIR}/original_main_head.txt"

	# Get branch prefix from mode config or default to "fix"
	local branch_prefix="${MODE_CONFIG[branch_prefix]:-fix}"
	local worktree_base="${WORKTREE_BASE:-$(dirname "$PROJECT_DIR")}"

	# First pass: Create all worktrees
	for i in $(seq 0 $((groups_count - 1))); do
		local group_name order padded_order branch_name worktree_path sanitized_name

		# Batch jq queries for performance (use tab delimiter to handle spaces in names)
		local jq_output
		jq_output=$(jq -r ".groups[$i] | \"\(.name)\t\(.order)\"" "$groups_file")
		IFS=$'\t' read -r group_name order <<< "$jq_output"

		log "DEBUG" "Creating worktree for group '$group_name' with order $order"

		padded_order=$(printf "%02d" "$order")

		# Use helper function for sanitization
		sanitized_name=$(sanitize_group_name "$group_name")

		branch_name="${branch_prefix}/${padded_order}-${sanitized_name}"

		# Use dynamic project name instead of hardcoded "tiendakit"
		local project_name
		project_name=$(basename "$PROJECT_DIR")
		worktree_path="${worktree_base}/${project_name}-${branch_prefix}-${padded_order}-${sanitized_name}"

		log "INFO" "Creating worktree for group: $group_name"
		log "INFO" "  Branch: $branch_name"
		log "INFO" "  Path: $worktree_path"

		# Remove existing worktree if present (with safety check)
		if [[ -d "$worktree_path" ]]; then
			# Validate path is in expected location before rm -rf
			if [[ "$worktree_path" == "$worktree_base"/*-${branch_prefix}-* ]]; then
				log "WARN" "Worktree path exists, removing: $worktree_path"
				git worktree remove --force "$worktree_path" 2>/dev/null || rm -rf "$worktree_path"
			else
				log "ERROR" "Unexpected worktree path: $worktree_path"
				exit 3
			fi
		fi

		# Delete existing branch if present
		if git show-ref --verify --quiet "refs/heads/$branch_name"; then
			log "WARN" "Branch exists, deleting: $branch_name"
			git branch -D "$branch_name" 2>/dev/null || true
		fi

		# Create branch from main
		git branch "$branch_name" main
		CREATED_BRANCHES+=("$branch_name")

		# Create worktree
		git worktree add "$worktree_path" "$branch_name"
		CREATED_WORKTREES+=("$worktree_path")

		# Copy .env files if they exist in the main project
		if [[ -f "${PROJECT_DIR}/.env" ]]; then
			cp "${PROJECT_DIR}/.env" "$worktree_path/.env"
			log "DEBUG" "Copied .env to $worktree_path"
		fi
		if [[ -f "${PROJECT_DIR}/.env.local" ]]; then
			cp "${PROJECT_DIR}/.env.local" "$worktree_path/.env.local"
			log "DEBUG" "Copied .env.local to $worktree_path"
		fi
	done

	log "INFO" "Created ${#CREATED_WORKTREES[@]} worktrees"

	# Second pass: Install dependencies in parallel
	log "INFO" "Installing dependencies in all worktrees (parallel)..."
	declare -a install_pids=()

	for worktree in "${CREATED_WORKTREES[@]}"; do
		(
			cd "$worktree" || exit 1
			if ! timeout "${COMMAND_TIMEOUT:-600}" ${INSTALL_CMD:-npm ci} >>"${LOG_FILE:-/dev/null}" 2>&1; then
				echo "FAILED: $worktree" >> "${LOG_DIR}/install_failures.txt"
			fi
		) &
		install_pids+=($!)
	done

	# Wait for all installations
	local install_failed=0
	for pid in "${install_pids[@]}"; do
		if ! wait "$pid"; then
			((install_failed++))
		fi
	done

	if [[ $install_failed -gt 0 ]]; then
		log "ERROR" "$install_failed worktree(s) failed to install dependencies"
		if [[ -f "${LOG_DIR}/install_failures.txt" ]]; then
			log "ERROR" "Failed worktrees:"
			while IFS= read -r line; do
				log "ERROR" "  $line"
			done < "${LOG_DIR}/install_failures.txt"
		fi
		exit 3
	fi

	log "INFO" "All dependencies installed successfully"
}

# =============================================================================
# WORKTREE RESTORATION (for --continue mode)
# =============================================================================

# Reconstruct worktree arrays from groups file (for --continue mode)
restore_worktrees_from_groups() {
	local groups_file="$1"
	local groups_count
	groups_count=$(jq -r '.summary.groups_count' "$groups_file")

	local branch_prefix="${MODE_CONFIG[branch_prefix]:-fix}"
	local worktree_base="${WORKTREE_BASE:-$(dirname "$PROJECT_DIR")}"

	for i in $(seq 0 $((groups_count - 1))); do
		local group_name order padded_order branch_name worktree_path sanitized_name

		# Batch jq queries for performance
		local jq_output
		jq_output=$(jq -r ".groups[$i] | \"\(.name)\t\(.order)\"" "$groups_file")
		IFS=$'\t' read -r group_name order <<< "$jq_output"
		padded_order=$(printf "%02d" "$order")

		sanitized_name=$(sanitize_group_name "$group_name")

		branch_name="${branch_prefix}/${padded_order}-${sanitized_name}"
		worktree_path="${worktree_base}/tiendakit-${branch_prefix}-${padded_order}-${sanitized_name}"

		if [[ -d "$worktree_path" ]]; then
			CREATED_WORKTREES+=("$worktree_path")
			CREATED_BRANCHES+=("$branch_name")
			log "INFO" "Found worktree: $worktree_path"
		else
			log "WARN" "Worktree not found: $worktree_path"
		fi
	done
}
