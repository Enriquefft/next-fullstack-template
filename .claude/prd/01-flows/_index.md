# Flow Documentation Index

**Last Updated**: [Date]

This index helps Claude Code navigate flow documents efficiently. Always read this file first when implementing features from the PRD.

## Quick Reference

| Feature Area | Flow File | When to Read |
|-------------|-----------|--------------|
| User Signup | `auth/signup-flows.md` | Implementing user registration, email verification |
| User Login | `auth/login-flows.md` | Implementing authentication, session management |
| [Feature] | `[domain]/[feature]-flows.md` | [When to use] |

## File Relationships

Dependencies between flow files and technical specifications:

- **Authentication flows** (`auth/*`) depend on:
  - `02-data-models.md` → User, Session, Verification tables
  - `03-api-design.md` → `signUp()`, `signIn()`, `verifyEmail()` actions
  - `05-integrations.md` → Better Auth configuration

- **[Feature domain]** (`[domain]/*`) depend on:
  - [List dependencies]

## Implementation Priority

Phases correspond to `00-overview.md` implementation phases.

### Phase 1: MVP

Priority order for initial implementation:

1. `auth/signup-flows.md` - User registration and email verification
2. `auth/login-flows.md` - User authentication and sessions
3. [Next feature flow file]

### Phase 2: Enhancement

4. [Feature flow file]
5. [Feature flow file]

### Phase 3: Polish

6. [Feature flow file]
7. [Feature flow file]

## E2E Test Coverage Matrix

Track which flows have corresponding E2E tests:

| Flow File | E2E Test File | Coverage | Notes |
|-----------|---------------|----------|-------|
| `auth/signup-flows.md` | `e2e/tests/auth.spec.ts` | ✅ 3/3 flows | All signup scenarios covered |
| `auth/login-flows.md` | `e2e/tests/auth.spec.ts` | ⚠️ 2/3 flows | Missing: session expiry test |
| [Flow file] | [Test file] | [Status] | [Notes] |

**Legend**:
- ✅ Complete - All flows have E2E tests
- ⚠️ Partial - Some flows missing tests
- ❌ None - No E2E tests yet

## Flow File Structure

All flow files follow this organization:

### Header Section
- Related PRD files (data models, API design, UI components)
- Table of contents with anchor links

### Flow Definitions
- **User Goal**: As a [persona], I want [action] so that [benefit]
- **Preconditions**: Initial state requirements
- **Steps**: Detailed user/system interactions
- **Expected DB State**: Database changes
- **UI State**: Frontend state changes
- **E2E Test Mapping**: Link to specific test scenario

### Flow Types
- **Happy Path**: Successful completion
- **Error**: Validation failures, edge cases
- **Alternative**: Different paths to same goal

## Guidelines for Adding New Flows

When creating new flow files:

1. **File Size**: Keep files between 200-400 lines (3-7 flows per file)
2. **Naming**: Use `[feature]-flows.md` format
3. **Organization**: Group related flows in subdirectories (e.g., `auth/`, `profile/`, `payments/`)
4. **Update Index**: Add to Quick Reference table and Implementation Priority
5. **Cross-Reference**: Link to related data models and API specs
6. **E2E Mapping**: Always specify corresponding test file and scenario

## Notes

[Additional context about flow organization, special cases, or important relationships]
