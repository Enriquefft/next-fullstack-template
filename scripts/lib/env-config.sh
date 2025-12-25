#!/bin/bash
#
# Environment Variables Configuration
#
# CUSTOMIZE THIS FILE FOR YOUR PROJECT
#
# This is the single source of truth for environment variables.
# Modify this file to add/remove/change variables for your specific project.
#
# Format: "VERCEL_NAME|DESCRIPTION|VERCEL_SCOPE|GITHUB_NAME|CACHE_KEY|DEFAULT_VALUE"
#
# Fields:
#   VERCEL_NAME   - Variable name for Vercel (use "none" to skip Vercel)
#   DESCRIPTION   - Human-readable description shown during setup
#   VERCEL_SCOPE  - "all", "production", "preview", "development", or "none"
#   GITHUB_NAME   - Secret name for GitHub Actions (use "none" to skip GitHub)
#   CACHE_KEY     - Key for caching values when setting both platforms
#   DEFAULT_VALUE - Optional default (empty string if none, "AUTO" for auto-detect)
#

# ============================================================================
# CATEGORY DEFINITIONS
# ============================================================================
# Define category names and their display titles
# Format: "CATEGORY_ID|Display Title|Emoji"

declare -a ENV_CATEGORIES=(
	"database|DATABASE CONFIGURATION|package"
	"auth|AUTHENTICATION CONFIGURATION|lock"
	"services|THIRD-PARTY SERVICES|electric_plug"
	"project|PROJECT CONFIGURATION|gear"
)

# ============================================================================
# VARIABLE DEFINITIONS BY CATEGORY
# ============================================================================

# --- DATABASE ---
# Simplified: 3 database URLs (production, preview, test)
# Local development uses DATABASE_URL_DEV in .env.local (not configured here)
declare -a ENV_VARS_DATABASE=(
	"DATABASE_URL|Production Database URL (Neon main branch) [Get free DB: https://neon.tech]|production|none|db_url_prod|"
	"DATABASE_URL|Preview Database URL (Neon preview branch) [Get free DB: https://neon.tech]|preview|none|db_url_preview|"
	"none|Test Database URL (for E2E tests) [Get free DB: https://neon.tech]|none|DATABASE_URL_TEST|db_url_test|"
)

# --- AUTHENTICATION ---
# Simplified: 3 auth secrets (production, preview, test) + shared OAuth credentials
declare -a ENV_VARS_AUTH=(
	"BETTER_AUTH_SECRET|Better Auth Secret for PRODUCTION [Generate with: bun run auth:secret]|production|none|auth_secret_prod|"
	"BETTER_AUTH_SECRET|Better Auth Secret for PREVIEW [Generate with: bun run auth:secret]|preview|none|auth_secret_preview|"
	"none|Better Auth Secret for TEST [Generate with: bun run auth:secret]|none|BETTER_AUTH_SECRET_TEST|auth_secret_test|"
	"GOOGLE_CLIENT_ID|Google OAuth Client ID [Setup at: https://console.cloud.google.com]|all|GOOGLE_CLIENT_ID|google_client_id|"
	"GOOGLE_CLIENT_SECRET|Google OAuth Client Secret [Setup at: https://console.cloud.google.com]|all|GOOGLE_CLIENT_SECRET|google_client_secret|"
)

# --- THIRD-PARTY SERVICES ---
# External service integrations (analytics, payments, uploads, etc.)
declare -a ENV_VARS_SERVICES=(
	"NEXT_PUBLIC_POSTHOG_KEY|PostHog API Key (public) [Get at: https://posthog.com]|all|NEXT_PUBLIC_POSTHOG_KEY|posthog_key|"
	"POSTHOG_PROJECT_ID|PostHog Project ID [Get at: https://posthog.com]|all|POSTHOG_PROJECT_ID|posthog_project|"
	"POLAR_ACCESS_TOKEN|Polar Access Token [Get at: https://polar.sh/settings]|all|POLAR_ACCESS_TOKEN|polar_token|"
	"POLAR_MODE|Polar Mode (production or sandbox) [Recommended: sandbox]|all|none|polar_mode|sandbox"
	"UPLOADTHING_TOKEN|UploadThing Token [Get at: https://uploadthing.com/dashboard]|all|UPLOADTHING_TOKEN|uploadthing_token|"
	"KAPSO_API_KEY|Kapso WhatsApp API Key (optional) [Get at: https://kapso.ai]|all|KAPSO_API_KEY|kapso_api_key|"
	"KAPSO_PHONE_NUMBER_ID|Kapso WhatsApp Phone Number ID (optional) [Get at: https://kapso.ai]|all|KAPSO_PHONE_NUMBER_ID|kapso_phone_id|"
	"META_APP_SECRET|Meta App Secret for webhook verification (optional) [Get at: https://developers.facebook.com]|all|META_APP_SECRET|meta_app_secret|"
)

# --- PROJECT CONFIGURATION ---
# Project-level settings
declare -a ENV_VARS_PROJECT=(
	"NEXT_PUBLIC_PROJECT_NAME|Project Name (used for DB schema) [Default: auto-detected from package.json]|all|NEXT_PUBLIC_PROJECT_NAME|project_name|AUTO"
)

# ============================================================================
# HELPER: Get all variables (combines all categories)
# ============================================================================
get_all_variables() {
	local vars=()
	vars+=("${ENV_VARS_DATABASE[@]}")
	vars+=("${ENV_VARS_AUTH[@]}")
	vars+=("${ENV_VARS_SERVICES[@]}")
	vars+=("${ENV_VARS_PROJECT[@]}")
	printf '%s\n' "${vars[@]}"
}

# ============================================================================
# HELPER: Get variables for a specific category
# ============================================================================
get_category_variables() {
	local category=$1
	case $category in
		database)
			printf '%s\n' "${ENV_VARS_DATABASE[@]}"
			;;
		auth)
			printf '%s\n' "${ENV_VARS_AUTH[@]}"
			;;
		services)
			printf '%s\n' "${ENV_VARS_SERVICES[@]}"
			;;
		project)
			printf '%s\n' "${ENV_VARS_PROJECT[@]}"
			;;
		*)
			echo "Unknown category: $category" >&2
			return 1
			;;
	esac
}

# ============================================================================
# HELPER: Get category info
# ============================================================================
get_category_info() {
	local category=$1
	for cat_def in "${ENV_CATEGORIES[@]}"; do
		IFS='|' read -r cat_id cat_title cat_emoji <<< "$cat_def"
		if [ "$cat_id" = "$category" ]; then
			echo "$cat_title|$cat_emoji"
			return 0
		fi
	done
	return 1
}

# ============================================================================
# CATEGORY-SPECIFIC NOTES (shown before processing each category)
# Override these functions to customize messages per category
# ============================================================================
show_category_notes() {
	local category=$1
	local platform=$2  # "vercel", "github", or "both"

	case $category in
		database)
			if [ "$platform" = "vercel" ] || [ "$platform" = "both" ]; then
				echo "Vercel deployments use DATABASE_URL (not DATABASE_URL_*)."
				echo "Setting for production and preview environments."
			fi
			;;
		auth)
			echo "Generate Better Auth secrets with: bun run auth:secret"
			echo "Use DIFFERENT secrets for each environment!"
			;;
		services)
			# No extra notes for services
			;;
		project)
			# No extra notes for project config
			;;
	esac
}
