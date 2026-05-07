---
name: mutation
description: Use when defining GraphQL mutations or input types. Triggers when user asks to create a mutation, define a mutation input, add create/update/delete operations, or set up GraphQL mutation schema.
---

## Rule
All mutations are defined in `GraphQL/Schema/Mutations/{ModelName}Mutation.graphql`. They always return `SuccessResponse`, use `@namespace` on the `extend type` block for shorthand resolvers, and inputs are plain — no `@validator`, no `@spread`.

## Conventions

### File Location
```
Modules/{ModuleName}/GraphQL/Schema/Mutations/{ModelName}Mutation.graphql
```

### Mutation Block Structure
- Always `extend type Mutation`
- Always `@namespace(field: "Modules\\{Module}\\GraphQL\\Mutations")` on the extend block
- Always `@guard` on the extend block unless the mutations are explicitly public
- Always `@hasPermission(name: "...")` on each individual mutation
- Mutation names in PascalCase: `create{Model}`, `update{Model}`, `delete{Model}` — camelCase with lowercase first word
- Always return `SuccessResponse!`
- Use shorthand `@field(resolver: "{Model}Mutator@{method}")` — namespace comes from the block

### Input Structure
- Create input: `Create{Model}Input` — plain, no `@validator`
- Update input: `Update{Model}Input` — plain, no `@validator`, always includes `id: ID!` as first field
- Delete: flat arg `id: ID!` directly on the mutation — no input type
- No `@spread` on input arguments
- Required fields use `!`, optional fields have no `!`
- All input fields use snake_case

### Update Input Field Rules
- `id: ID!` — always required
- All other fields — always optional (no `!`), client sends only what needs updating

### Naming
- Mutation names: camelCase (`createUser`, `updateUser`, `deleteUser`)
- Input names: PascalCase + `Input` suffix (`CreateUserInput`, `UpdateUserInput`)

### Example
```graphql
extend type Mutation
    @namespace(field: "Modules\\User\\GraphQL\\Mutations")
    @guard {
    """
    Create a new user
    """
    createUser(input: CreateUserInput!): SuccessResponse!
        @hasPermission(name: "create-user")
        @field(resolver: "UserMutator@create")

    """
    Update existing user
    """
    updateUser(input: UpdateUserInput!): SuccessResponse!
        @hasPermission(name: "update-user")
        @field(resolver: "UserMutator@update")

    """
    Delete existing user
    """
    deleteUser(id: ID!): SuccessResponse!
        @hasPermission(name: "delete-user")
        @field(resolver: "UserMutator@delete")
}

input CreateUserInput {
    name: String!
    email: String!
    password: String!
}

input UpdateUserInput {
    id: ID!
    name: String
    email: String
    status: String
}
```

## Non-Negotiables
- No `@validator` on any input type — validation is handled by FormRequests in the Controller
- No `@spread` on mutation arguments
- Always `@guard` on the `extend type` block unless explicitly public
- Always `@hasPermission` on each mutation
- Always use `@namespace` on the block — never write full resolver paths per mutation

## Related
- `SuccessResponse` type is defined once in the root `graphql/schema.graphql` — never inside a module
- FormRequests for each operation → see `skills/graphql/validation/SKILL.md`

## Clarifying Questions
- What is the model name and module?
- Which operations are needed? (create / update / delete / custom)
- What fields does each input need?
- What permission names should be used?
- Are any mutations public (no `@guard`)?
