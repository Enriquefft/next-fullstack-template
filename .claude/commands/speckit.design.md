---
description: Generate design documentation and component mapping using shadcn/ui
handoffs:
  - label: Build Technical Plan
    agent: speckit.plan
    prompt: Create implementation plan using the design
  - label: Refine Design
    agent: speckit.design
    prompt: Refine the design based on feedback
    send: false
---

## Overview

Generate comprehensive UI/UX design documentation for a feature using shadcn/ui components. This command:
- Parses `spec.md` for UI requirements
- Recommends appropriate shadcn/ui components
- Generates copy-paste JSX code structures
- Creates `design.md` with full implementation details
- Integrates with Figma MCP for visual designs
- Supports iterative refinement

**Stack**: shadcn/ui + Tailwind v4 + OKLCH colors

---

## Prerequisites

Before running, ensure:
1. Feature spec exists: `specs/###-feature/spec.md` (from `/speckit.specify`)
2. Brand configured (recommended): `.specify/brand/brand.yaml` (from `/speckit.brand`)
3. Spec includes "UI Specifications" section

---

## Execution Flow

### Step 1: Initialize Design Environment

Run the setup script to prepare design context:

```bash
.specify/scripts/bash/setup-design.sh --json
```

Parse the JSON output:
- `status`: "ready" or "error"
- `feature_dir`: Path to feature directory
- `feature_name`: Feature identifier
- `spec_file`: Path to spec.md
- `design_file`: Path to design.md
- `brand_file`: Path to brand.yaml
- `brand_exists`: Boolean - whether brand is configured
- `brand_version`: Brand version (e.g., "1.0.0")

If `status` is `"error"`, display the error message and exit.

### Step 2: Display Context

```
━━━━━ 🎨 Design: [FEATURE_NAME] ━━━━━

Stack: shadcn/ui + Tailwind v4
Brand: [brand_file] (v[brand_version]) or "Not configured"
  └── Primary: ████ oklch([L] [C] [H])

Feature: [spec_file]
Figma MCP: [Connected / Not connected]

Analyzing UI requirements...
```

To check Figma MCP:
- Look for tools matching pattern `mcp__figma_*`
- If found: "Connected ✓"
- If not found: "Not connected (will generate docs only)"

### Step 3: Parse spec.md for UI Requirements

Read the `spec.md` file and extract UI elements from the **"UI Specifications"** section.

Look for:

**Screens** (subsections under "### Screens"):
- Screen name
- Purpose
- Entry point (navigation)
- Key elements to display
- User actions available

**Data Display** (fields to show):
- Entity names
- Fields per entity

**Interactions** (user actions):
- Action descriptions
- Expected results

**Visual Requirements** (constraints):
- Mobile-responsive
- Dark mode support
- Accessibility needs

**Example extraction**:

If spec.md contains:
```markdown
## UI Specifications

### Screens

#### User List
- **Purpose**: View all team members
- **Entry Point**: Dashboard → Team
- **Key Elements**: User name, email, role, status
- **User Actions**: Add user, edit user, delete user

### Data Display
- User: name, email, role, avatar, status, created_at

### Interactions
- Click row → View user details
- Click "Add User" → Show invite modal
```

Extract:
- Screen 1: "User List"
  - Route: `/team` (infer from entry point)
  - Data: User (name, email, role, avatar, status, created_at)
  - Actions: Add user, Edit user, Delete user, View details
  - Layout: List/table (multiple items)

### Step 4: Present Summary for Confirmation

Display detected UI elements:

```
━━━━━ Detected UI Elements ━━━━━

Screens:
  1. User List - "View all team members"
  2. User Detail - "View and edit user information"
  3. Invite Modal - "Send email invitations"

Data to display:
  - User: name, email, role, avatar, status, created_at
  - Invitation: email, role, sent_at, status

User actions:
  - View user details (click row)
  - Edit user (from detail or dropdown)
  - Invite new user (button → modal)
  - Delete user (confirmation required)
  - Filter/search users

Proceed with design generation? [Y/n/select screens]
```

If user types "select screens", ask which screens to design.

### Step 5: Component Selection (Per Screen)

For each screen, analyze requirements and recommend shadcn/ui components.

**Analysis criteria**:

