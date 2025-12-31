#!/usr/bin/env bash
# =============================================================================
# setup-brand.sh - Initialize brand configuration for shadcn/ui project
# =============================================================================
# Usage:
#   ./setup-brand.sh [project-name]
#   ./setup-brand.sh --json [project-name]
#
# Outputs:
#   - Text mode: Human-readable summary
#   - JSON mode: Machine-readable output for parsing
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
BRAND_DIR="$REPO_ROOT/.specify/brand"
TEMPLATE_FILE="$REPO_ROOT/.specify/templates/brand-template.yaml"

# Color conversion script location
COLOR_CONVERTER="$REPO_ROOT/src/lib/color-conversion.ts"

# =============================================================================
# Find globals.css in common locations
# =============================================================================
find_globals_css() {
    local paths=(
        "src/styles/globals.css"
        "src/app/globals.css"
        "app/globals.css"
        "styles/globals.css"
    )

    for path in "${paths[@]}"; do
        local full_path="$REPO_ROOT/$path"
        if [[ -f "$full_path" ]]; then
            echo "$path"
            return 0
        fi
    done

    return 1
}

# =============================================================================
# Extract OKLCH value from CSS variable
# =============================================================================
# Input: oklch(0.205 0 0) or 0.205 0 0
# Output: 0.205 0 0
extract_oklch_var() {
    local file="$1"
    local var_name="$2"

    # Extract the variable value
    local value=$(grep -E "^\s*--${var_name}:" "$file" 2>/dev/null | head -1 | sed "s/.*--${var_name}:\s*//" | sed 's/;.*//' | xargs)

    # Remove oklch() wrapper if present and normalize spaces
    value=$(echo "$value" | sed 's/oklch(\(.*\))/\1/' | sed 's/\s\+/ /g' | xargs)

    echo "$value"
}

# =============================================================================
# Convert hex to OKLCH using TypeScript utility
# =============================================================================
convert_hex_to_oklch() {
    local hex="$1"

    if [[ ! -f "$COLOR_CONVERTER" ]]; then
        echo "Error: Color converter not found: $COLOR_CONVERTER" >&2
        return 1
    fi

    # Try bun first, fall back to node
    if command -v bun &>/dev/null; then
        bun run "$COLOR_CONVERTER" "$hex" 2>/dev/null || echo "0 0 0"
    elif command -v node &>/dev/null; then
        node "$COLOR_CONVERTER" "$hex" 2>/dev/null || echo "0 0 0"
    else
        echo "Error: Neither bun nor node found" >&2
        return 1
    fi
}

# =============================================================================
# Main execution
# =============================================================================
main() {
    local json_mode=false
    local project_name="Project"

    # Parse arguments
    if [[ "${1:-}" == "--json" ]]; then
        json_mode=true
        shift
    fi

    if [[ -n "${1:-}" ]]; then
        project_name="$1"
    fi

    # Find globals.css
    local globals_css
    if ! globals_css=$(find_globals_css); then
        if $json_mode; then
            cat << EOF
{
  "status": "error",
  "message": "globals.css not found. Run: npx shadcn@latest init"
}
EOF
        else
            echo ""
            echo "━━━━━ ⚠️  Error ━━━━━"
            echo ""
            echo "globals.css not found"
            echo "Run: npx shadcn@latest init"
            echo ""
        fi
        exit 1
    fi

    local globals_full_path="$REPO_ROOT/$globals_css"

    # Extract current OKLCH values
    local primary=$(extract_oklch_var "$globals_full_path" "primary")
    local secondary=$(extract_oklch_var "$globals_full_path" "secondary")
    local destructive=$(extract_oklch_var "$globals_full_path" "destructive")
    local radius=$(extract_oklch_var "$globals_full_path" "radius")

    # Default if not found
    primary="${primary:-0.205 0 0}"
    secondary="${secondary:-0.97 0 0}"
    destructive="${destructive:-0.577 0.245 27.325}"
    radius="${radius:-0.65rem}"

    # Create brand directory
    mkdir -p "$BRAND_DIR"

    # Create brand.yaml from template
    local brand_file="$BRAND_DIR/brand.yaml"
    local current_date=$(date +%Y-%m-%d)

    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        echo "Error: Template not found: $TEMPLATE_FILE" >&2
        exit 1
    fi

    # Copy template and replace placeholders
    cp "$TEMPLATE_FILE" "$brand_file"

    # Update placeholders
    sed -i "s|\[CREATION_DATE\]|$current_date|g" "$brand_file"
    sed -i "s|\[PROJECT_NAME\]|$project_name|g" "$brand_file"

    # Update actual CSS file path
    sed -i "s|css_file:.*|css_file: \"$globals_css\"|" "$brand_file"

    # Output results
    if $json_mode; then
        cat << EOF
{
  "status": "success",
  "brand_file": "$BRAND_DIR/brand.yaml",
  "css_file": "$globals_css",
  "css_file_full_path": "$globals_full_path",
  "current": {
    "primary": "$primary",
    "secondary": "$secondary",
    "destructive": "$destructive",
    "radius": "$radius"
  }
}
EOF
    else
        echo ""
        echo "━━━━━ ✓ Brand Setup Complete ━━━━━"
        echo ""
        echo "Created: $BRAND_DIR/brand.yaml"
        echo "CSS File: $globals_css"
        echo ""
        echo "Current theme:"
        echo "  --primary: $primary"
        echo "  --secondary: $secondary"
        echo "  --destructive: $destructive"
        echo "  --radius: $radius"
        echo ""
        echo "Next: Run /speckit.brand to customize"
        echo ""
    fi
}

main "$@"
