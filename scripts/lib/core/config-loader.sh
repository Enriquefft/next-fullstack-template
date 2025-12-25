#!/usr/bin/env bash
#
# config-loader.sh - Configuration file loader for codebase operations
#
# This file contains:
# - JSON configuration file loading
# - Configuration hierarchy (defaults → team → personal → CLI flags)
# - Validation and error handling
#
# Requires: jq, logging.sh
# Expects: PROJECT_DIR
#
# Configuration Hierarchy:
# 1. Script defaults (set in main script)
# 2. Team config (.codebase-ops.json) - committed to repo
# 3. Personal config (.codebase-ops.local.json) - gitignored
# 4. CLI flags (parsed after config load) - highest priority

# =============================================================================
# CONFIGURATION FILE PATHS
# =============================================================================

# Get team config file path
get_team_config_path() {
	echo "${PROJECT_DIR}/.codebase-ops.json"
}

# Get personal config file path
get_personal_config_path() {
	echo "${PROJECT_DIR}/.codebase-ops.local.json"
}

# =============================================================================
# JSON VALIDATION
# =============================================================================

# Validate JSON file syntax
# Returns 0 if valid, 1 if invalid
validate_json_file() {
	local file="$1"
	local file_type="$2"  # "team" or "personal"

	if [[ ! -f "$file" ]]; then
		return 0  # File doesn't exist, skip validation
	fi

	if ! jq empty "$file" >/dev/null 2>&1; then
		log "ERROR" "Invalid JSON in $file_type config: $file"
		log "ERROR" "Please fix JSON syntax or remove the file"
		return 1
	fi

	return 0
}

# =============================================================================
# CONFIGURATION LOADING
# =============================================================================

# Load configuration value from JSON file
# Usage: load_config_value <file> <key>
# Returns the value or empty string if not found
load_config_value() {
	local file="$1"
	local key="$2"

	if [[ ! -f "$file" ]]; then
		return 0
	fi

	local value
	value=$(jq -r ".${key} // empty" "$file" 2>/dev/null)

	# Return value (could be empty string)
	echo "$value"
}

# Apply configuration from JSON file to script variables
# Usage: apply_config_from_file <file> <config_type>
apply_config_from_file() {
	local file="$1"
	local config_type="$2"  # "team" or "personal"

	if [[ ! -f "$file" ]]; then
		log "DEBUG" "No $config_type config found: $file"
		return 0
	fi

	log "DEBUG" "Loading $config_type config from: $file"

	# Validate JSON first
	if ! validate_json_file "$file" "$config_type"; then
		return 1
	fi

	# Load mode
	local mode
	mode=$(load_config_value "$file" "mode")
	if [[ -n "$mode" ]]; then
		MODE="$mode"
		log "DEBUG" "  [$config_type] mode = $mode"
	fi

	# Load confidence level
	local confidence
	confidence=$(load_config_value "$file" "confidence")
	if [[ -n "$confidence" ]]; then
		CONFIDENCE_LEVEL="$confidence"
		if [[ "$confidence" == "safe" ]]; then
			SAFE_ONLY=true
		fi
		log "DEBUG" "  [$config_type] confidence = $confidence"
	fi

	# Load since ref
	local since
	since=$(load_config_value "$file" "since")
	if [[ -n "$since" ]]; then
		SINCE_REF="$since"
		log "DEBUG" "  [$config_type] since = $since"
	fi

	# Load execute mode
	local execute
	execute=$(load_config_value "$file" "execute")
	if [[ "$execute" == "true" ]]; then
		EXECUTE_MODE=true
		log "DEBUG" "  [$config_type] execute = true"
	elif [[ "$execute" == "false" ]]; then
		EXECUTE_MODE=false
		log "DEBUG" "  [$config_type] execute = false"
	fi

	# Load auto mode
	local auto
	auto=$(load_config_value "$file" "auto")
	if [[ "$auto" == "true" ]]; then
		AUTO_FIX=true
		AUTO_MERGE=true
		INTERACTIVE=false
		log "DEBUG" "  [$config_type] auto = true"
	elif [[ "$auto" == "false" ]]; then
		AUTO_FIX=false
		AUTO_MERGE=false
		log "DEBUG" "  [$config_type] auto = false"
	fi

	# Load simple_only
	local simple_only
	simple_only=$(load_config_value "$file" "simple_only")
	if [[ "$simple_only" == "true" ]]; then
		SIMPLE_ONLY=true
		log "DEBUG" "  [$config_type] simple_only = true"
	elif [[ "$simple_only" == "false" ]]; then
		SIMPLE_ONLY=false
		log "DEBUG" "  [$config_type] simple_only = false"
	fi

	# Load notifications
	local notifications
	notifications=$(load_config_value "$file" "notifications")
	if [[ "$notifications" == "true" ]]; then
		ENABLE_NOTIFICATIONS=true
		log "DEBUG" "  [$config_type] notifications = true"
	elif [[ "$notifications" == "false" ]]; then
		ENABLE_NOTIFICATIONS=false
		log "DEBUG" "  [$config_type] notifications = false"
	fi

	# Load verbosity
	local verbosity
	verbosity=$(load_config_value "$file" "verbosity")
	if [[ -n "$verbosity" ]]; then
		VERBOSITY="$verbosity"
		log "DEBUG" "  [$config_type] verbosity = $verbosity"
	fi

	# Load allow_dirty
	local allow_dirty
	allow_dirty=$(load_config_value "$file" "allow_dirty")
	if [[ "$allow_dirty" == "true" ]]; then
		ALLOW_DIRTY=true
		log "DEBUG" "  [$config_type] allow_dirty = true"
	elif [[ "$allow_dirty" == "false" ]]; then
		ALLOW_DIRTY=false
		log "DEBUG" "  [$config_type] allow_dirty = false"
	fi

	# Load show_diff
	local show_diff
	show_diff=$(load_config_value "$file" "show_diff")
	if [[ "$show_diff" == "true" ]]; then
		SHOW_DIFF=true
		log "DEBUG" "  [$config_type] show_diff = true"
	elif [[ "$show_diff" == "false" ]]; then
		SHOW_DIFF=false
		log "DEBUG" "  [$config_type] show_diff = false"
	fi

	return 0
}

