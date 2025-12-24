# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**For new projects**: Run `/implement-prd` to customize this template based on your requirements. See "PRD-Based Development Workflow" below.

**Additional context-specific rules** are in `.claude/rules/` and load automatically based on file paths.

**Product requirements and user flows** are documented in `.claude/prd/` for feature specifications and implementation planning.

## Development Commands

**Package Manager**: This project uses **Bun**. Always use `bun` instead of `npm` or `yarn`.

**Most Frequently Used:**
- `bun dev` – Start development server on port 3000
- `bun run build` – Build for production
- `bun lint` – Lint and format code with Biome
- `bun test` – Run unit tests with Happy DOM
- `bun run test:e2e` – Run end-to-end tests with Playwright
- `bun type` – Type-check without emitting files
- `bun run db:push` – Push Drizzle schema changes to database

**Testing Overview:**
- **Unit tests**: Configured with Happy DOM (preloaded via `bunfig.toml`). Test files live in `tests/` and use `.test.ts` or `.test.tsx` extensions. Run with `bun test`.
- **E2E tests**: Powered by Playwright (config in `e2e/playwright.config.ts`). Test files live in `e2e/tests/` and use `.spec.ts` extensions. Run with `bun run test:e2e`. Override port with `PORT=3001 bun test:e2e` if needed. See `.claude/rules/e2e-testing.md` for detailed documentation.

**Planning & Implementation:**
- **PRD workflow**: Use `/implement-prd` to scaffold from `.claude/prd/` requirements, then `/next-step` for incremental feature development
- **Test-driven**: Each feature requires unit tests and E2E tests matching PRD flows before moving to next feature
- **Plan tracking**: `plan.md` (auto-generated) tracks phases → steps → tasks with explicit test requirements

## Architecture Overview

### Database Architecture

This project uses a **multi-environment database architecture** with automatic environment selection:

**Environment Selection Logic** (`src/env/db.ts`):
1. **Production/Deployment**: Set `DATABASE_URL` environment variable (Vercel, Railway, etc.)
2. **Local Development**: Uses environment-specific URLs based on `NODE_ENV`:
   - `NODE_ENV=development` → `DATABASE_URL_DEV`
   - `NODE_ENV=test` → `DATABASE_URL_TEST`
   - `NODE_ENV=production` → `DATABASE_URL_PROD`

**Configuration**:
- All database URLs are defined in `.env` file
- Validation ensures either `DATABASE_URL` OR the appropriate `DATABASE_URL_{ENV}` is set
- Application code (`src/db/index.ts`) imports `databaseUrl` from `src/env/db.ts`
- No manual script injection required—automatic selection via `NODE_ENV`

**Example `.env` setup**:
```env
# Local development databases (for different environments)
DATABASE_URL_DEV='postgresql://...'
DATABASE_URL_TEST='postgresql://...'
DATABASE_URL_STAGING='postgresql://...'
DATABASE_URL_PROD='postgresql://...'

# Optional: Override for production deployment (Vercel sets this)
# DATABASE_URL='postgresql://...'
```

**Infrastructure**:
- Uses **Neon Serverless** PostgreSQL (separate branches per environment)
- No Docker or local PostgreSQL required—Neon branches are always available
- E2E tests automatically use `DATABASE_URL_TEST` via `NODE_ENV=test`

**For detailed E2E testing guide**, see `.claude/rules/e2e-testing.md` (loads automatically when working in `e2e/`).

### Authentication System

Authentication is handled by **Better Auth** with **Polar** integration for payment/subscription features.

- Uses Drizzle adapter with PostgreSQL for session storage
- Google OAuth configured via `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`
- Polar integration for checkout and customer portal (configured via `POLAR_ACCESS_TOKEN` and `POLAR_MODE`)

### Next.js Patterns

**IMPORTANT**: Prefer **Server Actions** and **Server Components** over API routes for data mutations and fetching.

- **Server Actions**: Use for form submissions, mutations, and server-side logic called from client components
- **Server Components**: Default for data fetching; they run on the server and can directly access the database
- **API Routes**: Reserve for external webhooks, third-party integrations, or when you need a public REST endpoint. Server Actions & Server Components are prefered.

Server Actions / Server Components provide better type safety, automatic request deduplication, and simpler data flow compared to API routes.

### Forms

Uses **TanStack Form** (`@tanstack/react-form`) with **Field** components from `src/components/ui/field.tsx`.

