# UI Components & Pages

**Last Updated**: [Date]

This document defines all pages, components, layouts, and UI/UX specifications for the project.

## Design System

**Framework**: Next.js 15 with App Router
**Styling**: Tailwind CSS v4 + shadcn/ui components
**Forms**: TanStack Form with Zod validation
**Theme**: Dark mode support via `next-themes`

## Page Routes

| Route | Purpose | Related Flows | Authentication |
|-------|---------|---------------|----------------|
| `/` | Home/landing page | - | Public |
| `/signup` | User registration | `auth/signup-flows.md` | Public only |
| `/login` | User login | `auth/login-flows.md` | Public only |
| `/dashboard` | User dashboard | - | Required |
| `[/route]` | [Purpose] | [Flow] | [Public/Required/Optional] |

## Component Hierarchy

```
app/
├── layout.tsx                 # Root layout with providers
├── page.tsx                   # Home page
├── (auth)/                    # Auth route group
│   ├── layout.tsx            # Auth-specific layout
│   ├── signup/
│   │   └── page.tsx          # Signup page
│   └── login/
│       └── page.tsx          # Login page
└── (dashboard)/              # Protected route group
    ├── layout.tsx            # Dashboard layout with nav
    └── dashboard/
        └── page.tsx          # Dashboard page

components/
├── ui/                       # shadcn/ui primitives (don't modify)
│   ├── button.tsx
│   ├── input.tsx
│   └── ...
├── forms/
│   ├── SignUpForm.tsx        # Signup form component
│   ├── SignInForm.tsx        # Login form component
│   └── [FeatureForm].tsx     # Feature-specific forms
├── layout/
│   ├── Header.tsx            # Site header/nav
│   ├── Footer.tsx            # Site footer
│   └── Sidebar.tsx           # Dashboard sidebar
└── features/
    └── [feature]/
        ├── [Feature]Card.tsx
        └── [Feature]List.tsx
```

## Page Specifications

### [Page Name]

**Route**: `/[route]`

**Purpose**: [What this page does]

**Related Flow**: `[flow-file].md` → [Flow name]

**Authentication**: [Public / Required / Optional]

**Layout**: [Which layout it uses]

**Key Components**:
- [Component 1]
- [Component 2]

**Data Loading**:
```typescript
// Server Component (preferred)
import { db } from "@/db";

export default async function [PageName]() {
  const data = await db.query.[table].findMany();

  return <div>{/* Render data */}</div>;
}
```

**SEO Metadata**:
```typescript
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "[Page Title]",
  description: "[Page Description]",
};
```

---

## Form Components

### [Form Name]

**Purpose**: [What this form does]

**Related Flow**: `[flow-file].md` → [Flow name]

**File**: `src/components/forms/[FormName].tsx`

**Fields**:
- `field1`: [Type, validation rules]
- `field2`: [Type, validation rules]

**Validation Schema**:
```typescript
import { z } from "zod";

const [formName]Schema = z.object({
  field1: z.string().min(3).max(100),
  field2: z.string().email(),
});
```

**Implementation**:
```typescript
"use client";

import { useForm } from "@tanstack/react-form";
import { zodValidator } from "@tanstack/zod-form-adapter";
import { Field } from "@/components/ui/field";
import { Button } from "@/components/ui/button";
import { [serverAction] } from "@/app/actions/[domain]";

export function [FormName]() {
  const form = useForm({
    defaultValues: {
      field1: "",
      field2: "",
    },
    validatorAdapter: zodValidator(),
    onSubmit: async ({ value }) => {
      const formData = new FormData();
      formData.append("field1", value.field1);
      formData.append("field2", value.field2);

      const result = await [serverAction](formData);

      if (!result.success) {
        // Handle error
      }
    },
  });

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault();
        form.handleSubmit();
      }}
    >
      <form.Field name="field1">
        {(field) => (
          <Field
            label="Field 1"
            error={field.state.meta.errors?.[0]}
          >
            <input
              value={field.state.value}
              onChange={(e) => field.handleChange(e.target.value)}
            />
          </Field>
        )}
      </form.Field>

      <Button type="submit">Submit</Button>
    </form>
  );
}
```

**Error Handling**:
- [How errors are displayed]
- [Field-level vs form-level errors]

