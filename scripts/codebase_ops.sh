#!/usr/bin/env bash
#
# codebase_ops.sh - Multi-Mode Codebase Operations Script
#
# This script automates codebase operations using Claude Code CLI instances:
# 1. Runs diagnostic commands and analyzes issues
# 2. Groups issues by module with dependency analysis
# 3. Creates git worktrees for isolated work
# 4. Launches parallel Claude instances to address issues
# 5. Merges changes back to main in order
#
# Modes:
#   fix     - Automated bug fixing (default)
#   improve - Codebase improvement and refactoring
#
# Model Strategy (optimized for cost and performance):
# - Phase 1 (Diagnostics): Opus for complex dependency analysis and grouping
# - Phase 3 (Tasks): Sonnet/Haiku for implementation tasks
#
# Usage:
#   ./codebase_ops.sh                    # Fix mode (default)
#   ./codebase_ops.sh --mode improve     # Improve mode
#   ./codebase_ops.sh --dry-run          # Only run diagnostics
#
set -euo pipefail

# =============================================================================
# SCRIPT LOCATION & INITIALIZATION
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default mode
MODE="fix"

# Parse --mode first (before loading libraries)
REMAINING_ARGS=()
while [[ $# -gt 0 ]]; do
	case "$1" in
		--mode)
			MODE="$2"
			shift 2
			;;
		--mode=*)
			MODE="${1#*=}"
			shift
			;;
		*)
			REMAINING_ARGS+=("$1")
			shift
			;;
	esac
done
set -- "${REMAINING_ARGS[@]:-}"

# =============================================================================
# LOAD CORE LIBRARIES
# =============================================================================

source "${SCRIPT_DIR}/lib/core/utils.sh"
source "${SCRIPT_DIR}/lib/core/logging.sh"
source "${SCRIPT_DIR}/lib/core/config.sh"
source "${SCRIPT_DIR}/lib/core/cache.sh"
source "${SCRIPT_DIR}/lib/core/cleanup.sh"
source "${SCRIPT_DIR}/lib/core/worktree.sh"
source "${SCRIPT_DIR}/lib/core/parallel.sh"
source "${SCRIPT_DIR}/lib/core/merge.sh"
source "${SCRIPT_DIR}/lib/core/history.sh"

# Load mode system
source "${SCRIPT_DIR}/lib/modes/base.sh"

# =============================================================================
# CONFIGURATION
# =============================================================================

# Auto-detect project directory
PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
WORKTREE_BASE="$(dirname "$PROJECT_DIR")"
LOG_DIR="${PROJECT_DIR}/.fix_bugs_logs"
CACHE_DIR="${LOG_DIR}/cache"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/codebase_ops_${TIMESTAMP}.log"
GROUPS_FILE="${LOG_DIR}/groups_${TIMESTAMP}.json"
DIAGNOSTIC_OUTPUT="${LOG_DIR}/diagnostic_output_${TIMESTAMP}.txt"
PIDS_FILE="${LOG_DIR}/claude_pids_${TIMESTAMP}.txt"
QUESTIONS_DIR="${LOG_DIR}/questions"
REPORT_FILE="${LOG_DIR}/report_${TIMESTAMP}.json"

# Model selection
DIAGNOSTIC_MODEL="opus"
FIXING_MODEL="sonnet"

# Performance tuning
MAX_PARALLEL_CLAUDE=5
COMMAND_TIMEOUT=600
MAX_OUTPUT_SIZE=100000

# Log retention
LOG_RETENTION_DAYS=7
CACHE_MAX_SIZE_MB=100

# Detect package manager and commands
PACKAGE_MANAGER=$(detect_package_manager)
detect_test_commands
detect_project_structure
set_install_command

# Arrays to track created resources
declare -a CREATED_WORKTREES=()
declare -a CREATED_BRANCHES=()

