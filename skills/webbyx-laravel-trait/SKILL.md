---
name: webbyx-laravel-trait
description: Use when creating a reusable PHP trait shared across multiple modules. Triggers when user asks to create a trait, extract reusable logic into a shared class, or add cross-module functionality to app/Traits/.
---

@agents/BRAINSTORM.md
@agents/CONVENTION.md
@agents/PRINCIPLES.md
@agents/SECURITY.md
@agents/PERFORMANCE.md

## Rule
Traits that are reused across modules live in `app/Traits/`. One trait per file, one file per concern. Traits are created only when logic is genuinely reused across multiple classes — never as boilerplate.

## Why
Traits keep cross-module logic in one place and out of individual Controllers or Services. Each trait has a single responsibility — splitting by concern keeps them composable and independently testable.

## Conventions

### File Location
```
app/Traits/{TraitName}.php
```

### Naming
- PascalCase, no suffix: `HasCustomField`, `ApplyFilter`, `SendPushNotification`
- Name by what the trait gives the class that uses it — not by where it's used
- Verb-based names for behaviour traits: `SendPushNotification`, `AppliesPrioritySorting`
- Noun-based names for capability traits: `HasCustomField`, `HasSlug`

### Class Structure
- Namespace: `App\Traits`
- No class declaration — trait only
- Methods follow camelCase
- Private helpers are allowed and encouraged — break complex logic into private methods
- No constructor — traits cannot be instantiated
- No dependency injection — use `new ClassName()` or static calls for dependencies

### What Belongs in a Trait
- Logic reused across multiple modules or classes
- Behaviour that a class "has" or "can do" — not its primary responsibility
- Helper methods shared by resolvers, controllers, or models across the codebase

### What Does NOT Belong in a Trait
- Single-use logic tied to one class — keep that as a private method in the class
- DB transactions — those belong in the Controller
- Response building — that belongs in the Controller
- Business logic that belongs in a Service

### Principles Enforced
- **SRP** — one trait, one concern. If the trait does two unrelated things, split it
- **DRY** — a trait exists only when the same logic appears in more than one place
- **No N+1** — any method touching DB must use eager loading or `whereIn`
- **No for loops over DB** — use `whereIn`, `upsert`, or bulk operations
- **Exceptions** — throw standard `Exception` or a domain-specific exception; never swallow errors silently
- **No raw SQL** — always use Eloquent or Query Builder with parameter binding

## Non-Negotiables
- One trait per file — never group multiple traits in the same file
- Namespace must be `App\Traits` — never inside a module
- Methods are camelCase — never snake_case
- Never add a trait unless the logic is genuinely reused — private method in the class is better for single use
- No `$guarded = []` or mass assignment shortcuts inside trait methods

## Clarifying Questions
- What is the reusable behaviour this trait provides?
- Which classes or modules will use it?
- Are there any DB operations? If yes — what are the tables and relationships involved?
- Does it interact with external services? If yes — which ones?

## Reference

@references/TRAIT.md
