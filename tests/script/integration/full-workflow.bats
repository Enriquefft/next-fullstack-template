#!/usr/bin/env bats
#
# Integration tests for full codebase_ops.sh workflow
# Uses mocked Claude CLI (ZERO TOKENS CONSUMED)
#

load ../helpers/test-helpers

setup() {
	setup_test_env

	# Create some test source files
	create_test_file "src/auth.ts" "export const user = undefined;"
	create_test_file "src/types.ts" "export type User = { name: string };"

	git commit -q -m "Add test files"
}

teardown() {
	teardown_test_env
}

@test "help command displays usage" {
	run bash ../../scripts/codebase_ops.sh --help

	[ "$status" -eq 0 ]
	[[ "$output" =~ "AI-powered codebase analysis" ]]
	[[ "$output" =~ "COMMON WORKFLOWS" ]]
}

@test "stats command works with no operations" {
	run bash ../../scripts/codebase_ops.sh stats

	[ "$status" -eq 0 ]
	[[ "$output" =~ "No operations recorded yet" ]]
}

@test "stats command works with fixture data" {
	copy_operation_fixtures

	run bash ../../scripts/codebase_ops.sh stats

	[ "$status" -eq 0 ]
	[[ "$output" =~ "Codebase Operations Statistics" ]]
	[[ "$output" =~ "All time" ]]
}

@test "history command works with no operations" {
	run bash ../../scripts/codebase_ops.sh history

	[ "$status" -eq 0 ]
	[[ "$output" =~ "No operations found" ]] || [[ "$output" =~ "Recent operations" ]]
}

@test "export json creates stats file" {
	copy_operation_fixtures

	run bash ../../scripts/codebase_ops.sh export json test-stats.json

	[ "$status" -eq 0 ]
	[ -f "test-stats.json" ]

	# Verify it's valid JSON
	run jq -e '.total_operations' test-stats.json
	[ "$status" -eq 0 ]
}

@test "export csv creates history file" {
	copy_operation_fixtures

	run bash ../../scripts/codebase_ops.sh export csv test-history.csv

	[ "$status" -eq 0 ]
	[ -f "test-history.csv" ]

	# Verify CSV header
	header=$(head -1 test-history.csv)
	[[ "$header" =~ "timestamp" ]]
	[[ "$header" =~ "mode" ]]
}

@test "export all creates both files" {
	copy_operation_fixtures

	run bash ../../scripts/codebase_ops.sh export all test-export

	[ "$status" -eq 0 ]
	[ -f "test-export-stats.json" ]
	[ -f "test-export-history.csv" ]
}

@test "mock claude is used instead of real claude" {
	reset_claude_calls

	# Run help which triggers claude auth check
	run bash ../../scripts/codebase_ops.sh --help

	# Verify mock was called
	assert_claude_called
}

@test "context detection works in CI environment" {
	simulate_ci_env

	# The script should detect CI context
	# We can't easily test the full run, but we can verify detection
	source_script_libs
	result=$(detect_context)

	[ "$result" = "ci" ]
}

@test "context detection works on PR branch" {
	create_feature_branch "feature/test-branch"

	source_script_libs
	result=$(detect_context)

	[ "$result" = "pr" ]
}
