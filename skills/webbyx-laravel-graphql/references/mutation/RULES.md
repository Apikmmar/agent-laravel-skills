# GraphQL Mutation — Rules & Conventions

## Rule
All mutations are defined in `GraphQL/Schema/Mutations/{ModelName}.graphql`. They always return `SuccessResponse`, use `@namespace` on the `extend type` block for shorthand resolvers, and inputs are plain — no `@validator`, no `@spread`.

## File Location
```
Modules/{ModuleName}/GraphQL/Schema/Mutations/{ModelName}.graphql
```

## Mutation Block Structure
- Always `extend type Mutation`
- Always `@namespace(field: "Modules\\{Module}\\GraphQL\\Mutations")` on the extend block
- Always `@guard` on the extend block unless the mutations are explicitly public
- Always `@hasPermission(name: "...")` on each individual mutation
- Mutation names in camelCase: `create{Model}`, `update{Model}`, `delete{Model}`
- Always return `SuccessResponse!`
- Use shorthand `@field(resolver: "{Model}Mutator@{method}")` — namespace comes from the block

## Input Structure
- Create input: `Create{Model}Input` — plain, no `@validator`
- Update input: `Update{Model}Input` — plain, no `@validator`, always includes `id: ID!` as first field
- Delete: flat arg `id: ID!` directly on the mutation — no input type
- No `@spread` on input arguments
- Required fields use `!`, optional fields have no `!`
- All input fields use snake_case

## Update Input Field Rules
- `id: ID!` — always required
- All other fields — always optional (no `!`), client sends only what needs updating

## Naming
- Mutation names: camelCase (`createUser`, `updateUser`, `deleteUser`)
- Input names: PascalCase + `Input` suffix (`CreateUserInput`, `UpdateUserInput`)

## Non-Negotiables
- No `@validator` on any input type — validation is handled by FormRequests in the Controller
- No `@spread` on mutation arguments
- Always `@guard` on the `extend type` block unless explicitly public — never omit it silently
- Always `@hasPermission` on each mutation
- Always use `@namespace` on the block — never write full resolver paths per mutation
- `SuccessResponse` is defined once in the root schema — never redefine inside a module

## Anti-Pattern — Missing `@guard`
```graphql
# NEVER — unprotected mutations with no explicit decision
extend type Mutation
    @namespace(field: "Modules\\Post\\GraphQL\\Mutations")
{
    createPost(input: CreatePostInput!): SuccessResponse! @field(resolver: "PostMutator@create")
}

# ALWAYS — guard stated explicitly
extend type Mutation
    @guard
    @namespace(field: "Modules\\Post\\GraphQL\\Mutations")
{
    createPost(input: CreatePostInput!): SuccessResponse! @field(resolver: "PostMutator@create") @hasPermission(name: "create-post")
}
```

## Clarifying Questions
- What is the model name and module?
- Which operations are needed? (create / update / delete / custom)
- What fields does each input need?
- What permission names should be used?
- Are any mutations public (no `@guard`)?
