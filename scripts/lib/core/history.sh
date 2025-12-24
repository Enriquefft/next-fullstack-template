#!/usr/bin/env bash
#
# history.sh - Operation history and undo/rollback functionality
#
# This file contains:
# - Operation history tracking
# - Undo/rollback commands
# - Git state management
#
# Requires: logging.sh, utils.sh
# Expects: PROJECT_DIR, LOG_DIR, TIMESTAMP

# =============================================================================
# HISTORY DIRECTORY
# =============================================================================

# Get history directory (lazy evaluation to avoid unbound variable errors)
get_history_dir() {
	echo "${LOG_DIR}/history"
}

get_operations_dir() {
	echo "$(get_history_dir)/operations"
}

# Ensure history directories exist
ensure_history_dirs() {
	local history_dir operations_dir
	history_dir=$(get_history_dir)
	operations_dir=$(get_operations_dir)
	mkdir -p "$history_dir" "$operations_dir"
}

# =============================================================================
# OPERATION TRACKING
# =============================================================================

# Save operation state before starting
# Creates git tag and saves manifest
save_operation_start() {
	local mode="$1"
	local groups_file="$2"

	ensure_history_dirs

	cd "$PROJECT_DIR"

	# Create before-state git tag
	local before_tag="codebase-ops-${TIMESTAMP}-before"
	git tag -f "$before_tag" 2>/dev/null || true

	# Save current commit
	local before_commit
	before_commit=$(git rev-parse HEAD)

	# Extract group names
	local groups_json
	groups_json=$(jq -r '.groups[].name' "$groups_file" 2>/dev/null | jq -R . | jq -s .)

	# Create operation manifest
	local manifest_file="$(get_operations_dir)/${TIMESTAMP}.json"
	cat > "$manifest_file" <<EOF
{
  "timestamp": "${TIMESTAMP}",
  "mode": "${mode}",
  "before_commit": "${before_commit}",
  "before_tag": "${before_tag}",
  "after_commit": null,
  "after_tag": null,
  "groups": ${groups_json},
  "groups_file": "${groups_file}",
  "status": "in_progress",
  "start_time": $(date +%s),
  "end_time": null
}
EOF

	log "DEBUG" "Operation state saved: $manifest_file"
	log "DEBUG" "Before tag created: $before_tag"

	# Save current operation reference
	echo "$TIMESTAMP" > "$(get_history_dir)/current_operation.txt"
}

# Save operation state after completion
save_operation_end() {
	local status="$1"  # success or failed

	ensure_history_dirs

	cd "$PROJECT_DIR"

	# Get current operation
	local current_op
	if [[ -f "$(get_history_dir)/current_operation.txt" ]]; then
		current_op=$(cat "$(get_history_dir)/current_operation.txt")
	else
		log "WARN" "No current operation found"
		return 1
	fi

	local manifest_file="$(get_operations_dir)/${current_op}.json"

	if [[ ! -f "$manifest_file" ]]; then
		log "WARN" "Operation manifest not found: $manifest_file"
		return 1
	fi

	# Create after-state git tag
	local after_tag="codebase-ops-${current_op}-after"
	git tag -f "$after_tag" 2>/dev/null || true

	# Get current commit
	local after_commit
	after_commit=$(git rev-parse HEAD)

	# Get list of changed files
	local before_commit
	before_commit=$(jq -r '.before_commit' "$manifest_file")
	local changed_files
	changed_files=$(git diff --name-only "$before_commit" "$after_commit" 2>/dev/null | jq -R . | jq -s . || echo "[]")

	# Update manifest
	local temp_file="${manifest_file}.tmp"
	jq ".after_commit = \"${after_commit}\" |
	    .after_tag = \"${after_tag}\" |
	    .status = \"${status}\" |
	    .end_time = $(date +%s) |
	    .files_changed = ${changed_files}" "$manifest_file" > "$temp_file"
	mv "$temp_file" "$manifest_file"

	log "DEBUG" "Operation completed: $status"
	log "DEBUG" "After tag created: $after_tag"

	# Clear current operation
	rm -f "$(get_history_dir)/current_operation.txt"
}

# =============================================================================
# HISTORY LISTING
# =============================================================================

