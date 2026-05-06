---
name: graphql-query
description: Use when defining GraphQL queries, filters, or sort inputs. Triggers when user asks to create a listing query, detail query, dropdown query, add pagination, or define filter and sort inputs.
---

## Rule
All queries are defined in `GraphQL/Schema/Queries/{ModelName}Queries.graphql`. Use `@paginate` for listing queries and `@field` for detail/dropdown queries.

## Why
`@paginate` handles cursor/page-based pagination automatically via Lighthouse. `@field` is for single-result or non-paginated resolvers.

## Conventions

### File Location
```
Modules/{ModuleName}/GraphQL/Schema/Queries/{ModelName}Queries.graphql
```

### Query Structure
- Always `extend type Query`
- Query names in PascalCase: `{Model}Listing`, `{Model}Detail`, `{Model}Dropdown`
- Listing queries use `@paginate(builder: "Modules\\{Module}\\GraphQL\\Queries\\{Model}Query@listing")`
- Detail/dropdown queries use `@field(resolver: "Modules\\{Module}\\GraphQL\\Queries\\{Model}Query@{method}")`
- Listing input always uses `@spread`

### Resolver Path — Always Full Namespace
Always write the full path inside `@paginate(builder:)` and `@field(resolver:)`, even when `@namespace` is present on the type extension:
```graphql
@paginate(builder: "Modules\\Post\\GraphQL\\Queries\\PostQuery@listing")
@field(resolver: "Modules\\Post\\GraphQL\\Queries\\PostQuery@detail")
```
Never use shorthand — shorthand depends on `@namespace` being correctly scoped and is fragile.

### Listing Input Structure
Every listing query has an input with exactly two fields:
```graphql
input {Model}ListingInput {
    filter: {Model}FilterInput
    sorts: [{Model}SortInput!]
}
```

### Filter Input
- Field name: `{Model}FilterInput`
- Filter field types are customizable — use the appropriate scalar or custom type per field
- All filter fields are optional (no `!`)

### Sort Input
- Field name: `{Model}SortInput`
- Always has two fields: `column: {Model}SortColumn!` and `direction: SortDirection!`
- `SortDirection` enum defined per module with values: `ASC`, `DESC`
- `{Model}SortColumn` enum always includes `CREATED_AT` at minimum — add other sortable columns as needed

## Clarifying Questions
- What is the model name and module?
- What query types are needed? (Listing / Detail / Dropdown / custom)
- What filter fields are needed for listing?
- What columns should be sortable?

## Reference
See `references/QUERY.md` for real examples.
