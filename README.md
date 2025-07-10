# Next Fullstack Template

A preconfigured Next.js starter built with TypeScript, Bun, Tailwind CSS and
Drizzle ORM. It includes Better Auth, shadcn/ui, PostHog analytics and a basic
Nix flake for development.

## Features

- Next.js 15 with the App Router
- Bun package manager and runtime
- Tailwind CSS with shadcn/ui components
- Drizzle ORM for PostgreSQL
- Authentication powered by Better Auth
- PostHog analytics integration
- Unit tests with Happy DOM and Testing Library
- Biome formatting and linting


## Technology Choices

- **Bun** – Fast runtime and package manager. Install from <https://bun.sh>, then run `bun dev` to start the app and `bun test` for tests.
- **Tailwind CSS & shadcn/ui** – Utility-first styling with prebuilt UI primitives. Global styles live in `src/styles` and components in `src/components/ui`.
- **Drizzle ORM** – Type-safe database toolkit. Schemas are in `src/db/schema`; run `bun run db:push` for migrations and `bun run db:studio` to explore.
- **Better Auth** – Simple authentication using Drizzle and Google OAuth. Configuration resides in `src/auth.ts`; client helpers are in `src/lib/auth-client.ts`.
- **PostHog Analytics** – Tracks usage and page views. Initialized via `PostHogProvider` from `posthog-js`.
- **Nix Flake** – Provides a reproducible dev shell. Run `nix develop` to enter the environment.
- **Biome** – Formatter and linter. Execute `bun run format` or rely on Lefthook pre-commit hooks.
- **Happy DOM with Testing Library** – Lightweight DOM testing environment defined in `tests/happydom.ts`.

## Getting Started
Install **Bun** first if it isn't already available on your system. Visit
<https://bun.sh> for installation instructions. Then clone the repo and install
its dependencies:

```bash
git clone https://github.com/Enriquefft/next-fullstack-template.git
cd next-fullstack-template
bun install
```

Create a `.env` file from `.env.example` and fill in the environment variables.

Install the Git hooks (optional but recommended):

```bash
bunx lefthook install
```

Run the development server:

```bash
bun dev
```

Visit <http://localhost:3000> in your browser.

## Available Scripts

The following commands rely on Bun and the packages installed with `bun install`:

- `bun dev` – start the dev server
- `bun run build` – build for production
- `bun start` – run the production build
- `bun test` – execute unit tests
- `bun run format` – format code with Biome
- `bunx tsc --noEmit` – type‑check the project
- `bun run db:push` – run Drizzle migrations
- `bun run db:studio` – open Drizzle Studio

## Project Structure

- `src/app` – Next.js routes and pages
- `src/components` – shared React components and `ui` primitives
- `src/db` – database schemas and utilities
- `src/styles` – global CSS and fonts
- `tests` – unit tests for Bun
- `docs` – project documentation

## Environment Variables

The `t3-oss/env-nextjs` package provides type‑safe access to env vars. Set the
values below in your `.env` file:

```bash
NEXT_PUBLIC_PROJECT_NAME=
DRIZZLE_DATABASE_URL=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
BETTER_AUTH_SECRET=
NEXT_PUBLIC_POSTHOG_KEY=
POLAR_ACCESS_TOKEN=
POLAR_MODE=
# Optional
BETTER_AUTH_URL=
```

See `.env.example` for details.

## Metadata and Social Sharing

Page metadata lives in `src/metadata.ts`. Customize the title, description and
authors to fit your project. Edit the `metadataBase` field so absolute URLs are
generated. This ensures the `og:image` preview works on platforms like
WhatsApp. Replace `public/opengraph-image.png` (and the
`opengraph-image.webp` variant) with your own social card if desired.

Next.js reads `src/app/icon.png` to generate the favicon and other metadata
icons. Swap this file for your own icon or add additional sizes following
Next.js file conventions. The exported `metadata` object in `src/metadata.ts`
imports these images. Update its `title`, `description`, `authors` and any other
fields to reflect your project. Ensure `metadataBase` points to your deployed
domain so that absolute URLs for icons and OpenGraph images resolve correctly.

## Contributing

Before opening a pull request, make sure Bun and the project dependencies are
installed with `bun install`. Then format and type-check the code and run tests:

```bash
bun run format
bunx tsc --noEmit
bun test
```

Keep commits focused and include a clear message.

## License

This project is available under the MIT License. See `LICENSE-MIT` for details.