# List operation history
list_history() {
	ensure_history_dirs

	local operations=()
	while IFS= read -r -d '' file; do
		operations+=("$file")
	done < <(find "$(get_operations_dir)" -name "*.json" -print0 2>/dev/null | sort -rz)

	if [[ ${#operations[@]} -eq 0 ]]; then
		log_clean "📋" "No operation history found"
		echo ""
		log_clean "" "History will be tracked after your first run."
		return 0
	fi

	echo ""
	log_clean "📋" "Operation History (most recent first):"
	echo ""

	local index=1
	for op_file in "${operations[@]}"; do
		local timestamp mode status groups_count duration files_count

		timestamp=$(jq -r '.timestamp' "$op_file")
		mode=$(jq -r '.mode' "$op_file")
		status=$(jq -r '.status' "$op_file")
		groups_count=$(jq -r '.groups | length' "$op_file")
		files_count=$(jq -r '.files_changed | length' "$op_file" 2>/dev/null || echo "0")

		# Calculate duration
		local start_time end_time
		start_time=$(jq -r '.start_time' "$op_file")
		end_time=$(jq -r '.end_time' "$op_file")

		if [[ "$end_time" != "null" ]] && [[ "$end_time" != "" ]]; then
			local duration_sec=$((end_time - start_time))
			duration=$(format_time $((duration_sec / 60)))
		else
			duration="in progress"
		fi

		# Status marker
		local marker
		case "$status" in
			success) marker="✅" ;;
			failed)  marker="❌" ;;
			*)       marker="⏳" ;;
		esac

		# Format date
		local date_str
		date_str=$(echo "$timestamp" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)_\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')

		printf "  [%d] %s %s | %s mode | %d groups | %d files | %s\n" \
			"$index" "$marker" "$date_str" "$mode" "$groups_count" "$files_count" "$duration"

		((index++))

		# Limit to last 10
		if [[ $index -gt 10 ]]; then
			break
		fi
	done

	echo ""
	log_clean "" "Use: ./scripts/codebase_ops.sh undo [number] to rollback"
	echo ""
}

# =============================================================================
# UNDO/ROLLBACK
# =============================================================================

# Undo last operation
undo_last() {
	ensure_history_dirs

	cd "$PROJECT_DIR"

	# Get most recent operation
	local latest_op
	latest_op=$(find "$(get_operations_dir)" -name "*.json" -type f 2>/dev/null | sort -r | head -1)

	if [[ -z "$latest_op" ]]; then
		log_clean "❌" "No operations to undo"
		return 1
	fi

	# Confirm undo
	local timestamp status groups
	timestamp=$(jq -r '.timestamp' "$latest_op")
	status=$(jq -r '.status' "$latest_op")
	groups=$(jq -r '.groups | join(", ")' "$latest_op")

	echo ""
	log_clean "⚠️ " "About to undo operation:"
	echo "  Timestamp: $timestamp"
	echo "  Status: $status"
	echo "  Groups: $groups"
	echo ""

	# Check if there are uncommitted changes
	if ! git diff-index --quiet HEAD -- 2>/dev/null; then
		log_clean "⚠️ " "WARNING: You have uncommitted changes"
		echo "  These will be lost if you undo."
		echo ""
	fi

	read -p "Are you sure you want to undo? (y/N): " -n 1 -r
	echo ""

	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		log_clean "⏭️ " "Undo cancelled"
		return 0
	fi

	# Perform undo
	local before_tag
	before_tag=$(jq -r '.before_tag' "$latest_op")

	if [[ -z "$before_tag" || "$before_tag" == "null" ]]; then
		log_clean "❌" "Cannot undo: no before-state tag found"
		return 1
	fi

	# Check if tag exists
	if ! git rev-parse "$before_tag" &>/dev/null; then
		log_clean "❌" "Cannot undo: tag $before_tag not found"
		log_clean "" "The git tags may have been cleaned up."
		return 1
	fi

	# Reset to before state
	log_clean "↩️ " "Resetting to before state..."

	if git reset --hard "$before_tag" 2>/dev/null; then
		log_clean "✅" "Successfully undone!"
		echo ""
		log_clean "📄" "Reverted to: $before_tag"
		log_clean "💡" "Use 'git reflog' to see all state changes"
		echo ""

		# Archive the operation manifest
		mkdir -p "$(get_history_dir)/undone"
		mv "$latest_op" "$(get_history_dir)/undone/$(basename "$latest_op")"

		return 0
	else
		log_clean "❌" "Failed to undo operation"
		log_clean "💡" "Try manually: git reset --hard $before_tag"
		return 1
	fi
}