| Requirement | Recommended Component |
|-------------|----------------------|
| List of items with multiple columns | Table |
| List of items as cards | Card grid |
| User avatar + info | Avatar + layout |
| Status indicator | Badge |
| Row actions (3+ options) | DropdownMenu |
| Row actions (1-2 options) | Inline Button |
| Add/Create action | Button in header |
| Focused task (< 5 fields) | Dialog |
| Complex form (> 5 fields) | Sheet |
| Destructive action | AlertDialog |
| Filter/search | Input + Command |
| Empty state | Custom Card + Icon |
| Loading | Skeleton |

**Interactive decision-making**:

When ambiguous (e.g., could be table OR card grid), ask:

**Question**: "How should the user list be displayed?"
**Header**: "Layout"
**Options**:
  - "Table" - "Best for scanning many rows, sortable columns"
  - "Card grid" - "More visual, good for fewer items with images"
  - "Simple list" - "Minimal, mobile-first approach"

### Step 6: Generate Component Structures

For each screen, generate implementation-ready JSX.

**Example: User List Screen with Table**

```tsx
"use client"

import { useState } from "react"
import { Plus, MoreHorizontal, Pencil, Trash } from "lucide-react"

import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"

interface User {
  id: string
  name: string
  email: string
  role: string
  avatar: string
  status: "active" | "inactive"
  initials: string
}

export function UserList() {
  const [users, setUsers] = useState<User[]>([])

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <div>
            <CardTitle>Team Members</CardTitle>
            <CardDescription>
              Manage your team and permissions
            </CardDescription>
          </div>
          <Dialog>
            <DialogTrigger asChild>
              <Button>
                <Plus className="mr-2 h-4 w-4" />
                Invite Member
              </Button>
            </DialogTrigger>
            <DialogContent>
              {/* Invite form - see Invite Modal section */}
            </DialogContent>
          </Dialog>
        </div>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>User</TableHead>
              <TableHead>Role</TableHead>
              <TableHead>Status</TableHead>
              <TableHead className="w-[50px]"></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {users.map((user) => (
              <TableRow
                key={user.id}
                className="cursor-pointer hover:bg-muted/50"
              >
                <TableCell>
                  <div className="flex items-center gap-3">
                    <Avatar className="h-8 w-8">
                      <AvatarImage src={user.avatar} alt={user.name} />
                      <AvatarFallback>{user.initials}</AvatarFallback>
                    </Avatar>
                    <div>
                      <p className="font-medium">{user.name}</p>
                      <p className="text-sm text-muted-foreground">
                        {user.email}
                      </p>
                    </div>
                  </div>
                </TableCell>
                <TableCell>
                  <Badge variant="secondary">{user.role}</Badge>
                </TableCell>
                <TableCell>
                  <Badge variant={user.status === "active" ? "default" : "outline"}>
                    {user.status}
                  </Badge>
                </TableCell>
                <TableCell>
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" size="icon">
                        <MoreHorizontal className="h-4 w-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                      <DropdownMenuItem>
                        <Pencil className="mr-2 h-4 w-4" />
                        Edit
                      </DropdownMenuItem>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem className="text-destructive">
                        <Trash className="mr-2 h-4 w-4" />
                        Delete
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  )
}
```

Generate structures for:
1. Main screen component
2. Empty state variant
3. Loading state variant
4. Error state variant
5. Modal/dialog components
6. Confirmation dialogs

### Step 7: Ask Clarifying Questions (When Needed)

Only ask when genuinely ambiguous. Maximum 3-5 questions per feature.

**Example questions**:

1. **Row actions presentation**:
   - Question: "How should row actions be displayed?"
   - Options: "DropdownMenu (⋮ icon)" vs "Inline buttons"

2. **Invite flow**:
   - Question: "What type of modal for inviting users?"
   - Options: "Dialog (centered modal)" vs "Sheet (side panel)"

3. **Empty state**:
   - Question: "Include empty state design?"
   - Options: "Yes - show when no users" vs "No - assume always has data"

### Step 8: Generate design.md

Create comprehensive design documentation using the template.

**Key sections to fill**:

1. **Overview**: Date, brand version, Figma URL
2. **Screens**: One section per screen with JSX code
3. **Components to Install**: Complete `npx shadcn@latest add` command
4. **States**: Loading, empty, error variants
5. **Design Decisions**: Rationale for component choices
6. **Responsive Behavior**: Breakpoint adjustments
7. **Accessibility**: Checklist and ARIA attributes
8. **Files to Create**: File structure with purposes

**Template replacements**:
- `[FEATURE_NAME]` → Feature name from directory
- `[DATE]` → Current date (YYYY-MM-DD)
- `[VERSION]` → Brand version from brand.yaml
- `[URL or N/A]` → Figma URL if generated, else "N/A"
- Fill all screen sections with generated JSX

