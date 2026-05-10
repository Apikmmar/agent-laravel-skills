---
name: graphql-schema
description: Use when defining GraphQL types, enums, or registering schema files. Triggers when user asks to create a GraphQL type, define an enum, add a schema component, or register imports in schema.graphql.
---

## Rule
All GraphQL types and enums are defined in `GraphQL/Schema/Components/{ModelName}.graphql` inside the module. Never define types inline in mutation or query files.

## Why
Centralizing types in Components keeps schema organized and prevents duplicate type definitions across files.

## Conventions

### File Location
```
Modules/{ModuleName}/GraphQL/Schema/Components/{ModelName}.graphql
```

### Type Definition
- Always define `id: ID!` as first field
- All fields use **snake_case**: `workflow_id`, `parent_execution_id`, `first_name`
- Relationship fields use Lighthouse directives: `@belongsTo`, `@hasMany`, `@hasOne`
- Use `relation:` argument when the PHP method name differs from the field name
- Always include `created_at: DateTime` and `updated_at: DateTime`
- Use scalar types: `JSON`, `DateTime`, `ID`, `String`, `Boolean`, `Int`

### Enums
- Enum names in PascalCase
- Enums defined in the same `Components/` file as the type that uses them
- **All enum values** use **UPPERCASE**: `ACTIVE`, `INACTIVE`, `PENDING`, `DRAFT`, `PUBLISHED`, `ASC`, `DESC`, `CREATED_AT`

### Relationships
- `@belongsTo` — for belongs-to relationships
- `@hasMany(relation: "methodName")` — always include `relation:` when PHP method is camelCase
- `@hasOne` — for has-one relationships

### Inputs
- Input types are defined in the mutation/query files — never in `Components/` schema files
- Plain `input` types — no `@validator`, no `@spread`
- All input fields use snake_case
- Validation is handled by FormRequests in the Controller

### SuccessResponse
All mutations return `SuccessResponse`. It is defined **once in the root schema** (e.g. `graphql/schema.graphql`) — never inside a module, never duplicated:

```graphql
type SuccessResponse {
    status: Boolean!
    message: String!
    data: JSON
}
```

This maps to the raw array returned by the Controller: `['status' => bool, 'message' => string, 'data' => mixed]`. AVOID redefine it per module.

### Module Registration
Every module has a `schema.graphql` at `Modules/{Module}/GraphQL/schema.graphql` that registers all its GraphQL files via `#import`:

```graphql
#import ../GraphQL/Schema/Components/{Model}.graphql

#import ../GraphQL/Schema/Mutations/{Model}.graphql

#import ../GraphQL/Schema/Queries/{Model}.graphql
```

- Every new Component, Mutation, and Query file added to the module must be registered here
- All three imports are always required — never omit Queries even if no queries are built yet
- Group by type: Components first, then Mutations, then Queries

## Clarifying Questions
- What is the model name?
- What fields does the type need?
- Are there any relationships? If yes — what type (belongsTo, hasMany, hasOne)?
- Are there any enum fields? If yes — what are the allowed values?

## Reference
See `references/SCHEMA.md` for real examples.
