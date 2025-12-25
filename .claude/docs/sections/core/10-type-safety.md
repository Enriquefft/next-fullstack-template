## Type Safety Notes

- **Strict mode**: TypeScript is configured with all strict checks enabled
- **No implicit any**: All types must be explicit
- **No `@ts-ignore`**: Never use `@ts-ignore` comments. Fix type errors properly instead of suppressing them
- **No `as` casting**: Avoid type assertions with `as`. Use proper type guards, validation, or refactor to eliminate the need for casting
- **Path aliases**: Use `@/` prefix for imports from `src/` (e.g., `@/db`, `@/lib/utils`)
- **File extensions**: Import statements should include `.ts`/`.tsx` extensions (e.g., `from "./schema.ts"`)