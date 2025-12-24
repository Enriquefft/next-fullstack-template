#!/usr/bin/env bash
#
# logging.sh - Logging and reporting functions for codebase operations
#
# This file contains:
# - Log function with verbosity support
# - Phase timing tracking
# - Log rotation and cleanup
# - Report generation
# - Question reporting
#
# Requires: utils.sh (for color codes)
# Expects: LOG_FILE, LOG_DIR, VERBOSITY, LOG_RETENTION_DAYS, CACHE_DIR, CACHE_MAX_SIZE_MB

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================

# Enhanced log function with verbosity support
# Usage: log LEVEL "message"
# Levels: ERROR (always shown), WARN (verbosity >= 0), INFO (>= 1), DEBUG (>= 2)
log() {
	local level="$1"
	shift
	local message="$*"
	local timestamp
	timestamp=$(date '+%Y-%m-%d %H:%M:%S')

	# Determine minimum verbosity for this level
	local min_verbosity=1
	case "$level" in
		ERROR) min_verbosity=0 ;;
		WARN)  min_verbosity=0 ;;
		INFO)  min_verbosity=1 ;;
		DEBUG) min_verbosity=2 ;;
	esac

	# Color based on level
	local color=""
	case "$level" in
		INFO)  color="$GREEN" ;;
		WARN)  color="$YELLOW" ;;
		ERROR) color="$RED" ;;
		DEBUG) color="$BLUE" ;;
	esac

	# Always write to log file (uncolored, structured format for grep)
	if [[ -n "${LOG_FILE:-}" ]]; then
		echo "[$level] [$timestamp] $message" >> "$LOG_FILE"
	fi

	# Only output to console if verbosity is sufficient
	if [[ ${VERBOSITY:-1} -ge $min_verbosity ]]; then
		echo -e "${color}[$timestamp] [$level]${NC} $message"
	fi
}

# Clean log function for user-facing output (no timestamps, cleaner format)
# Usage: log_clean "🔍" "message"
# Always shown unless --quiet, always logged to file
log_clean() {
	local icon="${1:-}"
	shift
	local message="$*"
	local timestamp
	timestamp=$(date '+%Y-%m-%d %H:%M:%S')

	# Always write to log file
	if [[ -n "${LOG_FILE:-}" ]]; then
		echo "[INFO] [$timestamp] $message" >> "$LOG_FILE"
	fi

	# Output to console unless quiet mode
	if [[ ${VERBOSITY:-1} -ge 0 ]]; then
		if [[ -n "$icon" ]]; then
			echo -e "${icon} ${message}"
		else
			echo -e "${message}"
		fi
	fi
}

# Progress indicator (spinner or simple dots)
# Usage: show_progress "message" & PID=$!; ... ; kill $PID 2>/dev/null
show_progress() {
	local message="$1"
	local delay=0.1
	local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
	local temp

	# Only show if not quiet
	if [[ ${VERBOSITY:-1} -lt 1 ]]; then
		return
	fi

	while true; do
		temp=${spinstr#?}
		printf "\r${message} %c " "$spinstr"
		spinstr=$temp${spinstr%"$temp"}
		sleep $delay
	done
}

# Progress bar
# Usage: progress_bar 40 100 "Fixing"
progress_bar() {
	local current=$1
	local total=$2
	local label="${3:-Progress}"
	local width=20
	local percentage=$((current * 100 / total))
	local filled=$((current * width / total))
	local empty=$((width - filled))

	# Only show if not quiet
	if [[ ${VERBOSITY:-1} -lt 1 ]]; then
		return
	fi

	printf "\r${label}: ["
	printf "%${filled}s" | tr ' ' '█'
	printf "%${empty}s" | tr ' ' '░'
	printf "] %3d%%" "$percentage"

	if [[ $current -eq $total ]]; then
		echo ""
	fi
}

# Send desktop notification
# Usage: send_notification "title" "message" "type"
# Types: success, error, info
send_notification() {
	local title="$1"
	local message="$2"
	local type="${3:-info}"

	# Check if notifications are enabled
	if [[ "${ENABLE_NOTIFICATIONS:-true}" != "true" ]]; then
		return
	fi

	# Check if notify-send is available
	if ! command -v notify-send &>/dev/null; then
		return
	fi

	local icon urgency
	case "$type" in
		success)
			icon="dialog-information"
			urgency="normal"
			;;
		error)
			icon="dialog-error"
			urgency="critical"
			;;
		*)
			icon="dialog-information"
			urgency="normal"
			;;
	esac

	notify-send "$title" "$message" --icon="$icon" --urgency="$urgency" 2>/dev/null || true
}

# =============================================================================
# PHASE TIMING
# =============================================================================

# Associative arrays for phase tracking (declare if not exists)
if [[ -z "${PHASE_START_TIMES+x}" ]]; then
	declare -gA PHASE_START_TIMES=()
fi
if [[ -z "${PHASE_DURATIONS+x}" ]]; then
	declare -gA PHASE_DURATIONS=()
fi

# Start timing a phase
start_phase() {
	local phase="$1"
	PHASE_START_TIMES["$phase"]=$(date +%s)
	log "DEBUG" "Phase '$phase' started"
}

# End timing a phase and record duration
end_phase() {
	local phase="$1"
	local status="${2:-completed}"
	local start_time="${PHASE_START_TIMES[$phase]:-$(date +%s)}"
	local end_time
	end_time=$(date +%s)
	local duration=$((end_time - start_time))
	PHASE_DURATIONS["$phase"]=$duration
	log "INFO" "Phase '$phase' $status in ${duration}s"
}

