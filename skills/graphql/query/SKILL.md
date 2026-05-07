---
name: graphql-query
description: Use when defining GraphQL queries. Triggers when user asks to create a listing query, detail query, dropdown query, add pagination, or define query schema.
---

## Rule
All queries are defined in `GraphQL/Schema/Queries/{ModelName}Queries.graphql`. Use `@namespace` on the `extend type` block for shorthand resolvers. Use `@paginate(builder:)` for paginated listing and `@field(resolver:)` for all others.

## Conventions

### File Location
```
Modules/{ModuleName}/GraphQL/Schema/Queries/{ModelName}Queries.graphql
```

### Query Block Structure
- Always `extend type Query`
- Always `@guard` on the extend block unless queries are explicitly public
- Always `@namespace(field: "...", paginate: "...")` on the extend block — both keys required when mixing `@field` and `@paginate`
- Always `@hasPermission(name: "...")` on each individual query
- Use shorthand resolver names — namespace comes from the block
- Query names in camelCase: `user`, `users`, `paginatedUsers`

### Resolver Types
- Paginated listing: `@paginate(builder: "{Model}Query@paginatedListing")`
- Non-paginated listing: `@field(resolver: "{Model}Query@listing")`
- Detail / dropdown: `@field(resolver: "{Model}Query@detail")`

### No filter/sort inputs required by default
Filtering is handled by model scopes (e.g. `User::filter()`). Only add explicit filter inputs if the user requests them.

### Example
```graphql
extend type Query
    @guard
    @namespace(
        field: "Modules\\User\\GraphQL\\Queries"
        paginate: "Modules\\User\\GraphQL\\Queries"
    ) {
    """
    Fetch specific user detail
    """
    user(id: ID!): User
        @hasPermission(name: "view-user")
        @field(resolver: "UserQuery@detail")

    """
    Fetch list of users
    """
    users: [User!]!
        @hasPermission(name: "view-all-users")
        @field(resolver: "UserQuery@listing")

    """
    Fetch paginated list of users
    """
    paginatedUsers: [User!]!
        @hasPermission(name: "view-all-users")
        @paginate(builder: "UserQuery@paginatedListing")
}
```

## Non-Negotiables
- Always `@namespace` on the `extend type` block — never write full resolver paths per query
- Always `@guard` on the block unless explicitly public
- Always `@hasPermission` on each query
- `paginatedListing` controller method must return a `Builder` — `@paginate` breaks otherwise
- No filter/sort input types unless the user explicitly requests them

## Clarifying Questions
- What is the model name and module?
- What queries are needed? (paginatedListing / listing / detail / custom)
- What permission names should be used?
- Are any queries public (no `@guard`)?
