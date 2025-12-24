#!/usr/bin/env bash
#
# config.sh - Configuration detection for codebase operations
#
# This file contains:
# - Package manager detection (bun/pnpm/yarn/npm)
# - Test command detection from package.json
# - Project structure detection (src/, App/Pages Router)
# - Install command configuration
#
# Exports:
# - detect_package_manager() -> sets PACKAGE_MANAGER
# - detect_test_commands() -> sets TEST_CMD, TYPE_CMD, BUILD_CMD, E2E_CMD, BIOME_CMD
# - detect_project_structure() -> sets HAS_SRC, SRC_PREFIX, ROUTER_TYPE, ROUTER_DIR, etc.
# - set_install_command() -> sets INSTALL_CMD
#
# Source this file after setting PROJECT_DIR

# =============================================================================
# CONFIGURATION DETECTION
# =============================================================================

# Auto-detect package manager from lockfiles
detect_package_manager() {
	if [[ -f "${PROJECT_DIR}/bun.lockb" ]]; then
		echo "bun"
	elif [[ -f "${PROJECT_DIR}/bun.lock" ]]; then
		echo "bun"
	elif [[ -f "${PROJECT_DIR}/pnpm-lock.yaml" ]]; then
		echo "pnpm"
	elif [[ -f "${PROJECT_DIR}/yarn.lock" ]]; then
		echo "yarn"
	elif [[ -f "${PROJECT_DIR}/package-lock.json" ]]; then
		echo "npm"
	else
		echo "npm"  # Default fallback
	fi
}

# Detect available test commands from package.json
detect_test_commands() {
	local pkg_json="${PROJECT_DIR}/package.json"

	if [[ ! -f "$pkg_json" ]]; then
		# Defaults if no package.json
		TEST_CMD="$PACKAGE_MANAGER test"
		TYPE_CMD="$PACKAGE_MANAGER run type"
		BUILD_CMD="$PACKAGE_MANAGER run build"
		E2E_CMD="$PACKAGE_MANAGER run test:e2e"
		BIOME_CMD=""
		return
	fi

	# Check for available scripts and set commands
	if jq -e '.scripts.test' "$pkg_json" &>/dev/null; then
		TEST_CMD="$PACKAGE_MANAGER test"
	else
		TEST_CMD=""
	fi

	# Type check script (try multiple common names)
	if jq -e '.scripts.type' "$pkg_json" &>/dev/null; then
		TYPE_CMD="$PACKAGE_MANAGER run type"
	elif jq -e '.scripts["type:check"]' "$pkg_json" &>/dev/null; then
		TYPE_CMD="$PACKAGE_MANAGER run type:check"
	elif jq -e '.scripts.typecheck' "$pkg_json" &>/dev/null; then
		TYPE_CMD="$PACKAGE_MANAGER run typecheck"
	else
		TYPE_CMD=""
	fi

	if jq -e '.scripts.build' "$pkg_json" &>/dev/null; then
		BUILD_CMD="$PACKAGE_MANAGER run build"
	else
		BUILD_CMD=""
	fi

	# E2E test script (try multiple common names)
	if jq -e '.scripts["test:e2e"]' "$pkg_json" &>/dev/null; then
		E2E_CMD="$PACKAGE_MANAGER run test:e2e"
	elif jq -e '.scripts.e2e' "$pkg_json" &>/dev/null; then
		E2E_CMD="$PACKAGE_MANAGER run e2e"
	else
		E2E_CMD=""
	fi

	# Biome check (prefer 'check' over 'format' for comprehensive linting)
	# Check for "lint" script first (common in projects using biome)
	if jq -e '.scripts.lint' "$pkg_json" &>/dev/null && grep -q "biome" "$pkg_json"; then
		BIOME_CMD="$PACKAGE_MANAGER lint"
	elif jq -e '.scripts["biome:check"]' "$pkg_json" &>/dev/null; then
		BIOME_CMD="$PACKAGE_MANAGER run biome:check"
	elif command -v biome &>/dev/null; then
		BIOME_CMD="biome check --write ."
	elif [[ -f "${PROJECT_DIR}/node_modules/.bin/biome" ]]; then
		BIOME_CMD="${PROJECT_DIR}/node_modules/.bin/biome check --write ."
	elif jq -e '.scripts.format' "$pkg_json" &>/dev/null && grep -q "biome" "$pkg_json"; then
		# Fallback to format script if check is not available
		BIOME_CMD="$PACKAGE_MANAGER run format"
	else
		BIOME_CMD=""
	fi
}

# Detect project structure (src/ vs root, App Router vs Pages Router)
detect_project_structure() {
	# Check for src/ directory
	if [[ -d "${PROJECT_DIR}/src" ]]; then
		HAS_SRC=true
		SRC_PREFIX="src/"
	else
		HAS_SRC=false
		SRC_PREFIX=""
	fi

	# Check for App Router (app/) or Pages Router (pages/)
	if [[ -d "${PROJECT_DIR}/${SRC_PREFIX}app" ]]; then
		ROUTER_TYPE="app"
		ROUTER_DIR="${SRC_PREFIX}app"
	elif [[ -d "${PROJECT_DIR}/${SRC_PREFIX}pages" ]]; then
		ROUTER_TYPE="pages"
		ROUTER_DIR="${SRC_PREFIX}pages"
	else
		ROUTER_TYPE="unknown"
		ROUTER_DIR=""
	fi

	# Set common directory paths for reference in prompts
	LIB_DIR="${SRC_PREFIX}lib"
	COMPONENTS_DIR="${SRC_PREFIX}components"
	HOOKS_DIR="${SRC_PREFIX}hooks"
	ACTIONS_DIR="${SRC_PREFIX}actions"
}

