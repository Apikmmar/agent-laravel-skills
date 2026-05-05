---
name: graphql-validation
description: Use when creating a GraphQL input validator. Triggers when user asks to add validation, create a validator class, add @validator to an input, or define validation rules for a mutation input.
---

## Rule
Input validation uses Lighthouse's `Validator` class. Each top-level input type used in a mutation gets `@validator` in the schema and a corresponding validator class. Nested input types are validated via dot notation in the parent validator — they never have their own `@validator`.

## Why
Lighthouse's `@validator` automatically runs the validator before the mutator is called, keeping validation out of the mutator entirely. Nested inputs are covered by the parent validator using dot notation and wildcard (`*`) syntax.

## Conventions

### File Location
```
Modules/{ModuleName}/GraphQL/Validators/{InputName}Validator.php
```

### Class Naming
- Class name = GraphQL input name + `Validator` suffix
- e.g. `CreateWorkflowInput` → `CreateWorkflowInputValidator`
- Namespace: `Modules\{Module}\GraphQL\Validators`
- Extends: `Nuwave\Lighthouse\Validation\Validator`

### Schema — where to place `@validator`
- `@validator` goes on the `input` type definition, not on the mutation
- Only top-level inputs used directly in mutations get `@validator`
- Nested inputs never get `@validator`

```graphql
input CreatePostInput @validator {
    title: String!
    content: String!
}

input PostTagInput {
    tag_id: ID!
}
```

### Class Structure
- Two required methods: `rules()` and `attributes()`
- `attributes()` must cover every field defined in `rules()` — no exceptions
- Use dot notation for nested fields: `nested.field`
- Use wildcard for arrays: `nested.*.field`

### rules()
- Standard Laravel validation rules as an array
- Nested fields use dot notation: `'workflow_trigger.trigger_type' => ['required', 'string']`
- Array items use wildcard: `'workflow_nodes.*.name' => ['required', 'string']`

### attributes()
- Human-readable label for every field in `rules()`
- Used in validation error messages
- Must be kept in sync with `rules()` — every key in `rules()` must have an entry here

## Clarifying Questions
- What input types need `@validator`?
- What are the validation rules for each field?
- What human-readable label should each field have?

## Reference
See `references/VALIDATION.md` for real examples.
