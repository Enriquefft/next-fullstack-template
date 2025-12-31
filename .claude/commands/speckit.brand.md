---
description: Customize shadcn/ui theme by updating CSS variables with OKLCH colors
handoffs:
  - label: Specify New Feature
    agent: speckit.specify
    prompt: Create a new feature specification
---

## Overview

Customize your application's brand by updating the shadcn/ui theme colors. This command:
- Supports OKLCH color space (perceptually uniform, better accessibility)
- Provides personality-based color suggestions
- Offers 9 preset themes
- Updates `globals.css` with new CSS variables
- Saves configuration to `.specify/brand/brand.yaml`

**Important**: This uses OKLCH colors only (NOT HSL). All hex inputs are converted to OKLCH.

---

## Execution Flow

### Step 1: Initialize Brand Configuration

Run the setup script to detect current theme:

```bash
.specify/scripts/bash/setup-brand.sh --json
```

Parse the JSON output to extract:
- `css_file`: Path to globals.css
- `css_file_full_path`: Full path to globals.css
- `brand_file`: Path to brand.yaml
- `current.primary`: Current primary color OKLCH values
- `current.secondary`: Current secondary color OKLCH values
- `current.destructive`: Current destructive color OKLCH values
- `current.radius`: Current border radius

If `status` is `"error"`, display the error message and exit.

### Step 2: Display Current Theme

Present the current theme to the user:

```
━━━━━ 🎨 Brand Setup (shadcn/ui + Tailwind v4) ━━━━━

Found: [css_file]

Current theme (OKLCH):
  --primary:     [L C H] (e.g., 0.205 0 0 - neutral dark)
  --secondary:   [L C H]
  --destructive: [L C H]
  --radius:      [value]

What would you like to do?
```

### Step 3: Present Options

Use the AskUserQuestion tool to present the main menu:

**Question**: "How would you like to customize your brand?"
**Header**: "Customize"
**Options**:
1. "Interactive colors" - "Choose personality traits and get color suggestions"
2. "Preset theme" - "Apply one of 9 pre-designed themes"
3. "Custom hex" - "Enter hex color codes directly"
4. "Keep current" - "No changes, just create brand config"

### Step 4: Process User Choice

#### Option 1: Interactive Colors (Personality-Based)

1. Ask for personality selection:

**Question**: "What personality should your brand convey? (select 1-2)"
**Header**: "Personality"
**multiSelect**: true
**Options**:
  - "Professional" - "Trustworthy, corporate, reliable (blue tones)"
  - "Friendly" - "Warm, approachable, welcoming (orange/yellow tones)"
  - "Playful" - "Fun, creative, energetic (pink/purple tones)"
  - "Bold" - "Strong, impactful, assertive (red tones)"
  - "Minimal" - "Clean, simple, understated (neutral grays)"
  - "Technical" - "Modern, precise, innovative (cyan/tech blue)"

2. Based on personality selection, suggest primary colors using this mapping:

| Personality | Hex Color | OKLCH | Description |
|-------------|-----------|-------|-------------|
| Professional | #2563EB | 0.546 0.215 262.9 | Trustworthy blue |
| Friendly | #F59E0B | 0.769 0.165 70.1 | Warm orange |
| Playful | #EC4899 | 0.650 0.240 340.0 | Vibrant pink |
| Bold | #EF4444 | 0.620 0.250 25.0 | Strong red |
| Minimal | #171717 | 0.205 0.000 89.9 | Neutral black |
| Technical | #0EA5E9 | 0.670 0.180 220.0 | Modern cyan |

If multiple personalities selected, blend them or present both options.

3. Convert suggested hex to OKLCH using the color converter:

```bash
bun run src/lib/color-conversion.ts "#2563EB"
```

4. Display the suggestion:

```
Suggested primary color for [Personality]:
  Color: ████ [Hex] ([Description])
  OKLCH: [L C H]

Options:
  1. Apply this color
  2. Enter a different hex code
  3. Try another personality
```

