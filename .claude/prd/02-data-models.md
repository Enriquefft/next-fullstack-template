# Data Models

**Last Updated**: [Date]

This document defines all database tables, relationships, and schema design for the project.

## Schema Namespace

**IMPORTANT**: All tables use the project-specific schema namespace defined in `src/db/schema/schema.ts`:

```typescript
import { pgSchema } from "drizzle-orm/pg-core";
import { env } from "@/env/client";

export const schema = pgSchema(env.NEXT_PUBLIC_PROJECT_NAME);
```

**Always use** the `schema` object when defining new tables, not `pgSchema` directly.

## Tables Overview

| Table Name | Purpose | Related Flows |
|------------|---------|---------------|
| User | User accounts and profiles | `auth/signup-flows.md`, `auth/login-flows.md` |
| Session | User authentication sessions | `auth/login-flows.md` |
| [Table] | [Purpose] | [Flow files] |

## Table Definitions

### User Table

**File**: `src/db/schema/user.ts`

**Purpose**: Stores user account information and profile data

```typescript
import { schema } from "./schema.ts";
import { pgTable, text, timestamp, boolean } from "drizzle-orm/pg-core";

export const user = schema.table("user", {
  id: text("id").primaryKey(),
  email: text("email").notNull().unique(),
  name: text("name"),
  emailVerified: boolean("email_verified").default(false).notNull(),
  image: text("image"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});
```

**Indexes**:
- Primary key on `id`
- Unique index on `email`
- Consider index on `emailVerified` if querying verified users frequently

**Relationships**:
- One-to-many with Session (user can have multiple sessions)
- One-to-many with Account (user can have multiple OAuth providers)

**Validation Rules**:
- `email`: Must be valid email format, unique
- `id`: UUID v4 format
- `emailVerified`: Defaults to false, set to true after verification

---

### [Additional Table Template]

**File**: `src/db/schema/[table-name].ts`

**Purpose**: [What this table stores]

```typescript
import { schema } from "./schema.ts";
import { pgTable, text, timestamp, integer, boolean } from "drizzle-orm/pg-core";

export const [tableName] = schema.table("[table_name]", {
  id: text("id").primaryKey(),
  // Add fields here
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});
```

**Indexes**:
- [List indexes needed for performance]

**Relationships**:
- [Foreign key relationships]

**Validation Rules**:
- [Field-level constraints and validation]

---

## Relationships Diagram

```
User (1) ----< (N) Session
User (1) ----< (N) Account
User (1) ----< (N) [YourEntity]
[Entity1] (N) ----< (N) [Entity2]  // Many-to-many via join table
```

## Migration Strategy

### Creating Migrations

```bash
# Generate migration from schema changes
bun run db:generate

# Push changes to database
bun run db:push

# For production: Use migrations
bun run db:migrate
```

### Migration Guidelines

1. **Always use migrations** for schema changes in production
2. **Test migrations** on development database first
3. **Backup data** before running migrations
4. **Document breaking changes** in migration files
5. **Handle data transformations** carefully

### Example Migration Scenarios

**Adding a new table**:
```typescript
// Just define the table in src/db/schema/
// Run bun run db:generate
// Review generated migration
// Run bun run db:push (dev) or db:migrate (prod)
```

**Adding a column**:
```typescript
// Add field to table definition
// Set default value if column is NOT NULL
// Generate and apply migration
```

**Changing column type**:
```typescript
// May require data transformation
// Create migration with data conversion logic
// Test thoroughly before applying to production
```

## Enum Types

If using PostgreSQL enums:

```typescript
import { pgEnum } from "drizzle-orm/pg-core";

export const [enumName] = pgEnum("[enum_name]", ["value1", "value2", "value3"]);

// Use in table:
export const [table] = schema.table("[table]", {
  status: [enumName]("status").notNull(),
});
```

## JSON Fields

For flexible data storage:

```typescript
import { json } from "drizzle-orm/pg-core";

export const [table] = schema.table("[table]", {
  metadata: json("metadata").$type<{
    key1: string;
    key2: number;
  }>(),
});
```

## Timestamps

**Standard pattern** for all tables:

```typescript
createdAt: timestamp("created_at").defaultNow().notNull(),
updatedAt: timestamp("updated_at").defaultNow().notNull(),
```

Consider adding update trigger or using application logic to update `updatedAt`.

## Soft Deletes

If using soft deletes instead of hard deletes:

```typescript
deletedAt: timestamp("deleted_at"),
```

Query pattern:
```typescript
// Only get non-deleted records
where(isNull(table.deletedAt))
```

## Performance Considerations

### Indexing Strategy

- **Primary keys**: Always indexed automatically
- **Foreign keys**: Index if used in joins
- **Search fields**: Index fields used in WHERE clauses
- **Unique constraints**: Create unique indexes for data integrity
- **Composite indexes**: For multi-column queries

### Query Optimization

- Use `select()` to fetch only needed columns
- Implement pagination for large datasets
- Use database-level aggregations when possible
- Consider read replicas for read-heavy workloads

## Data Integrity Rules

1. **Foreign key constraints**: Use `.references()` for relationships
2. **NOT NULL constraints**: Use `.notNull()` for required fields
3. **Unique constraints**: Use `.unique()` for unique values
4. **Check constraints**: Use `.check()` for complex validations
5. **Default values**: Use `.default()` or `.defaultNow()` appropriately

## Example Schema File Structure

```
src/db/schema/
├── schema.ts          # Defines pgSchema namespace
├── index.ts           # Re-exports all schemas
├── user.ts            # User table (from Better Auth)
├── session.ts         # Session table (from Better Auth)
├── account.ts         # Account table (from Better Auth)
├── verification.ts    # Verification table (from Better Auth)
├── post.ts            # Example entity (can be removed)
└── [your-entity].ts   # Your custom entities
```

## Notes

[Any additional context, constraints, or important information about data modeling for this project]