### Step 9: Figma Integration (REQUIRED)

**Check for Figma MCP availability**:

Look for tools matching: `mcp__figma_*`

**If Figma MCP is available**:

1. Create new Figma file or use existing:
   - Tool: `mcp__figma_create_file` or similar
   - File name: `[Feature Name] - Design`

2. For each screen, create a frame:
   - Tool: `mcp__figma_create_frame`
   - Frame name: Screen name
   - Dimensions: 1440x900 (desktop), 375x667 (mobile)

3. Apply brand variables to components:
   - Load colors from `.specify/brand/brand.yaml`
   - Convert OKLCH to RGB for Figma:
     - Use `oklchToHex()` from color-conversion.ts
     - Extract hex values
   - Set Figma color variables:
     - Primary → brand primary color
     - Secondary → brand secondary color
     - Destructive → brand destructive color

4. Generate components based on shadcn/ui:
   - Card frames with rounded corners (radius from brand.yaml)
   - Button shapes with brand colors
   - Typography using Inter font
   - Icon placeholders from lucide-react set

5. Link Figma file in design.md:
   - Update `## Figma Design` section
   - Add file URL
   - List frame URLs for each screen

**If Figma MCP is NOT available**:

Display error with setup instructions:

```
⚠️  Figma MCP Required

This command requires Figma MCP integration to generate visual designs.

Setup instructions: .claude/docs/figma-mcp-setup.md

Or run without Figma:
  - Design documentation will still be generated
  - You'll have JSX code structures
  - Figma URL will be marked as "N/A"

Continue without Figma? [Y/n]
```

If user chooses "Y", proceed with documentation-only output.
If "n", exit and direct to Figma setup docs.

### Step 10: Refinement Support

After generating design.md, offer refinement:

```
━━━━━ ✓ Design Complete ━━━━━

Output: [design_file]

Screens designed:
  ✓ User List (Table layout)
  ✓ Invite Modal (Dialog)
  ✓ Empty State
  ✓ Delete Confirmation (AlertDialog)

Components to install:
  npx shadcn@latest add card table avatar badge button dialog dropdown-menu alert-dialog input label select

Figma: [URL or "Not generated - MCP not available"]

Refinements? (Enter to finish, or describe changes)
>
```

**Refinement examples**:

Input: `Use Sheet instead of Dialog for invite`
Action:
- Update design.md
- Replace all DialogContent with SheetContent
- Update component import list
- Adjust layout for side panel

Input: `Make table rows not clickable`
Action:
- Remove `cursor-pointer` class
- Remove `hover:bg-muted/50` class
- Update interaction description

Input: `Add search functionality`
Action:
- Add Input component to card header
- Add Command component for filtering
- Update component install list
- Generate search code structure

**Refinement mode**: `/speckit.design refine [description]`
- Load existing design.md
- Parse change request
- Update relevant sections
- Regenerate affected code blocks

### Step 11: Validation

Before saving design.md, validate:

1. **All screens from spec are covered**:
   - Check spec.md "UI Specifications" section
   - Ensure every listed screen has a design section

2. **Component install command is complete**:
   - Extract all component imports from JSX
   - Generate full `npx shadcn@latest add [list]` command
   - Deduplicate components

3. **Accessibility checklist items**:
   - Every interactive element has keyboard support
   - Icon buttons have aria-labels
   - Forms have associated labels

4. **Brand colors used correctly**:
   - No hardcoded colors (e.g., `bg-blue-500`)
   - All colors use CSS variables (e.g., `bg-primary`)

5. **Files to create list is accurate**:
   - Match component names to file paths
   - Follow project structure conventions

### Step 12: Summary Output

```
━━━━━ ✓ Design Complete ━━━━━

Feature: [FEATURE_NAME]
Output: [design_file]

Screens:
  ✓ [Screen 1 name] ([Component type])
  ✓ [Screen 2 name] ([Component type])
  ✓ [Screen 3 name] ([Component type])

Components to install:
  npx shadcn@latest add [full list]

Design patterns used:
  • Table layout for data lists
  • Dialog for focused tasks
  • AlertDialog for destructive actions
  • DropdownMenu for row actions

Figma:
  [✓ File created: [URL]] OR [⚠️  Not generated - MCP not available]

Accessibility:
  ✓ Keyboard navigation supported
  ✓ ARIA labels on icon buttons
  ✓ WCAG AA contrast ratios
  ✓ Semantic HTML elements

Files to create:
  1. [path/to/file.tsx]
  2. [path/to/component.tsx]
  [...]

Next: /speckit.plan to create technical implementation plan
```