5. If user chooses to enter custom hex:
   - Prompt for hex code (e.g., "#2563EB")
   - Validate format (6-digit hex)
   - Convert to OKLCH
   - Check WCAG contrast against white (#FFFFFF) and dark (#000000)
   - Warn if contrast ratio < 4.5 (fails WCAG AA)
   - Show preview

6. Derive secondary and other colors from primary:
   - Secondary: Desaturate primary (reduce chroma by 80%)
   - Destructive: Keep as red/orange (#D84040 → 0.577 0.245 27.325)
   - Border: Light gray (0.922 0 0)
   - Background/Foreground: Pure white/black

#### Option 2: Preset Theme

Present 9 preset themes:

**Question**: "Choose a preset theme:"
**Header**: "Preset"
**Options**:
  1. "Zinc" - "Neutral gray, minimal and clean"
  2. "Slate" - "Cool gray, professional and modern"
  3. "Stone" - "Warm gray, earthy and natural"
  4. "Red" - "Vibrant red, bold and energetic"
  5. "Rose" - "Soft pink, friendly and warm"
  6. "Orange" - "Warm orange, inviting and approachable"
  7. "Green" - "Natural green, trustworthy and calm"
  8. "Blue" - "Classic blue, professional and reliable"
  9. "Violet" - "Creative purple, modern and innovative"

Preset color values (primary color in OKLCH):

| Preset | Hex | OKLCH |
|--------|-----|-------|
| Zinc | #18181B | 0.205 0 0 |
| Slate | #1E293B | 0.240 0.015 255 |
| Stone | #292524 | 0.220 0.008 30 |
| Red | #DC2626 | 0.558 0.217 29 |
| Rose | #E11D48 | 0.558 0.217 9 |
| Orange | #EA580C | 0.648 0.180 41 |
| Green | #16A34A | 0.598 0.174 145 |
| Blue | #2563EB | 0.546 0.215 262.9 |
| Violet | #7C3AED | 0.530 0.210 293 |

#### Option 3: Custom Hex

Prompt for hex codes directly:
- Primary color: "#______"
- (Optional) Secondary color: "#______" or "auto" to derive
- Convert to OKLCH
- Validate WCAG contrast

#### Option 4: Keep Current

- Don't modify colors
- Create brand.yaml with existing values
- Useful for just documenting current theme

### Step 5: Generate Dark Mode Colors

Automatically derive dark mode from light mode:
- Background: Invert lightness (1 → 0.145, black → nearly black)
- Foreground: Invert lightness (0.145 → 0.985, nearly black → nearly white)
- Primary: Keep same or slightly adjust lightness for better contrast
- Secondary: Darken significantly (0.97 → 0.215)
- Muted: Darken (0.97 → 0.215)
- Border: Darken (0.922 → 0.215)

### Step 6: Update globals.css

Read the current `globals.css` file and update ONLY the CSS variable values in the `:root` and `.dark` sections.

**Critical**: Preserve all existing structure, comments, and other CSS. Only replace the values inside `oklch()`.

Example transformation:
```css
/* BEFORE */
:root {
  --primary: oklch(0.205 0 0);
}

/* AFTER (if new primary is blue) */
:root {
  --primary: oklch(0.546 0.215 262.9);
}
```

Update these variables:
- `--background`
- `--foreground`
- `--card` / `--card-foreground`
- `--popover` / `--popover-foreground`
- `--primary` / `--primary-foreground`
- `--secondary` / `--secondary-foreground`
- `--muted` / `--muted-foreground`
- `--accent` / `--accent-foreground`
- `--destructive` / `--destructive-foreground`
- `--border`
- `--input`
- `--ring`

### Step 7: Update brand.yaml

Update `.specify/brand/brand.yaml` with:
- New OKLCH color values in `colors:` section
- New OKLCH dark mode values in `dark:` section
- Hex reference values in `hex_reference:` section
- Selected personality in `identity.personality:` array
- Update `updated_at:` timestamp
- Increment `version:` if this is an update (1.0.0 → 1.1.0)

### Step 8: Validate Changes

1. Run bun type check to ensure no CSS syntax errors:
```bash
bun run src/lib/color-conversion.ts "#FFFFFF" > /dev/null
```

2. Check WCAG contrast ratios:
   - Primary on white background: >= 4.5 (AA standard)
   - Primary on black background: >= 4.5
   - Foreground on background: >= 4.5

3. Display warnings if any fail

### Step 9: Summary Output

```
━━━━━ ✓ Brand Updated ━━━━━

Theme applied: [Preset name or "Custom"]
Personality: [Personality traits]

Colors (OKLCH):
  --primary:     ████ oklch([L] [C] [H])  [Hex]
  --secondary:   ████ oklch([L] [C] [H])  [Hex]
  --destructive: ████ oklch([L] [C] [H])  [Hex]

Files updated:
  ✓ [css_file]
  ✓ .specify/brand/brand.yaml (v[VERSION])

WCAG AA Contrast:
  ✓ Primary on white: [ratio]:1
  ✓ Foreground on background: [ratio]:1

All shadcn/ui components now use your brand.
Preview: Run 'bun dev' to see changes.

Next: /speckit.specify to create a feature
```

---

## Update Mode

If called with arguments like `/speckit.brand update Make it more playful`, parse the natural language request and:
1. Load current brand.yaml
2. Identify requested change (e.g., "more playful" → adjust toward playful personality colors)
3. Apply gradual adjustments
4. Follow steps 6-9 above

---

## Error Handling

**If globals.css not found**:
```
⚠️  globals.css not found
   Run: npx shadcn@latest init
```

**If color converter fails**:
```
⚠️  Color conversion failed
   Check that src/lib/color-conversion.ts exists
   Try: bun run src/lib/color-conversion.ts "#000000"
```

**If WCAG contrast fails**:
```
⚠️  Accessibility Warning
   Primary color has low contrast ([ratio]:1)
   WCAG AA requires >= 4.5:1
   Consider choosing a lighter/darker shade

Continue anyway? [Y/n]
```

---

## Notes

- **NO HSL**: This command uses OKLCH exclusively. Never reference or use HSL format.
- **Preserve structure**: When editing globals.css, preserve all comments, formatting, and non-color CSS.
- **Atomic updates**: If any step fails, don't partially update files.
- **Version bumping**: Increment `version` in brand.yaml on each update (semver: breaking changes = major, new colors = minor, tweaks = patch).
- **Figma sync**: If Figma MCP is available and `figma.sync_enabled` is true, also update Figma library colors (future enhancement).

---

## Testing Checklist

Before marking complete, verify:
- [ ] Script detects globals.css correctly
- [ ] Personality suggestions provide correct OKLCH values
- [ ] Preset themes apply correctly
- [ ] Custom hex input converts to OKLCH accurately
- [ ] globals.css is updated without breaking structure
- [ ] brand.yaml is created/updated with correct values
- [ ] Dark mode colors are derived appropriately
- [ ] WCAG contrast warnings appear for low-contrast colors
- [ ] Version is incremented on updates
