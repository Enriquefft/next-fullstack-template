# SEO & GEO (Generative Engine Optimization) Guide

This guide applies when working with SEO-related files:
- `src/lib/seo/metadata.ts`
- `src/lib/seo/sitemap-utils.ts`
- `src/lib/seo/schema/`
- `src/app/robots.ts`
- `src/app/sitemap.ts`
- `src/metadata.ts`

## Overview

This template includes comprehensive SEO infrastructure optimized for both traditional search engines (Google, Bing) and AI search engines (ChatGPT, Perplexity, Claude, Gemini).

## Core Components

- **`src/metadata.ts`** – Site configuration (name, description, keywords, author, theme color, OG image)
- **`src/lib/seo/metadata.ts`** – Locale-aware metadata utilities
- **`src/lib/seo/sitemap-utils.ts`** – Sitemap generation helpers
- **`src/app/robots.ts`** – Dynamic robots.txt (environment-aware)
- **`src/app/sitemap.ts`** – Multi-locale sitemap generator

## Features

### 1. Locale-Aware Metadata

Automatically generates for all pages:
- Canonical URLs for all pages
- Hreflang links for all supported locales + x-default
- Locale-specific OpenGraph tags (og:locale)
- Viewport and theme-color meta tags
- Twitter card support

### 2. Robots.txt

- **Environment-aware**: Blocks crawlers in development/staging, allows in production
- **Override**: Set `NEXT_PUBLIC_ROBOTS_ALLOW` env var to control manually
- **Excludes**: `/api/`, `/admin/`, `/_next/`, `/private/`, `*.json`

### 3. Sitemap.xml

- Automatic locale variants for all routes
- Configurable changeFrequency and priority per route
- Utilities for dynamic routes (blog posts, products, etc.)

## Usage Patterns

### Adding Metadata to Pages

Use `generatePageMetadata()` in any page component:

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

### Adding Routes to Sitemap

Edit `src/app/sitemap.ts` and add routes to the `staticRoutes` array:

```typescript
const staticRoutes = [
  { path: "/", changeFrequency: "daily", priority: 1.0 },
  { path: "/about", changeFrequency: "monthly", priority: 0.8 },
  // Add more routes here
];
```

### Adding Dynamic Routes to Sitemap

For dynamic content like blog posts:

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

## JSON-LD Structured Data (GEO Optimization)

The template includes a comprehensive JSON-LD schema system optimized for AI search engines. All pages automatically include Organization and WebSite schemas.

### Adding Page-Specific Schemas

Example for blog/article pages:

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

### Available Schema Types

- `generateOrganizationSchema()` – Company/organization info (auto-added to all pages)
- `generateWebSiteSchema()` – Website info with optional search action (auto-added)
- `generateWebPageSchema()` – Individual page metadata
- `generateArticleSchema()` – Blog posts, news articles (CRITICAL for GEO - AI search engines prioritize articles)
- `generateFAQSchema()` – FAQ pages (ChatGPT loves these for Q&A responses!)
- `generateProductSchema()` – E-commerce products
- `generateBreadcrumbSchema()` – Breadcrumb navigation

See `src/lib/seo/schema/` for all available schemas and detailed implementation examples.

## Customization During `/implement-prd`

When running `/implement-prd`, the following will be automatically updated from PRD requirements:

### Update `src/metadata.ts`

The `siteConfig` object should be customized with:

- `name` – Your product/project name
- `description` – SEO description (155 characters max recommended)
- `keywords` – Relevant keywords array for your project
- `author` – Your name and URL
- `themeColor` – Brand primary color (hex format)
- `ogImage` – Path to 1200x630px OpenGraph image

### Update Message Files

Update localized metadata in `messages/{locale}.json` files under the `Metadata` namespace:

```json
{
  "Metadata": {
    "title": "Your Project Name",
    "description": "Localized SEO description for this language"
  }
}
```

### Add New Locales

If your project supports additional locales:

1. Add locale to `src/i18n/config.ts`
2. Create `messages/{locale}.json` file
3. Update `src/lib/seo/metadata.ts` if locale mappings are needed

## Best Practices

1. **Always use `generatePageMetadata()`** for pages instead of hardcoding metadata
2. **Add structured data** to content pages (articles, products, FAQs) for better AI search visibility
3. **Keep descriptions under 155 characters** for optimal display in search results
4. **Use descriptive keywords** that match user search intent
5. **Update sitemap** whenever adding new routes or dynamic content
6. **Test OpenGraph images** are exactly 1200x630px for best social media display
7. **Verify robots.txt** doesn't block important pages in production

## GEO-Specific Tips

For maximum visibility in AI search engines (ChatGPT, Perplexity, Claude):

1. **Use ArticleSchema** on blog posts and documentation pages
2. **Use FAQSchema** on help/support pages (AI engines use these for Q&A)
3. **Include author attribution** with `createPerson()` for credibility
4. **Add datePublished and dateModified** to show content freshness
5. **Use clear, semantic keywords** in schema data
6. **Structure content hierarchically** with proper headings (h1, h2, h3)