**Loading States**:
- [Show spinner, disable button, etc.]

**Success States**:
- [Toast notification, redirect, etc.]

---

## Reusable Components

### [Component Name]

**Purpose**: [What this component does]

**Props**:
```typescript
interface [ComponentName]Props {
  prop1: string;
  prop2?: number;
  onAction?: () => void;
}
```

**Usage**:
```typescript
<[ComponentName] prop1="value" prop2={123} onAction={() => {}} />
```

**Variants**: [List different visual variants if applicable]

---

## Layout Components

### Root Layout

**File**: `src/app/layout.tsx`

**Providers**:
- `ThemeProvider` - Dark mode support
- `PostHogProvider` - Analytics (if using)
- [Other providers]

**Global Elements**:
- Metadata configuration
- Font definitions
- Global CSS imports

### Dashboard Layout

**File**: `src/app/(dashboard)/layout.tsx`

**Features**:
- Sidebar navigation
- User menu
- Logout button
- Protected route (checks authentication)

---

## Styling Patterns

### Tailwind Utility Classes

```typescript
// Button styles
className="rounded-lg bg-primary px-4 py-2 text-white hover:bg-primary/90"

// Card styles
className="rounded-lg border bg-card p-6 shadow-sm"

// Form field
className="rounded-md border border-input bg-background px-3 py-2"
```

### Dark Mode

```typescript
// Light and dark variants
className="bg-white dark:bg-gray-900 text-black dark:text-white"
```

### Responsive Design

```typescript
// Mobile-first approach
className="text-sm md:text-base lg:text-lg"
className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3"
```

### Using cn() Utility

```typescript
import { cn } from "@/lib/utils";

className={cn(
  "base-classes",
  isActive && "active-classes",
  isError && "error-classes"
)}
```

---

## Accessibility

### ARIA Labels

```tsx
<button aria-label="Close dialog">×</button>
<input aria-describedby="email-error" />
<div id="email-error" role="alert">{error}</div>
```

### Keyboard Navigation

- All interactive elements must be keyboard accessible
- Use proper focus management
- Implement focus trapping in modals

### Screen Readers

- Use semantic HTML (`<nav>`, `<main>`, `<article>`)
- Provide text alternatives for images
- Use proper heading hierarchy

---

## Loading States

### Page-Level Loading

```typescript
// app/[route]/loading.tsx
export default function Loading() {
  return <div>Loading...</div>;
}
```

### Component-Level Loading

```typescript
{isLoading ? <Spinner /> : <Content />}
```

### Skeleton Screens

Use for better UX during data loading:

```typescript
<div className="animate-pulse space-y-4">
  <div className="h-4 bg-gray-200 rounded w-3/4"></div>
  <div className="h-4 bg-gray-200 rounded w-1/2"></div>
</div>
```

---

## Error States

### Error Boundaries

```typescript
// app/[route]/error.tsx
"use client";

export default function Error({
  error,
  reset,
}: {
  error: Error;
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

### Form Errors

- Show field-level errors below inputs
- Show form-level errors at top of form
- Use red text and icons for errors
- Provide clear, actionable error messages

---

## Responsive Design

### Breakpoints

- `sm`: 640px
- `md`: 768px
- `lg`: 1024px
- `xl`: 1280px
- `2xl`: 1536px

### Mobile-First Approach

```typescript
// Default styles for mobile
className="text-sm px-2"

// Larger screens
className="md:text-base md:px-4 lg:text-lg lg:px-6"
```

---

## Performance Optimizations

### Image Optimization

```typescript
import Image from "next/image";

<Image
  src="/image.jpg"
  alt="Description"
  width={500}
  height={300}
  priority // For above-the-fold images
/>
```

### Code Splitting

```typescript
import dynamic from "next/dynamic";

const HeavyComponent = dynamic(() => import("./HeavyComponent"), {
  loading: () => <Spinner />,
});
```

### Client vs Server Components

- **Use Server Components** by default for data fetching
- **Use Client Components** ("use client") only when needed:
  - Event handlers (onClick, onChange)
  - State (useState, useReducer)
  - Effects (useEffect)
  - Browser APIs

---

## Notes

[Additional context about UI/UX patterns, design decisions, or important considerations]
