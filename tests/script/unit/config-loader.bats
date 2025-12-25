#!/usr/bin/env bats
#
# Unit tests for configuration file loading
#

load ../helpers/test-helpers

setup() {
	setup_test_env
	source_script_libs
}

teardown() {
	teardown_test_env
}

@test "get_team_config_path returns correct path" {
	result=$(get_team_config_path)

	[[ "$result" =~ ".codebase-ops.json" ]]
}

@test "get_personal_config_path returns correct path" {
	result=$(get_personal_config_path)

	[[ "$result" =~ ".codebase-ops.local.json" ]]
}

@test "validate_json_file succeeds with valid JSON" {
	echo '{"mode": "fix"}' > .codebase-ops.json

	run validate_json_file ".codebase-ops.json" "team"

	[ "$status" -eq 0 ]
}

@test "validate_json_file fails with invalid JSON" {
	echo '{"mode": invalid}' > .codebase-ops.json

	run validate_json_file ".codebase-ops.json" "team"

	[ "$status" -eq 1 ]
}

@test "validate_json_file succeeds when file doesn't exist" {
	run validate_json_file "nonexistent.json" "team"

	[ "$status" -eq 0 ]
}

@test "load_config_value returns correct value" {
	echo '{"mode": "fix", "confidence": "safe"}' > .codebase-ops.json

	result=$(load_config_value ".codebase-ops.json" "mode")

	[ "$result" = "fix" ]
}

@test "load_config_value returns empty for missing key" {
	echo '{"mode": "fix"}' > .codebase-ops.json

	result=$(load_config_value ".codebase-ops.json" "nonexistent")

	[ -z "$result" ]
}

@test "load_config_value returns empty for missing file" {
	result=$(load_config_value "nonexistent.json" "mode")

	[ -z "$result" ]
}

@test "apply_config_from_file sets MODE variable" {
	echo '{"mode": "improve"}' > .codebase-ops.json

	MODE="fix"  # Initial value
	apply_config_from_file ".codebase-ops.json" "team"

	[ "$MODE" = "improve" ]
}

@test "apply_config_from_file sets CONFIDENCE_LEVEL variable" {
	echo '{"confidence": "medium"}' > .codebase-ops.json

	CONFIDENCE_LEVEL=""  # Initial value
	apply_config_from_file ".codebase-ops.json" "team"

	[ "$CONFIDENCE_LEVEL" = "medium" ]
}

@test "apply_config_from_file sets SAFE_ONLY when confidence is safe" {
	echo '{"confidence": "safe"}' > .codebase-ops.json

	SAFE_ONLY=false
	apply_config_from_file ".codebase-ops.json" "team"

	[ "$SAFE_ONLY" = "true" ]
}

@test "apply_config_from_file sets boolean flags correctly" {
	echo '{"execute": true, "auto": false}' > .codebase-ops.json

	EXECUTE_MODE=false
	AUTO_FIX=true
	apply_config_from_file ".codebase-ops.json" "team"

	[ "$EXECUTE_MODE" = "true" ]
	[ "$AUTO_FIX" = "false" ]
}

@test "apply_config_from_file handles missing file gracefully" {
	MODE="fix"

	run apply_config_from_file "nonexistent.json" "team"

	[ "$status" -eq 0 ]
	[ "$MODE" = "fix" ]  # Unchanged
}

@test "personal config overrides team config" {
	echo '{"mode": "fix", "confidence": "safe"}' > .codebase-ops.json
	echo '{"confidence": "medium"}' > .codebase-ops.local.json

	MODE=""
	CONFIDENCE_LEVEL=""

	# Load team config
	apply_config_from_file ".codebase-ops.json" "team"
	team_confidence="$CONFIDENCE_LEVEL"

	# Load personal config
	apply_config_from_file ".codebase-ops.local.json" "personal"
	personal_confidence="$CONFIDENCE_LEVEL"

	[ "$team_confidence" = "safe" ]
	[ "$personal_confidence" = "medium" ]
}
