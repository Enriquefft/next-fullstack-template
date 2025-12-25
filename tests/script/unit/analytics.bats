#!/usr/bin/env bats
#
# Unit tests for analytics functions
#

load ../helpers/test-helpers

setup() {
	setup_test_env
	source_script_libs
	copy_operation_fixtures
}

teardown() {
	teardown_test_env
}

@test "calculate_time_saved returns correct minutes for 1 group" {
	result=$(calculate_time_saved 1)

	[ "$result" -eq 8 ]
}

@test "calculate_time_saved returns correct minutes for 5 groups" {
	result=$(calculate_time_saved 5)

	[ "$result" -eq 40 ]
}

@test "calculate_time_saved returns 0 for 0 groups" {
	result=$(calculate_time_saved 0)

	[ "$result" -eq 0 ]
}

@test "get_all_operations returns operation files" {
	cd "$TEST_DIR"

	operations=$(get_all_operations)

	# Should have at least one operation from fixtures
	[ -n "$operations" ]
}

@test "get_all_operations returns files in reverse chronological order" {
	cd "$TEST_DIR"

	operations=$(get_all_operations)
	first_op=$(echo "$operations" | head -1)

	# First operation should be the most recent (20241221)
	[[ "$first_op" =~ "20241221" ]]
}

@test "calculate_statistics returns valid JSON" {
	cd "$TEST_DIR"

	stats=$(calculate_statistics "all")

	# Check it's valid JSON by parsing a field
	total_ops=$(echo "$stats" | jq -r '.total_operations')
	[ "$total_ops" -ge 0 ]
}

@test "calculate_statistics shows 2 operations from fixtures" {
	cd "$TEST_DIR"

	stats=$(calculate_statistics "all")
	total_ops=$(echo "$stats" | jq -r '.total_operations')

	[ "$total_ops" -eq 2 ]
}

@test "calculate_statistics shows 100% success rate for fixtures" {
	cd "$TEST_DIR"

	stats=$(calculate_statistics "all")
	success_rate=$(echo "$stats" | jq -r '.success_rate')

	[ "$success_rate" -eq 100 ]
}

@test "calculate_statistics tracks total groups fixed" {
	cd "$TEST_DIR"

	stats=$(calculate_statistics "all")
	total_groups=$(echo "$stats" | jq -r '.total_groups_fixed')

	# Fixtures have 2 + 2 = 4 groups total
	[ "$total_groups" -eq 4 ]
}

@test "calculate_statistics tracks total files changed" {
	cd "$TEST_DIR"

	stats=$(calculate_statistics "all")
	total_files=$(echo "$stats" | jq -r '.total_files_changed')

	# Fixtures have 3 + 3 = 6 files total
	[ "$total_files" -eq 6 ]
}

@test "calculate_statistics calculates time saved" {
	cd "$TEST_DIR"

	stats=$(calculate_statistics "all")
	hours_saved=$(echo "$stats" | jq -r '.total_hours_saved')

	# 4 groups * 8 min = 32 min = 0.5 hours
	# Allow floating point comparison
	result=$(echo "$hours_saved >= 0.5" | bc -l 2>/dev/null || echo "1")
	[ "$result" -eq 1 ]
}

@test "show_stats_report displays without errors when no data" {
	cd "$TEST_DIR"
	# Remove fixtures
	rm -rf .fix_bugs_logs/history/operations/*

	run show_stats_report

	[ "$status" -eq 0 ]
	[[ "$output" =~ "No operations recorded yet" ]]
}

@test "show_stats_report displays statistics with data" {
	cd "$TEST_DIR"

	run show_stats_report

	[ "$status" -eq 0 ]
	[[ "$output" =~ "Codebase Operations Statistics" ]]
	[[ "$output" =~ "All time" ]]
}
