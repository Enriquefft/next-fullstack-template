# Design System Guide

This guide provides detailed implementation guidance for the Design System Principles defined in `.specify/memory/constitution.md`.

Referenced by: Constitution DS-1 through DS-5

---

## DS-1: Use shadcn/ui Components First

### Requirement

MUST use shadcn/ui components over custom implementations unless component doesn't exist in the library.

### Rationale

Ensures consistency, accessibility, and maintainability across the application. shadcn/ui components are battle-tested and follow best practices.

### Extension

Components may be extended via `className` prop and composition. Do NOT fork or modify shadcn/ui source code.

### Enforcement

Code reviews must verify that custom components have justification for not using shadcn/ui equivalents.

### When Custom Components Are Acceptable

- Component doesn't exist in shadcn/ui library
- shadcn/ui component cannot be extended to meet requirements
- Performance requirements necessitate custom implementation (must be documented)

---

## DS-2: Brand via CSS Variables

### Requirement

MUST use CSS variables from `globals.css` for all colors. NEVER hardcode color values in components.

### Color Format

Use OKLCH color space exclusively (NOT HSL or RGB).

### Semantic Tokens

Use these semantic tokens for consistent theming:

| Token | Usage |
|-------|-------|
| `--primary` | Main brand color, primary CTAs |
| `--secondary` | Muted actions, secondary buttons |
| `--destructive` | Errors, delete actions, warnings |
| `--muted` | Subtle backgrounds, disabled states |
| `--border` | Borders and dividers |
| `--background` / `--foreground` | Base colors for surfaces and text |
| `--accent` | Highlights, hover states |
| `--ring` | Focus rings, keyboard navigation indicators |

### Examples

#### ✓ CORRECT

```tsx
// Using semantic tokens with Tailwind classes
<Button className="bg-primary text-primary-foreground">
  Click me
</Button>

// Using muted for subtle backgrounds
<Card className="bg-muted/50">
  <CardContent>Subtle card</CardContent>
</Card>

// Using destructive for delete actions
<Button variant="destructive">
  Delete
</Button>
```

#### ✗ WRONG

```tsx
// Hardcoded Tailwind color classes
<Button className="bg-blue-500 text-white">
  Click me
</Button>

// Inline hex colors
<Button style={{ backgroundColor: "#2563EB" }}>
  Click me
</Button>

// RGB values
<div style={{ color: "rgb(37, 99, 235)" }}>
  Text
</div>
```

### Updating Brand Colors

All color changes must go through `/speckit.brand`. This command:
- Updates `globals.css` with new OKLCH values
- Validates WCAG AA contrast ratios
- Saves configuration to `.specify/brand/brand.yaml`

Never manually edit color values in `globals.css`.

### Enforcement

Linting rules prevent hardcoded colors. ESLint configuration includes:
- No hardcoded hex colors in className
- No RGB/HSL values in inline styles
- No Tailwind color utilities (blue-500, red-600, etc.)

---

## DS-3: Design Before Implementation

### Requirement

UI features MUST have `design.md` documentation before coding starts.

### Workflow

1. `/speckit.specify` - Create specification with UI Specifications section
2. `/speckit.design` - Generate design.md with component structures
3. `/speckit.plan` - Create technical plan referencing design.md
4. `/speckit.tasks` - Break down implementation with design.md file references
5. `/speckit.implement` - Execute using design.md JSX structures

### design.md Content Requirements

Every design.md must include:

#### 1. Component Structures
Copy-paste JSX with semantic HTML:
```tsx
<section aria-labelledby={headingId} data-testid="user-profile">
  <h2 id={headingId}>User Profile</h2>
  {/* ... */}
</section>
```

#### 2. shadcn/ui Install Commands
```bash
npx shadcn@latest add button card dialog
```

#### 3. Accessibility Checklist
- [ ] Keyboard navigation works (Tab, Enter, Escape, Arrow keys)
- [ ] Focus states visible on all interactive elements
- [ ] WCAG AA contrast ratios met (4.5:1 normal text, 3:1 large text)
- [ ] Touch targets ≥ 44px on mobile
- [ ] Semantic HTML used (`<button>`, `<nav>`, `<main>`, etc.)
- [ ] ARIA labels on icon-only buttons

#### 4. Responsive Behavior
- Mobile breakpoint behavior (< 768px)
- Tablet adjustments (768px - 1024px)
- Desktop layout (> 1024px)

#### 5. Design Decision Rationale
Why specific components were chosen, alternatives considered, trade-offs made.

### Enforcement

Pull requests for UI features must:
1. Link to design.md in PR description
2. Implementation must match design.md structures
3. Accessibility checklist must be completed
4. Screenshots/videos demonstrating responsive behavior

---

## DS-4: Consistent UI Patterns

### Pattern Selection Guide

#### Tables

**When to use**: Data lists with multiple columns, sortable data, bulk actions.

**Component**: `Table` from shadcn/ui

**Do NOT use**: Card grids unless mobile-first requirement exists.

