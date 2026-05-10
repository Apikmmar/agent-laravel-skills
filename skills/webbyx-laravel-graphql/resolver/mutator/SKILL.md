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

Run the script first — AI edits the generated stub, never creates from scratch:

**Windows:**
```powershell
.\.claude\scripts\make-graphql\make-graphql.ps1 -ModuleName {ModuleName} -ModelName {ModelName} -ProjectPath "{C:\path\to\project}"
```
**Mac / Linux:**
```bash
./.claude/scripts/make-graphql/make-graphql.sh {ModuleName} {ModelName} {/path/to/project}
```

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
