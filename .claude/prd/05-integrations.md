# Third-Party Integrations

**Last Updated**: [Date]

This document defines all third-party service integrations, APIs, and external dependencies.

## Integrations Overview

| Service | Purpose | Required | Configuration |
|---------|---------|----------|---------------|
| Better Auth | Authentication | Yes | `src/auth.ts` |
| Polar | Payments/subscriptions | Optional | `src/lib/polar.ts` |
| PostHog | Analytics | Optional | `src/lib/posthog.ts` |
| [Service] | [Purpose] | [Yes/No] | [File] |

## Authentication: Better Auth

### Configuration

**File**: `src/auth.ts`

**Features**:
- Email/password authentication
- Google OAuth
- Session management
- Email verification

**Environment Variables**:
```env
# Better Auth
BETTER_AUTH_SECRET=<random-string>
BETTER_AUTH_URL=http://localhost:3000  # Production: https://yourdomain.com

# Google OAuth (optional)
GOOGLE_CLIENT_ID=<your-google-client-id>
GOOGLE_CLIENT_SECRET=<your-google-client-secret>
```

**Setup**:
```typescript
// src/auth.ts
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { db } from "@/db";

export const auth = betterAuth({
  database: drizzleAdapter(db, {
    provider: "pg",
  }),
  emailAndPassword: {
    enabled: true,
  },
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    },
  },
});
```

**Client Usage**:
```typescript
import { useSession, signIn, signOut } from "@/lib/auth-client";

// In component
const { data: session } = useSession();
```

**Customization**:
- [List any project-specific auth requirements]
- [Custom session duration, etc.]

---

## Payments: Polar

### Configuration

**File**: `src/lib/polar.ts`

**Features**:
- Subscription management
- Checkout flows
- Customer portal
- Webhook handling

**Environment Variables**:
```env
# Polar
POLAR_ACCESS_TOKEN=<your-polar-access-token>
POLAR_MODE=sandbox  # or production
```

**Setup**:
```typescript
import { Polar } from "@polar-sh/sdk";

export const polar = new Polar({
  accessToken: process.env.POLAR_ACCESS_TOKEN!,
  server: process.env.POLAR_MODE === "production" ? "production" : "sandbox",
});
```

**Client Usage**:
```typescript
import { checkout } from "@/lib/auth-client";

// Initiate checkout
const result = await checkout({
  priceId: "price_xxx",
});
```

**Webhook Handling**:
```typescript
// src/app/api/webhooks/polar/route.ts
import { polar } from "@/lib/polar";

export async function POST(request: Request) {
  const payload = await request.text();
  const signature = request.headers.get("polar-signature");

  // Verify and handle webhook
}
```

**Products & Pricing**:
- [List product IDs]
- [Pricing tiers]
- [Features per tier]

**Customization**:
- [Project-specific payment flows]
- [Trial period configuration]

---

## Analytics: PostHog

### Configuration

**Files**:
- `src/lib/posthog.ts` - Server-side client
- `src/components/PostHogProvider.tsx` - Client provider

**Environment Variables**:
```env
# PostHog
NEXT_PUBLIC_POSTHOG_KEY=<your-posthog-key>
NEXT_PUBLIC_POSTHOG_HOST=https://app.posthog.com
```

**Setup**:
```typescript
// src/lib/posthog.ts (server)
import { PostHog } from "posthog-node";

export const posthog = new PostHog(
  process.env.NEXT_PUBLIC_POSTHOG_KEY!,
  {
    host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
  }
);

// src/components/PostHogProvider.tsx (client)
"use client";

import posthog from "posthog-js";
import { PostHogProvider } from "posthog-js/react";

// Initialize and wrap app
```

**Event Tracking**:
```typescript
// Client-side
posthog.capture("event_name", { property: "value" });

// Server-side
posthog.capture({
  distinctId: userId,
  event: "event_name",
  properties: { property: "value" },
});
```

**Custom Events**:
- `user_signup` - When user creates account
- `email_verified` - When user verifies email
- `subscription_started` - When user subscribes
- [Add project-specific events]

**Feature Flags**:
```typescript
const isEnabled = posthog.isFeatureEnabled("feature-flag-key", userId);
```

**Customization**:
- [Specific events to track]
- [Feature flags to implement]
- [A/B tests to run]

---

## Email Service (Example)

### Configuration

**Service**: [Resend / SendGrid / AWS SES / Other]

**Environment Variables**:
```env
# Email
EMAIL_FROM=noreply@yourdomain.com
[SERVICE]_API_KEY=<your-api-key>
```

