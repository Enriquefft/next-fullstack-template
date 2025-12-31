<!--
  CONSTITUTION TEMPLATE STRUCTURE

  This file follows the spec-kit constitution pattern with both PRE-FILLED and TEMPLATE sections.

  PRE-FILLED SECTIONS (template defaults - included in every project):
    • Design System Principles (DS-1 through DS-5)
      Template-specific governance for shadcn/ui, OKLCH colors, and Tailwind CSS.
      These define HOW this Next.js fullstack template handles UI/UX design.

  TEMPLATE SECTIONS (fill via /speckit.constitution):
    • [PROJECT_NAME] - Your project's name
    • Core Principles (PRINCIPLE_1 through PRINCIPLE_5) - Your project's architectural rules
    • Additional Sections (SECTION_2, SECTION_3) - Domain-specific governance
    • Governance - Amendment procedures, versioning, compliance

  USAGE:
    Run `/speckit.constitution` to fill template placeholders with project-specific values.
    Pre-filled sections remain unchanged unless modifying template defaults.

  GUIDELINE:
    Keep constitution concise (~50-80 lines). Principles define WHAT we always do.
    Move detailed HOW-TO guidance to separate docs (see .claude/docs/).

  Based on: github.com/github/spec-kit/blob/main/memory/constitution.md
-->

# [PROJECT_NAME] Constitution
<!-- Example: Spec Constitution, TaskFlow Constitution, etc. -->

## Core Principles

### [PRINCIPLE_1_NAME]
<!-- Example: I. Library-First -->
[PRINCIPLE_1_DESCRIPTION]
<!-- Example: Every feature starts as a standalone library; Libraries must be self-contained, independently testable, documented; Clear purpose required - no organizational-only libraries -->

### [PRINCIPLE_2_NAME]
<!-- Example: II. CLI Interface -->
[PRINCIPLE_2_DESCRIPTION]
<!-- Example: Every library exposes functionality via CLI; Text in/out protocol: stdin/args → stdout, errors → stderr; Support JSON + human-readable formats -->

### [PRINCIPLE_3_NAME]
<!-- Example: III. Test-First (NON-NEGOTIABLE) -->
[PRINCIPLE_3_DESCRIPTION]
<!-- Example: TDD mandatory: Tests written → User approved → Tests fail → Then implement; Red-Green-Refactor cycle strictly enforced -->

### [PRINCIPLE_4_NAME]
<!-- Example: IV. Integration Testing -->
[PRINCIPLE_4_DESCRIPTION]
<!-- Example: Focus areas requiring integration tests: New library contract tests, Contract changes, Inter-service communication, Shared schemas -->

### [PRINCIPLE_5_NAME]
<!-- Example: V. Observability, VI. Versioning & Breaking Changes, VII. Simplicity -->
[PRINCIPLE_5_DESCRIPTION]
<!-- Example: Text I/O ensures debuggability; Structured logging required; Or: MAJOR.MINOR.BUILD format; Or: Start simple, YAGNI principles -->

## [SECTION_2_NAME]
<!-- Example: Additional Constraints, Security Requirements, Performance Standards, etc. -->

[SECTION_2_CONTENT]
<!-- Example: Technology stack requirements, compliance standards, deployment policies, etc. -->

## [SECTION_3_NAME]
<!-- Example: Development Workflow, Review Process, Quality Gates, etc. -->

[SECTION_3_CONTENT]
<!-- Example: Code review requirements, testing gates, deployment approval process, etc. -->

## Design System Principles

### DS-1: Component Library First

shadcn/ui components MUST be used unless component doesn't exist in the library. Custom implementations require explicit justification in design.md. Components may be extended via `className` prop and composition but source code must not be modified.

### DS-2: CSS Variables Only

All colors MUST use CSS variables from `globals.css` in OKLCH format. Hardcoded colors (hex, RGB, HSL) and Tailwind color utilities (blue-500, red-600) are prohibited. Color changes MUST go through `/speckit.brand` command.

### DS-5: WCAG AA Accessibility

All UI MUST meet WCAG AA standards: keyboard navigation support, visible focus states with `--ring` variable, 4.5:1 contrast ratio for normal text, touch targets ≥ 44px on mobile, semantic HTML elements, ARIA labels on icon-only buttons. E2E tests must include keyboard navigation. Lighthouse score must be ≥ 90.

**Detailed implementation guidance**: See `.claude/docs/design-system-guide.md`

---

## Governance
<!-- Example: Constitution supersedes all other practices; Amendments require documentation, approval, migration plan -->

[GOVERNANCE_RULES]
<!-- Example: All PRs/reviews must verify compliance; Complexity must be justified; Use [GUIDANCE_FILE] for runtime development guidance -->

**Version**: [CONSTITUTION_VERSION] | **Ratified**: [RATIFICATION_DATE] | **Last Amended**: [LAST_AMENDED_DATE]
<!-- Example: Version: 2.1.1 | Ratified: 2025-06-13 | Last Amended: 2025-07-16 -->
