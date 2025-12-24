#!/bin/bash
#
# Environment Setup Shared Library
#
# Reusable functions for setting up environment variables in Vercel and GitHub.
# Used by setup-vercel-env.sh, setup-github-secrets.sh, and setup-env.sh.
#

# ============================================================================
# VALUE CACHING (for unified script to share values between platforms)
# ============================================================================

# Global associative array for caching values (Bash 4+)
declare -A VALUE_CACHE

# Store a value in cache
# Arguments: key, value
cache_value() {
	local key=$1
	local value=$2
	VALUE_CACHE["$key"]="$value"
}

# Get a value from cache (returns empty string if not found)
# Arguments: key
# Returns: cached value or empty string
get_cached_value() {
	local key=$1
	echo "${VALUE_CACHE[$key]:-}"
}

# Check if value is cached
# Arguments: key
# Returns: 0 if cached, 1 if not
is_value_cached() {
	local key=$1
	[[ -n "${VALUE_CACHE[$key]:-}" ]]
}

# ============================================================================
# EXISTENCE CHECKING
# ============================================================================

# Check if Vercel environment variable exists for a specific environment
# Arguments: var_name, env (production/preview/development)
# Returns: 0 if exists, 1 if not exists
check_vercel_var_exists() {
	local var_name=$1
	local env=$2

	# Use vercel env ls and grep for exact match
	vercel env ls --environment="$env" 2>/dev/null | grep -q "^$var_name "
}

# Check if GitHub secret exists
# Arguments: secret_name
# Returns: 0 if exists, 1 if not exists
check_github_secret_exists() {
	local secret_name=$1

	# Use gh secret list and grep for exact match
	gh secret list 2>/dev/null | grep -q "^$secret_name\s"
}

# ============================================================================
# INTERACTIVE PROMPTING
# ============================================================================

