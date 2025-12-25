#!/usr/bin/env bash
#
# analytics.sh - Analytics and statistics for codebase operations
#
# This file contains:
# - Operation metrics calculation
# - Statistics aggregation
# - Report generation
# - Export functionality
#
# Requires: jq, logging.sh, history.sh
# Expects: PROJECT_DIR, LOG_DIR

# =============================================================================
# METRICS CALCULATION
# =============================================================================

# Calculate time saved estimate based on operation data
# Rough heuristic: each group takes ~10-15 min manually, 2-3 min automated
calculate_time_saved() {
	local groups_fixed="$1"

	# Conservative estimate: 8 minutes saved per group
	local minutes_saved=$((groups_fixed * 8))

	echo "$minutes_saved"
}

# Get all operation manifests sorted by date (newest first)
get_all_operations() {
	local operations_dir
	operations_dir=$(get_operations_dir)

	if [[ ! -d "$operations_dir" ]]; then
		return 0
	fi

	find "$operations_dir" -name "*.json" -type f 2>/dev/null | sort -r
}

# Get operations from last N days
get_operations_since() {
	local days="$1"
	local cutoff_timestamp
	cutoff_timestamp=$(date -d "$days days ago" +%s 2>/dev/null || date -v-"${days}d" +%s 2>/dev/null)

	local operations_dir
	operations_dir=$(get_operations_dir)

	if [[ ! -d "$operations_dir" ]]; then
		return 0
	fi

	find "$operations_dir" -name "*.json" -type f 2>/dev/null | while read -r op_file; do
		local start_time
		start_time=$(jq -r '.start_time // 0' "$op_file" 2>/dev/null)

		if [[ "$start_time" -ge "$cutoff_timestamp" ]]; then
			echo "$op_file"
		fi
	done | sort -r
}

# =============================================================================
# STATISTICS AGGREGATION
# =============================================================================

# Calculate aggregate statistics from operation manifests
calculate_statistics() {
	local time_period="$1"  # "all", "30", "7", etc. (days)

	local operations
	if [[ "$time_period" == "all" ]]; then
		operations=$(get_all_operations)
	else
		operations=$(get_operations_since "$time_period")
	fi

	if [[ -z "$operations" ]]; then
		echo "{}"
		return 0
	fi

	local total_operations=0
	local successful_operations=0
	local total_groups=0
	local total_files=0
	local total_duration=0
	local total_time_saved=0

	# Associative array for issue type counting
	declare -A issue_types
	declare -A files_fixed

	while IFS= read -r op_file; do
		if [[ ! -f "$op_file" ]]; then
			continue
		fi

		((total_operations++))

		# Read operation data
		local status
		local groups_count
		local files_changed
		local start_time
		local end_time
		local mode

		status=$(jq -r '.status // "unknown"' "$op_file" 2>/dev/null)
		groups_count=$(jq -r '.groups | length' "$op_file" 2>/dev/null || echo "0")
		files_changed=$(jq -r '.files_changed | length' "$op_file" 2>/dev/null || echo "0")
		start_time=$(jq -r '.start_time // 0' "$op_file" 2>/dev/null)
		end_time=$(jq -r '.end_time // 0' "$op_file" 2>/dev/null)
		mode=$(jq -r '.mode // "fix"' "$op_file" 2>/dev/null)

		# Count successful operations
		if [[ "$status" == "success" ]]; then
			((successful_operations++))
		fi

		# Aggregate metrics
		total_groups=$((total_groups + groups_count))
		total_files=$((total_files + files_changed))

		# Calculate duration
		if [[ "$end_time" -gt 0 ]] && [[ "$start_time" -gt 0 ]]; then
			local duration=$((end_time - start_time))
			total_duration=$((total_duration + duration))
		fi

		# Calculate time saved
		local saved
		saved=$(calculate_time_saved "$groups_count")
		total_time_saved=$((total_time_saved + saved))

		# Count files that were fixed (for most-fixed tracking)
		jq -r '.files_changed[]? // empty' "$op_file" 2>/dev/null | while read -r file; do
			if [[ -n "$file" ]]; then
				files_fixed["$file"]=$((${files_fixed["$file"]:-0} + 1))
			fi
		done

	done <<< "$operations"

	# Calculate success rate
	local success_rate=0
	if [[ $total_operations -gt 0 ]]; then
		success_rate=$(awk "BEGIN {printf \"%.0f\", ($successful_operations / $total_operations) * 100}")
	fi

	# Convert duration to hours
	local hours_spent
	hours_spent=$(awk "BEGIN {printf \"%.1f\", $total_duration / 3600}")

	# Convert time saved to hours
	local hours_saved
	hours_saved=$(awk "BEGIN {printf \"%.1f\", $total_time_saved / 60}")

	# Calculate average duration per operation (in minutes)
	local avg_duration=0
	if [[ $total_operations -gt 0 ]]; then
		avg_duration=$(awk "BEGIN {printf \"%.1f\", $total_duration / 60 / $total_operations}")
	fi

	# Output JSON statistics
	cat <<EOF
{
  "total_operations": $total_operations,
  "successful_operations": $successful_operations,
  "success_rate": $success_rate,
  "total_groups_fixed": $total_groups,
  "total_files_changed": $total_files,
  "total_hours_spent": $hours_spent,
  "total_hours_saved": $hours_saved,
  "average_duration_minutes": $avg_duration
}
EOF
}

# =============================================================================
# REPORT GENERATION
# =============================================================================

