#!/bin/bash
#
# Unified Environment Setup Script
#
# SECURITY BEST PRACTICES:
# - Uses interactive prompts (no secrets in shell history)
# - Never reads from .env file directly (prevents bulk extraction)
# - Requires manual paste for each secret (deliberate action)
# - No secrets appear in process list or terminal output
#
# Configure environment variables for:
#   - Vercel (production, preview)
#   - GitHub Actions (secrets)
#
# Options:
#   --include-vercel-dev   Also configure Vercel development environment
#                         (for 'vercel dev' command - rarely needed)
#
# CUSTOMIZATION:
#   Edit scripts/lib/env-config.sh to add/remove/modify environment variables
#

# Parse command-line flags
INCLUDE_VERCEL_DEV=0
while [[ $# -gt 0 ]]; do
	case $1 in
		--include-vercel-dev)
			INCLUDE_VERCEL_DEV=1
			shift
			;;
		-h|--help)
			echo "Usage: $0 [OPTIONS]"
			echo ""
			echo "Options:"
			echo "  --include-vercel-dev   Include Vercel development environment"
			echo "                         (for 'vercel dev' - not needed for 'bun dev')"
			echo "  -h, --help            Show this help message"
			exit 0
			;;
		*)
			echo "Unknown option: $1"
			echo "Use -h or --help for usage information"
			exit 1
			;;
	esac
done

# Warn if running as root
if [ "$EUID" -eq 0 ]; then
	echo "WARNING: Running as root is not recommended for security reasons" >&2
	read -rp "Continue anyway? (y/n): " -n 1 confirm >&2
	echo "" >&2
	if [[ ! $confirm =~ ^[Yy]$ ]]; then
		exit 1
	fi
fi

# Get script directory and source the shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/env-setup-lib.sh"

echo "Environment Setup (Interactive & Secure)"
echo ""
echo "This script will configure environment variables for:"
echo "  - Vercel (production, preview)"
echo "  - GitHub Actions (secrets)"
if [ "$INCLUDE_VERCEL_DEV" -eq 1 ]; then
	echo "  - Vercel development (--include-vercel-dev enabled)"
fi
echo ""
echo "CUSTOMIZATION: Edit scripts/lib/env-config.sh to modify variables"
echo ""

# Ask which platforms to configure
echo "Which platforms would you like to configure?"
echo "  1. Both (recommended - values will be entered once and reused)"
echo "  2. Vercel only"
echo "  3. GitHub Actions only"
echo ""
read -rp "Choice (1-3) [default: 1]: " platform_choice
platform_choice=${platform_choice:-1}
echo ""

# Determine platform mode
PLATFORM="both"
case $platform_choice in
	1)
		PLATFORM="both"
		echo "Will configure both Vercel and GitHub Actions"
		;;
	2)
		PLATFORM="vercel"
		echo "Will configure Vercel only"
		;;
	3)
		PLATFORM="github"
		echo "Will configure GitHub Actions only"
		;;
	*)
		echo "Invalid choice. Exiting."
		exit 1
		;;
esac

echo ""

# Check required CLIs based on platform choice
if [ "$PLATFORM" = "both" ] || [ "$PLATFORM" = "vercel" ]; then
	if ! check_vercel_cli; then
		exit 1
	fi
	if ! check_vercel_project; then
		exit 1
	fi
fi

if [ "$PLATFORM" = "both" ] || [ "$PLATFORM" = "github" ]; then
	if ! check_github_cli; then
		exit 1
	fi
fi

echo ""
read -rp "Continue with setup? (y/n) " -n 1 confirm
echo ""
if [[ ! $confirm =~ ^[Yy]$ ]]; then
	echo "Setup cancelled."
	exit 0
fi

# Determine if we should use caching (only for "both" mode)
USE_CACHE=0
if [ "$PLATFORM" = "both" ]; then
	USE_CACHE=1
fi

# Process all categories
process_all_categories "$PLATFORM" "$USE_CACHE" "$INCLUDE_VERCEL_DEV"

# ============================================================================
# GIT INTEGRATION (Vercel only)
# ============================================================================

if [ "$PLATFORM" = "vercel" ] || [ "$PLATFORM" = "both" ]; then
	echo ""
	echo "============================================================"
	echo "  GIT INTEGRATION (AUTOMATIC DEPLOYMENTS)"
	echo "============================================================"
	echo ""
	echo "Connect Vercel to your GitHub repo for automatic deployments:"
	echo "   - Push to main -> auto-deploy to production"
	echo "   - Open PR -> auto-deploy preview environment"
	echo ""

	# Detect Git remote
	GIT_REMOTE=$(git remote get-url origin 2>/dev/null)
	if [ -z "$GIT_REMOTE" ]; then
		echo "No Git remote found. Skipping Git integration."
		echo "   Run 'git remote add origin <repo-url>' to add a remote."
	else
		echo "Detected Git repository: $GIT_REMOTE"
		echo ""
		read -rp "Would you like to connect Vercel to this repository? (y/n) " -n 1 git_reply
		echo ""

		if [[ $git_reply =~ ^[Yy]$ ]]; then
			echo ""
			echo "Connecting Vercel project to Git repository..."

			if vercel git connect "$GIT_REMOTE"; then
				echo ""
				echo "Git integration configured successfully!"
				echo ""
				echo "Automatic deployments are now enabled:"
				echo "   - git push origin main -> deploys to production"
				echo "   - git push origin feature-branch -> creates preview deployment"
				echo "   - Open PR -> creates preview deployment with unique URL"
			else
				echo ""
				echo "Git integration failed. You can set it up manually:"
				echo "   1. Visit: https://vercel.com/dashboard"
				echo "   2. Go to your project -> Settings -> Git"
				echo "   3. Connect your GitHub repository"
				echo ""
				echo "   Or try: vercel git connect $GIT_REMOTE"
			fi
		else
			echo ""
			echo "Skipping Git integration."
			echo ""
			echo "To enable automatic deployments later, run:"
			echo "   vercel git connect $GIT_REMOTE"
			echo ""
			echo "   Or set it up in the dashboard:"
			echo "   https://vercel.com/dashboard -> Your Project -> Settings -> Git"
		fi
	fi
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo "============================================================"
echo "  SETUP COMPLETE!"
echo "============================================================"
echo ""
echo "Summary:"

if [ "$PLATFORM" = "both" ]; then
	echo "   - Vercel environment variables configured"
	echo "   - GitHub Actions secrets configured"
elif [ "$PLATFORM" = "vercel" ]; then
	echo "   - Vercel environment variables configured"
elif [ "$PLATFORM" = "github" ]; then
	echo "   - GitHub Actions secrets configured"
fi

echo ""
echo "Useful Commands:"

if [ "$PLATFORM" = "vercel" ] || [ "$PLATFORM" = "both" ]; then
	echo "   - Verify Vercel env vars:  vercel env ls"
	echo "   - Pull env to local:       vercel env pull .env.local"
	echo "   - View deployments:        vercel ls"
fi

if [ "$PLATFORM" = "github" ] || [ "$PLATFORM" = "both" ]; then
	echo "   - Verify GitHub secrets:   gh secret list"
fi

echo ""
