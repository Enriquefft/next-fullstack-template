#!/usr/bin/env bats
#
# Unit tests for context detection (smart defaults)
#

load ../helpers/test-helpers

setup() {
	source_script_libs
	clear_ci_env
}

teardown() {
	clear_ci_env
}

@test "detect_context returns 'ci' when CI=true" {
	export CI=true

	result=$(detect_context)

	[ "$result" = "ci" ]
}

@test "detect_context returns 'ci' when GITHUB_ACTIONS=true" {
	export GITHUB_ACTIONS=true

	result=$(detect_context)

	[ "$result" = "ci" ]
}

@test "detect_context returns 'ci' when GITLAB_CI=true" {
	export GITLAB_CI=true

	result=$(detect_context)

	[ "$result" = "ci" ]
}

@test "detect_context returns 'git-hook' when GIT_INDEX_FILE is set" {
	export GIT_INDEX_FILE="/tmp/git-index"

	result=$(detect_context)

	[ "$result" = "git-hook" ]
}

@test "detect_context returns 'local' on main branch" {
	setup_test_env
	git checkout main -q 2>/dev/null || git checkout -b main -q

	cd "$TEST_DIR"
	result=$(detect_context)

	[ "$result" = "local" ]

	teardown_test_env
}

@test "detect_context returns 'pr' on feature branch" {
	setup_test_env
	git checkout -b feature/test -q

	cd "$TEST_DIR"
	result=$(detect_context)

	[ "$result" = "pr" ]

	teardown_test_env
}

@test "detect_context returns 'local' on master branch" {
	setup_test_env
	git checkout -b master -q

	cd "$TEST_DIR"
	result=$(detect_context)

	[ "$result" = "local" ]

	teardown_test_env
}

@test "detect_context returns 'local' on develop branch" {
	setup_test_env
	git checkout -b develop -q

	cd "$TEST_DIR"
	result=$(detect_context)

	[ "$result" = "local" ]

	teardown_test_env
}

@test "CI detection takes precedence over branch detection" {
	setup_test_env
	git checkout -b feature/test -q
	export GITHUB_ACTIONS=true

	cd "$TEST_DIR"
	result=$(detect_context)

	[ "$result" = "ci" ]

	teardown_test_env
}
