#!/usr/bin/env bash
#
# base.sh - Mode interface definition for codebase operations
#
# This file defines:
# - MODE_CONFIG associative array contract
# - Template loading utility (load_prompt)
# - Default implementations for mode functions
#
# Each mode must define:
# - MODE_CONFIG associative array with required keys
# - get_diagnostic_prompt() function
# - get_task_prompt() function
# - filter_groups() function (optional, has default)

# =============================================================================
# MODE CONFIGURATION CONTRACT
# =============================================================================
#
# Required MODE_CONFIG keys:
#   [name]           - Human-readable mode name (e.g., "Bug Fixing")
#   [description]    - Help text for usage
#   [prompts_dir]    - Directory containing prompt templates
#   [docs_file]      - Documentation file to track updates
#   [output_prefix]  - Prefix for generated output files
#   [commit_prefix]  - Conventional commit prefix (fix/refactor/chore)
#   [branch_prefix]  - Git branch prefix (fix/improve)
#   [default_filter] - Default complexity filter (simple/quick-win/all)
#
# Optional MODE_CONFIG keys:
#   [diagnostic_focus] - What to analyze (errors/improvements)

# =============================================================================
# TEMPLATE LOADING
# =============================================================================

# Load a prompt template and substitute variables
# Usage: load_prompt "template.md" VAR1="value1" VAR2="value2"
#
# Template syntax: ${VARIABLE_NAME}
# Falls back to shared prompts if mode-specific not found
load_prompt() {
	local template="$1"
	shift

	local prompts_dir="${MODE_CONFIG[prompts_dir]:-${SCRIPT_DIR}/lib/prompts/fix}"
	local template_path="${prompts_dir}/${template}"

	# Fall back to shared prompts
	if [[ ! -f "$template_path" ]]; then
		template_path="${SCRIPT_DIR}/lib/prompts/shared/${template}"
	fi

	# Check if template exists
	if [[ ! -f "$template_path" ]]; then
		log "ERROR" "Prompt template not found: $template"
		log "ERROR" "Searched: ${prompts_dir}/${template}"
		log "ERROR" "Searched: ${SCRIPT_DIR}/lib/prompts/shared/${template}"
		return 1
	fi

	local content
	content=$(cat "$template_path")

	# Substitute ${KEY} with value for each VAR=value argument
	for var in "$@"; do
		local key="${var%%=*}"
		local value="${var#*=}"
		# Escape special characters in value for sed
		local escaped_value
		escaped_value=$(printf '%s\n' "$value" | sed -e 's/[\/&]/\\&/g' -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g')
		content=$(echo "$content" | sed "s/\${${key}}/${escaped_value}/g")
	done

	echo "$content"
}

# =============================================================================
# DEFAULT IMPLEMENTATIONS
# =============================================================================

# Default filter implementation - can be overridden by modes
# Filters groups based on estimated_complexity field
_default_filter_groups() {
	local input_file="$1"
	local filter_type="${2:-${MODE_CONFIG[default_filter]:-all}}"

	if [[ "$filter_type" == "all" ]]; then
		cat "$input_file"
		return
	fi

	# Filter by complexity matching filter_type
	jq --arg filter "$filter_type" '{
		summary: {
			total_errors: ([.groups[] | select(.estimated_complexity == $filter) | (.errors // .findings // .improvements) | length] | add // 0),
			groups_count: ([.groups[] | select(.estimated_complexity == $filter)] | length),
			commands_run: .summary.commands_run,
			filtered_from: {
				original_total: (.summary.total_errors // .summary.total_findings // 0),
				original_groups: .summary.groups_count
			}
		},
		groups: [.groups[] | select(.estimated_complexity == $filter)]
	}' "$input_file"
}

# Default function if mode doesn't define filter_groups
filter_groups() {
	if type -t _mode_filter_groups &>/dev/null; then
		_mode_filter_groups "$@"
	else
		_default_filter_groups "$@"
	fi
}

# =============================================================================
# MODE VALIDATION
# =============================================================================

# Validate that a mode has all required configuration
validate_mode_config() {
	local required_keys=("name" "prompts_dir" "docs_file" "output_prefix" "commit_prefix" "branch_prefix" "default_filter")
	local missing=()

	for key in "${required_keys[@]}"; do
		if [[ -z "${MODE_CONFIG[$key]:-}" ]]; then
			missing+=("$key")
		fi
	done

	if [[ ${#missing[@]} -gt 0 ]]; then
		log "ERROR" "Mode configuration missing required keys: ${missing[*]}"
		return 1
	fi

	# Validate prompts directory exists
	local prompts_dir="${MODE_CONFIG[prompts_dir]}"
	if [[ ! -d "$prompts_dir" ]]; then
		log "WARN" "Mode prompts directory does not exist: $prompts_dir"
		log "WARN" "Will fall back to shared prompts"
	fi

	return 0
}

# =============================================================================
# MODE LOADING
# =============================================================================

# Load a mode by name
# Sets up MODE_CONFIG and mode-specific functions
load_mode() {
	local mode_name="$1"
	local mode_file="${SCRIPT_DIR}/lib/modes/${mode_name}.sh"

	if [[ ! -f "$mode_file" ]]; then
		log "ERROR" "Unknown mode: $mode_name"
		log "ERROR" "Available modes:"
		for f in "${SCRIPT_DIR}"/lib/modes/*.sh; do
			[[ "$(basename "$f")" == "base.sh" ]] && continue
			log "ERROR" "  - $(basename "$f" .sh)"
		done
		return 1
	fi

	# Source the mode file (sets MODE_CONFIG and defines functions)
	source "$mode_file"

	# Validate configuration
	if ! validate_mode_config; then
		return 1
	fi

	log "INFO" "Loaded mode: ${MODE_CONFIG[name]}"
	return 0
}