# =============================================================================
# LOG ROTATION & CACHE MANAGEMENT
# =============================================================================

# Log rotation - clean up old logs
cleanup_old_logs() {
	local retention_days="${1:-${LOG_RETENTION_DAYS:-7}}"

	if [[ ! -d "${LOG_DIR:-}" ]]; then
		return
	fi

	local deleted_count=0

	# Find and delete old log files
	while IFS= read -r -d '' file; do
		rm -f "$file"
		((deleted_count++))
	done < <(find "$LOG_DIR" -maxdepth 1 -type f -mtime "+$retention_days" -print0 2>/dev/null)

	# Clean old cache files too
	if [[ -d "${CACHE_DIR:-}" ]]; then
		while IFS= read -r -d '' file; do
			rm -f "$file"
			((deleted_count++))
		done < <(find "$CACHE_DIR" -type f -mtime "+$retention_days" -print0 2>/dev/null)
	fi

	if [[ $deleted_count -gt 0 ]]; then
		log "INFO" "Cleaned up $deleted_count old log/cache files (older than ${retention_days} days)"
	fi
}

# Cache size management
manage_cache_size() {
	local max_size_mb="${1:-${CACHE_MAX_SIZE_MB:-100}}"

	if [[ ! -d "${CACHE_DIR:-}" ]]; then
		return
	fi

	local cache_size_kb
	cache_size_kb=$(du -sk "$CACHE_DIR" 2>/dev/null | cut -f1)
	local cache_size_mb=$((cache_size_kb / 1024))

	if [[ $cache_size_mb -gt $max_size_mb ]]; then
		log "INFO" "Cache size ${cache_size_mb}MB exceeds limit ${max_size_mb}MB, pruning..."

		# Delete oldest files until under limit
		local deleted=0
		while [[ $cache_size_mb -gt $max_size_mb && $deleted -lt 50 ]]; do
			local oldest
			oldest=$(find "$CACHE_DIR" -type f -printf '%T+ %p\n' 2>/dev/null | sort | head -1 | cut -d' ' -f2-)
			if [[ -n "$oldest" && -f "$oldest" ]]; then
				rm -f "$oldest"
				((deleted++))
			else
				break
			fi
			cache_size_kb=$(du -sk "$CACHE_DIR" 2>/dev/null | cut -f1)
			cache_size_mb=$((cache_size_kb / 1024))
		done

		log "INFO" "Pruned $deleted cache files, new size: ${cache_size_mb}MB"
	fi
}

# =============================================================================
# REPORTING
# =============================================================================

# Report unresolved questions from Claude instances
report_questions() {
	if [[ ! -d "${QUESTIONS_DIR:-}" ]]; then
		return 0
	fi

	local question_files=()
	while IFS= read -r -d '' file; do
		question_files+=("$file")
	done < <(find "$QUESTIONS_DIR" -name "*.md" -type f -size +0 -print0 2>/dev/null)

	if [[ ${#question_files[@]} -gt 0 ]]; then
		log "WARN" "=========================================="
		log "WARN" "UNRESOLVED QUESTIONS FROM CLAUDE"
		log "WARN" "=========================================="

		for qfile in "${question_files[@]}"; do
			local group_name
			group_name=$(basename "$qfile" .md | sed 's/_questions$//')
			log "WARN" ""
			log "WARN" "--- $group_name ---"
			while IFS= read -r line; do
				log "WARN" "  $line"
			done < "$qfile"
		done

		log "WARN" "=========================================="
		return 1
	fi

	return 0
}

# Generate final JSON report
generate_report() {
	local exit_status="${1:-0}"
	local end_time
	end_time=$(date +%s)
	local total_duration=$((end_time - ${SCRIPT_START_TIME:-$end_time}))

	# Build phase durations JSON
	local phases_json="{"
	local first=true
	for phase in "${!PHASE_DURATIONS[@]}"; do
		if [[ "$first" != true ]]; then
			phases_json+=","
		fi
		phases_json+="\"$phase\":${PHASE_DURATIONS[$phase]}"
		first=false
	done
	phases_json+="}"

	# Get diagnostics data from groups file
	local diagnostics_json="{}"
	local groups_file="${GROUPS_FILE:-${BUG_GROUPS_FILE:-}}"
	if [[ -f "$groups_file" ]]; then
		diagnostics_json=$(jq -c '{
			total_errors: (.summary.total_errors // .summary.total_findings // 0),
			groups_count: .summary.groups_count,
			groups: [.groups[] | {name, complexity: .estimated_complexity, errors: ((.errors // .findings // .improvements) | length)}]
		}' "$groups_file" 2>/dev/null || echo "{}")
	fi

	cat > "${REPORT_FILE:-/dev/null}" <<JSONEOF
{
  "timestamp": "${TIMESTAMP:-$(date +%Y%m%d_%H%M%S)}",
  "mode": "${MODE:-fix}",
  "duration_seconds": $total_duration,
  "exit_status": $exit_status,
  "git": {
    "original_head": "${ORIGINAL_MAIN_HEAD:-null}",
    "final_head": "$(git -C "${PROJECT_DIR:-.}" rev-parse HEAD 2>/dev/null || echo null)"
  },
  "diagnostics": $diagnostics_json,
  "phase_durations": $phases_json,
  "log_file": "$(basename "${LOG_FILE:-unknown}")"
}
JSONEOF

	log "INFO" "Report: ${REPORT_FILE:-/dev/null}"
}
