### Next.js Patterns

**IMPORTANT**: Prefer **Server Actions** and **Server Components** over API routes for data mutations and fetching.

- **Server Actions**: Use for form submissions, mutations, and server-side logic called from client components
- **Server Components**: Default for data fetching; they run on the server and can directly access the database
- **API Routes**: Reserve for external webhooks, third-party integrations, or when you need a public REST endpoint. Server Actions & Server Components are preferred.

Server Actions / Server Components provide better type safety, automatic request deduplication, and simpler data flow compared to API routes.