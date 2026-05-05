---
title: GraphQL Resolver — Mutator
impact: CRITICAL
tags: [graphql, resolver, mutator, lighthouse, transaction]
---

## Rule
Mutation resolvers live in `GraphQL/Mutations/{Model}Mutator.php` inside the module. All CUD operations must wrap in a DB transaction. Logic that is only used within the mutator stays as a private method; logic reused across other classes belongs in a service.

## Why
Single Responsibility: mutators own the GraphQL boundary and transaction lifecycle, services own business logic. DB transactions ensure data consistency across multi-model operations.

## Conventions

### File Location
```
Modules/{ModuleName}/GraphQL/Mutations/{ModelName}Mutator.php
```

### Class Structure
- Namespace: `Modules\{Module}\GraphQL\Mutations`
- Class name: `{Model}Mutator`
- Always use `GraphQLResponse` trait from `Modules\{Module}\Traits\GraphQLResponse`
- Inject services via constructor (Dependency Injection)
- Method signature: `($_, array $args)` — first param is always `$_`
- Standard methods: `create`, `update`, `delete`
- Custom operations: camelCase (e.g. `publish`, `activate`)

### DB Transaction
- ALL CUD operations (create, update, delete, and custom) must use `DB::beginTransaction()`, `DB::commit()`, `DB::rollBack()`
- Wrap entire operation in try/catch
- On catch: `DB::rollBack()` then return `$this->createResponse(false, $e->getMessage())`

### Response
- Always return `$this->createResponse(bool, string)` or `$this->createResponse(bool, string, $data)`
- `true` = success, `false` = failure

### Private Helpers
- Every fetch/lookup before a main operation (getPost, getPosts, etc.) must be a private method — never inline inside a public method
- Any sub-operation used only within this mutator stays as a private method
- If a method is needed by another class → move to a service

### Resolver Path Format
```
Modules\\{Module}\\GraphQL\\Mutations\\{Model}Mutator@{method}
```

## Clarifying Questions
- What is the model name and module?
- What mutations are needed? (create / update / delete / custom)
- Any custom operations beyond CRUD?
- Which services does this mutator depend on?

## Reference
See `references/MUTATOR.md` for real examples.
