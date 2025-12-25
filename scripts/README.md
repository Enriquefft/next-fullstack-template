# Automated Codebase Operations

**`codebase_ops.sh`** - AI-powered automation script for parallel bug fixing and code improvements.

## Quick Start

```bash
# 🌟 First time? Start here - see what needs fixing
./scripts/codebase_ops.sh --dry-run

# ⚡ Fix only what you changed in your PR (90% faster!)
./scripts/codebase_ops.sh --since main

# 🧹 Quick cleanup - only safe/automated fixes
./scripts/codebase_ops.sh --safe

# 🔄 Made a mistake? Undo instantly
./scripts/codebase_ops.sh undo
```

## Features

### Developer Experience

- **Preview by Default** - Shows what will be fixed before doing anything (safe to explore!)
- **Interactive Selection** - Choose exactly which issues to fix
- **Incremental Mode** - Fix only files changed in your PR (`--since main` = 90% faster)
- **Smart Defaults** - Auto-detects context (CI, git hook, PR, local) and applies appropriate flags
- **Undo/Rollback** - Instant rollback with `./scripts/codebase_ops.sh undo`
- **Confidence Levels** - `--safe` flag for zero-risk automated fixes
- **Diff-First** - `--show-diff` to review changes per group before applying
- **Smart Errors** - Every error has actionable next steps
- **Pre-flight Checks** - Validates environment before starting

## Common Workflows

```bash
# 🎯 SELECTIVE: Preview and choose specific issues
./scripts/codebase_ops.sh
# Shows grouped issues, you pick which to fix

# 🔍 DETAILED REVIEW: See exactly what changes before applying
./scripts/codebase_ops.sh --show-diff
# Shows files + issues per group, approve each one

# 📋 VIEW HISTORY: See recent operations
./scripts/codebase_ops.sh history
# List last 10 operations with status

# 🔄 ROLLBACK: Undo to specific operation
./scripts/codebase_ops.sh rollback 2
# Rollback to operation #2

# 🚀 POWER USER: Fix everything automatically
./scripts/codebase_ops.sh --all --execute --auto
# Skips confirmation, fixes all issues (use with caution!)

# 🔍 CODE IMPROVEMENTS: Find quality improvements
./scripts/codebase_ops.sh --mode improve
# Finds dead code, bandaid fixes, type safety issues
```

## How It Works

1. 🔍 **Pre-flight checks** - Validates environment (git, Claude auth, disk space)
2. 🏃 **Runs diagnostics** - Test/type/build/lint in parallel
3. 🤖 **AI analysis** - Groups issues by module and dependencies
4. 📋 **Shows preview** - Time estimates, complexity markers
5. ❓ **Interactive selection** - Choose which groups to fix
6. 💾 **Saves state** - Creates git tags for undo/rollback
7. 🔧 **Parallel fixing** - Isolated git worktrees for each group
8. ✅ **Merges changes** - In dependency order
9. 🔔 **Notification** - Desktop alert when complete

## Key Options

- `--since <ref>` - Only analyze files changed since git ref (90% faster)
- `--safe` - Only apply safe/simple fixes (zero-risk)
- `--confidence <level>` - Filter by confidence: safe, medium, low
- `--show-diff` - Show files/issues per group and prompt to approve
- `--execute` - Apply fixes without confirmation
- `--dry-run` - Just show what would be fixed
- `--mode <mode>` - Select mode: fix or improve
- `--all` - Process ALL issues (default: simple/safe only)

## Safety Features

- `history` - List last 10 operations with status
- `undo` - Rollback last operation to before-state
- `rollback <number>` - Rollback to specific operation by index

## Smart Defaults (Context Detection)

The script automatically detects your environment and applies appropriate flags:

### CI Environment

(GitHub Actions, GitLab CI, CircleCI, etc.)
- Auto-applies: `--execute --auto --all --quiet`
- Fully automated, non-interactive
- Processes all issues without prompts

### Git Hook

(pre-commit, pre-push, etc.)
- Auto-applies: `--since HEAD --safe --quiet`
- Fast, safe-only fixes
- Minimal output for hook integration

### Pull Request / Feature Branch

- Auto-applies: `--since origin/main --safe`
- Only analyzes files changed in your branch
- Safe defaults to avoid breaking changes

### Local Development

(main/master/develop branch)
- Uses standard defaults
- Interactive preview mode
- You choose what to fix

### Override Behavior

Explicit flags always override smart defaults. For example:

```bash
# On PR branch, smart defaults apply --since origin/main --safe
# But you can override with:
./scripts/codebase_ops.sh --all  # Disables safe-only filter
```

## Requirements

- `claude` CLI installed and authenticated
- `jq` for JSON processing
- `tmux` for interactive mode (optional, use `--auto` without)
- Clean git working directory (or use `--allow-dirty`)
