#!/usr/bin/env bash
#
# utils.sh - Utility functions for codebase operations
#
# This file contains:
# - Color codes for terminal output
# - String sanitization functions
# - File truncation utilities
# - JSON validation helpers
#
# Source this file early as other modules may depend on color codes

# =============================================================================
# COLOR CODES
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Helper function: Sanitize group name for branch/path
# Converts to lowercase, replaces / with -, removes special chars
sanitize_group_name() {
	echo "$1" | tr '/' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g'
}

# Helper function: Truncate large files for Claude context
# Keeps first half and last half with truncation notice
truncate_output() {
	local file="$1"
	local max_size="$2"

	if [[ ! -f "$file" ]]; then
		return
	fi

	local file_size
	file_size=$(wc -c < "$file")

	if [[ $file_size -gt $max_size ]]; then
		local temp_file="${file}.truncated"
		head -c $((max_size / 2)) "$file" > "$temp_file"
		echo -e "\n\n... [OUTPUT TRUNCATED - Original size: ${file_size} bytes] ...\n\n" >> "$temp_file"
		tail -c $((max_size / 2)) "$file" >> "$temp_file"
		mv "$temp_file" "$file"
		log "WARN" "Truncated $(basename "$file") from ${file_size} to ${max_size} bytes"
	fi
}

# Helper function: Validate JSON schema for groups file
# Checks that required fields exist
validate_groups_json() {
	local json_file="$1"

	if ! jq -e '.summary.total_errors and .summary.groups_count and .groups' "$json_file" >/dev/null 2>&1; then
		# Try alternate schema for improve mode
		if ! jq -e '.summary.total_findings and .summary.groups_count and .groups' "$json_file" >/dev/null 2>&1; then
			log "ERROR" "Invalid groups JSON schema"
			return 1
		fi
	fi

	return 0
}

# Alias for backward compatibility
validate_bug_groups_json() {
	validate_groups_json "$@"
}

# =============================================================================
# GROUP DISPLAY & SELECTION
# =============================================================================

# Estimate fix time based on complexity and issue count
estimate_fix_time() {
	local complexity="$1"
	local count="${2:-1}"

	case "$complexity" in
		simple|quick-win)
			echo "$((count * 1))"  # 1 min per issue
			;;
		medium|moderate)
			echo "$((count * 3))"  # 3 min per issue
			;;
		complex|major)
			echo "$((count * 5))"  # 5 min per issue
			;;
		*)
			echo "$((count * 2))"  # 2 min default
			;;
	esac
}

# Format time in minutes to human-readable
format_time() {
	local minutes=$1

	if [[ $minutes -lt 1 ]]; then
		echo "<1 min"
	elif [[ $minutes -lt 60 ]]; then
		echo "${minutes} min"
	else
		local hours=$((minutes / 60))
		local mins=$((minutes % 60))
		if [[ $mins -eq 0 ]]; then
			echo "${hours}h"
		else
			echo "${hours}h ${mins}m"
		fi
	fi
}

# Display groups summary for user selection
# Usage: display_groups_summary groups_file
display_groups_summary() {
	local groups_file="$1"
	local groups_count
	groups_count=$(jq -r '.summary.groups_count' "$groups_file")

	echo ""
	log_clean "📋" "Found ${groups_count} issue groups:"
	echo ""

	for i in $(seq 0 $((groups_count - 1))); do
		local name complexity files_count issues_count eta marker

		# Extract group data
		name=$(jq -r ".groups[$i].name" "$groups_file")
		complexity=$(jq -r ".groups[$i].estimated_complexity" "$groups_file")
		files_count=$(jq -r ".groups[$i].files | length" "$groups_file")

		# Count issues (errors or findings or improvements)
		issues_count=$(jq -r ".groups[$i] | ((.errors // .findings // .improvements) | length)" "$groups_file")

		# Estimate time
		local minutes
		minutes=$(estimate_fix_time "$complexity" "$issues_count")
		eta=$(format_time "$minutes")

		# Safety marker
		case "$complexity" in
			simple|quick-win)
				marker="✓"
				;;
			medium|moderate)
				marker="⚠️ "
				;;
			complex|major)
				marker="⚠️ "
				;;
			*)
				marker=" "
				;;
		esac

		printf "  [%d] %s %-25s (%d files, %d issues, ~%s) %s\n" \
			"$((i + 1))" "$marker" "$name" "$files_count" "$issues_count" "$eta" \
			"$(echo "$complexity" | tr '[:lower:]' '[:upper:]')"
	done

	echo ""
	log_clean "" "Legend: ✓ = SAFE (automated) | ⚠️  = REVIEW (inspect first)"
	echo ""
}

# Parse user selection into array of group indices
# Usage: parse_selection "1,3,5" → returns array (0 2 4)
parse_selection() {
	local input="$1"
	local groups_file="$2"
	local -a indices=()

	# Handle special keywords
	case "$input" in
		all|ALL)
			# Return all indices
			local count
			count=$(jq -r '.summary.groups_count' "$groups_file")
			for i in $(seq 0 $((count - 1))); do
				indices+=("$i")
			done
			;;
		safe|SAFE)
			# Return only simple/quick-win groups
			local count
			count=$(jq -r '.summary.groups_count' "$groups_file")
			for i in $(seq 0 $((count - 1))); do
				local complexity
				complexity=$(jq -r ".groups[$i].estimated_complexity" "$groups_file")
				if [[ "$complexity" == "simple" || "$complexity" == "quick-win" ]]; then
					indices+=("$i")
				fi
			done
			;;
		*)
			# Parse comma-separated numbers
			IFS=',' read -ra nums <<< "$input"
			for num in "${nums[@]}"; do
				# Trim whitespace
				num=$(echo "$num" | xargs)
				# Convert to zero-indexed
				if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -gt 0 ]]; then
					indices+=("$((num - 1))")
				fi
			done
			;;
	esac

	# Return as space-separated string
	echo "${indices[@]}"
}

# Filter groups file to only selected indices
# Usage: filter_selected_groups groups_file "0 2 4"
filter_selected_groups() {
	local groups_file="$1"
	local selected_indices="$2"
	local output_file="${groups_file%.json}_filtered.json"

	# Build jq filter for selected indices
	local filter=".groups[$(echo "$selected_indices" | tr ' ' ',')]"

	# Create filtered JSON
	jq "{
		summary: {
			total_errors: ([${filter} | (.errors // .findings // .improvements) | length] | add // 0),
			total_findings: ([${filter} | (.errors // .findings // .improvements) | length] | add // 0),
			groups_count: ([${filter}] | length),
			commands_run: .summary.commands_run,
			filtered_from: {
				original_total: (.summary.total_errors // .summary.total_findings // 0),
				original_groups: .summary.groups_count,
				selected_indices: \"$selected_indices\"
			}
		},
		groups: [${filter}]
	}" "$groups_file" > "$output_file"

	echo "$output_file"
}
