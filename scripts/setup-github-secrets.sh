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
# CUSTOMIZATION:
#   Edit scripts/lib/env-config.sh to add/remove/modify environment variables
#

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

echo "GitHub Secrets Setup (Interactive & Secure)"
echo ""
echo "This script will prompt you to paste each secret value."
echo "Values will NOT appear in your terminal or shell history."
echo ""
echo "CUSTOMIZATION: Edit scripts/lib/env-config.sh to modify variables"
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

# Process all categories for GitHub
process_all_categories "github" 0 0

echo ""
echo "============================================================"
echo "  ALL SECRETS CONFIGURED!"
echo "============================================================"
echo ""
echo "Verify with: gh secret list"
echo ""