**Example**:
```tsx
<Table>
  <TableHeader>
    <TableRow>
      <TableHead>Name</TableHead>
      <TableHead>Email</TableHead>
      <TableHead>Status</TableHead>
      <TableHead className="text-right">Actions</TableHead>
    </TableRow>
  </TableHeader>
  <TableBody>
    {users.map((user) => (
      <TableRow key={user.id}>
        <TableCell>{user.name}</TableCell>
        <TableCell>{user.email}</TableCell>
        <TableCell>{user.status}</TableCell>
        <TableCell className="text-right">
          <DropdownMenu>...</DropdownMenu>
        </TableCell>
      </TableRow>
    ))}
  </TableBody>
</Table>
```

#### Dialogs

**When to use**: Focused, blocking tasks with fewer than 5 form fields.

**Component**: `Dialog` from shadcn/ui

**Positioning**: Center on screen

**Example**:
```tsx
<Dialog>
  <DialogTrigger asChild>
    <Button>Add User</Button>
  </DialogTrigger>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>Add New User</DialogTitle>
      <DialogDescription>
        Enter user details below.
      </DialogDescription>
    </DialogHeader>
    <form>{/* 2-4 fields */}</form>
    <DialogFooter>
      <Button variant="outline">Cancel</Button>
      <Button type="submit">Save</Button>
    </DialogFooter>
  </DialogContent>
</Dialog>
```

#### Sheets

**When to use**: Complex forms with more than 5 fields, multi-step flows, detail views.

**Component**: `Sheet` from shadcn/ui

**Positioning**: Slides from right side

**Example**:
```tsx
<Sheet>
  <SheetTrigger asChild>
    <Button>Edit Profile</Button>
  </SheetTrigger>
  <SheetContent>
    <SheetHeader>
      <SheetTitle>Edit Profile</SheetTitle>
      <SheetDescription>
        Update your profile information.
      </SheetDescription>
    </SheetHeader>
    <form className="space-y-4">
      {/* 6+ fields or multi-step */}
    </form>
    <SheetFooter>
      <Button type="submit">Save Changes</Button>
    </SheetFooter>
  </SheetContent>
</Sheet>
```

#### AlertDialog

**When to use**: Destructive confirmations (delete, remove, irreversible actions).

**Component**: `AlertDialog` from shadcn/ui

**MUST use for**: Any action that permanently deletes or removes data.

**Example**:
```tsx
<AlertDialog>
  <AlertDialogTrigger asChild>
    <Button variant="destructive">Delete Account</Button>
  </AlertDialogTrigger>
  <AlertDialogContent>
    <AlertDialogHeader>
      <AlertDialogTitle>Are you absolutely sure?</AlertDialogTitle>
      <AlertDialogDescription>
        This action cannot be undone. This will permanently delete your
        account and remove your data from our servers.
      </AlertDialogDescription>
    </AlertDialogHeader>
    <AlertDialogFooter>
      <AlertDialogCancel>Cancel</AlertDialogCancel>
      <AlertDialogAction onClick={handleDelete}>
        Delete
      </AlertDialogAction>
    </AlertDialogFooter>
  </AlertDialogContent>
</AlertDialog>
```

#### DropdownMenu

**When to use**: Row/item actions when there are 3 or more actions.

**Component**: `DropdownMenu` from shadcn/ui

**Benefit**: Saves horizontal space in tables and cards.

**Example**:
```tsx
<DropdownMenu>
  <DropdownMenuTrigger asChild>
    <Button variant="ghost" size="icon">
      <MoreHorizontal className="h-4 w-4" />
    </Button>
  </DropdownMenuTrigger>
  <DropdownMenuContent align="end">
    <DropdownMenuItem>Edit</DropdownMenuItem>
    <DropdownMenuItem>Duplicate</DropdownMenuItem>
    <DropdownMenuSeparator />
    <DropdownMenuItem className="text-destructive">
      Delete
    </DropdownMenuItem>
  </DropdownMenuContent>
</DropdownMenu>
```

#### Toast

**When to use**: Non-blocking feedback messages (success, error notifications).

**Component**: `Toast` (Sonner) from shadcn/ui

**Duration**: 3-5 seconds for info, persistent for errors with dismiss option.

**Example**:
```tsx
import { toast } from "sonner";

// Success
toast.success("User created successfully");

// Error
toast.error("Failed to save changes", {
  description: "Please try again or contact support.",
  action: {
    label: "Retry",
    onClick: () => handleRetry(),
  },
});
```

### Rationale

Consistent patterns reduce cognitive load for users and developers. Users learn the interaction model once and apply it everywhere.

### Enforcement

Design reviews verify pattern usage. Deviations require explicit justification in design.md with user research or technical constraints documented.

---

## DS-5: Accessibility by Default

### Requirements

#### 1. Keyboard Navigation

MUST support keyboard navigation on all interactive elements.

**Key Bindings**:
- `Tab` / `Shift+Tab` - Move focus forward/backward
- `Enter` / `Space` - Activate buttons and links
- `Escape` - Close modals, dialogs, dropdowns
- `Arrow keys` - Navigate lists, menus, tabs

