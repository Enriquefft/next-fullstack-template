#!/usr/bin/env bash
#
# cache.sh - Caching system for codebase operations
#
# This file contains:
# - Git commit-based cache key generation
# - Diagnostic result caching
# - Output hash-based caching
# - Large output summarization
#
# Requires: logging.sh (for log function)
# Expects: PROJECT_DIR, CACHE_DIR, COMMAND_TIMEOUT

# =============================================================================
# CACHE KEY GENERATION
# =============================================================================

# Compute cache key from git commit hash
compute_cache_key() {
	local git_hash
	git_hash=$(git -C "${PROJECT_DIR:-.}" rev-parse HEAD 2>/dev/null || echo "no-git")
	echo "${git_hash}"
}

# Compute output hash from diagnostic command outputs
# Takes multiple file paths as arguments
compute_output_hash() {
	# Concatenate all files and compute hash
	cat "$@" 2>/dev/null | sha256sum | cut -d' ' -f1
}

# =============================================================================
# DIAGNOSTIC CACHE
# =============================================================================

# Check if cached diagnostic result exists and is valid
# Returns the cache file path on success, exits 1 on failure
check_diagnostic_cache() {
	local cache_key="$1"
	local cache_file="${CACHE_DIR}/diagnostic_${cache_key}.json"

	if [[ -f "$cache_file" ]]; then
		# Validate cached file
		if jq -e '.summary and .groups' "$cache_file" >/dev/null 2>&1; then
			echo "$cache_file"
			return 0
		else
			log "WARN" "Cached file corrupted, ignoring: $cache_file"
			rm -f "$cache_file"
		fi
	fi

	return 1
}

# Save diagnostic result to cache
save_diagnostic_cache() {
	local cache_key="$1"
	local groups_file="$2"

	mkdir -p "${CACHE_DIR}"
	local cache_file="${CACHE_DIR}/diagnostic_${cache_key}.json"

	cp "$groups_file" "$cache_file"
	log "INFO" "Cached diagnostic result: $cache_file"
}

# Load cached diagnostic result
load_diagnostic_cache() {
	local cache_file="$1"
	local target_file="$2"

	cp "$cache_file" "$target_file"
	log "INFO" "Loaded cached diagnostic result from: $(basename "$cache_file")"
}

# =============================================================================
# OUTPUT CACHE (for analysis results by output hash)
# =============================================================================

# Check if cached analysis exists for this output hash
check_output_cache() {
	local output_hash="$1"
	local cache_file="${CACHE_DIR}/analysis_${output_hash}.json"

	if [[ -f "$cache_file" ]]; then
		# Validate cached file
		if jq -e '.summary and .groups' "$cache_file" >/dev/null 2>&1; then
			echo "$cache_file"
			return 0
		else
			log "WARN" "Cached analysis corrupted, ignoring: $cache_file"
			rm -f "$cache_file"
		fi
	fi

	return 1
}

# Save analysis result to output cache
save_output_cache() {
	local output_hash="$1"
	local groups_file="$2"

	mkdir -p "${CACHE_DIR}"
	local cache_file="${CACHE_DIR}/analysis_${output_hash}.json"

	cp "$groups_file" "$cache_file"
	log "INFO" "Cached analysis result: $cache_file"
}

# =============================================================================
# OUTPUT SUMMARIZATION
# =============================================================================

# Conditionally summarize large output files (>50KB)
# Uses Claude Haiku for fast, cheap summarization
summarize_if_large() {
	local file="$1"
	local threshold="${2:-51200}"  # 50KB default

	if [[ ! -f "$file" ]]; then
		echo ""
		return
	fi

	local file_size
	file_size=$(wc -c < "$file")

	if [[ $file_size -le $threshold ]]; then
		# Small enough, return full content
		cat "$file"
		return
	fi

	# Large file, summarize with Claude Haiku (fast + cheap)
	log "INFO" "Output file $(basename "$file") is ${file_size} bytes (>${threshold}), summarizing..."

	local summary
	summary=$(claude --print --model haiku --dangerously-skip-permissions "Summarize this command output. Focus on errors, warnings, and failures. Omit successful test output.

Output:
\`\`\`
$(cat "$file")
\`\`\`

Provide concise summary (max 500 words):" 2>/dev/null || echo "Error: Failed to summarize output")

	echo "[SUMMARIZED - Original size: $file_size bytes]
$summary"
}