- **Validation**: Zod schemas via `@tanstack/zod-form-adapter` and `zodValidator()`
- **Pattern**: `useForm()` hook with `validatorAdapter`, render fields with `<form.Field>` children function
- **Examples**: See `src/components/form-example.tsx` and `src/components/AddressAutocomplete.tsx`

### Database Layer

Uses **Drizzle ORM** with **Neon Serverless** driver for PostgreSQL.

- **Connection**: `src/db/index.ts` exports `db` instance using `databaseUrl` from `src/env/db.ts`
- **Schema organization**: All schemas live in `src/db/schema/` directory
  - `schema.ts` creates the base schema using `pgSchema(env.NEXT_PUBLIC_PROJECT_NAME)` – this means all tables are namespaced by project name
  - `index.ts` re-exports all schemas for convenient imports
  - `auth.ts` contains Better Auth tables (user, session, account, verification)
  - `post.ts` is an example schema file
- **Schema filter**: `drizzle.config.ts` uses `schemaFilter` to isolate this project's tables by `NEXT_PUBLIC_PROJECT_NAME`
- **Important**: When creating new tables, always use the `schema` object from `schema.ts`, not `pgSchema` directly

### Environment Variables

Type-safe environment validation using **@t3-oss/env-nextjs** in `src/env/[client|server|db].ts`.

- **Client vars** (prefixed with `NEXT_PUBLIC_`): Available in browser
- **Server vars**: Backend-only, validated at build time
- **Database URLs**: See "Database Architecture" section above for details on multi-environment setup

### Code Organization

- `src/app/` – Next.js 15 App Router pages and routes
- `src/components/` – React components
  - `ui/` – shadcn/ui primitives (excluded from Biome linting)
  - Root level: Custom components like `sign-in.tsx`, `ProductCard.tsx`, theme provider
- `src/db/` – Database client and schemas
- `src/lib/` – Utilities (`utils.ts`, `auth-client.ts`, `posthog.ts`, `polar.ts`, `handle-error.ts`)
- `src/hooks/` – Custom React hooks (e.g., `use-google-places.tsx`, `use-mobile.tsx`)
- `src/styles/` – Global CSS and fonts
- `src/metadata.ts` – Centralized Next.js metadata (title, description, OG images)
- `tests/` – Unit tests (Happy DOM)
- `e2e/` – End-to-end tests (Playwright)
  - `setup/` – Global setup/teardown and database utilities
  - `helpers/` – Auth, database, and fixture helpers
  - `fixtures/` – Seed data definitions
  - `tests/` – Test files (*.spec.ts)
  - `playwright.config.ts` – Playwright configuration

### Styling System

- **Tailwind CSS v4** with **shadcn/ui** components
- **Global styles**: `src/styles/` directory
- **Theme**: Dark mode support via `next-themes` (see `theme-provider.tsx`)
- **Utility**: `cn()` function in `src/lib/utils.ts` for class merging with `clsx` and `tailwind-merge`

### Analytics

**PostHog** is integrated for analytics and feature flags.

- `src/lib/posthog.ts` – Server-side PostHog client
- `src/components/PostHogProvider.tsx` – Client-side provider wrapper

### SEO & GEO (Generative Engine Optimization)

This template includes comprehensive SEO infrastructure optimized for both traditional search engines and AI search engines (ChatGPT, Perplexity, Claude, Gemini).

**Core Components:**

- **`src/metadata.ts`** – Site configuration (name, description, keywords, author, theme color, OG image)
- **`src/lib/seo/metadata.ts`** – Locale-aware metadata utilities
- **`src/lib/seo/sitemap-utils.ts`** – Sitemap generation helpers
- **`src/app/robots.ts`** – Dynamic robots.txt (environment-aware)
- **`src/app/sitemap.ts`** – Multi-locale sitemap generator

**Features Included:**

1. **Locale-Aware Metadata**
   - Automatic canonical URLs for all pages
   - Hreflang links for all supported locales + x-default
   - Locale-specific OpenGraph tags (og:locale)
   - Viewport and theme-color meta tags
   - Twitter card support

2. **Robots.txt**
   - Environment-aware: blocks crawlers in development/staging, allows in production
   - Override via `NEXT_PUBLIC_ROBOTS_ALLOW` env var
   - Excludes `/api/`, `/admin/`, `/_next/`, `/private/`, `*.json`

3. **Sitemap.xml**
   - Automatic locale variants for all routes
   - Configurable changeFrequency and priority per route
   - Utilities for dynamic routes (blog posts, products, etc.)