**Tab Order**:
- Must follow visual flow (left-to-right, top-to-bottom)
- Skip links for screen readers (`<a href="#main-content">Skip to content</a>`)
- Focus trapping in modals (focus stays within until closed)

**Testing**: Navigate entire feature using only keyboard before PR approval.

#### 2. Focus States

MUST provide visible focus states using `--ring` CSS variable.

**Requirements**:
- Focus rings use brand primary color
- Minimum 2px outline width
- High contrast against all backgrounds (meets WCAG AA)
- Offset from element for clarity

**Example**:
```tsx
// Tailwind classes automatically apply focus-visible:ring
<Button className="focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2">
  Click me
</Button>
```

**Testing**: Verify focus states in both light and dark mode.

#### 3. WCAG AA Color Contrast

MUST meet 4.5:1 contrast ratio for normal text, 3:1 for large text (18px+ or 14px+ bold).

**Validation**:
- Automatically validated during `/speckit.brand` configuration
- Warnings shown for low-contrast combinations
- Both light and dark mode must pass

**Tools**:
- Chrome DevTools Color Picker (shows contrast ratio)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- Lighthouse accessibility audit

**Common Issues**:
- Light gray text on white backgrounds
- Dark blue text on black backgrounds
- Insufficient contrast in dark mode

#### 4. Touch Targets

MUST provide touch targets ≥ 44px × 44px on mobile devices.

**Implementation**:
```tsx
// Add padding to meet minimum size
<Button size="icon" className="h-11 w-11 md:h-9 md:w-9">
  <Icon className="h-4 w-4" />
</Button>
```

**Spacing**:
- Adequate spacing between adjacent targets (≥ 8px)
- Avoid crowded action rows on mobile

**Testing**: Test on actual mobile device, not just desktop browser resize.

#### 5. Semantic HTML

MUST use semantic HTML elements for their intended purpose.

**Correct Usage**:
- `<button>` for actions (NOT `<div onclick>`)
- `<a>` for navigation (NOT `<button>` that navigates)
- `<nav>` for navigation sections
- `<main>` for main content area
- `<aside>` for sidebars
- `<header>` / `<footer>` for page sections
- `<form>` for forms with `<label>` elements
- `<article>` for self-contained content

**Example**:
```tsx
// ✓ CORRECT
<button onClick={handleSubmit} type="button">
  Submit
</button>

// ✗ WRONG
<div onClick={handleSubmit} className="button">
  Submit
</div>
```

#### 6. ARIA Labels

MUST provide ARIA labels for elements where text content isn't sufficient.

**Required Cases**:

**Icon-only buttons**:
```tsx
<Button variant="ghost" size="icon" aria-label="Close dialog">
  <X className="h-4 w-4" />
</Button>
```

**Complex interactions**:
```tsx
<button
  aria-expanded={isOpen}
  aria-controls="menu-id"
  onClick={toggleMenu}
>
  Menu
</button>
```

**Live regions** (dynamic updates):
```tsx
<div aria-live="polite" aria-atomic="true">
  {notificationCount} new messages
</div>
```

**Status messages**:
```tsx
<div role="status" aria-live="polite">
  Form submitted successfully
</div>

<div role="alert" aria-live="assertive">
  Error: Please fix the highlighted fields
</div>
```

**Landmarks**:
```tsx
// Use aria-labelledby for multiple landmarks of same type
const headingId = useId();

<section aria-labelledby={headingId}>
  <h2 id={headingId}>User Settings</h2>
  {/* ... */}
</section>
```

### Testing Checklist

Before PR approval, complete this accessibility checklist:

- [ ] Keyboard navigation works (tested using only keyboard)
- [ ] Focus states visible on all interactive elements
- [ ] Color contrast meets WCAG AA in both light and dark mode
- [ ] Touch targets ≥ 44px on mobile (tested on actual device)
- [ ] Semantic HTML used (no `<div>` buttons or `<button>` links)
- [ ] ARIA labels present on icon-only buttons
- [ ] Screen reader tested (macOS VoiceOver, NVDA, or JAWS)
- [ ] Lighthouse accessibility score ≥ 90

### Tools

**Browser DevTools**:
- Chrome DevTools Accessibility Inspector
- Firefox Accessibility Inspector
- Color contrast ratio checker

**Screen Readers**:
- macOS: VoiceOver (Cmd+F5)
- Windows: NVDA (free, open-source)
- Windows: JAWS (commercial)

**Automated Testing**:
- Lighthouse (built into Chrome DevTools)
- axe DevTools (browser extension)
- E2E keyboard navigation tests in Playwright

### Enforcement

- E2E tests MUST include keyboard navigation tests
- Manual accessibility review required for new UI components
- Lighthouse accessibility score must be ≥ 90 in CI/CD
- Pull requests must include completed accessibility checklist

---

## Additional Resources

- [shadcn/ui Documentation](https://ui.shadcn.com/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [WebAIM Resources](https://webaim.org/resources/)
- [OKLCH Color Picker](https://oklch.com/)
- [Tailwind CSS v4 Documentation](https://tailwindcss.com/docs)

---

**Last Updated**: 2025-12-31
