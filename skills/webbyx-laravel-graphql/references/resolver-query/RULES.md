# Query Resolver — Rules & Conventions

## Rule
Query resolvers live in `GraphQL/Queries/{Model}Query.php`. They extend `App\GraphQL\Queries\Query` and delegate all read logic to the Controller via `$this->resolve()`. The Query class is a thin proxy only — never put logic here.

## Architecture Flow
```
GraphQL Schema → Query (proxy) → Controller (read logic)
```

## File Creation
Run this command from the project root first — AI edits the generated stubs, never creates from scratch:

```bash
php artisan module:make-graphql {ModelName} {ModuleName}
```

## File Location
```
Modules/{ModuleName}/GraphQL/Queries/{ModelName}Query.php
```

## Class Structure
- Extends `App\GraphQL\Queries\Query`
- Declare `protected $controller = {Model}Controller::class` — no constructor injection
- One public method per query, each calls `$this->resolve(__FUNCTION__, ...)`
- Method signature: `(mixed $_, array $args, GraphQLContext $graphqlContext, ResolveInfo $resolveInfo)`
- Standard methods: `paginatedListing`, `listing`, `detail`
- Never put business logic, DB calls, or model access in the Query class

## Resolver Path Format
Uses shorthand because `@namespace` is on the schema `extend type` block:
```
UserQuery@paginatedListing
UserQuery@listing
UserQuery@detail
```

## Non-Negotiables
- Extends `App\GraphQL\Queries\Query` — never a standalone class
- `protected $controller` — never constructor injection
- Every method delegates via `$this->resolve(__FUNCTION__, ...)` — nothing else
- Method names must match the Controller method names exactly
- `paginatedListing` Controller method must return a `Builder` — `@paginate` breaks otherwise
- Read logic, filtering, and responses all belong in the Controller

## Clarifying Questions
- What is the model name and module?
- What queries are needed? (paginatedListing / listing / detail / custom)