# Rollback to specific operation (by index)
rollback_to() {
	local target_index="$1"

	ensure_history_dirs

	cd "$PROJECT_DIR"

	# Get operation by index
	local operations=()
	while IFS= read -r -d '' file; do
		operations+=("$file")
	done < <(find "$(get_operations_dir)" -name "*.json" -print0 2>/dev/null | sort -rz)

	if [[ ${#operations[@]} -eq 0 ]]; then
		log_clean "❌" "No operations to rollback to"
		return 1
	fi

	if [[ $target_index -lt 1 || $target_index -gt ${#operations[@]} ]]; then
		log_clean "❌" "Invalid index: $target_index"
		log_clean "💡" "Valid range: 1-${#operations[@]}"
		return 1
	fi

	local target_op="${operations[$((target_index - 1))]}"

	# Show what we're rolling back to
	local timestamp status groups
	timestamp=$(jq -r '.timestamp' "$target_op")
	status=$(jq -r '.status' "$target_op")
	groups=$(jq -r '.groups | join(", ")' "$target_op")

	echo ""
	log_clean "⚠️ " "About to rollback to operation #${target_index}:"
	echo "  Timestamp: $timestamp"
	echo "  Status: $status"
	echo "  Groups: $groups"
	echo ""
	log_clean "⚠️ " "This will UNDO all operations after this one!"
	echo ""

	read -p "Are you sure? (y/N): " -n 1 -r
	echo ""

	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		log_clean "⏭️ " "Rollback cancelled"
		return 0
	fi

	# Perform rollback
	local before_tag
	before_tag=$(jq -r '.before_tag' "$target_op")

	if [[ -z "$before_tag" || "$before_tag" == "null" ]]; then
		log_clean "❌" "Cannot rollback: no before-state tag found"
		return 1
	fi

	if ! git rev-parse "$before_tag" &>/dev/null; then
		log_clean "❌" "Cannot rollback: tag $before_tag not found"
		return 1
	fi

	log_clean "↩️ " "Rolling back..."

	if git reset --hard "$before_tag" 2>/dev/null; then
		log_clean "✅" "Successfully rolled back!"
		echo ""

		# Archive all operations after the target
		mkdir -p "$(get_history_dir)/undone"
		for ((i=0; i<target_index; i++)); do
			mv "${operations[$i]}" "$(get_history_dir)/undone/$(basename "${operations[$i]}")"
		done

		return 0
	else
		log_clean "❌" "Failed to rollback"
		return 1
	fi
}

# =============================================================================
# CLEANUP
# =============================================================================

# Clean up old git tags (keep last 10 operations)
cleanup_old_tags() {
	cd "$PROJECT_DIR"

	# Get all codebase-ops tags, sorted by date
	local tags=()
	while IFS= read -r tag; do
		tags+=("$tag")
	done < <(git tag -l "codebase-ops-*" | sort -r)

	# Keep last 20 tags (10 operations × 2 tags each)
	if [[ ${#tags[@]} -gt 20 ]]; then
		log "DEBUG" "Cleaning up old operation tags (keeping last 10 operations)"

		for ((i=20; i<${#tags[@]}; i++)); do
			git tag -d "${tags[$i]}" 2>/dev/null || true
		done
	fi
}

# Clean up old operation manifests (keep last 30 days)
cleanup_old_operations() {
	ensure_history_dirs

	local retention_days=30
	local deleted=0

	while IFS= read -r -d '' file; do
		rm -f "$file"
		((deleted++))
	done < <(find "$(get_operations_dir)" -name "*.json" -type f -mtime "+$retention_days" -print0 2>/dev/null)

	if [[ $deleted -gt 0 ]]; then
		log "DEBUG" "Cleaned up $deleted old operation manifests (older than ${retention_days} days)"
	fi
}