# Load all configuration files in order
# Applies: team config → personal config
# Note: Smart defaults are applied before this, CLI flags after
load_configuration_files() {
	log "DEBUG" "Loading configuration files..."

	local team_config
	local personal_config

	team_config=$(get_team_config_path)
	personal_config=$(get_personal_config_path)

	# Apply team config first
	if ! apply_config_from_file "$team_config" "team"; then
		log "ERROR" "Failed to load team configuration"
		return 1
	fi

	# Apply personal config (overrides team)
	if ! apply_config_from_file "$personal_config" "personal"; then
		log "ERROR" "Failed to load personal configuration"
		return 1
	fi

	# Log summary
	if [[ -f "$team_config" ]] || [[ -f "$personal_config" ]]; then
		log "DEBUG" "Configuration loaded successfully"
	else
		log "DEBUG" "No configuration files found (using defaults)"
	fi

	return 0
}

# =============================================================================
# CONFIGURATION PROFILES (Future Enhancement)
# =============================================================================

# Load a named profile from team config
# Usage: load_profile <profile_name>
# Profiles allow teams to define common configurations like "safe", "review", "full"
load_profile() {
	local profile_name="$1"
	local team_config
	team_config=$(get_team_config_path)

	if [[ ! -f "$team_config" ]]; then
		log "ERROR" "No team config found, cannot load profile: $profile_name"
		return 1
	fi

	# Check if profile exists
	local profile_exists
	profile_exists=$(jq -r ".profiles.${profile_name} // empty" "$team_config" 2>/dev/null)

	if [[ -z "$profile_exists" ]]; then
		log "ERROR" "Profile not found in team config: $profile_name"
		log "INFO" "Available profiles:"
		jq -r '.profiles | keys[]' "$team_config" 2>/dev/null | while read -r name; do
			log "INFO" "  - $name"
		done
		return 1
	fi

	log "INFO" "Loading profile: $profile_name"

	# Extract profile config to temporary file
	local temp_profile="/tmp/codebase-ops-profile-$$.json"
	jq ".profiles.${profile_name}" "$team_config" > "$temp_profile"

	# Apply profile config
	apply_config_from_file "$temp_profile" "profile:$profile_name"

	# Cleanup
	rm -f "$temp_profile"

	return 0
}
