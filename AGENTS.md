# Agent Instructions

This repository provides a **Next.js** template configured with **TypeScript**, **Bun**, **Tailwind CSS**, and **Drizzle ORM**. It is meant to be cloned and adapted into your own project. Update names, documentation, and configuration files to reflect the new project once you copy this template.

## Workflow

1. **Format** all changed files with **Biome**:
   ```bash
   bun run format
   # or
   biome format --write
   ```
2. **Type-check** the code:
   ```bash
   bunx tsc --noEmit
   ```
3. **Run tests**:
   ```bash
   bun test
   ```
   If these commands cannot run because of missing dependencies or network limits, note this in the PR description.
4. Keep commits small and focused with clear messages. Prefix them with `feat:`, `fix:`, `style:`, or `chore:` when suitable.
5. Pull request descriptions must summarize the changes, cite any updated files, and show test output.

## Repository Structure

- `src/app` – Next.js routes and pages.
- `src/components` – shared React components. Reusable UI primitives live in `src/components/ui`.
- `src/db` – Drizzle schemas and database utilities.
- `src/styles` – global CSS and fonts.
- `tests` – unit tests configured for Bun.
- `docs` – documentation such as the brand guideline template at `docs/brand.md`.

## Code Style

- Follow patterns already established in the components and utilities.
- Use **Tailwind CSS** classes and Shadcn/UI components for UI work.
- Components and types use **PascalCase**. Variables and functions use **camelCase**. File names use **kebab-case**.
- Keep lines under 80 characters when practical and remove unused code.
- Single source of truth is a must everywhere and for everything.

## Customization Checklist

This is a template repository. After cloning, update all references to match your project:

- Rename the project in `package.json` and `README.md`.
- Adjust environment variables in `src/env.ts` and `.env.local` (if present).
- Replace placeholder text in `docs/brand.md` with your real brand details.
- Review the sample components and pages under `src/app` and `src/components` and adapt as needed.
- Lastly, update this file: `AGENTS.md`, removing every mention that this is a template repository alongside this customization checklist (after making all needed changes).


## AGENTS.md Inheritance

These instructions govern the entire repository. If another `AGENTS.md` is added in a subdirectory, its rules override these instructions for files within that folder.

By following these guidelines and updating all placeholders, you can transform this template into your own production-ready project.
