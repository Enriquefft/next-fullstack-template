### Authentication System

Authentication is handled by **Better Auth** with **Polar** integration for payment/subscription features.

- Uses Drizzle adapter with PostgreSQL for session storage
- Google OAuth configured via `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`
- Polar integration for checkout and customer portal (configured via `POLAR_ACCESS_TOKEN` and `POLAR_MODE`)
- Run `bun run auth:gen` after modifying auth configuration to regenerate types

**Important Pattern - Client-side auth usage**:
```ts
import { useSession } from "@/lib/auth-client";
const { data: session } = useSession();
```