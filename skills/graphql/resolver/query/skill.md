---
title: GraphQL Resolver — Query
impact: CRITICAL
tags: [graphql, resolver, query, lighthouse, paginate]
---

## Rule
Query resolvers live in `GraphQL/Queries/{Model}Query.php` inside the module. The `listing` method must return a `Builder` instance.

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