# Flags
DRY_RUN=false
INTERACTIVE=true
AUTO_FIX=false
AUTO_MERGE=false
ALLOW_DIRTY=false
FINAL_REVIEW=false
SIMPLE_ONLY=true
VERBOSITY=1
PREVIEW_MODE=true     # New: Show preview and prompt by default
EXECUTE_MODE=false    # New: Skip confirmation prompt
ENABLE_NOTIFICATIONS=true  # New: Desktop notifications
SINCE_REF=""          # New: Only analyze files changed since ref
FILE_FILTER=""        # New: Only analyze specific files/directories
CONFIDENCE_LEVEL=""   # New: Filter by confidence level (safe/medium/low)
SAFE_ONLY=false       # New: Alias for --confidence safe
SHOW_DIFF=false       # New: Show group details and prompt per group

# Phase timing
declare -A PHASE_START_TIMES=()
declare -A PHASE_DURATIONS=()
SCRIPT_START_TIME=$(date +%s)

# Original HEAD for change detection
ORIGINAL_MAIN_HEAD=""

# For backward compatibility with fix mode
BUG_GROUPS_FILE="$GROUPS_FILE"

# =============================================================================
# USAGE
# =============================================================================

usage() {
	cat <<EOF
$(basename "$0") - AI-powered codebase analysis and fixing

Usage: $(basename "$0") [OPTIONS]

COMMON WORKFLOWS (90% of use cases):

  $(basename "$0")                    # Preview issues, choose what to fix (RECOMMENDED)
  $(basename "$0") --since main       # Fix only files changed in current branch
  $(basename "$0") --execute          # Preview then apply fixes (skip confirmation)
  $(basename "$0") --dry-run          # Just show what would be fixed

MODES:
  fix (default)   Fix test/type/build/lint failures
  improve         Find code quality improvements

KEY OPTIONS:
  --since <ref>       Only analyze files changed since git ref (main, HEAD~1, etc.)
  --safe              Only apply safe/simple fixes (same as --confidence safe)
  --confidence <lvl>  Filter by confidence: safe, medium, low (default: all)
  --show-diff         Show files/issues per group and prompt to approve each one
  --execute           Apply fixes without confirmation (preview still shown)
  --dry-run           Only run analysis, don't prompt or fix anything
  --mode <mode>       Select mode: fix or improve
  --all               Process ALL issues (default: simple/safe only)
  --continue          Resume from previous interactive session
  --no-notifications  Disable desktop notifications

ADVANCED OPTIONS:
  --interactive       Run Claude in tmux for Q&A [DEFAULT]
  --auto              Fully automatic (background + auto-merge, no interaction)
  --auto-fix          Auto task phase only (background, no tmux)
  --auto-merge        Auto merge phase only (no prompts)
  --allow-dirty       Allow running with uncommitted changes
  --final-review      Run final Claude review after all merges
  --verbose, -v       Show detailed DEBUG messages
  --quiet, -q         Show only warnings and errors

EXAMPLES:

  # First time? Start here - see what needs fixing
  $(basename "$0") --dry-run

  # Fix only what you changed in your PR (fastest!)
  $(basename "$0") --since main

  # Only apply safe, automated fixes (formatting, imports, etc.)
  $(basename "$0") --safe

  # Fix safe + medium complexity issues
  $(basename "$0") --confidence medium

  # Review each group in detail before fixing
  $(basename "$0") --show-diff

  # Fix formatting issues quickly
  $(basename "$0") --dry-run
  # (then select only safe/lint groups when prompted)

  # Fix everything automatically (use with caution!)
  $(basename "$0") --all --execute --auto

  # Code quality improvements
  $(basename "$0") --mode improve

HOW IT WORKS:
  1. 🔍 Runs diagnostics (test, type, build, lint) in parallel
  2. 🤖 AI analyzes and groups issues by module & dependencies
  3. 📋 Shows preview and lets you choose what to fix
  4. 🔧 Creates isolated git worktrees for parallel fixing
  5. 🎯 Launches Claude Code CLI to fix each group
  6. ✅ Merges changes back to main in dependency order

REQUIREMENTS:
  - claude CLI (authenticated)
  - jq (JSON processing)
  - tmux (for --interactive mode)
  - Clean git working directory (or use --allow-dirty)

TIPS:
  - Use --since main for fastest feedback (only fix your changes)
  - Use --safe for fully automated, zero-risk fixes
  - Default mode shows preview first - safe to explore
  - Groups marked "SAFE" (✓) are low-risk automated fixes
  - Groups marked "REVIEW" (⚠️ ) should be inspected before applying
  - Confidence levels: safe < medium < low (increasing complexity)
  - Logs saved to: .fix_bugs_logs/ (auto-cleaned after 7 days)

Full docs: See CLAUDE.md section "Automated Codebase Operations"
EOF
}

