---
name: graphql-mutation
description: Use when defining GraphQL mutations or input types. Triggers when user asks to create a mutation, define a mutation input, add create/update/delete operations, or set up GraphQL mutation schema.
---

## Rule
All mutations are defined in `GraphQL/Schema/Mutations/{ModelName}Mutation.graphql`, always return `SuccessResponse`, use `@spread` on inputs, and all Create/Update inputs must have `@validator`. Delete uses plain arguments — no input type, no validator.

## Why
Consistent mutation structure ensures uniform API responses and validation across all operations.

## Conventions

### File Location
```
Modules/{ModuleName}/GraphQL/Schema/Mutations/{ModelName}Mutation.graphql
```

### Mutation Structure
- Always `extend type Mutation`
- Mutation names in PascalCase: `Create{Model}`, `Update{Model}`, `Delete{Model}`
- Always return `SuccessResponse`
- Always use `@field(resolver: "Modules\\{Module}\\GraphQL\\Mutations\\{Model}Mutator@{method}")`
- Input argument always uses `@spread`
- Delete accepts either `id: ID!` (single) or `ids: [ID!]!` (bulk) — ask user which

### Input Structure
- Create input: `Create{Model}Input @validator`
- Update input: `Update{Model}Input @validator` — always includes `id: ID!` as first field
- Nested inputs do NOT use `@validator` — validation handled in parent validator file
- Required fields use `!`, optional fields have no `!`

### Naming
- Input names: `{Action}{Model}Input` (e.g. `CreateWorkflowInput`, `UpdateWorkflowInput`)
- Nested inputs: `{Model}{Purpose}Input` (e.g. `WorkflowTriggerInput`, `WorkflowNodesInput`)

## Clarifying Questions
- What is the model name and module?
- Which operations are needed? (Create / Update / Delete / custom)
- For Delete — single `id: ID!` or bulk `ids: [ID!]!`?
- What fields does the Create input need?
- What fields does the Update input need? (usually same as Create but all optional except `id`)
- Are there nested inputs?

## Related
- `SuccessResponse` type is defined **once in the root `graphql/schema.graphql`** — never inside a module, never duplicated. See `skills/graphql/schema/SKILL.md`.
- Validator classes for Create/Update inputs → see `skills/graphql/validation/SKILL.md`

## Reference
See `references/MUTATION.md` for real examples.
