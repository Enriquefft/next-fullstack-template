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
# For production deployments, consider using a secrets manager:
# - 1Password CLI: op read "op://vault/item/field"
# - Bitwarden CLI: bw get password "item-id"
# - AWS Secrets Manager: aws secretsmanager get-secret-value
#

echo "🔐 GitHub Secrets Setup (Interactive & Secure)"
echo ""
echo "This script will prompt you to paste each secret value."
echo "Values will NOT appear in your terminal or shell history."
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ gh CLI not found. Please install it first:"
    echo "   macOS: brew install gh"
    echo "   Linux: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub. Run: gh auth login"
    exit 1
fi

echo "📦 Database Secrets"
echo "---"
echo "Paste value for DATABASE_URL_TEST (from your .env file):"
gh secret set DATABASE_URL_TEST

echo ""
echo "Paste value for DATABASE_URL_STAGING:"
gh secret set DATABASE_URL_STAGING

echo ""
echo "Paste value for DATABASE_URL_PROD:"
gh secret set DATABASE_URL_PROD

echo ""
echo "🔑 Authentication Secrets"
echo "---"
echo "Generate Better Auth secrets with: bun run auth:secret"
echo ""
echo "Paste BETTER_AUTH_SECRET_TEST (generate new):"
gh secret set BETTER_AUTH_SECRET_TEST

echo ""
echo "Paste BETTER_AUTH_SECRET_STAGING (generate new):"
gh secret set BETTER_AUTH_SECRET_STAGING

echo ""
echo "Paste BETTER_AUTH_SECRET_PROD (generate new, DIFFERENT from above):"
gh secret set BETTER_AUTH_SECRET_PROD

echo ""
echo "Paste GOOGLE_CLIENT_ID (from .env):"
gh secret set GOOGLE_CLIENT_ID

echo ""
echo "Paste GOOGLE_CLIENT_SECRET (from .env):"
gh secret set GOOGLE_CLIENT_SECRET

echo ""
echo "🔌 Third-Party Service Secrets"
echo "---"
echo "Paste NEXT_PUBLIC_POSTHOG_KEY (from .env):"
gh secret set NEXT_PUBLIC_POSTHOG_KEY

echo ""
echo "Paste POSTHOG_PROJECT_ID (from .env):"
gh secret set POSTHOG_PROJECT_ID

echo ""
echo "Paste POLAR_ACCESS_TOKEN (from .env):"
gh secret set POLAR_ACCESS_TOKEN

echo ""
echo "Paste UPLOADTHING_TOKEN (from .env):"
gh secret set UPLOADTHING_TOKEN

echo ""
echo "Paste NEXT_PUBLIC_PROJECT_NAME (from .env):"
gh secret set NEXT_PUBLIC_PROJECT_NAME

echo ""
echo "✅ All secrets configured!"
echo ""
echo "Verify with: gh secret list"
