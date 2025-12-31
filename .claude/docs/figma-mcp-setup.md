# Figma MCP Setup Guide

This guide explains how to set up Figma MCP integration for the `/speckit.design` command to generate visual designs automatically.

## Overview

The `/speckit.design` command requires Figma MCP (Model Context Protocol) integration to create actual Figma design files. Without Figma MCP, the command will still generate comprehensive `design.md` documentation but won't create visual designs.

## Prerequisites

- Figma account (free or paid)
- Figma personal access token
- Claude Code with MCP support
- bun or Node.js installed

## Installation Steps

### Step 1: Get Figma Access Token

1. Log in to [Figma](https://www.figma.com/)
2. Go to **Settings** → **Account** → **Personal Access Tokens**
3. Click **Generate new token**
4. Name it: "Claude Code MCP"
5. Copy the token (you won't see it again!)

**Security Note**: Never commit your Figma token to git. Store it in environment variables or a secure credential manager.

### Step 2: Install Figma MCP Server

There are several Figma MCP server implementations. Choose one:

#### Option A: figma-mcp (Recommended)

```bash
# Install globally
bun add -g figma-mcp

# Or add to project dev dependencies
bun add -D figma-mcp
```

#### Option B: Custom MCP Server

If your organization has a custom Figma MCP server, follow their installation instructions.

### Step 3: Configure MCP in Claude Code

Add the Figma MCP server to your Claude Code configuration:

**Location**: `~/.claude/mcp_config.json` or project-specific `.claude/mcp.json`

```json
{
  "mcpServers": {
    "figma": {
      "command": "figma-mcp",
      "args": [],
      "env": {
        "FIGMA_ACCESS_TOKEN": "your-token-here"
      }
    }
  }
}
```

**Environment variable alternative**:

Instead of embedding the token in config, use an environment variable:

```bash
# Add to ~/.bashrc or ~/.zshrc
export FIGMA_ACCESS_TOKEN="your-token-here"
```

Then reference it in config:

```json
{
  "mcpServers": {
    "figma": {
      "command": "figma-mcp",
      "args": [],
      "env": {
        "FIGMA_ACCESS_TOKEN": "${FIGMA_ACCESS_TOKEN}"
      }
    }
  }
}
```

### Step 4: Restart Claude Code

After configuration:

```bash
# Restart Claude Code session
# MCP servers are loaded at startup
```

### Step 5: Verify Installation

Run this command to check if Figma MCP is available:

```bash
# Claude Code should detect tools matching: mcp__figma_*
# You should see tools like:
#   - mcp__figma_create_file
#   - mcp__figma_create_frame
#   - mcp__figma_get_file
#   - etc.
```

When you run `/speckit.design`, it should now display:

```
Figma MCP: Connected ✓
```

## Usage

Once configured, `/speckit.design` will automatically:

1. **Create Figma File**: Generates a new file named `[Feature Name] - Design`
2. **Create Frames**: One frame per screen from your spec
3. **Apply Brand Colors**: Uses colors from `.specify/brand/brand.yaml`
4. **Generate Components**: Creates button, card, and UI element mockups
5. **Link in design.md**: Adds Figma file URL to documentation

## Troubleshooting

### "Figma MCP not connected" Error

**Cause**: MCP server not configured or token invalid.

**Solution**:
1. Verify token is correct in environment or config
2. Check MCP server is installed: `which figma-mcp` or `bun pm ls -g`
3. Restart Claude Code to reload MCP configuration
4. Check Claude Code logs for MCP connection errors

### "Figma API Error: 403 Forbidden"

**Cause**: Token doesn't have required permissions.

**Solution**:
1. Regenerate Figma access token
2. Ensure token has "File content" and "File write" scopes
3. Update environment variable or config with new token

### "Cannot create file in team"

**Cause**: Token may not have access to the team/project.

**Solution**:
1. Create files in your personal "Drafts" first
2. Move to team after creation
3. Or request team-level access token from admin

### Figma MCP Tools Not Detected

**Cause**: MCP server not running or misconfigured.

**Solution**:
1. Test MCP server directly:
   ```bash
   FIGMA_ACCESS_TOKEN="your-token" figma-mcp
   ```
2. Check for error messages
3. Verify Claude Code MCP config path is correct
4. Try reinstalling MCP server

## Alternative: Documentation-Only Mode

If you don't want Figma integration, `/speckit.design` will still work in documentation-only mode:

- Generates comprehensive `design.md` with JSX code structures
- Includes component install commands
- Provides design decisions and accessibility checklists
- No visual Figma files created

To use documentation-only mode, just skip Figma MCP setup. The command will detect it's unavailable and proceed without Figma generation.

## Brand Integration

Figma designs automatically use colors from `.specify/brand/brand.yaml`:

| Brand Variable | Figma Usage |
|----------------|-------------|
| `colors.primary` | Primary button color, links, brand elements |
| `colors.secondary` | Secondary buttons, muted UI |
| `colors.destructive` | Error states, delete buttons |
| `radius` | Border radius for cards, buttons |

**Note**: OKLCH colors in brand.yaml are converted to hex/RGB for Figma compatibility.

## Advanced Configuration

### Custom Figma Team/Project

To create files in a specific team/project:

```json
{
  "mcpServers": {
    "figma": {
      "command": "figma-mcp",
      "args": [],
      "env": {
        "FIGMA_ACCESS_TOKEN": "${FIGMA_ACCESS_TOKEN}",
        "FIGMA_TEAM_ID": "your-team-id",
        "FIGMA_PROJECT_ID": "your-project-id"
      }
    }
  }
}
```

### Design System Library Sync

To sync with an existing Figma design system:

1. Add design system library URL to `.specify/brand/brand.yaml`:

```yaml
figma:
  library_url: "https://www.figma.com/file/abc123/Design-System"
  sync_enabled: true
```

2. `/speckit.design` will reference components from the library

## Security Best Practices

1. **Never commit tokens**: Add `.env` and MCP config to `.gitignore`
2. **Use environment variables**: Store tokens outside of code
3. **Rotate tokens regularly**: Generate new tokens every 90 days
4. **Limit token scope**: Only grant necessary permissions
5. **Use team tokens carefully**: Personal tokens are safer for local development

## Resources

- [Figma API Documentation](https://www.figma.com/developers/api)
- [MCP Specification](https://modelcontextprotocol.org/)
- [Claude Code MCP Guide](https://docs.anthropic.com/claude/mcp)

## Support

If you encounter issues:

1. Check this troubleshooting guide first
2. Verify Figma API status: [status.figma.com](https://status.figma.com)
3. Test token with Figma API directly:
   ```bash
   curl -H "X-Figma-Token: your-token" https://api.figma.com/v1/me
   ```
4. Check Claude Code logs for MCP errors
5. File an issue at your MCP server's repository

---

**Last Updated**: 2025-12-31
**Speckit Version**: 1.0.0