# Prompt for a secret value with existence check and confirmation
# Arguments: var_name, description, check_exists_func, [env_arg], [cache_key], [default_value]
# Returns: 0 and outputs value if provided, 1 if skipped
prompt_for_value() {
	local var_name=$1
	local description=$2
	local check_exists_func=$3
	local env_arg=${4:-}  # Optional: environment for Vercel checks
	local cache_key=${5:-}  # Optional: cache key for value sharing
	local default_value=${6:-}  # Optional: default value to use if empty

	# Check if value is already cached (for unified script)
	if [ -n "$cache_key" ] && is_value_cached "$cache_key"; then
		local cached_value
		cached_value=$(get_cached_value "$cache_key")
		echo "$cached_value"
		return 0
	fi

	# Check if variable already exists
	local exists=false
	if [ -n "$check_exists_func" ] && [ "$check_exists_func" != "none" ]; then
		if [ -n "$env_arg" ]; then
			# Call with environment argument (for Vercel)
			if $check_exists_func "$var_name" "$env_arg" 2>/dev/null; then
				exists=true
			fi
		else
			# Call without environment argument (for GitHub)
			if $check_exists_func "$var_name" 2>/dev/null; then
				exists=true
			fi
		fi
	fi

	# Display prompt with existence status
	echo "" >&2
	echo "────────────────────────────────────────" >&2
	echo "🔑 $description" >&2
	echo "Variable: $var_name" >&2

	if [ "$exists" = true ]; then
		local status_msg="📌 Status: Already exists"

		# Try to get last 8 chars for Vercel env vars only
		if [ "$check_func" = "check_vercel_var_exists" ] && [ -n "$env_arg" ]; then
			local temp_env=$(mktemp)
			if vercel env pull "$temp_env" --environment="$env_arg" 2>/dev/null; then
				local existing_value=$(grep "^$var_name=" "$temp_env" 2>/dev/null | cut -d'=' -f2-)
				if [ -n "$existing_value" ] && [ "${#existing_value}" -gt 8 ]; then
					local masked="...${existing_value: -8}"
					status_msg="$status_msg (current: $masked)"
				fi
				rm -f "$temp_env"
			fi
		fi

		echo "$status_msg (will be updated if you provide a value)" >&2
	else
		echo "⚠️  Status: Does not exist (will be created)" >&2
	fi

	# Show default value if available
	if [ -n "$default_value" ]; then
		echo "💡 Default: $default_value" >&2
	fi

	# Read value (hidden)
	local value
	if [ -n "$default_value" ]; then
		read -rsp "Paste value (or press Enter for default): " value
	else
		read -rsp "Paste value (or press Enter to skip): " value
	fi
	echo "" >&2

	# Handle empty input
	if [ -z "$value" ]; then
		# Use default value if available
		if [ -n "$default_value" ]; then
			echo "✓ Using default value: $default_value" >&2
			value="$default_value"
		elif [ "$exists" = true ]; then
			echo "✓ Skipping - keeping existing value" >&2
			return 1  # Signal to skip
		else
			# Confirm blank input for non-existing variables
			echo "⚠️  WARNING: This variable does not exist yet." >&2
			local confirm
			read -rp "Are you sure you want to skip? (y/n): " -n 1 confirm
			echo "" >&2

			if [[ $confirm =~ ^[Yy]$ ]]; then
				echo "⏭️  Skipped" >&2
				return 1  # Signal to skip
			else
				# Re-prompt
				echo "Please enter a value:" >&2
				read -rsp "Paste value: " value
				echo "" >&2

				if [ -z "$value" ]; then
					echo "❌ Still empty - skipping" >&2
					return 1
				fi
			fi
		fi
	fi

	# Validate value is not just whitespace
	if [[ "$value" =~ ^[[:space:]]*$ ]]; then
		echo "❌ Error: Value cannot be empty or whitespace only" >&2
		return 1
	fi

	# Warn if value contains shell variable syntax
	if [[ "$value" =~ \$\{?[A-Za-z_] ]]; then
		echo "⚠️  Warning: Value contains '\$' - make sure this is intentional" >&2
		read -rp "Continue? (y/n): " -n 1 confirm
		echo "" >&2
		if [[ ! $confirm =~ ^[Yy]$ ]]; then
			echo "⏭️  Skipped" >&2
			return 1
		fi
	fi

	# Cache the value if cache_key provided
	if [ -n "$cache_key" ]; then
		cache_value "$cache_key" "$value"
	fi

	echo "$value"
	return 0
}

# ============================================================================
# VARIABLE SETTING
# ============================================================================

# Set Vercel environment variable for specific environment
# Arguments: var_name, env (production/preview/development), value
# Returns: 0 on success, 1 on failure
set_vercel_var() {
	local var_name=$1
	local env=$2
	local value=$3

	if [ -z "$value" ]; then
		return 1
	fi

	if echo "$value" | vercel env add "$var_name" "$env" --force > /dev/null 2>&1; then
		echo "✅ $var_name configured for $env" >&2
		return 0
	else
		echo "❌ Failed to set $var_name for $env (check permissions)" >&2
		return 1
	fi
}

# Set Vercel environment variable for all environments
# Arguments: var_name, value
# Returns: 0 on success, 1 if any environment failed
set_vercel_var_all_envs() {
	local var_name=$1
	local value=$2

	if [ -z "$value" ]; then
		return 1
	fi

	local success=true
	for env in production preview development; do
		if ! set_vercel_var "$var_name" "$env" "$value" > /dev/null 2>&1; then
			success=false
		fi
	done

	if [ "$success" = true ]; then
		echo "✅ $var_name configured for all environments" >&2
		return 0
	else
		echo "⚠️  Some environments may have failed for $var_name" >&2
		return 1
	fi
}

# Set GitHub secret
# Arguments: secret_name, value
# Returns: 0 on success, 1 on failure
set_github_secret() {
	local secret_name=$1
	local value=$2

	if [ -z "$value" ]; then
		return 1
	fi

	# Use gh secret set with stdin
	if echo "$value" | gh secret set "$secret_name" > /dev/null 2>&1; then
		echo "✅ $secret_name configured" >&2
		return 0
	else
		echo "❌ Failed to set $secret_name (check permissions)" >&2
		return 1
	fi
}

# ============================================================================
# CLI VALIDATION
# ============================================================================

# Check if Vercel CLI is installed and user is authenticated
# Returns: 0 if OK, 1 if not
check_vercel_cli() {
	if ! command -v vercel &> /dev/null; then
		echo "❌ Vercel CLI not found. Please install it first:"
		echo "   npm i -g vercel"
		echo "   or: bun add -g vercel"
		return 1
	fi

	if ! vercel whoami &> /dev/null; then
		echo "❌ Not authenticated with Vercel. Run: vercel login"
		return 1
	fi

	return 0
}

# Check if Vercel project is linked
# Returns: 0 if OK, 1 if not linked
check_vercel_project() {
	local needs_linking=false
	local reason=""

	# Check if project.json exists
	if [ ! -f ".vercel/project.json" ]; then
		needs_linking=true
		reason="not linked to any Vercel project"
	else
		# Verify the linked project is still accessible
		if ! vercel env ls &> /dev/null; then
			needs_linking=true
			reason="linked to an inaccessible project (may have been deleted or transferred)"
			# Remove stale linking
			rm -rf .vercel
		fi
	fi

	if [ "$needs_linking" = true ]; then
		echo "⚠️  Project is $reason."
		echo "Run 'vercel link' to connect this directory to a Vercel project."
		echo ""
		local reply
		read -rp "Would you like to run 'vercel link' now? (y/n) " -n 1 reply
		echo ""

		if [[ $reply =~ ^[Yy]$ ]]; then
			vercel link
			if [ $? -ne 0 ]; then
				echo "❌ Failed to link project. Exiting."
				return 1
			fi
		else
			echo "❌ Project must be linked before setting environment variables."
			return 1
		fi
	fi

	return 0
}

# Check if GitHub CLI is installed and user is authenticated
# Returns: 0 if OK, 1 if not
check_github_cli() {
	if ! command -v gh &> /dev/null; then
		echo "❌ gh CLI not found. Please install it first:"
		echo "   macOS: brew install gh"
		echo "   Linux: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
		return 1
	fi

	if ! gh auth status &> /dev/null; then
		echo "❌ Not authenticated with GitHub. Run: gh auth login"
		return 1
	fi

	return 0
}

# ============================================================================
# VARIABLE DEFINITIONS
# ============================================================================

# Define all environment variables with metadata
# Format: "VERCEL_NAME|DESCRIPTION|VERCEL_SCOPE|GITHUB_NAME|CACHE_KEY|DEFAULT_VALUE"
# VERCEL_SCOPE: all, production, preview, development, or none
# Use "none" for VERCEL_NAME or GITHUB_NAME to skip that platform
# DEFAULT_VALUE: optional default value (empty string if none)
declare -a ENV_VARIABLES=(
	# Database - Environment-specific
	"DATABASE_URL|Production Database URL (Neon prod branch) [Get free DB: https://neon.tech]|production|none|db_url_prod|"
	"DATABASE_URL|Preview Database URL (Neon staging branch) [Get free DB: https://neon.tech]|preview|none|db_url_preview|"
	"DATABASE_URL|Development Database URL (for vercel dev) [Get free DB: https://neon.tech]|development|none|db_url_dev|"
	"none|Test Database URL (for GitHub Actions) [Get free DB: https://neon.tech]|none|DATABASE_URL_TEST|db_url_test|"
	"none|Staging Database URL (for GitHub Actions) [Get free DB: https://neon.tech]|none|DATABASE_URL_STAGING|db_url_staging|"
	"none|Production Database URL (for GitHub Actions) [Get free DB: https://neon.tech]|none|DATABASE_URL_PROD|db_url_prod|"

	# Auth - Environment-specific secrets
	"BETTER_AUTH_SECRET|Better Auth Secret for PRODUCTION [Generate with: bun run auth:secret]|production|none|auth_secret_prod|"
	"BETTER_AUTH_SECRET|Better Auth Secret for PREVIEW [Generate with: bun run auth:secret]|preview|none|auth_secret_preview|"
	"BETTER_AUTH_SECRET|Better Auth Secret for DEVELOPMENT [Generate with: bun run auth:secret]|development|none|auth_secret_dev|"
	"none|Better Auth Secret for TEST [Generate with: bun run auth:secret]|none|BETTER_AUTH_SECRET_TEST|auth_secret_test|"
	"none|Better Auth Secret for STAGING [Generate with: bun run auth:secret]|none|BETTER_AUTH_SECRET_STAGING|auth_secret_staging|"
	"none|Better Auth Secret for PROD [Generate with: bun run auth:secret]|none|BETTER_AUTH_SECRET_PROD|auth_secret_prod|"

	# OAuth - Shared across all environments
	"GOOGLE_CLIENT_ID|Google OAuth Client ID [Setup at: https://console.cloud.google.com]|all|GOOGLE_CLIENT_ID|google_client_id|"
	"GOOGLE_CLIENT_SECRET|Google OAuth Client Secret [Setup at: https://console.cloud.google.com]|all|GOOGLE_CLIENT_SECRET|google_client_secret|"

	# Third-party services - Shared
	"NEXT_PUBLIC_POSTHOG_KEY|PostHog API Key (public) [Get at: https://posthog.com]|all|NEXT_PUBLIC_POSTHOG_KEY|posthog_key|"
	"POSTHOG_PROJECT_ID|PostHog Project ID [Get at: https://posthog.com]|all|POSTHOG_PROJECT_ID|posthog_project|"
	"POLAR_ACCESS_TOKEN|Polar Access Token [Get at: https://polar.sh/settings]|all|POLAR_ACCESS_TOKEN|polar_token|"
	"POLAR_MODE|Polar Mode (production or sandbox) [Recommended: sandbox]|all|none|polar_mode|sandbox"
	"UPLOADTHING_TOKEN|UploadThing Token [Get at: https://uploadthing.com/dashboard]|all|UPLOADTHING_TOKEN|uploadthing_token|"

	# Project configuration
	"NEXT_PUBLIC_PROJECT_NAME|Project Name (used for DB schema) [Default: auto-detected from package.json]|all|NEXT_PUBLIC_PROJECT_NAME|project_name|AUTO"
)

# Process a single variable definition
# Arguments: var_def, platform (vercel/github/both), use_cache (0/1)
# Returns: 0 on success, 1 if skipped
process_variable() {
	local var_def=$1
	local platform=$2  # "vercel", "github", or "both"
	local use_cache=$3  # 0 or 1

	# Parse variable definition
	IFS='|' read -r vercel_name description vercel_scope github_name cache_key default_value <<< "$var_def"

	# Handle AUTO default for NEXT_PUBLIC_PROJECT_NAME
	if [ "$default_value" = "AUTO" ]; then
		# Try to get from package.json, fallback to directory name
		if [ -f "package.json" ]; then
			default_value=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' package.json | cut -d'"' -f4)
		fi
		if [ -z "$default_value" ]; then
			default_value=$(basename "$PWD")
		fi
	fi

	# Skip if not applicable to current platform
	if [ "$platform" = "vercel" ] && [ "$vercel_name" = "none" ]; then
		return 0
	fi
	if [ "$platform" = "github" ] && [ "$github_name" = "none" ]; then
		return 0
	fi

	# Determine which check function to use based on first platform encountered
	local check_func="none"
	local check_env=""

	if [ "$platform" = "both" ]; then
		# For unified script, check based on which platform will be set first
		if [ "$vercel_name" != "none" ]; then
			check_func="check_vercel_var_exists"
			if [ "$vercel_scope" != "all" ]; then
				check_env="$vercel_scope"
			else
				check_env="production"  # Check production for "all" scope
			fi
		elif [ "$github_name" != "none" ]; then
			check_func="check_github_secret_exists"
		fi
	elif [ "$platform" = "vercel" ]; then
		check_func="check_vercel_var_exists"
		if [ "$vercel_scope" != "all" ]; then
			check_env="$vercel_scope"
		else
			check_env="production"  # Check production for "all" scope
		fi
	elif [ "$platform" = "github" ]; then
		check_func="check_github_secret_exists"
	fi

	# Determine which name to use for the prompt
	local prompt_name="$vercel_name"
	if [ "$vercel_name" = "none" ]; then
		prompt_name="$github_name"
	fi

	# Determine cache key usage
	local cache_key_arg=""
	if [ "$use_cache" -eq 1 ]; then
		cache_key_arg="$cache_key"
	fi

	# Prompt for value
	local value
	value=$(prompt_for_value "$prompt_name" "$description" "$check_func" "$check_env" "$cache_key_arg" "$default_value")
	local prompt_result=$?

	# If prompt was skipped, return
	if [ $prompt_result -ne 0 ]; then
		# If skipped but has a default value, use the default
		if [ -n "$default_value" ]; then
			value="$default_value"
		else
			return 1
		fi
	fi

	# Set in Vercel if applicable
	if [ "$platform" = "vercel" ] || [ "$platform" = "both" ]; then
		if [ "$vercel_name" != "none" ] && [ -n "$value" ]; then
			if [ "$vercel_scope" = "all" ]; then
				set_vercel_var_all_envs "$vercel_name" "$value"
			else
				set_vercel_var "$vercel_name" "$vercel_scope" "$value"
			fi
		fi
	fi

	# Set in GitHub if applicable
	if [ "$platform" = "github" ] || [ "$platform" = "both" ]; then
		if [ "$github_name" != "none" ] && [ -n "$value" ]; then
			set_github_secret "$github_name" "$value"
		fi
	fi

	return 0
}
