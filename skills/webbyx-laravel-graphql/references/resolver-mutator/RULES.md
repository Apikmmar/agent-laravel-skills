# Mutator Resolver — Rules & Conventions

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
- `Modules/{ModuleName}/GraphQL/Schema/Components/.gitkeep` — create `{ModelName}.graphql` here from scratch
- `Modules/{ModuleName}/GraphQL/Schema/Mutations/{ModelName}.graphql` — fill in content
- `Modules/{ModuleName}/GraphQL/Schema/Queries/{ModelName}.graphql` — fill in content

## File Location
```
Modules/{ModuleName}/GraphQL/Mutations/{ModelName}Mutator.php
```

## Class Structure
- Extends `App\GraphQL\Mutations\Mutator`
- Declare `protected $controller = {Model}Controller::class` — no constructor injection
- One public method per mutation, each calls `$this->resolve(__FUNCTION__, ...)`
- Method signature: `(mixed $_, array $args, GraphQLContext $graphqlContext, ResolveInfo $resolveInfo)`
- Standard methods: `create`, `update`, `delete`
- Custom operations: camelCase (e.g. `publish`, `activate`)
- Never put business logic, DB calls, or model access in the Mutator

## Multiple Controllers per Module
When a mutation is handled by a separate controller (not the default `$this->controller`), use `app()->call()` directly:

```php
public function update(mixed $_, array $args, GraphQLContext $graphqlContext, ResolveInfo $resolveInfo): array
{
    return app()->call([app(UpdatePostController::class), 'update'], $args);
}
```

- Only use this pattern when the user explicitly requests a separate controller for that operation
- Default is one controller per module via `$this->resolve()`

## Non-Negotiables
- Extends `App\GraphQL\Mutations\Mutator` — never a standalone class
- `protected $controller` — never constructor injection
- Every method delegates via `$this->resolve(__FUNCTION__, ...)` — nothing else
- Method names must match the Controller method names exactly
- Business logic, DB transactions, and responses all belong in the Controller

## Clarifying Questions
- What is the model name and module?
- What mutations are needed? (create / update / delete / custom)
- Any custom operations beyond CRUD?
