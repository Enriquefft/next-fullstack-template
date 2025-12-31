# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]  
**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]  
**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]  
**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]  
**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]
**Project Type**: [single/web/mobile - determines source structure]  
**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]  
**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]  
**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

[Gates determined based on constitution file]

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Design Integration *(include if feature has UI)*

<!--
  Include this section if the feature has user interface components.
  Links design.md artifacts to technical implementation.
-->

| Aspect | Decision |
|--------|----------|
| **Design Doc** | `.specify/specs/[###-feature]/design.md` |
| **Figma** | [URL or N/A] |
| **Component Library** | shadcn/ui |
| **Brand Config** | `.specify/brand/brand.yaml v[VERSION]` |

### UI Components Required

Install shadcn/ui components before implementation:

\`\`\`bash
# From design.md - install these components first
npx shadcn@latest add [component-list-from-design-md]
\`\`\`

*Example:*
\`\`\`bash
npx shadcn@latest add card table avatar badge button dialog dropdown-menu alert-dialog input label select
\`\`\`

### Component File Structure

Map design.md screens to implementation files:

| File | Purpose | From Design.md Section |
|------|---------|------------------------|
| `[path/to/file.tsx]` | [Component description] | [Screen name in design.md] |

*Example:*
| File | Purpose | From Design.md Section |
|------|---------|------------------------|
| `src/app/team/page.tsx` | Team member list screen | User List |
| `src/components/team/invite-dialog.tsx` | User invitation modal | Invite Modal |
| `src/components/team/user-row.tsx` | Table row component | User List > Table Structure |

### Design-Driven Implementation Order

Follow this sequence to ensure UI matches design:

1. **Install components** (see command above)
2. **Create file structure** (see table above)
3. **Implement screens** using JSX from design.md
4. **Add loading/empty/error states** from design.md variants
5. **Test accessibility** against design.md checklist
6. **Verify responsive behavior** per design.md breakpoints

### Brand Color Usage

Reference CSS variables from `.specify/brand/brand.yaml`:

| CSS Variable | Used For |
|--------------|----------|
| `--primary` | Primary buttons, links, focus rings |
| `--secondary` | Secondary buttons, muted UI elements |
| `--destructive` | Delete actions, error states |
| `--muted` | Subtle backgrounds, disabled states |
| `--border` | Borders, dividers |

**Important**: Never hardcode colors. Always use CSS variables to maintain brand consistency.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
