# API Design & Server Actions

**Last Updated**: [Date]

This document defines all server actions, API routes, and backend logic for the project.

## Design Philosophy

**IMPORTANT**: This template **prefers Server Actions over API routes** for:
- Form submissions
- Data mutations
- Server-side logic called from client components

**Reserve API routes** only for:
- External webhooks (Stripe, third-party services)
- Public REST endpoints
- OAuth callbacks

## Server Actions Overview

| Action Name | Purpose | Related Flows | File Location |
|-------------|---------|---------------|---------------|
| `signUp()` | Create new user account | `auth/signup-flows.md` | `src/app/actions/auth.ts` |
| `signIn()` | Authenticate user | `auth/login-flows.md` | `src/app/actions/auth.ts` |
| [Action] | [Purpose] | [Flow] | [File] |

## Server Action Template

### [Action Name]

**Purpose**: [What this action does]

**Related Flow**: `[flow-file].md` → [Flow name]

**File**: `src/app/actions/[domain].ts`

**Signature**:
```typescript
"use server";

import { db } from "@/db";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { z } from "zod";

// Input validation schema
const [actionName]Schema = z.object({
  field1: z.string().min(3).max(100),
  field2: z.number().int().positive(),
});

export async function [actionName](
  formData: FormData
): Promise<{ success: boolean; error?: string; data?: any }> {
  // 1. Parse and validate input
  const rawData = {
    field1: formData.get("field1") as string,
    field2: Number(formData.get("field2")),
  };

  const validation = [actionName]Schema.safeParse(rawData);
  if (!validation.success) {
    return {
      success: false,
      error: validation.error.issues[0].message,
    };
  }

  const { field1, field2 } = validation.data;

  try {
    // 2. Check authentication (if needed)
    // const session = await getSession();
    // if (!session) {
    //   return { success: false, error: "Unauthorized" };
    // }

    // 3. Business logic and database operations
    const result = await db
      .insert([table])
      .values({
        field1,
        field2,
      })
      .returning();

    // 4. Revalidate cache if needed
    revalidatePath("/[relevant-path]");

    // 5. Return success response
    return {
      success: true,
      data: result[0],
    };
  } catch (error) {
    console.error("[actionName] error:", error);
    return {
      success: false,
      error: "Something went wrong. Please try again.",
    };
  }
}
```

**Validation Rules**:
- `field1`: [Constraints]
- `field2`: [Constraints]

**Authentication**: [Required / Optional / None]

**Database Operations**:
- [Describe what tables are affected]

