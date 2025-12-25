#!/bin/bash
# Post-template repository setup
# Run this ONCE after creating a new repo from the template
# This script will self-delete after successful completion

set -euo pipefail

SCRIPT_PATH="${BASH_SOURCE[0]}"
MARKER_FILE=".repo-setup-complete"

# Check if already run
if [ -f "$MARKER_FILE" ]; then
    echo "⚠️  Repository setup already completed on $(cat "$MARKER_FILE")"
    echo ""
    echo "To re-run setup:"
    echo "  1. Delete marker: rm $MARKER_FILE"
    echo "  2. Restore script: git restore $SCRIPT_PATH"
    echo "  3. Run again: $SCRIPT_PATH"
    exit 0
fi

echo "🚀 New Repository Setup (Post-Template)"
echo ""
echo "This script configures repository-specific settings that don't"
echo "propagate when creating a repo from the template."
echo ""

# Check GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed"
    echo "   Install: https://cli.github.com/"
    exit 1
fi

# Verify authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI"
    echo "   Run: gh auth login"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  CONFIGURING REPOSITORY SETTINGS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Disable default CodeQL (we use custom workflow)
echo "→ Disabling default CodeQL setup (using custom workflow)..."
if gh api --method PATCH \
    /repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)/code-scanning/default-setup \
    -f state=not-configured &> /dev/null; then
    echo "  ✅ Default CodeQL disabled"
else
    echo "  ⚠️  Could not disable default CodeQL"
    echo "     You may need to disable it manually in:"
    echo "     Settings → Code security and analysis → Code scanning"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ REPOSITORY CONFIGURATION COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create marker file
date > "$MARKER_FILE"
echo "📝 Created marker file: $MARKER_FILE"

# Self-delete prompt
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗑️  CLEANUP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This is a one-time setup script. Would you like to:"
echo "  1) Delete this script and commit (recommended)"
echo "  2) Keep the script for reference"
echo ""
read -rp "Choice (1/2): " -n 1 cleanup_choice
echo ""

if [[ $cleanup_choice == "1" ]]; then
    # Check if git is clean enough to commit
    if git diff --quiet && git diff --cached --quiet; then
        # Git is clean, we can commit
        git add "$MARKER_FILE"
        git rm "$SCRIPT_PATH"
        git commit -m "chore: complete initial repository setup

- Disabled default CodeQL (using custom workflow)
- Self-deleted setup script (one-time operation)

Setup completed on $(date)"

        echo "✅ Script deleted and changes committed"
        echo "🎉 Repository configuration complete!"
    else
        # Git has uncommitted changes, just delete without committing
        echo "⚠️  You have uncommitted changes. Deleting script without committing."
        git rm -f "$SCRIPT_PATH" 2>/dev/null || rm "$SCRIPT_PATH"
        echo "✅ Script deleted (not committed)"
        echo ""
        echo "To commit the setup marker:"
        echo "  git add $MARKER_FILE"
        echo "  git commit -m 'chore: complete initial repository setup'"
    fi
else
    echo "✅ Keeping setup script"
    echo ""
    echo "📌 Note: The marker file prevents re-running this script."
    echo "   To re-run, delete: $MARKER_FILE"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 REMINDER: Complete Setup Steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "If you haven't already, complete these steps (in order):"
echo ""
echo "1. ✅ Create Neon database branches (REQUIRED FIRST!)"
echo "   - Go to: https://console.neon.tech"
echo "   - Create 2 branches: dev, test"
echo "   - Copy connection strings for next step"
echo ""
echo "2. ✅ Set up local environment"
echo "   cp .env.example .env"
echo "   # Edit .env and add:"
echo "   #   - DATABASE_URL_DEV (from Neon dev branch)"
echo "   #   - DATABASE_URL_TEST (from Neon test branch)"
echo "   #   - NEXT_PUBLIC_PROJECT_NAME (your project name)"
echo ""
echo "3. ✅ Generate auth secrets"
echo "   bun run auth:secret"
echo "   # Copy output to BETTER_AUTH_SECRET in .env"
echo ""
echo "4. ✅ Set up GitHub Secrets (for CI/CD)"
echo "   ./scripts/setup-github-secrets.sh"
echo ""
echo "5. ✅ Set up Vercel environment variables"
echo "   ./scripts/setup-vercel-env.sh"
echo ""
echo "6. ✅ Start development"
echo "   bun dev"
echo ""
echo "See README.md for detailed instructions."
echo ""