# Display terminal statistics report
show_stats_report() {
	local time_period="${1:-30}"  # Default: last 30 days

	log_clean "" ""
	log_clean "📊" "Codebase Operations Statistics"
	log_clean "" ""

	# Calculate statistics
	local stats_30days
	local stats_7days
	local stats_all

	stats_30days=$(calculate_statistics "30")
	stats_7days=$(calculate_statistics "7")
	stats_all=$(calculate_statistics "all")

	# Check if any operations exist
	local total_all
	total_all=$(echo "$stats_all" | jq -r '.total_operations')

	if [[ "$total_all" -eq 0 ]]; then
		log_clean "ℹ️ " "No operations recorded yet"
		log_clean "" ""
		log_clean "" "Run some operations first, then check back!"
		log_clean "" ""
		return 0
	fi

	# Display last 30 days stats
	local ops_30=$(echo "$stats_30days" | jq -r '.total_operations')

	if [[ "$ops_30" -gt 0 ]]; then
		log_clean "📅" "Last 30 days:"
		echo "  Operations: $ops_30"
		echo "  Groups fixed: $(echo "$stats_30days" | jq -r '.total_groups_fixed')"
		echo "  Files changed: $(echo "$stats_30days" | jq -r '.total_files_changed')"
		echo "  Time saved: ~$(echo "$stats_30days" | jq -r '.total_hours_saved') hours"
		echo "  Success rate: $(echo "$stats_30days" | jq -r '.success_rate')%"
		echo ""
	fi

	# Display this week stats
	local ops_7=$(echo "$stats_7days" | jq -r '.total_operations')

	if [[ "$ops_7" -gt 0 ]]; then
		log_clean "📆" "This week (last 7 days):"
		echo "  Operations: $ops_7"
		echo "  Groups fixed: $(echo "$stats_7days" | jq -r '.total_groups_fixed')"
		echo "  Files changed: $(echo "$stats_7days" | jq -r '.total_files_changed')"
		echo "  Avg duration: $(echo "$stats_7days" | jq -r '.average_duration_minutes') min/operation"
		echo ""
	fi

	# Display all-time stats
	log_clean "🏆" "All time:"
	echo "  Total operations: $total_all"
	echo "  Success rate: $(echo "$stats_all" | jq -r '.success_rate')%"
	echo "  Total time saved: ~$(echo "$stats_all" | jq -r '.total_hours_saved') hours"
	echo ""

	# Show most recent operations
	log_clean "🕒" "Recent operations (last 5):"
	local operations
	operations=$(get_all_operations | head -5)

	if [[ -n "$operations" ]]; then
		while IFS= read -r op_file; do
			local timestamp
			local status
			local groups_count
			local mode

			timestamp=$(jq -r '.timestamp // "unknown"' "$op_file" 2>/dev/null)
			status=$(jq -r '.status // "unknown"' "$op_file" 2>/dev/null)
			groups_count=$(jq -r '.groups | length' "$op_file" 2>/dev/null || echo "0")
			mode=$(jq -r '.mode // "fix"' "$op_file" 2>/dev/null)

			# Format timestamp
			local date_str
			date_str=$(echo "$timestamp" | sed 's/_/ /' | sed 's/\([0-9]\{8\}\) \([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1 \2:\3:\4/')

			# Status icon
			local status_icon="✓"
			if [[ "$status" != "success" ]]; then
				status_icon="✗"
			fi

			echo "  $status_icon $date_str - $mode mode - $groups_count groups"
		done <<< "$operations"
	fi

	echo ""
}

# =============================================================================
# EXPORT FUNCTIONALITY
# =============================================================================

# Export statistics to JSON format
export_stats_json() {
	local output_file="${1:-stats.json}"

	local stats_all
	stats_all=$(calculate_statistics "all")

	echo "$stats_all" > "$output_file"

	log "INFO" "Statistics exported to: $output_file"
}

# Export operation history to CSV format
export_history_csv() {
	local output_file="${1:-operations.csv}"

	local operations
	operations=$(get_all_operations)

	# CSV header
	echo "timestamp,mode,status,groups_fixed,files_changed,duration_minutes,success" > "$output_file"

	# CSV data
	while IFS= read -r op_file; do
		if [[ ! -f "$op_file" ]]; then
			continue
		fi

		local timestamp
		local mode
		local status
		local groups_count
		local files_count
		local start_time
		local end_time

		timestamp=$(jq -r '.timestamp // "unknown"' "$op_file" 2>/dev/null)
		mode=$(jq -r '.mode // "fix"' "$op_file" 2>/dev/null)
		status=$(jq -r '.status // "unknown"' "$op_file" 2>/dev/null)
		groups_count=$(jq -r '.groups | length' "$op_file" 2>/dev/null || echo "0")
		files_count=$(jq -r '.files_changed | length' "$op_file" 2>/dev/null || echo "0")
		start_time=$(jq -r '.start_time // 0' "$op_file" 2>/dev/null)
		end_time=$(jq -r '.end_time // 0' "$op_file" 2>/dev/null)

		# Calculate duration in minutes
		local duration=0
		if [[ "$end_time" -gt 0 ]] && [[ "$start_time" -gt 0 ]]; then
			duration=$(awk "BEGIN {printf \"%.1f\", ($end_time - $start_time) / 60}")
		fi

		# Success boolean
		local success="false"
		if [[ "$status" == "success" ]]; then
			success="true"
		fi

		echo "$timestamp,$mode,$status,$groups_count,$files_count,$duration,$success" >> "$output_file"

	done <<< "$operations"

	log "INFO" "Operation history exported to: $output_file"
}

# Export all data (stats + history)
export_all() {
	local base_name="${1:-codebase-ops-export}"

	export_stats_json "${base_name}-stats.json"
	export_history_csv "${base_name}-history.csv"

	log_clean "✅" "Exported all data:"
	echo "  - ${base_name}-stats.json (aggregate statistics)"
	echo "  - ${base_name}-history.csv (operation history)"
	echo ""
}
