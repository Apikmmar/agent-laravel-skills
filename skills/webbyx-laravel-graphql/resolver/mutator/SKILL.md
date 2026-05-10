---
name: graphql-resolver-mutator
description: Use when creating a GraphQL mutator resolver class. Triggers when user asks to create a mutator, implement create/update/delete resolver, add a mutation resolver class, or wire up a GraphQL mutation to PHP.
---

## Rule
Mutation resolvers live in `GraphQL/Mutations/{Model}Mutator.php`. They extend `App\GraphQL\Mutations\Mutator` and delegate all business logic to the Controller via `$this->resolve()`. The Mutator is a thin proxy only — never put logic here.

## Architecture Flow

```
GraphQL Schema → Mutator (proxy) → Controller (business logic + validation)
```

## File Creation

Run this command from the project root first — AI edits the generated stubs, never creates from scratch:

```bash
php artisan module:make-graphql {ModelName} {ModuleName}
```

This generates:
- `Modules/{ModuleName}/GraphQL/Mutations/{ModelName}Mutator.php` — fill in content
- `Modules/{ModuleName}/GraphQL/Queries/{ModelName}Query.php` — fill in content
- `Modules/{ModuleName}/GraphQL/Schema/Components/.gitkeep` — Components folder only; **create** `{ModelName}.graphql` here from scratch
- `Modules/{ModuleName}/GraphQL/Schema/Mutations/{ModelName}.graphql` — fill in content
- `Modules/{ModuleName}/GraphQL/Schema/Queries/{ModelName}.graphql` — fill in content

Edit the generated stubs directly. For `Schema/Components/{ModelName}.graphql` — artisan only creates a `.gitkeep`; create that file from scratch.

## Conventions

### File Location
```
Modules/{ModuleName}/GraphQL/Mutations/{ModelName}Mutator.php
```

### Class Structure
- Extends `App\GraphQL\Mutations\Mutator`
- Declare `protected $controller = {Model}Controller::class` — no constructor injection
- One public method per mutation, each calls `$this->resolve(__FUNCTION__, ...)`
- Method signature: `(mixed $_, array $args, GraphQLContext $graphqlContext, ResolveInfo $resolveInfo)`
- Standard methods: `create`, `update`, `delete`
- Custom operations: camelCase (e.g. `publish`, `activate`)
- Never put business logic, DB calls, or model access in the Mutator

### Multiple Controllers per Module
When a mutation is handled by a **separate controller** (not the default `$this->controller`), use `app()->call()` directly in that method instead of `$this->resolve()`:

```php
public function update(mixed $_, array $args, GraphQLContext $graphqlContext, ResolveInfo $resolveInfo): array
{
    return app()->call([app(UpdatePostController::class), 'update'], $args);
}
```

- Only use this pattern when the user explicitly requests a separate controller for that operation
- The separate controller must still follow all controller skill conventions (FormRequest, DB transaction, ExecutionException)
- Default is one controller per module via `$this->resolve()` — use this only when controllers are intentionally split

### Resolver Path Format
Uses shorthand because `@namespace` is on the schema `extend type` block:
```
UserMutator@create
```

## Non-Negotiables
- Extends `App\GraphQL\Mutations\Mutator` — never a standalone class
- `protected $controller` — never constructor injection
- Every method delegates via `$this->resolve(__FUNCTION__, ...)` — nothing else
- Method names must match the Controller method names exactly
- Business logic, DB transactions, and responses all belong in the Controller — see `skills/graphql/controller/SKILL.md`

## Clarifying Questions
- What is the model name and module?
- What mutations are needed? (create / update / delete / custom)
- Any custom operations beyond CRUD?

## Reference
See `references/MUTATOR.md` for real examples.