# =============================================================================
# DEPENDENCY CHECKING
# =============================================================================

check_dependencies() {
	log "INFO" "Checking dependencies..."

	local missing=()

	# Platform check
	local platform
	platform=$(uname -s)
	if [[ "$platform" != "Linux" ]]; then
		log "WARN" "Platform: $platform (script designed for Linux)"
	fi

	if ! command -v claude &>/dev/null; then
		missing+=("claude (Claude Code CLI)")
	fi

	if ! command -v jq &>/dev/null; then
		missing+=("jq (JSON processor)")
	fi

	if ! command -v $PACKAGE_MANAGER &>/dev/null; then
		missing+=("$PACKAGE_MANAGER (package manager)")
	fi

	if ! command -v git &>/dev/null; then
		missing+=("git")
	fi

	if [[ "$INTERACTIVE" == true ]] && ! command -v tmux &>/dev/null; then
		missing+=("tmux (required for --interactive mode)")
	fi

	if [[ ${#missing[@]} -gt 0 ]]; then
		# Show specific error guidance based on what's missing
		for dep in "${missing[@]}"; do
			if [[ "$dep" == *"claude"* ]]; then
				show_error_guidance "claude_not_found"
				exit 1
			elif [[ "$dep" == *"jq"* ]]; then
				show_error_guidance "jq_not_found"
				exit 1
			elif [[ "$dep" == *"tmux"* ]]; then
				show_error_guidance "tmux_not_found"
				exit 1
			fi
		done

		# Generic missing dependencies error
		log "ERROR" "Missing required dependencies:"
		for dep in "${missing[@]}"; do
			log "ERROR" "  - $dep"
		done
		exit 1
	fi

	log "INFO" "All required dependencies found"
}

# =============================================================================
# DIAGNOSTIC PHASE
# =============================================================================

run_diagnostics() {
	log "INFO" "=========================================="
	log "INFO" "PHASE 1: DIAGNOSTIC ANALYSIS"
	log "INFO" "=========================================="

	# Apply incremental mode filtering (--since)
	if [[ -n "$SINCE_REF" ]]; then
		if ! build_filtered_commands "$SINCE_REF"; then
			log_clean "ℹ️ " "No files changed since '$SINCE_REF'"
			exit 0
		fi
	fi

	# Check for cached diagnostic result
	local cache_key
	cache_key=$(compute_cache_key)
	log "INFO" "Git commit: $cache_key"

	local cached_file
	if cached_file=$(check_diagnostic_cache "$cache_key"); then
		log "INFO" "✓ Found cached diagnostic result!"
		load_diagnostic_cache "$cached_file" "$GROUPS_FILE"
		return 0
	fi

	log "INFO" "Running diagnostic commands in parallel..."

	# Run diagnostic commands
	local test_output="${LOG_DIR}/test_output_${TIMESTAMP}.txt"
	local type_output="${LOG_DIR}/type_output_${TIMESTAMP}.txt"
	local build_output="${LOG_DIR}/build_output_${TIMESTAMP}.txt"
	local e2e_output="${LOG_DIR}/e2e_output_${TIMESTAMP}.txt"
	local biome_output="${LOG_DIR}/biome_output_${TIMESTAMP}.txt"

	local test_pid="" type_pid="" build_pid="" e2e_pid="" biome_pid=""

	[[ -n "$TEST_CMD" ]] && { (cd "$PROJECT_DIR" && timeout "$COMMAND_TIMEOUT" $TEST_CMD) >"$test_output" 2>&1 & test_pid=$!; }
	[[ -n "$TYPE_CMD" ]] && { (cd "$PROJECT_DIR" && timeout "$COMMAND_TIMEOUT" $TYPE_CMD) >"$type_output" 2>&1 & type_pid=$!; }
	[[ -n "$BUILD_CMD" ]] && { (cd "$PROJECT_DIR" && timeout "$COMMAND_TIMEOUT" $BUILD_CMD) >"$build_output" 2>&1 & build_pid=$!; }
	[[ -n "$E2E_CMD" ]] && { (cd "$PROJECT_DIR" && timeout "$COMMAND_TIMEOUT" $E2E_CMD) >"$e2e_output" 2>&1 & e2e_pid=$!; }
	[[ -n "$BIOME_CMD" ]] && { (cd "$PROJECT_DIR" && timeout "$COMMAND_TIMEOUT" $BIOME_CMD) >"$biome_output" 2>&1 & biome_pid=$!; }

	# Wait for commands
	[[ -n "$test_pid" ]] && { wait $test_pid || true; log "INFO" "  ✓ $TEST_CMD complete"; }
	[[ -n "$type_pid" ]] && { wait $type_pid || true; log "INFO" "  ✓ $TYPE_CMD complete"; }
	[[ -n "$build_pid" ]] && { wait $build_pid || true; log "INFO" "  ✓ $BUILD_CMD complete"; }
	[[ -n "$e2e_pid" ]] && { wait $e2e_pid || true; log "INFO" "  ✓ $E2E_CMD complete"; }
	[[ -n "$biome_pid" ]] && { wait $biome_pid || true; log "INFO" "  ✓ $BIOME_CMD complete"; }

	# Truncate large outputs
	truncate_output "$test_output" "$MAX_OUTPUT_SIZE"
	truncate_output "$type_output" "$MAX_OUTPUT_SIZE"
	truncate_output "$build_output" "$MAX_OUTPUT_SIZE"
	truncate_output "$e2e_output" "$MAX_OUTPUT_SIZE"
	truncate_output "$biome_output" "$MAX_OUTPUT_SIZE"

	# Build command outputs for prompt
	local cmd_outputs=""
	local cmd_num=1

	for cmd_var in TEST_CMD TYPE_CMD BUILD_CMD E2E_CMD BIOME_CMD; do
		local cmd="${!cmd_var}"
		local output_file="${LOG_DIR}/${cmd_var,,}_output_${TIMESTAMP}.txt"
		output_file="${output_file//_cmd_/_}"

		if [[ -n "$cmd" ]] && [[ -f "$output_file" ]]; then
			cmd_outputs+="### ${cmd_num}. $cmd
\`\`\`
$(summarize_if_large "$output_file")
\`\`\`

"
			((cmd_num++))
		fi
	done

	# Get diagnostic prompt from mode
	local diag_prompt
	diag_prompt=$(get_diagnostic_prompt "$cmd_outputs")

	log "INFO" "Running Claude diagnostic analysis (${DIAGNOSTIC_MODEL^^})..."

	if ! claude --print \
		--dangerously-skip-permissions \
		--model "$DIAGNOSTIC_MODEL" \
		"$diag_prompt" > "$DIAGNOSTIC_OUTPUT" 2>&1; then
		show_error_guidance "claude_analysis_failed" "$DIAGNOSTIC_OUTPUT"
		exit 2
	fi

	# Extract and validate JSON
	local json_result
	json_result=$(cat "$DIAGNOSTIC_OUTPUT")

	if ! echo "$json_result" | jq . >/dev/null 2>&1; then
		log "INFO" "Extracting JSON from output..."
		json_result=$(echo "$json_result" | grep -Pzo '\{[\s\S]*\}' 2>/dev/null | tr -d '\0' || echo "")
	fi

	if echo "$json_result" | jq -e '.summary and .groups' >/dev/null 2>&1; then
		echo "$json_result" | jq . > "$GROUPS_FILE"
		log "INFO" "Groups saved to: $GROUPS_FILE"
		save_diagnostic_cache "$cache_key" "$GROUPS_FILE"
	else
		show_error_guidance "invalid_json" "$GROUPS_FILE"
		exit 2
	fi

	# Check results
	local total_items groups_count
	total_items=$(jq -r '.summary.total_errors // .summary.total_findings // 0' "$GROUPS_FILE")
	groups_count=$(jq -r '.summary.groups_count // 0' "$GROUPS_FILE")

	if [[ "$total_items" -eq 0 ]]; then
		show_error_guidance "no_issues_found"
		exit 0
	fi

	log "INFO" "Found $total_items items in $groups_count groups"

	# Display summary
	log "INFO" "Groups (ordered by priority):"
	jq -r '.groups[] | "  \(.order). \(.name) - \(.estimated_complexity) - \((.errors // .findings // .improvements) | length) items"' "$GROUPS_FILE"
}

# =============================================================================
# CONTINUE FROM INTERACTIVE MODE
# =============================================================================

continue_from_interactive() {
	log "INFO" "=========================================="
	log "INFO" "CONTINUING FROM INTERACTIVE MODE"
	log "INFO" "=========================================="

	if [[ ! -f "${LOG_DIR}/current_groups.txt" ]]; then
		log "ERROR" "No previous session found. Run without --continue first."
		exit 1
	fi

	GROUPS_FILE=$(cat "${LOG_DIR}/current_groups.txt")
	BUG_GROUPS_FILE="$GROUPS_FILE"

	if [[ ! -f "$GROUPS_FILE" ]]; then
		log "ERROR" "Groups file not found: $GROUPS_FILE"
		exit 1
	fi

	log "INFO" "Using groups from: $GROUPS_FILE"

	# Restore original main HEAD
	if [[ -f "${LOG_DIR}/original_main_head.txt" ]]; then
		ORIGINAL_MAIN_HEAD=$(cat "${LOG_DIR}/original_main_head.txt")
		log "INFO" "Restored original main HEAD: ${ORIGINAL_MAIN_HEAD:0:8}"
	fi

	# Restore worktrees from groups
	restore_worktrees_from_groups "$GROUPS_FILE"

	# Kill tmux session
	if [[ -f "${LOG_DIR}/current_session.txt" ]]; then
		local session_name
		session_name=$(cat "${LOG_DIR}/current_session.txt")
		tmux kill-session -t "$session_name" 2>/dev/null || true
	fi
}

# =============================================================================
# FINAL REVIEW
# =============================================================================

run_final_review() {
	log "INFO" "=========================================="
	log "INFO" "PHASE 5: FINAL REVIEW"
	log "INFO" "=========================================="

	cd "$PROJECT_DIR"

	local review_range="${ORIGINAL_MAIN_HEAD}..HEAD"
	local commits_count
	commits_count=$(git rev-list --count "$review_range" 2>/dev/null || echo "0")

	if [[ "$commits_count" -eq 0 ]]; then
		log "INFO" "No commits to review"
		return 0
	fi

	log "INFO" "Reviewing $commits_count commit(s)"

	local diff_file="${LOG_DIR}/final_review_diff_${TIMESTAMP}.txt"
	git diff "$review_range" > "$diff_file"

	local changed_files
	changed_files=$(git diff --name-only "$review_range" | head -50)

	local review_prompt
	if type -t get_final_review_prompt &>/dev/null; then
		review_prompt=$(get_final_review_prompt "$diff_file" "$changed_files" "$commits_count" "$review_range")
	else
		log "WARN" "No final review prompt defined for this mode"
		return 0
	fi

	local review_output="${LOG_DIR}/final_review_${TIMESTAMP}.txt"

	if ! claude --print \
		--dangerously-skip-permissions \
		--model opus \
		"$review_prompt" > "$review_output" 2>&1; then
		log "ERROR" "Final review failed"
		return 1
	fi

	log "INFO" "Final review complete!"
	cat "$review_output"
	log "INFO" "Full review saved to: $review_output"

	if grep -qi "critical" "$review_output"; then
		log "WARN" "CRITICAL ISSUES DETECTED IN REVIEW"
		if [[ -t 0 ]]; then
			read -p "Continue anyway? (y/N): " continue_anyway
			[[ "$continue_anyway" != "y" && "$continue_anyway" != "Y" ]] && return 1
		fi
	fi

	return 0
}

# =============================================================================
# SUBCOMMANDS (history, undo, rollback)
# =============================================================================

# Check if first argument is a subcommand
if [[ $# -gt 0 ]]; then
	case "$1" in
		history)
			# Show operation history
			mkdir -p "$LOG_DIR"
			list_history
			exit 0
			;;
		undo)
			# Undo last operation or specific index
			mkdir -p "$LOG_DIR"
			if [[ -n "$2" ]] && [[ "$2" =~ ^[0-9]+$ ]]; then
				rollback_to "$2"
			else
				undo_last
			fi
			exit $?
			;;
		rollback)
			# Rollback to specific operation (requires index)
			mkdir -p "$LOG_DIR"
			if [[ -z "$2" ]] || [[ ! "$2" =~ ^[0-9]+$ ]]; then
				log_clean "❌" "Usage: $0 rollback <number>"
				log_clean "💡" "Use '$0 history' to see available operations"
				exit 1
			fi
			rollback_to "$2"
			exit $?
			;;
	esac
fi

# =============================================================================
# MAIN
# =============================================================================

main() {
	local CONTINUE_MODE=false

	# Parse remaining arguments
	while [[ $# -gt 0 ]]; do
		case "$1" in
			--dry-run) DRY_RUN=true; PREVIEW_MODE=false; shift ;;
			--execute) EXECUTE_MODE=true; PREVIEW_MODE=true; shift ;;
			--since) SINCE_REF="$2"; shift 2 ;;
			--since=*) SINCE_REF="${1#*=}"; shift ;;
			--safe) SAFE_ONLY=true; CONFIDENCE_LEVEL="safe"; shift ;;
			--confidence) CONFIDENCE_LEVEL="$2"; shift 2 ;;
			--confidence=*) CONFIDENCE_LEVEL="${1#*=}"; shift ;;
			--show-diff) SHOW_DIFF=true; shift ;;
			--no-notifications) ENABLE_NOTIFICATIONS=false; shift ;;
			--interactive|-i) INTERACTIVE=true; AUTO_FIX=false; shift ;;
			--auto) AUTO_FIX=true; AUTO_MERGE=true; INTERACTIVE=false; EXECUTE_MODE=true; shift ;;
			--auto-fix) AUTO_FIX=true; INTERACTIVE=false; shift ;;
			--auto-merge) AUTO_MERGE=true; shift ;;
			--continue|-c) CONTINUE_MODE=true; shift ;;
			--allow-dirty) ALLOW_DIRTY=true; shift ;;
			--final-review) FINAL_REVIEW=true; shift ;;
			--all) SIMPLE_ONLY=false; shift ;;
			--verbose|-v) VERBOSITY=2; shift ;;
			--quiet|-q) VERBOSITY=0; shift ;;
			--help|-h) usage; exit 0 ;;
			*)
				# Check if it's a file or directory (for FILE_FILTER)
				if [[ -e "$1" || "$1" == *"/"* ]]; then
					FILE_FILTER="$1"
					shift
				else
					log "ERROR" "Unknown option: $1"
					usage
					exit 1
				fi
				;;
		esac
	done

	# Setup
	mkdir -p "$LOG_DIR" "$QUESTIONS_DIR" "$CACHE_DIR"
	trap cleanup_on_interrupt SIGINT SIGTERM

	# Clean old logs
	cleanup_old_logs
	manage_cache_size

	# Load mode
	if ! load_mode "$MODE"; then
		exit 1
	fi

	# Display startup info
	log "INFO" "=========================================="
	log "INFO" "Codebase Operations - ${MODE_CONFIG[name]}"
	log "INFO" "Timestamp: $TIMESTAMP"
	log "INFO" "Log file: $LOG_FILE"
	log "INFO" "=========================================="

	# Check dependencies
	check_dependencies

	# Handle continue mode
	if [[ "$CONTINUE_MODE" == true ]]; then
		continue_from_interactive
	else
		# Phase 1: Diagnostics
		start_phase "diagnostics"
		run_diagnostics
		end_phase "diagnostics"

		# Apply filtering if simple-only mode
		if [[ "$SIMPLE_ONLY" == true ]]; then
			log "INFO" "Filtering to ${MODE_CONFIG[default_filter]} items..."
			local full_groups="$GROUPS_FILE"
			local filtered
			filtered=$(filter_groups "$full_groups" "${MODE_CONFIG[default_filter]}")
			echo "$filtered" > "${GROUPS_FILE%.json}_filtered.json"
			GROUPS_FILE="${GROUPS_FILE%.json}_filtered.json"
			BUG_GROUPS_FILE="$GROUPS_FILE"

			# Report skipped items
			if type -t report_skipped_groups &>/dev/null; then
				report_skipped_groups "$full_groups"
			fi

			local filtered_count
			filtered_count=$(jq -r '.summary.groups_count' "$GROUPS_FILE")
			if [[ "$filtered_count" -eq 0 ]]; then
				log "INFO" "No ${MODE_CONFIG[default_filter]} items found."
				exit 0
			fi
		fi

		# Apply confidence-based filtering (Phase 2 DX Improvement)
		if [[ -n "$CONFIDENCE_LEVEL" ]] || [[ "$SAFE_ONLY" == true ]]; then
			local confidence="${CONFIDENCE_LEVEL:-safe}"
			local complexity_filter=""

			# Map confidence to complexity values
			case "$confidence" in
				safe|high)
					complexity_filter='["simple", "quick-win"]'
					log "INFO" "Filtering to safe/simple groups only..."
					;;
				medium)
					complexity_filter='["simple", "quick-win", "medium", "moderate"]'
					log "INFO" "Filtering to safe and medium-complexity groups..."
					;;
				low|all)
					# No filtering - include all groups
					complexity_filter=""
					;;
				*)
					log "WARN" "Unknown confidence level: $confidence. Using 'safe' as default."
					complexity_filter='["simple", "quick-win"]'
					;;
			esac

			if [[ -n "$complexity_filter" ]]; then
				local full_groups="$GROUPS_FILE"
				local filtered

				# Filter groups by complexity
				filtered=$(jq --argjson allowed "$complexity_filter" '
					.groups |= map(select(.complexity as $c | $allowed | index($c))) |
					.summary.groups_count = (.groups | length) |
					.summary.total_files = ([.groups[].files | length] | add // 0) |
					.summary.total_issues = ([.groups[].diagnostics | length] | add // 0)
				' "$full_groups")

				echo "$filtered" > "${GROUPS_FILE%.json}_confidence_filtered.json"
				GROUPS_FILE="${GROUPS_FILE%.json}_confidence_filtered.json"
				BUG_GROUPS_FILE="$GROUPS_FILE"

				local filtered_count
				filtered_count=$(jq -r '.summary.groups_count' "$GROUPS_FILE")

				if [[ "$filtered_count" -eq 0 ]]; then
					log_clean "ℹ️ " "No groups match confidence level '$confidence'."
					log_clean "" "Try a lower confidence threshold or run without --safe flag."
					exit 0
				fi

				log "DEBUG" "Filtered to $filtered_count groups matching confidence level '$confidence'"
			fi
		fi

		# Phase 1.5: Preview and Selection (NEW DX IMPROVEMENT)
		if [[ "$PREVIEW_MODE" == true ]]; then
			# Display groups summary
			display_groups_summary "$GROUPS_FILE"

			# Exit if dry-run (no prompting)
			if [[ "$DRY_RUN" == true ]]; then
				log_clean "" "Dry run complete. Use --execute to apply fixes."
				log "INFO" "Full analysis: $GROUPS_FILE"
				exit 0
			fi

			# Prompt for selection (unless --execute flag)
			if [[ "$EXECUTE_MODE" != true ]]; then
				log_clean "❓" "Which groups would you like to fix?"
				echo -n "Enter selection [numbers like 1,3,5 | 'all' | 'safe' | 'none']: "
				read -r selection

				# Handle 'none' or empty
				if [[ -z "$selection" || "$selection" == "none" || "$selection" == "n" ]]; then
					log_clean "⏭️ " "Skipped. No changes made."
					exit 0
				fi

				# Parse selection and filter groups
				local selected_indices
				selected_indices=$(parse_selection "$selection" "$GROUPS_FILE")

				if [[ -z "$selected_indices" ]]; then
					log_clean "❌" "Invalid selection. Exiting."
					exit 1
				fi

				# Filter to selected groups
				log_clean "🔍" "Filtering to selected groups..."
				GROUPS_FILE=$(filter_selected_groups "$GROUPS_FILE" "$selected_indices")
				BUG_GROUPS_FILE="$GROUPS_FILE"

				# Verify we still have groups
				local final_count
				final_count=$(jq -r '.summary.groups_count' "$GROUPS_FILE")
				if [[ "$final_count" -eq 0 ]]; then
					log_clean "❌" "No groups selected. Exiting."
					exit 0
				fi

				log_clean "✓" "Will fix $final_count group(s)"
				echo ""
			fi
		fi

		# Phase 1.6: Per-Group Approval with Diff Preview (--show-diff)
		if [[ "$SHOW_DIFF" == true ]]; then
			log_clean "🔍" "Showing detailed preview for each group..."
			echo ""

			# Get current group count
			local groups_count
			groups_count=$(jq -r '.summary.groups_count' "$GROUPS_FILE")

			# Track approved group indices
			local approved_indices=()

			# Loop through each group
			for ((i=0; i<groups_count; i++)); do
				local group_name
				group_name=$(jq -r ".groups[$i].name" "$GROUPS_FILE")

				# Show preview
				show_group_preview "$GROUPS_FILE" "$i"

				# Prompt for approval
				if prompt_group_approval "$group_name"; then
					approved_indices+=("$i")
					log_clean "✓" "Group '$group_name' approved"
				fi
				echo ""
			done

			# Check if any groups were approved
			if [[ ${#approved_indices[@]} -eq 0 ]]; then
				log_clean "⏭️ " "No groups approved. Exiting."
				exit 0
			fi

			# Filter to only approved groups
			log_clean "🔍" "Filtering to ${#approved_indices[@]} approved group(s)..."
			GROUPS_FILE=$(filter_selected_groups "$GROUPS_FILE" "${approved_indices[*]}")
			BUG_GROUPS_FILE="$GROUPS_FILE"

			log_clean "✓" "Will proceed with ${#approved_indices[@]} group(s)"
			echo ""
		fi

		# Save operation start state (for undo/rollback)
		if [[ "$DRY_RUN" != true ]]; then
			save_operation_start "$MODE" "$GROUPS_FILE"
		fi

		# Phase 2: Create worktrees
		start_phase "worktree_creation"
		create_worktrees
		end_phase "worktree_creation"

		# Phase 3: Parallel tasks
		start_phase "tasks"
		run_parallel_tasks
		# Note: In interactive mode, this exits
	fi

	# Phase 4: Sequential merging
	start_phase "merging"
	if merge_branches; then
		end_phase "merging"

		# Phase 5: Final review (optional)
		if [[ "$FINAL_REVIEW" == true ]]; then
			start_phase "final_review"
			if ! run_final_review; then
				end_phase "final_review" "failed"
				exit 1
			fi
			end_phase "final_review"
		fi

		# Calculate total time
		local total_time=$(($(date +%s) - SCRIPT_START_TIME))
		local time_str
		time_str=$(format_time $((total_time / 60)))

		log_clean "✅" "SUCCESS: All fixes applied in ${time_str}!"
		echo ""

		report_questions
		cleanup_worktrees
		cleanup_temp_files
		generate_report 0

		# Save operation end state
		save_operation_end "success"
		cleanup_old_tags
		cleanup_old_operations

		# Desktop notification
		local groups_fixed
		groups_fixed=$(jq -r '.summary.groups_count' "$GROUPS_FILE" 2>/dev/null || echo "0")
		send_notification \
			"Codebase Fixes Complete" \
			"✅ ${groups_fixed} groups fixed in ${time_str}\nReview: git diff" \
			"success"

		log_clean "📄" "Logs: $LOG_FILE"
		log_clean "💡" "Undo: ./scripts/codebase_ops.sh undo"
		log "INFO" "Report: $REPORT_FILE"
	else
		end_phase "merging" "failed"

		log_clean "❌" "FAILURE: Some fixes could not be applied"
		echo ""

		report_questions
		generate_report 1

		# Save operation end state
		save_operation_end "failed"

		# Desktop notification
		send_notification \
			"Codebase Fixes Failed" \
			"❌ Some groups failed. Check logs for details." \
			"error"

		log_clean "📄" "Logs: $LOG_FILE"
		log_clean "💡" "Undo partial changes: ./scripts/codebase_ops.sh undo"
		exit 1
	fi
}

main "$@"
