# VSCode Integration for Codebase Operations

This directory contains pre-configured VSCode tasks and keyboard shortcuts for AI-powered codebase operations.

## Quick Start

### Using Tasks

1. **Open Command Palette:** `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (Mac)
2. **Type:** "Run Task"
3. **Select:** One of the codebase operations tasks

### Keyboard Shortcuts

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Ctrl+Shift+F` | Fix Changed Files | Fix only files changed since main (safe mode) |
| `Ctrl+Shift+D` | Preview Issues | Dry run - show what would be fixed |
| `Ctrl+Shift+U` | Undo Last Operation | Rollback the last operation |

**Note:** Shortcuts work when editor is focused (not in terminal).

## Available Tasks

### Recommended Workflows

**🌟 Codebase: Fix Changed Files (Recommended)**
- Keyboard shortcut: `Ctrl+Shift+F`
- Fixes only files you've changed since main branch
- Uses safe mode for low-risk fixes
- **Most common workflow** - use this for PR cleanup

**🔍 Codebase: Preview Issues (Dry Run)**
- Keyboard shortcut: `Ctrl+Shift+D`
- Shows what issues exist without fixing anything
- Great for understanding what needs work
- Zero risk - read-only operation

**📝 Codebase: Fix with Review**
- Interactive mode with detailed diff preview
- Shows exactly what will change before applying
- Approve or skip each group of fixes
- Good for learning or cautious fixing

### Quick Fix Options

**⚡ Codebase: Safe Auto-Fix**
- Automatically applies only safe, low-risk fixes
- No interaction needed - runs to completion
- Good for formatting, imports, simple type fixes
- Uses the `safe` profile

**🎯 Codebase: Fix All Issues**
- Interactive selection of which groups to fix
- Default behavior - preview then choose
- Full control over what gets fixed

### Advanced Operations

**📋 Codebase: Show History**
- View last 10 operations
- See what was fixed and when
- Shows rollback options

**🔄 Codebase: Undo Last Operation**
- Keyboard shortcut: `Ctrl+Shift+U`
- Instant rollback to before-state
- Uses git tags for safe restoration

**🚀 Codebase: Code Improvements**
- Finds quality improvement opportunities
- Detects dead code, bandaid fixes, etc.
- Different from bug fixing - focuses on refactoring

## How It Works

All tasks run `./scripts/codebase_ops.sh` with different flags:

```bash
# Fix Changed Files =
./scripts/codebase_ops.sh --since main --safe

# Preview Issues =
./scripts/codebase_ops.sh --dry-run

# Fix with Review =
./scripts/codebase_ops.sh --profile review
```

## Customization

### Custom Keyboard Shortcuts

Edit `.vscode/keybindings.json` to change shortcuts:

```json
[
  {
    "key": "ctrl+alt+f",  // Your preferred shortcut
    "command": "workbench.action.tasks.runTask",
    "args": "Codebase: Fix Changed Files (Recommended)"
  }
]
```

### Add New Tasks

Edit `.vscode/tasks.json` to add custom workflows:

```json
{
  "label": "Codebase: My Custom Workflow",
  "type": "shell",
  "command": "./scripts/codebase_ops.sh --since main --confidence medium",
  "group": "build"
}
```

### Team Configuration

Share these tasks across your team by committing `.vscode/` to your repository. Individual developers can override shortcuts in their personal settings.

## Tips

1. **Start with Preview** - Always run "Preview Issues" first to see what needs fixing
2. **Use Fix Changed Files** - Most efficient workflow for PR development
3. **Learn from Review Mode** - Use "Fix with Review" to understand what changes are made
4. **Don't Fear Undo** - Experiment freely knowing you can rollback instantly
5. **Keyboard Shortcuts** - Learn the 3 main shortcuts for maximum productivity

## Troubleshooting

**Task doesn't appear in list:**
- Make sure you're in the project root directory
- Reload VSCode window: `Ctrl+Shift+P` → "Reload Window"

**Keyboard shortcut conflicts:**
- Edit `.vscode/keybindings.json` to use different keys
- Check VSCode's Keyboard Shortcuts editor for conflicts

**Script not found:**
- Ensure `./scripts/codebase_ops.sh` exists and is executable
- Run `chmod +x ./scripts/codebase_ops.sh` if needed

**Want more details:**
- See `scripts/README.md` for full script documentation
- See `README.md` for overall project architecture

## Related Documentation

- **Full Script Documentation:** `scripts/README.md`
- **Team Configuration:** See `.codebase-ops.json` examples in main README
- **Smart Defaults:** Automatic context detection (CI, PR, local)
- **Command Reference:** Run `./scripts/codebase_ops.sh --help`
