---
title: GraphQL Resolver — Query
impact: CRITICAL
tags: [graphql, resolver, query, lighthouse, paginate]
---

## Rule
Query resolvers live in `GraphQL/Queries/{Model}Query.php` inside the module. The `listing` method must return a `Builder` instance — never a collection.

## Why
Lighthouse's `@paginate` requires a query `Builder` to apply pagination, filtering, and sorting. Returning a collection breaks pagination.

## Conventions

### File Location
```
Modules/{ModuleName}/GraphQL/Queries/{ModelName}Query.php
```

### Class Structure
- Namespace: `Modules\{Module}\GraphQL\Queries`
- Class name: `{Model}Query`
- Standard methods: `listing`, `detail`, `dropdown`
- `listing` always returns `Builder` — used with `@paginate`
- `detail` and `dropdown` return model or collection — used with `@field`

### Resolver Path Format
```
Modules\\{Module}\\GraphQL\\Queries\\{Model}Query@{method}
```

## Clarifying Questions
- What is the model name and module?
- What queries are needed? (listing / detail / dropdown / custom)

## Reference
See `references/query.md` for real examples.
