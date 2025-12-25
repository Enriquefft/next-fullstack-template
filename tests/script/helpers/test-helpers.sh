#!/usr/bin/env bash
#
# Test helpers for codebase_ops.sh tests
#

# Setup test environment with mock Claude
setup_test_env() {
	# Add mock claude to PATH (highest priority)
	export PATH="$(pwd)/tests/script/mocks:$PATH"

	# Create temporary test directory
	export TEST_DIR="${BATS_TEST_TMPDIR:-/tmp/bats-test-$$}"
	mkdir -p "$TEST_DIR"

	# Set log directory to test location
	export MOCK_LOG_DIR="$TEST_DIR"

	# Create mock project structure
	cd "$TEST_DIR"
	git init -q
	git config user.email "test@example.com"
	git config user.name "Test User"

	# Create initial commit
	echo "# Test Project" > README.md
	git add README.md
	git commit -q -m "Initial commit"

	# Set PROJECT_DIR for scripts
	export PROJECT_DIR="$TEST_DIR"
}

# Cleanup test environment
teardown_test_env() {
	if [[ -n "$TEST_DIR" ]] && [[ -d "$TEST_DIR" ]]; then
		cd /
		rm -rf "$TEST_DIR"
	fi
}

# Source script libraries without running main
source_script_libs() {
	local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../scripts" && pwd)"

	# Source libraries
	source "${script_dir}/lib/core/utils.sh"
	source "${script_dir}/lib/core/logging.sh"
	source "${script_dir}/lib/core/config.sh"
	source "${script_dir}/lib/core/config-loader.sh"
	source "${script_dir}/lib/core/analytics.sh"
}

# Create a test file with content
create_test_file() {
	local file_path="$1"
	local content="${2:-// Test file}"

	mkdir -p "$(dirname "$file_path")"
	echo "$content" > "$file_path"
	git add "$file_path"
}

# Create a feature branch for PR testing
create_feature_branch() {
	local branch_name="${1:-feature/test}"

	git checkout -b "$branch_name" -q
}

# Simulate CI environment
simulate_ci_env() {
	export CI=true
	export GITHUB_ACTIONS=true
}

# Clear CI environment
clear_ci_env() {
	unset CI
	unset GITHUB_ACTIONS
	unset GITLAB_CI
	unset CIRCLECI
}

# Copy fixture operations for analytics testing
copy_operation_fixtures() {
	local fixtures_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../fixtures/operations" && pwd)"
	local dest_dir="${PROJECT_DIR}/.fix_bugs_logs/history/operations"

	mkdir -p "$dest_dir"
	cp -r "$fixtures_dir"/* "$dest_dir/" 2>/dev/null || true
}

# Assert mock Claude was called
assert_claude_called() {
	local log_file="${MOCK_LOG_DIR}/mock-claude-calls.log"

	if [[ ! -f "$log_file" ]]; then
		echo "ERROR: Mock Claude was not called (log file missing)"
		return 1
	fi

	if [[ ! -s "$log_file" ]]; then
		echo "ERROR: Mock Claude was not called (log file empty)"
		return 1
	fi

	return 0
}

# Get number of mock Claude calls
get_claude_call_count() {
	local log_file="${MOCK_LOG_DIR}/mock-claude-calls.log"

	if [[ ! -f "$log_file" ]]; then
		echo "0"
		return
	fi

	wc -l < "$log_file"
}

# Reset mock Claude call log
reset_claude_calls() {
	local log_file="${MOCK_LOG_DIR}/mock-claude-calls.log"
	rm -f "$log_file"
}
