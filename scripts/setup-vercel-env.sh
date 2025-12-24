#!/bin/bash
#
# Vercel Environment Variables Setup (Interactive & Secure)
#
# SECURITY BEST PRACTICES:
# - Uses interactive prompts (no secrets in shell history)
# - Never reads from .env file directly (prevents bulk extraction)
# - Requires manual paste for each secret (deliberate action)
# - No secrets appear in process list or terminal output
#
# VERCEL ENVIRONMENTS:
# - production: Used for production deployments (main branch)
# - preview: Used for preview deployments (PRs, other branches)
# - development: Used for local development with `vercel dev`
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

echo "🚀 Vercel Environment Variables Setup (Interactive & Secure)"
echo ""
echo "This script will configure environment variables for your Vercel project."
echo "You'll be prompted to paste each secret value."
echo "Values will NOT appear in your terminal or shell history."
echo ""

# Check Vercel CLI
if ! check_vercel_cli; then
	exit 1
fi

# Check if project is linked
if ! check_vercel_project; then
	exit 1
fi

echo ""
echo "📋 Environment Setup Options"
echo "---"
echo "This script will set up environment variables for:"
echo "  • Production (main branch deployments)"
echo "  • Preview (PR and branch deployments)"
echo "  • Development (local vercel dev)"
echo ""
read -rp "Continue? (y/n) " -n 1 confirm
echo ""
if [[ ! $confirm =~ ^[Yy]$ ]]; then
	echo "Setup cancelled."
	exit 0
fi

# ============================================================================
# CONFIGURE VARIABLES
# ============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 DATABASE CONFIGURATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "ℹ️  Vercel deployments use DATABASE_URL (not DATABASE_URL_*)"
echo "   We'll set DATABASE_URL for production, preview, and development."
echo ""

# Process database variables
for var_def in "${ENV_VARIABLES[@]}"; do
	# Only process Vercel variables (skip GitHub-only ones)
	IFS='|' read -r vercel_name _ _ github_name _ <<< "$var_def"
	if [[ "$var_def" == *"Database URL"* ]] && [ "$vercel_name" != "none" ]; then
		process_variable "$var_def" "vercel" 0
	fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 AUTHENTICATION CONFIGURATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "ℹ️  Generate Better Auth secrets with: bun run auth:secret"
echo "   Use DIFFERENT secrets for each environment!"
echo ""

# Process auth variables
for var_def in "${ENV_VARIABLES[@]}"; do
	IFS='|' read -r vercel_name _ _ github_name _ <<< "$var_def"
	if [[ "$var_def" == *"Auth"* ]] || [[ "$var_def" == *"GOOGLE_"* ]]; then
		if [ "$vercel_name" != "none" ]; then
			process_variable "$var_def" "vercel" 0
		fi
	fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔌 THIRD-PARTY SERVICES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Process third-party service variables
for var_def in "${ENV_VARIABLES[@]}"; do
	IFS='|' read -r vercel_name _ _ github_name _ <<< "$var_def"
	if [[ "$var_def" == *"PostHog"* ]] || [[ "$var_def" == *"Polar"* ]] || [[ "$var_def" == *"UploadThing"* ]]; then
		if [ "$vercel_name" != "none" ]; then
			process_variable "$var_def" "vercel" 0
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
		if [ "$vercel_name" != "none" ]; then
			process_variable "$var_def" "vercel" 0
		fi
	fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔗 GIT INTEGRATION (AUTOMATIC DEPLOYMENTS)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "ℹ️  Connect Vercel to your GitHub repo for automatic deployments:"
echo "   • Push to main → auto-deploy to production"
echo "   • Open PR → auto-deploy preview environment"
echo ""

# Detect Git remote
GIT_REMOTE=$(git remote get-url origin 2>/dev/null)
if [ -z "$GIT_REMOTE" ]; then
	echo "⚠️  No Git remote found. Skipping Git integration."
	echo "   Run 'git remote add origin <repo-url>' to add a remote."
else
	echo "📍 Detected Git repository: $GIT_REMOTE"
	echo ""
	read -rp "Would you like to connect Vercel to this repository? (y/n) " -n 1 git_reply
	echo ""

	if [[ $git_reply =~ ^[Yy]$ ]]; then
		echo ""
		echo "🔌 Connecting Vercel project to Git repository..."

		if vercel git connect "$GIT_REMOTE"; then
			echo ""
			echo "✅ Git integration configured successfully!"
			echo ""
			echo "🎉 Automatic deployments are now enabled:"
			echo "   • git push origin main → deploys to production"
			echo "   • git push origin feature-branch → creates preview deployment"
			echo "   • Open PR → creates preview deployment with unique URL"
		else
			echo ""
			echo "⚠️  Git integration failed. You can set it up manually:"
			echo "   1. Visit: https://vercel.com/dashboard"
			echo "   2. Go to your project → Settings → Git"
			echo "   3. Connect your GitHub repository"
			echo ""
			echo "   Or try: vercel git connect $GIT_REMOTE"
		fi
	else
		echo ""
		echo "⏭️  Skipping Git integration."
		echo ""
		echo "💡 To enable automatic deployments later, run:"
		echo "   vercel git connect $GIT_REMOTE"
		echo ""
		echo "   Or set it up in the dashboard:"
		echo "   https://vercel.com/dashboard → Your Project → Settings → Git"
	fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SETUP COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Summary:"
echo "   ✅ Environment variables configured"
if [ ! -z "$GIT_REMOTE" ] && [[ $git_reply =~ ^[Yy]$ ]]; then
	echo "   ✅ Git integration enabled (automatic deployments)"
else
	echo "   ⏭️  Git integration skipped (manual deployments only)"
fi
echo ""
echo "🚀 Deployment Options:"
if [ ! -z "$GIT_REMOTE" ] && [[ $git_reply =~ ^[Yy]$ ]]; then
	echo "   • Automatic: git push origin main (deploys to production)"
	echo "   • Manual:    vercel --prod"
else
	echo "   • Manual only: vercel --prod"
fi
echo ""
echo "📋 Useful Commands:"
echo "   • Verify environment variables: vercel env ls"
echo "   • Check Git connection:         vercel project ls"
echo "   • Pull env to local:            vercel env pull .env.local"
echo "   • View deployments:             vercel ls"
echo ""
