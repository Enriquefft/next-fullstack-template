# /speckit.design

## Purpose
Generate implementation-ready design constraints from spec.

## Input
- specs/{feature}/spec.md

## Process
1. Read spec.md
2. Identify all screens from user stories
3. For each screen:
   - Define layout (Tailwind classes)
   - List components needed
   - Define all states
4. For each component:
   - Provide exact JSX with Tailwind classes
   - Show all variants (default, loading, error, disabled)
5. Reference shadcn/ui components by name
6. Use project's CSS variables for colors

## Output
specs/{feature}/design.md containing:
- Screen inventory with layouts
- Component code snippets
- State definitions
- Spacing/layout classes

## Constraints (from constitution)
- Components: shadcn/ui only
- Styling: Tailwind CSS
- Icons: lucide-react
- Colors: CSS variables (--primary, --secondary, etc.)
- Spacing: 4px grid (p-1, p-2, p-4, p-6, p-8)
- Responsive: Mobile-first (default, sm:, md:, lg:)