**Usage**:
```typescript
// src/lib/email.ts
import { Resend } from "resend";

const resend = new Resend(process.env.RESEND_API_KEY);

export async function sendVerificationEmail(email: string, token: string) {
  await resend.emails.send({
    from: process.env.EMAIL_FROM!,
    to: email,
    subject: "Verify your email",
    html: `<p>Click <a href="${verificationUrl}">here</a> to verify</p>`,
  });
}
```

**Email Templates**:
- Verification email
- Password reset
- Welcome email
- [Other templates]

---

## External APIs

### [API Name]

**Purpose**: [What this API is used for]

**Documentation**: [Link to API docs]

**Environment Variables**:
```env
[API_NAME]_API_KEY=<your-api-key>
[API_NAME]_BASE_URL=https://api.example.com
```

**Client Setup**:
```typescript
// src/lib/[api-name].ts
export const apiClient = {
  async get(endpoint: string) {
    const response = await fetch(
      `${process.env.API_BASE_URL}${endpoint}`,
      {
        headers: {
          Authorization: `Bearer ${process.env.API_KEY}`,
        },
      }
    );
    return response.json();
  },
};
```

**Rate Limiting**:
- [Limits and handling]

**Error Handling**:
- [How to handle API errors]

---

## Database: Neon PostgreSQL

### Configuration

**Service**: Neon Serverless PostgreSQL

**Environment Variables**:
```env
# Local development (in .env.local)
DATABASE_URL_DEV=postgresql://...   # For bun dev
DATABASE_URL_TEST=postgresql://...  # For E2E tests

# Deployed environments (set by Vercel)
DATABASE_URL=postgresql://...       # Auto-set per environment
```

**Branch Strategy**:
- Vercel production → Neon main branch
- Vercel preview → Neon preview branch
- Local/CI tests → Neon test branch

**Connection Pooling**:
```typescript
// src/db/index.ts
import { drizzle } from "drizzle-orm/neon-http";
import { neon } from "@neondatabase/serverless";

const sql = neon(process.env.DRIZZLE_DATABASE_URL!);
export const db = drizzle(sql);
```

**Migrations**:
```bash
# Generate migration
bun run db:generate

# Push to database
bun run db:push

# For production
bun run db:migrate
```

---

## File Storage (Example)

### Service: [AWS S3 / Cloudflare R2 / UploadThing]

**Purpose**: Store user uploads (avatars, documents, etc.)

**Environment Variables**:
```env
S3_BUCKET_NAME=your-bucket
S3_REGION=us-east-1
S3_ACCESS_KEY_ID=<your-access-key>
S3_SECRET_ACCESS_KEY=<your-secret-key>
```

**Upload Function**:
```typescript
// src/lib/storage.ts
export async function uploadFile(file: File) {
  // Upload logic
  return { url: "https://..." };
}
```

**URL Signing** (for private files):
```typescript
export async function getSignedUrl(key: string) {
  // Generate presigned URL
}
```

---

## Monitoring & Logging

### Error Tracking: [Sentry / LogRocket / Other]

**Environment Variables**:
```env
SENTRY_DSN=<your-sentry-dsn>
```

**Setup**:
```typescript
// src/lib/sentry.ts
import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
});
```

### Application Monitoring

- Response time tracking
- Error rate monitoring
- User session recording (if applicable)

---

## Rate Limiting & Security

### Rate Limiting Service

**Implementation**: [Upstash / Redis / In-memory]

```typescript
// src/lib/rate-limit.ts
export const rateLimit = {
  check: async (identifier: string, action: string) => {
    // Check rate limit
    return { success: boolean };
  },
};
```

### CORS Configuration

```typescript
// For API routes that need CORS
export async function OPTIONS(request: Request) {
  return new Response(null, {
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
    },
  });
}
```

---

## Environment Variable Validation

All environment variables are validated using `@t3-oss/env-nextjs`:

**Files**:
- `src/env/client.ts` - Client-side vars (NEXT_PUBLIC_*)
- `src/env/server.ts` - Server-side vars
- `src/env/db.ts` - Database vars

**Adding New Variables**:
```typescript
// src/env/server.ts
export const env = createEnv({
  server: {
    NEW_API_KEY: z.string().min(1),
  },
  runtimeEnv: {
    NEW_API_KEY: process.env.NEW_API_KEY,
  },
});
```

---

## Notes

[Additional context about integrations, API quotas, or important considerations]