---

## Refine Mode

**Usage**: `/speckit.design refine [description]`

**Example**: `/speckit.design refine Make the invite flow use a Sheet instead of Dialog`

**Process**:
1. Load existing design.md
2. Parse natural language change request
3. Identify affected sections (e.g., "Invite Modal" section)
4. Apply changes:
   - Update component names
   - Adjust JSX code
   - Update component install list
   - Regenerate affected Figma frames (if MCP available)
5. Display diff of changes
6. Save updated design.md

---

## Component Recommendation Rules

Use these rules to select appropriate shadcn/ui components:

### Data Display

| Pattern | Component | When to Use |
|---------|-----------|-------------|
| Tabular data (3+ columns) | Table | Many items, sortable, filterable |
| Items with rich content | Card grid | Images, varied content, < 20 items |
| Simple list | Card with list | Mobile-first, minimal data |
| Single item detail | Card | Focused view of one entity |

### Actions

| Pattern | Component | When to Use |
|---------|-----------|-------------|
| Primary action | Button (default) | Main action on screen |
| Secondary action | Button (outline) | Alternative actions |
| Destructive action | Button (destructive) | Delete, remove, danger |
| Row actions (3+) | DropdownMenu | Space-efficient, many options |
| Row actions (1-2) | Inline Buttons | Quick access, obvious actions |

### Modals & Overlays

| Pattern | Component | When to Use |
|---------|-----------|-------------|
| Focused task (< 5 fields) | Dialog | Blocking task, quick form |
| Complex form (> 5 fields) | Sheet | Multi-step, needs space |
| Confirmation | AlertDialog | Yes/no questions, destructive actions |
| Contextual info | Popover | Non-blocking info, tooltips |

### Feedback

| Pattern | Component | When to Use |
|---------|-----------|-------------|
| Success/error message | Toast (sonner) | Non-blocking feedback |
| Warning/info | Alert | Persistent message |
| Loading | Skeleton | Content is loading |
| Empty state | Custom Card | No data available |

### Forms

| Pattern | Component | When to Use |
|---------|-----------|-------------|
| Text input | Input | Single-line text |
| Multi-line text | Textarea | Long-form text |
| Selection (< 5 options) | RadioGroup | Mutually exclusive |
| Selection (> 5 options) | Select | Dropdown selection |
| Multiple selection | Checkbox group | Non-exclusive choices |

---

## Error Handling

**If spec.md has no UI Specifications section**:
```
⚠️  No UI Requirements Found

spec.md doesn't have a "UI Specifications" section.

Add UI requirements to spec.md or update with:
  /speckit.specify update Add UI section for [feature]

Or create a basic design anyway? [Y/n]
```

**If Figma MCP fails**:
```
⚠️  Figma Generation Failed

Error: [error message]

Design documentation has been generated successfully.
Figma integration skipped.

Troubleshooting: .claude/docs/figma-mcp-setup.md
```

**If design.md already exists**:
```
design.md already exists. Choose action:

1. Overwrite completely
2. Update specific sections
3. Create new version (design-v2.md)
4. Cancel

Choice [1-4]:
```

---

## Notes

- **OKLCH colors only**: Never use HSL. All brand colors are in OKLCH format.
- **Component-first**: Always recommend shadcn/ui components before custom solutions.
- **Copy-paste ready**: All JSX should be immediately usable in the codebase.
- **Accessibility by default**: Every design includes ARIA labels and keyboard navigation.
- **Mobile-first**: Consider responsive behavior for all screens.
- **Brand consistency**: Always reference CSS variables from globals.css.
- **Figma required**: This implementation requires Figma MCP. Error gracefully if unavailable.

---

## Testing Checklist

- [ ] Parses spec.md UI Specifications section correctly
- [ ] Recommends appropriate shadcn/ui components
- [ ] Generates valid, compilable JSX code
- [ ] Includes all component variants (loading, empty, error)
- [ ] Creates complete `npx shadcn add` command
- [ ] Figma MCP integration generates visual designs
- [ ] Figma file URL appears in design.md
- [ ] Refinement mode updates design.md correctly
- [ ] Accessibility checklist is comprehensive
- [ ] Design decisions include rationale
