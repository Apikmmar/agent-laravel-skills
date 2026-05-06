---
name: graphql-resolver-query
description: Use when creating a GraphQL query resolver class. Triggers when user asks to create a query resolver, implement listing or detail resolver, add a query class, or wire up a GraphQL query to PHP.
---

## Rule
Query resolvers live in `GraphQL/Queries/{Model}Query.php` inside the module. The `listing` method must return a `Builder` instance.

## Non-Negotiables

- **Never proxy to a Controller** — query logic must live directly in the Query class. AVOID inject or call a Controller, AVOID use `$this->resolve()`, AVOID delegate to any HTTP layer. The Query class IS the read boundary.
- **`listing` must return a `Builder`** — never return a Collection, array, or paginated result directly. Lighthouse's `@paginate` handles pagination; returning anything other than a Builder breaks it.
- **This skill overrides existing codebase patterns** — if other modules in the project use a Controller proxy pattern or `$this->resolve()`, AVOID replicate it. This skill is the standard; existing code that contradicts it is legacy, not convention.

## Why
Lighthouse's `@paginate` requires a `Builder` to apply pagination. Keeping filter/sort logic in the query class follows Single Responsibility — the query class owns all read-path concerns for its model.

## Conventions

### File Location
```
Modules/{ModuleName}/GraphQL/Queries/{ModelName}Query.php
```

### Class Structure
- Namespace: `Modules\{Module}\GraphQL\Queries`
- Class name: `{Model}Query`
- Method signature: `($_, array $args)` — first param is always `$_`
- Standard methods: `listing`, `detail`, `dropdown`
- Method names are plain by default — ask user if prefixed names are needed (e.g. `listingWorkflow`)

### Method Signature — Strict
Every public method must use exactly this signature:
```php
public function listing($_, array $args): Builder
```
- Never add `GraphQLContext`, `ResolveInfo`, or any other parameters — even if you find them in base classes in the project
- The base class signature is irrelevant; the Query class does not extend any base class

### listing
- Always returns `Builder` — required for `@paginate`

### detail
- Returns single model instance
- Always throws `\Exception` if not found

### dropdown
- Returns simplified collection (id + label only)
- Apply active/status filter where applicable

### Private Helpers
- Private methods allowed for logic used only within this query class
- If a method is needed by another class → move to a service

### Resolver Path Format
```
Modules\\{Module}\\GraphQL\\Queries\\{Model}Query@{method}
```

## Clarifying Questions
- What is the model name and module?
- What queries are needed? (listing / detail / dropdown / custom)
- Are prefixed method names needed (e.g. `listingPost`)?

## Reference
See `references/QUERY.md` for real examples.
