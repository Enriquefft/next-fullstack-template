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