# Set package-manager-specific install command
set_install_command() {
	case "$PACKAGE_MANAGER" in
		npm)
			INSTALL_CMD="npm ci"
			;;
		pnpm)
			INSTALL_CMD="pnpm install --frozen-lockfile"
			;;
		yarn)
			INSTALL_CMD="yarn install --frozen-lockfile"
			;;
		bun)
			INSTALL_CMD="bun install --frozen-lockfile"
			;;
		*)
			INSTALL_CMD="npm ci"
			;;
	esac
}

# =============================================================================
# INCREMENTAL MODE (--since) SUPPORT
# =============================================================================

# Get list of changed files since a git ref
# Usage: get_changed_files <ref>
get_changed_files() {
	local since_ref="$1"

	if [[ -z "$since_ref" ]]; then
		return 1
	fi

	# Use three-dot diff to get files changed in current branch vs base
	git diff --name-only "${since_ref}...HEAD" 2>/dev/null || \
		git diff --name-only "${since_ref}" 2>/dev/null || \
		return 1
}

# Filter files by pattern
# Usage: filter_files_by_pattern "file1\nfile2" "*.ts"
filter_files_by_pattern() {
	local files="$1"
	local pattern="$2"

	echo "$files" | grep -E "$pattern" || true
}

# Get TypeScript/TSX files from list
# Usage: filter_ts_files "file1\nfile2"
filter_ts_files() {
	local files="$1"
	filter_files_by_pattern "$files" '\.(ts|tsx)$'
}

# Get test files from list
# Usage: filter_test_files "file1\nfile2"
filter_test_files() {
	local files="$1"
	filter_files_by_pattern "$files" '\.(test|spec)\.(ts|tsx|js|jsx)$'
}

# Get source files (excluding tests, config, build artifacts)
# Usage: filter_source_files "file1\nfile2"
filter_source_files() {
	local files="$1"
	echo "$files" | grep -vE '(\.test\.|\.spec\.|\.config\.|node_modules/|dist/|build/|\.next/)' || true
}

# Build filtered diagnostic commands based on changed files
# Exports: FILTERED_CHANGED_FILES (for prompt context)
# Returns: 0 if any files to check, 1 if no relevant files
build_filtered_commands() {
	local since_ref="$1"

	if [[ -z "$since_ref" ]]; then
		return 0  # No filtering needed
	fi

	log "INFO" "Detecting files changed since '$since_ref'..."

	local changed_files
	changed_files=$(get_changed_files "$since_ref")

	if [[ -z "$changed_files" ]]; then
		log "WARN" "No files changed since '$since_ref'"
		return 1
	fi

	local changed_count
	changed_count=$(echo "$changed_files" | wc -l)
	log "INFO" "Found $changed_count changed file(s)"

	# Export for prompt context
	FILTERED_CHANGED_FILES="$changed_files"

	# Filter by file type
	local ts_files test_files source_files
	ts_files=$(filter_ts_files "$changed_files")
	test_files=$(filter_test_files "$changed_files")
	source_files=$(filter_source_files "$changed_files")

	# Modify commands to target only changed files
	if [[ -n "$ts_files" ]] && [[ -n "$TYPE_CMD" ]]; then
		# TypeScript files changed - filter type check
		local ts_file_list
		ts_file_list=$(echo "$ts_files" | tr '\n' ' ')

		# Override TYPE_CMD with filtered version
		if [[ "$TYPE_CMD" =~ "bunx tsc" ]] || [[ "$TYPE_CMD" =~ "tsc" ]]; then
			TYPE_CMD="bunx tsc --noEmit $ts_file_list"
		fi

		log "DEBUG" "Filtered TYPE_CMD to ${#ts_files} TypeScript file(s)"
	elif [[ -z "$ts_files" ]]; then
		# No TypeScript files changed - skip type check
		TYPE_CMD=""
		log "DEBUG" "Skipping type check (no TypeScript files changed)"
	fi

	if [[ -n "$test_files" ]] && [[ -n "$TEST_CMD" ]]; then
		# Test files changed - filter test command
		local test_file_list
		test_file_list=$(echo "$test_files" | tr '\n' ' ')

		# Override TEST_CMD with filtered version
		TEST_CMD="$PACKAGE_MANAGER test $test_file_list"

		log "DEBUG" "Filtered TEST_CMD to ${#test_files} test file(s)"
	elif [[ -z "$test_files" ]]; then
		# No test files changed - skip tests
		TEST_CMD=""
		log "DEBUG" "Skipping tests (no test files changed)"
	fi

	# Biome and build commands stay as-is (they're fast and comprehensive)
	# E2E tests are typically slow, so skip unless E2E files changed
	if [[ -n "$E2E_CMD" ]]; then
		local e2e_files
		e2e_files=$(echo "$changed_files" | grep -E 'e2e/.*\.(spec|test)\.(ts|js)$' || true)

		if [[ -z "$e2e_files" ]]; then
			E2E_CMD=""
			log "DEBUG" "Skipping E2E tests (no E2E test files changed)"
		fi
	fi

	return 0
}
