---
title: GraphQL Resolver — Mutator
impact: CRITICAL
tags: [graphql, resolver, mutator, lighthouse]
---

## Rule
Mutation resolvers live in `GraphQL/Mutations/{Model}Mutator.php` inside the module. Mutator classes only delegate to services — no business logic inside.

## Why
Keeping mutators thin follows Single Responsibility. Business logic in services is reusable and testable independently from GraphQL.

## Conventions

### File Location
```
Modules/{ModuleName}/GraphQL/Mutations/{ModelName}Mutator.php
```

### Class Structure
- Namespace: `Modules\{Module}\GraphQL\Mutations`
- Class name: `{Model}Mutator`
- Methods in camelCase matching the `@` suffix in resolver path
- Standard methods: `create`, `update`, `delete`
- Custom operations: camelCase (e.g. `publish`, `activate`)

### Resolver Path Format
```
Modules\\{Module}\\GraphQL\\Mutations\\{Model}Mutator@{method}
```

## Clarifying Questions
- What is the model name and module?
- What mutations are needed? (create / update / delete / custom)
- Any custom operations beyond CRUD?

## Reference
See `references/mutator.md` for real examples.
