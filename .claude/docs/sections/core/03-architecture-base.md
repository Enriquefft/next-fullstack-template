## Architecture Overview

### Environment Variables

Type-safe environment validation using **@t3-oss/env-nextjs** in `src/env/[client|server|db].ts`.

- **Client vars** (prefixed with `NEXT_PUBLIC_`): Available in browser
- **Server vars**: Backend-only, validated at build time