**Using SEO Utilities:**

```typescript
// In any page.tsx file
import { generatePageMetadata } from "@/lib/seo/metadata";

export async function generateMetadata({ params }: Props) {
  const { locale } = await params;
  return generatePageMetadata({
    locale,
    path: "/about", // Current page path
    namespace: "AboutPage", // Translation namespace in messages/{locale}.json
    keywords: ["about", "company"], // Additional keywords
  });
}
```

**Adding Routes to Sitemap:**

Edit `src/app/sitemap.ts` and add routes to the `staticRoutes` array:

```typescript
const staticRoutes = [
  { path: "/", changeFrequency: "daily", priority: 1.0 },
  { path: "/about", changeFrequency: "monthly", priority: 0.8 },
  // Add more routes here
];
```

For dynamic routes (e.g., blog posts):

```typescript
import { db } from "@/db";
import { posts } from "@/db/schema";
import { generateDynamicEntries } from "@/lib/seo/sitemap-utils";

const blogPosts = await db.select().from(posts);
const blogEntries = generateDynamicEntries(
  blogPosts,
  (post) => `/blog/${post.slug}`,
  {
    changeFrequency: 'weekly',
    priority: 0.7,
    lastModifiedGetter: (post) => post.updatedAt,
  }
);
```

**Customizing for New Projects:**

When running `/implement-prd`, update `src/metadata.ts` with project-specific values:

- `name` – Your product name
- `description` – SEO description (155 chars max recommended)
- `keywords` – Relevant keywords array
- `author` – Your name and URL
- `themeColor` – Brand color (hex)
- `ogImage` – Path to 1200x630px OpenGraph image

Also update `messages/{locale}.json` files with localized metadata under the `Metadata` namespace.

**JSON-LD Structured Data (GEO Optimization):**

The template includes a comprehensive JSON-LD schema system for AI search engines. All pages automatically include Organization and WebSite schemas. Add page-specific schemas as needed:

```typescript
// Example: Article/Blog page
import { SchemaScript } from "@/components/seo/schema-script";
import { generateArticleSchema, createPerson } from "@/lib/seo/schema";

export default function BlogPost() {
  const articleSchema = generateArticleSchema({
    type: "BlogPosting",
    headline: "10 Tips for Better SEO",
    description: "Learn how to optimize your content",
    image: "https://example.com/article.jpg",
    datePublished: "2024-01-15",
    author: createPerson("John Doe", { url: "https://example.com/author/john" }),
    publisher: {
      name: "My Blog",
      logo: { "@type": "ImageObject", url: "https://example.com/logo.png" },
    },
    keywords: ["SEO", "optimization"],
  });

  return (
    <>
      <SchemaScript schema={articleSchema} />
      {/* Page content */}
    </>
  );
}
```

Available schema types:
- `generateOrganizationSchema()` – Company/organization info (auto-added to all pages)
- `generateWebSiteSchema()` – Website info with optional search action (auto-added)
- `generateWebPageSchema()` – Individual page metadata
- `generateArticleSchema()` – Blog posts, news articles (CRITICAL for GEO)
- `generateFAQSchema()` – FAQ pages (ChatGPT loves these!)
- `generateProductSchema()` – E-commerce products
- `generateBreadcrumbSchema()` – Breadcrumb navigation

See `src/lib/seo/schema/` for all available schemas and detailed usage examples.

### Performance Optimization

This template is optimized for fast development and production builds.

**Turbopack (Development)**

The development server uses **Turbopack** for 5-25x faster builds compared to Webpack:

- Enabled in `package.json`: `"dev": "... next dev --turbopack"`
- Instant server startup (~1s)
- Fast Hot Module Replacement (HMR)
- Incremental compilation

**Image Optimization**

Automatic image optimization is configured in `next.config.ts`:

- **Modern Formats**: AVIF and WebP (automatic fallback to original format)
- **Responsive Images**: Automatic srcset generation for different device sizes
- **Device Sizes**: `[640, 750, 828, 1080, 1200, 1920, 2048, 3840]`
- **Image Sizes**: `[16, 32, 48, 64, 96, 128, 256, 384]`
- **Cache TTL**: 7 days for optimized images

**Best Practices for Images:**

```tsx
import Image from "next/image";

// Always specify width and height for static images
<Image
  src="/hero.jpg"
  alt="Hero image"
  width={1200}
  height={630}
  priority // Use for above-the-fold images
/>

// For responsive images, use fill with object-fit
<div className="relative w-full h-64">
  <Image
    src="/background.jpg"
    alt="Background"
    fill
    className="object-cover"
    sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
  />
</div>

// External images require domain configuration
// Add to next.config.ts: images.remotePatterns
```

