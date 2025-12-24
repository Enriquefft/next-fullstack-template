#!/bin/bash

echo "🛡️  Setting up branch protection for 'main' branch..."
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ gh CLI not found. Please install it first:"
    echo "   macOS: brew install gh"
    echo "   Linux: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    exit 1
fi

# Get repo info
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
echo "📦 Repository: $REPO"
echo ""

# Set branch protection
echo "Setting branch protection rules..."

gh api repos/$REPO/branches/main/protection \
  --method PUT \
  --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "checks": [
      {"context": "quality (typecheck)"},
      {"context": "quality (lint)"},
      {"context": "quality (deps)"},
      {"context": "unit-tests"},
      {"context": "e2e-tests"},
      {"context": "build"},
      {"context": "CodeQL"}
    ]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Branch protection enabled for 'main'!"
    echo ""
    echo "Protection rules:"
    echo "  ✅ Required status checks (must pass before merge)"
    echo "  ✅ Require 1 PR approval"
    echo "  ✅ Require branch up-to-date"
    echo "  ✅ Require conversation resolution"
    echo "  ✅ No force pushes allowed"
else
    echo ""
    echo "❌ Failed to set branch protection"
    echo ""
    echo "If you get a 404 error, you may need to create a PR first"
    echo "so that GitHub recognizes the branch protection check contexts."
fi
