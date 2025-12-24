#!/bin/bash
#
# GitHub Secrets Setup (Interactive & Secure)
#
# SECURITY BEST PRACTICES:
# - Uses interactive prompts (no secrets in shell history)
# - Never reads from .env file directly (prevents bulk extraction)
# - Requires manual paste for each secret (deliberate action)
# - No secrets appear in process list or terminal output
#

# Warn if running as root
if [ "$EUID" -eq 0 ]; then
	echo "⚠️  WARNING: Running as root is not recommended for security reasons" >&2
	read -rp "Continue anyway? (y/n): " -n 1 confirm >&2
	echo "" >&2
	if [[ ! $confirm =~ ^[Yy]$ ]]; then
		exit 1
	fi
fi

# Get script directory and source the shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/env-setup-lib.sh"

echo "🔐 GitHub Secrets Setup (Interactive & Secure)"
echo ""
echo "This script will prompt you to paste each secret value."
echo "Values will NOT appear in your terminal or shell history."
echo ""

# Check GitHub CLI
if ! check_github_cli; then
	exit 1
fi

echo ""
read -rp "Continue with setup? (y/n) " -n 1 confirm
echo ""
if [[ ! $confirm =~ ^[Yy]$ ]]; then
	echo "Setup cancelled."
	exit 0
fi

# ============================================================================
# CONFIGURE SECRETS
# ============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 DATABASE SECRETS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Process database variables (GitHub-only ones)
for var_def in "${ENV_VARIABLES[@]}"; do
	IFS='|' read -r vercel_name _ _ github_name _ <<< "$var_def"
	if [[ "$var_def" == *"Database URL"* ]] && [ "$github_name" != "none" ]; then
		process_variable "$var_def" "github" 0
	fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔑 AUTHENTICATION SECRETS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "ℹ️  Generate Better Auth secrets with: bun run auth:secret"
echo "   Use DIFFERENT secrets for each environment!"
echo ""

# Process auth variables
for var_def in "${ENV_VARIABLES[@]}"; do
	IFS='|' read -r vercel_name _ _ github_name _ <<< "$var_def"
	if [[ "$var_def" == *"Auth"* ]] || [[ "$var_def" == *"GOOGLE_"* ]]; then
		if [ "$github_name" != "none" ]; then
			process_variable "$var_def" "github" 0
		fi
	fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔌 THIRD-PARTY SERVICE SECRETS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Process third-party service variables
for var_def in "${ENV_VARIABLES[@]}"; do
	IFS='|' read -r vercel_name _ _ github_name _ <<< "$var_def"
	if [[ "$var_def" == *"PostHog"* ]] || [[ "$var_def" == *"Polar"* ]] || [[ "$var_def" == *"UploadThing"* ]]; then
		if [ "$github_name" != "none" ]; then
			process_variable "$var_def" "github" 0
		fi
	fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  PROJECT CONFIGURATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Process project configuration variables
for var_def in "${ENV_VARIABLES[@]}"; do
	IFS='|' read -r vercel_name _ _ github_name _ <<< "$var_def"
	if [[ "$var_def" == *"NEXT_PUBLIC_PROJECT_NAME"* ]]; then
		if [ "$github_name" != "none" ]; then
			process_variable "$var_def" "github" 0
		fi
	fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ALL SECRETS CONFIGURED!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Verify with: gh secret list"
echo ""
