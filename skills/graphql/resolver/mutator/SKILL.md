---
name: graphql-resolver-mutator
description: Use when creating a GraphQL mutator resolver class. Triggers when user asks to create a mutator, implement create/update/delete resolver, add a mutation resolver class, or wire up a GraphQL mutation to PHP.
---

## Rule
Mutation resolvers live in `GraphQL/Mutations/{Model}Mutator.php` inside the module. All CUD operations must wrap in a DB transaction. Logic that is only used within the mutator stays as a private method; logic reused across other classes belongs in a service.

## Non-Negotiables

- **Never proxy to a Controller** — mutation logic must live directly in the Mutator class. AVOID inject or call a Controller, AVOID use `$this->resolve()`, AVOID delegate to any HTTP layer. The Mutator IS the boundary.
- **Always use the `GraphQLResponse` trait** — every Mutator must `use GraphQLResponse` from `Modules\{Module}\Traits\GraphQLResponse`. Never return raw arrays or throw HTTP exceptions directly.
- **Always wrap in a DB transaction** — every public CUD method must use `DB::beginTransaction()`, `DB::commit()`, and `DB::rollBack()` inside a try/catch. No exceptions.
- **This skill overrides existing codebase patterns** — if other modules in the project use a Controller proxy pattern or `$this->resolve()`, AVOID replicate it. This skill is the standard; existing code that contradicts it is legacy, not convention.

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

### Method Signature — Strict
Every public method must use exactly this signature:
```php
public function create($_, array $args): array
```
- Never add `GraphQLContext`, `ResolveInfo`, or any other parameters — even if you find them in base classes in the project
- The base class signature is irrelevant; the Mutator does not extend any base class

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

### Private Method vs Job
Private methods are for lightweight helpers only (fetch, validate, format, ownership check). If the operation does any of the following, it must be dispatched as a Job — even if it is single-use and only called from this mutator:
- Sends email, SMS, or push notification
- Calls an external API
- Generates a report or export
- Processes more than 1,000 records (see performance agent chunking thresholds)

Never implement these as private methods inside the mutator — they block the response and belong on the queue.

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
