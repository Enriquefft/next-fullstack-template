# Dynamic CLAUDE.md System

This template uses a **dynamic documentation system** that generates `CLAUDE.md` based on the features actually present in your project.

## Overview

Instead of having one static `CLAUDE.md` file with documentation for all possible features (many of which you might not use), this system:

1. **Detects** which features are present in your project
2. **Assembles** documentation only for the features you're using
3. **Generates** a customized `CLAUDE.md` file

## Why Dynamic?

When you run `/implement-prd`, the template should be customized to match your project requirements. This includes:

- Removing unused features (e.g., if your project doesn't need payments, Polar documentation shouldn't be included)
- Adding new features specific to your project
- Keeping documentation relevant and focused

## How It Works

### 1. Modular Sections

Documentation is split into modular sections:

```
.claude/docs/sections/
├── core/                 # Always included
│   ├── 01-intro.md
│   ├── 02-dev-commands.md
│   ├── 03-architecture-base.md
│   └── ...
└── features/             # Conditionally included
    ├── database.md       # If Drizzle + Neon detected
    ├── auth.md           # If Better Auth detected
    ├── payments.md       # If Polar detected
    ├── analytics.md      # If PostHog detected
    ├── whatsapp.md       # If Kapso detected
    └── ...
```

### 2. Feature Manifest

The `feature-manifest.json` file defines:

- Which features can be detected
- How to detect them (packages, files, env vars, directories)
- Which documentation section to include

Example:

```json
{
  "features": {
    "whatsapp": {
      "name": "WhatsApp Integration (Kapso)",
      "section": "features/whatsapp.md",
      "detectors": {
        "packages": ["@kapso/whatsapp-cloud-api"],
        "files": ["src/lib/kapso.ts"],
        "envVars": ["KAPSO_API_KEY"]
      }
    }
  }
}
```

### 3. Build Script

The `build-claude-md.ts` script:

1. Reads `package.json` to find installed packages
2. Reads `.env.example` to find configured environment variables
3. Checks for specific files and directories
4. Detects which features are present
5. Assembles the appropriate sections
6. Generates `CLAUDE.md`

## Usage

### Build CLAUDE.md

```bash
# Build with default output
bun run build:claude-md

# Build with verbose logging
bun run build:claude-md --verbose
```

### When to Rebuild

Rebuild `CLAUDE.md` when:

- **During `/implement-prd`**: Automatically customizes for your project
- **Adding a new feature**: After integrating a new service/library
- **Removing a feature**: After removing unused dependencies
- **Updating feature documentation**: After modifying section files

## Adding New Features

To add a new feature to the dynamic system:

### 1. Create Documentation Section

Create a markdown file in `.claude/docs/sections/features/`:

```bash
# .claude/docs/sections/features/my-feature.md
### My Feature

Description of your feature, how to use it, configuration, etc.
```

### 2. Add to Feature Manifest

Edit `.claude/docs/feature-manifest.json`:

```json
{
  "features": {
    "my-feature": {
      "name": "My Feature",
      "section": "features/my-feature.md",
      "detectors": {
        "packages": ["my-feature-package"],
        "files": ["src/lib/my-feature.ts"],
        "envVars": ["MY_FEATURE_API_KEY"]
      }
    }
  }
}
```

### 3. Rebuild CLAUDE.md

```bash
bun run build:claude-md
```

## Detection Logic

A feature is detected if **at least 50% of its detectors match**:

- **Packages**: Checked against `package.json` dependencies
- **Files**: Checked for existence in the project
- **Directories**: Checked for existence
- **Environment Variables**: Checked in `.env.example`

### Example:

If a feature has 4 detectors (2 packages, 1 file, 1 env var), it needs at least 2 matches to be detected.

## Core vs Feature Sections

- **Core Sections**: Always included (intro, dev commands, architecture basics, code style, git workflow, etc.)
- **Feature Sections**: Conditionally included based on detection

## Modifying Sections

### Edit Existing Section

```bash
# Edit the section file
nano .claude/docs/sections/features/whatsapp.md

# Rebuild CLAUDE.md
bun run build:claude-md
```

### Add Core Section

Core sections are numbered and always included in order:

```bash
# Create new core section
echo "### My Section" > .claude/docs/sections/core/13-my-section.md

# Add to manifest
# Edit .claude/docs/feature-manifest.json:
# "coreSections": [
#   ...
#   "core/13-my-section.md"
# ]

# Rebuild
bun run build:claude-md
```

## Integration with `/implement-prd`

When users run `/implement-prd`, the slash command should:

1. Analyze the PRD to determine required features
2. Remove unused packages and files
3. **Run `bun run build:claude-md`** to regenerate CLAUDE.md
4. Result: A customized CLAUDE.md that only documents the features being used

## Benefits

✅ **Focused Documentation**: Only see docs for features you're using
✅ **Easier Maintenance**: Update feature docs in one place
✅ **Scalable**: Easy to add new features without cluttering CLAUDE.md
✅ **Project-Specific**: Each project gets relevant documentation
✅ **Version Control Friendly**: Section files are easier to diff/review than one massive file

## File Structure Reference

```
.claude/
├── docs/
│   ├── feature-manifest.json     # Feature definitions and detectors
│   ├── README.md                 # This file
│   └── sections/
│       ├── core/                 # Always-included sections
│       │   ├── 01-intro.md
│       │   ├── 02-dev-commands.md
│       │   └── ...
│       └── features/             # Conditional sections
│           ├── database.md
│           ├── auth.md
│           ├── payments.md
│           └── ...
└── scripts/
    └── build-claude-md.ts        # Builder script

package.json                      # Contains "build:claude-md" script
CLAUDE.md                         # Generated output (DO NOT EDIT DIRECTLY)
```

## Important Notes

⚠️ **Do Not Edit CLAUDE.md Directly**: Edit the section files in `.claude/docs/sections/` instead, then rebuild.

⚠️ **Commit Section Files**: The modular sections should be version controlled. `CLAUDE.md` can be generated.

⚠️ **Keep Manifest Updated**: When adding features to the template, update the manifest accordingly.