**Error Handling**:
- [List possible errors and how they're handled]

**Cache Invalidation**:
- Revalidates: `[paths that need revalidation]`

---

## Example: Authentication Server Actions

### `signUp()`

**File**: `src/app/actions/auth.ts`

```typescript
"use server";

import { db } from "@/db";
import { user } from "@/db/schema";
import { hash } from "bcrypt";
import { z } from "zod";
import { redirect } from "next/navigation";

const signUpSchema = z.object({
  email: z.string().email("Please enter a valid email address"),
  password: z
    .string()
    .min(8, "Password must be at least 8 characters")
    .regex(/[A-Z]/, "Password must contain an uppercase letter")
    .regex(/[a-z]/, "Password must contain a lowercase letter")
    .regex(/[0-9]/, "Password must contain a number"),
});

export async function signUp(formData: FormData) {
  // Validation
  const validation = signUpSchema.safeParse({
    email: formData.get("email"),
    password: formData.get("password"),
  });

  if (!validation.success) {
    return {
      success: false,
      error: validation.error.issues[0].message,
    };
  }

  const { email, password } = validation.data;

  try {
    // Check if user already exists
    const existingUser = await db.query.user.findFirst({
      where: (user, { eq }) => eq(user.email, email),
    });

    if (existingUser) {
      return {
        success: false,
        error: "This email is already registered",
      };
    }

    // Hash password
    const hashedPassword = await hash(password, 10);

    // Create user
    await db.insert(user).values({
      id: crypto.randomUUID(),
      email,
      password: hashedPassword,
      emailVerified: false,
    });

    // TODO: Send verification email
    // TODO: Create session

    // Redirect to verification page
    redirect("/verify-email");
  } catch (error) {
    console.error("Signup error:", error);
    return {
      success: false,
      error: "Something went wrong. Please try again.",
    };
  }
}
```

---

## API Routes

### When to Use API Routes

Use API routes (`src/app/api/[route]/route.ts`) only for:

1. **Webhooks**: External services calling your app
2. **OAuth Callbacks**: Third-party authentication
3. **Public APIs**: REST endpoints for external consumption
4. **File Uploads**: Handling multipart/form-data
5. **Streaming Responses**: Server-Sent Events, streaming data

### API Route Template

```typescript
import { NextRequest, NextResponse } from "next/server";
import { db } from "@/db";

export async function POST(request: NextRequest) {
  try {
    // 1. Parse request body
    const body = await request.json();

    // 2. Validate input
    // Use Zod schema

    // 3. Authenticate if needed
    // Check headers, session, API key

    // 4. Business logic

    // 5. Return response
    return NextResponse.json(
      { success: true, data: {} },
      { status: 200 }
    );
  } catch (error) {
    console.error("API error:", error);
    return NextResponse.json(
      { success: false, error: "Internal server error" },
      { status: 500 }
    );
  }
}
```

---

## Validation Patterns

### Zod Schemas

All server actions should use Zod for input validation:

```typescript
import { z } from "zod";

// Reusable field validators
const emailValidator = z.string().email();
const passwordValidator = z
  .string()
  .min(8)
  .regex(/[A-Z]/)
  .regex(/[a-z]/)
  .regex(/[0-9]/);

// Compose schemas
const signUpSchema = z.object({
  email: emailValidator,
  password: passwordValidator,
});
```

### Common Validators

```typescript
// Email
z.string().email()

// URL
z.string().url()

// Phone
z.string().regex(/^\+?[1-9]\d{1,14}$/)

// UUID
z.string().uuid()

// Enum
z.enum(["option1", "option2", "option3"])

// Optional with default
z.string().optional().default("default value")

// Transformations
z.string().transform((val) => val.toLowerCase())

// Refinements (custom validation)
z.string().refine((val) => val.length > 0, "Cannot be empty")
```

---

## Error Handling

### Standard Error Response Format

```typescript
type ActionResult<T> =
  | { success: true; data: T }
  | { success: false; error: string };
```

### Error Types

1. **Validation Errors**: Return specific field errors
2. **Authentication Errors**: Return "Unauthorized"
3. **Not Found Errors**: Return "Resource not found"
4. **Database Errors**: Return generic "Something went wrong"
5. **Rate Limit Errors**: Return "Too many requests"

### Error Logging

```typescript
import { logger } from "@/lib/logger"; // If using a logger

try {
  // ...
} catch (error) {
  logger.error("Action error", {
    action: "[actionName]",
    error: error instanceof Error ? error.message : "Unknown error",
    userId: session?.user.id,
  });

  return {
    success: false,
    error: "Something went wrong. Please try again.",
  };
}
```

---

## Authentication & Authorization

### Checking Authentication

```typescript
import { auth } from "@/auth";

export async function protectedAction() {
  const session = await auth();

  if (!session) {
    return { success: false, error: "Unauthorized" };
  }

  // Action logic with session.user.id
}
```

### Role-Based Access Control

```typescript
if (session.user.role !== "admin") {
  return { success: false, error: "Forbidden" };
}
```

---

## Rate Limiting

Consider implementing rate limiting for actions:

```typescript
import { rateLimit } from "@/lib/rate-limit";

export async function publicAction(formData: FormData) {
  const ip = headers().get("x-forwarded-for") ?? "127.0.0.1";

  const { success } = await rateLimit.check(ip, "publicAction");

  if (!success) {
    return { success: false, error: "Too many requests. Try again later." };
  }

  // Action logic
}
```

---

## Testing Server Actions

### Unit Test Example

```typescript
// tests/actions/auth.test.ts
import { describe, it, expect, beforeEach } from "bun:test";
import { signUp } from "@/app/actions/auth";

describe("signUp", () => {
  beforeEach(() => {
    // Setup test database
  });

  it("creates user with valid input", async () => {
    const formData = new FormData();
    formData.append("email", "test@example.com");
    formData.append("password", "Test123!");

    const result = await signUp(formData);

    expect(result.success).toBe(true);
  });

  it("returns error for duplicate email", async () => {
    // Create user first
    // Try to create again
    // Expect error
  });
});
```

---

## Notes

[Additional context about API design patterns, conventions, or important considerations for this project]