**Production Builds:**

- Uses Turbopack for faster compilation (~14s for this template)
- Automatic code splitting and tree shaking
- Bundle size optimization
- Static page generation (SSG) where possible

## Code Style Guidelines

These rules are enforced by Biome (see `biome.jsonc`):

- **Indentation**: Tabs (not spaces)
- **Quotes**: Double quotes for JavaScript/TypeScript
- **Line length**: Keep under 80 characters when practical
- **Naming conventions**:
  - Components and types: `PascalCase`
  - Variables and functions: `camelCase`
  - Files: `kebab-case`
- **Imports**: Auto-organized and sorted via Biome
- **No default exports**: Except in Next.js route files (page.tsx, layout.tsx, error.tsx)
- **shadcn/ui files**: Components in `src/components/ui/` are excluded from linting

## Git Workflow

**Claude commits**: Claude Code can create commits following the conventional commit format. Always ensure `bun type`, `bun lint`, `bun run build` are successful before committing.

**PRD references in commits**: When implementing features from `.claude/prd/`, reference the specific flow file and line number in commit messages:

```bash
git commit -m "feat: implement email/password signup

Implements flow from .claude/prd/01-flows/auth/signup-flows.md:12

- Add signUp() server action with validation
- Create SignUpForm component
- Add E2E tests for happy path and error cases"
```

## Type Safety Notes

- **Strict mode**: TypeScript is configured with all strict checks enabled
- **No implicit any**: All types must be explicit
- **No `@ts-ignore`**: Never use `@ts-ignore` comments. Fix type errors properly instead of suppressing them
- **No `as` casting**: Avoid type assertions with `as`. Use proper type guards, validation, or refactor to eliminate the need for casting
- **Path aliases**: Use `@/` prefix for imports from `src/` (e.g., `@/db`, `@/lib/utils`)
- **File extensions**: Import statements should include `.ts`/`.tsx` extensions (e.g., `from "./schema.ts"`)
- **Better Auth types**: Run `bun run auth:gen` after modifying auth configuration

## Important Patterns

1. **Database schemas must use the namespaced schema object**:
   ```ts
   import { schema } from "./schema.ts";
   export const myTable = schema.table("my_table", { ... });
   ```

2. **Client-side auth usage**:
   ```ts
   import { useSession } from "@/lib/auth-client";
   const { data: session } = useSession();
   ```

3. **Utility imports**:
   ```ts
   import { cn } from "@/lib/utils";
   ```

4. **Server Actions with proper validation**:
   ```ts
   "use server";

   import { db } from "@/db";
   import { revalidatePath } from "next/cache";
   import { z } from "zod";

   const createPostSchema = z.object({
     title: z.string().min(1),
   });

   export async function createPost(formData: FormData) {
     const parsed = createPostSchema.parse({
       title: formData.get("title"),
     });

     await db.insert(posts).values(parsed);

     revalidatePath("/posts");
   }
   ```

## PRD-Based Development Workflow

This template supports a structured workflow from requirements to implementation:

### 1. Generate PRD in Claude Chat

Use Claude Chat to create your Product Requirements Document from your project idea. The PRD should be structured as:

- `00-overview.md` – Project vision, success metrics, template customization notes
- `01-flows/` – User flows organized by feature domain (auth/, payments/, etc.)
- `02-data-models.md` – Database schema specifications
- `03-api-design.md` – Server actions and API design
- `04-ui-components.md` – UI/UX specifications
- `05-integrations.md` – Third-party services and APIs

See `.claude/prd/` for templates and examples.

### 2. Place PRD in `.claude/prd/`

Copy generated PRD files into `.claude/prd/` directory in your cloned template.

### 3. Run `/implement-prd`

Execute the `/implement-prd` slash command in Claude Code. This will:
- Read your PRD requirements
- Customize template (remove unused features, update configs)
- Generate `plan.md` with implementation roadmap

### 4. Incremental Implementation with `/next-step`

Run `/next-step` repeatedly to implement features one at a time:
- Verifies previous feature has passing tests
- Implements next feature from plan.md
- Creates unit tests and E2E tests
- Validates with `bun test` and `bun run test:e2e`

For detailed guidance, see `.claude/rules/prd-implementation.md` (auto-loads when working in `src/` or `.claude/prd/`).
