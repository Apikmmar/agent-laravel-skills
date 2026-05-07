---
name: laravel-module
description: Use when creating a new Laravel module. Triggers when user asks to create a module, scaffold a new feature, set up a new domain, or run module:make commands.
---

## Rule
All features are organized as modules under `Modules\`. Always follow the creation flow — scaffold, model, GraphQL, Controller, FormRequests, migration.

## Why
Modules keep domain logic isolated and consistent. Running commands in the wrong order or placing files in the wrong location breaks the module structure.

## Conventions

### Creation Flow
Run in this exact order:

**Step 1 — Scaffold the module**
```bash
php artisan module:make {ModuleName}
```

**Step 2 — Create the model inside the module**
```bash
php artisan module:make-model {ModelName} {ModuleName}
```

**Step 3 — Generate GraphQL files**
```bash
php artisan module:make-graphql {ModelName} {ModuleName}
```

**Step 4 — Create the HTTP Controller**

No artisan command — generate manually:
```
Modules/{ModuleName}/Http/Controllers/{ModelName}Controller.php
```
See `skills/graphql/resolver/mutator/SKILL.md` for the full Controller convention.

**Step 5 — Create FormRequests**

No artisan command — generate manually, one per mutation operation:
```
Modules/{ModuleName}/Http/Requests/Create{ModelName}Request.php
Modules/{ModuleName}/Http/Requests/Update{ModelName}Request.php
Modules/{ModuleName}/Http/Requests/Delete{ModelName}Request.php
```
See `skills/graphql/request/SKILL.md` for the full FormRequest convention.

**Step 6 — Create the migration**
```bash
php artisan make:migration create_{table_name}_table
```
> Migration goes in `database/migrations/` — NOT inside the module.

### Generated Structure
After running all commands:

```
Modules/
└── {ModuleName}/
    ├── GraphQL/
    │   ├── schema.graphql
    │   ├── Mutations/
    │   │   └── {ModelName}Mutator.php
    │   ├── Queries/
    │   │   └── {ModelName}Query.php
    │   └── Schema/
    │       ├── Components/
    │       │   └── {ModelName}Schema.graphql
    │       ├── Mutations/
    │       │   └── {ModelName}Mutation.graphql
    │       └── Queries/
    │           └── {ModelName}Queries.graphql
    ├── Http/
    │   ├── Controllers/
    │   │   └── {ModelName}Controller.php
    │   └── Requests/
    │       ├── Create{ModelName}Request.php
    │       ├── Update{ModelName}Request.php
    │       └── Delete{ModelName}Request.php
    ├── Models/
    │   └── {ModelName}.php
    └── Services/           ← not scaffolded; create as needed (see skills/service/SKILL.md)

database/
└── migrations/
    └── {timestamp}_create_{table_name}_table.php
```

### Scaffold Cleanup — Delete Empty Generated Files
`module:make-graphql` generates placeholder `.graphql` files using just the model name (e.g. `Post.graphql`). These conflict with the correctly named files the skill requires. After running the command, delete them:

```
# Delete these scaffold artifacts — they are empty and wrong
GraphQL/Schema/Components/{ModelName}.graphql    ← delete, keep {ModelName}Schema.graphql
GraphQL/Schema/Mutations/{ModelName}.graphql     ← delete, keep {ModelName}Mutation.graphql
GraphQL/Schema/Queries/{ModelName}.graphql       ← delete, keep {ModelName}Queries.graphql
```

Only the suffixed files (`*Schema.graphql`, `*Mutation.graphql`, `*Queries.graphql`) should remain and be imported in `schema.graphql`.

## After Scaffolding
Once commands are run, apply the relevant skill conventions:
- Model file → follow `skills/models/SKILL.md`
- Migration file → follow `skills/migration/SKILL.md`
- GraphQL type/enum → follow `skills/graphql/schema/SKILL.md`
- GraphQL mutation schema → follow `skills/graphql/mutation/SKILL.md`
- GraphQL query schema → follow `skills/graphql/query/SKILL.md`
- Mutator resolver → follow `skills/graphql/resolver/mutator/SKILL.md`
- Query resolver → follow `skills/graphql/resolver/query/SKILL.md`
- Controller (mutations + queries) → follow `skills/graphql/controller/SKILL.md`
- FormRequests → follow `skills/graphql/request/SKILL.md`
- Service layer → follow `skills/service/SKILL.md` (create only when logic is reused across classes)

## Non-Negotiables
- **Controller is mandatory** — every module has one; it owns all business logic for both mutations and queries
- **FormRequests are mandatory for mutations** — one per mutation operation; never use raw `Request` for CUD
- **Resolvers are proxies only** — Mutator and Query classes contain no logic beyond `$this->resolve()`
- **No `@validator` anywhere** — validation is entirely in FormRequests
- **No `Traits/GraphQLResponse.php`** — Controllers return raw arrays; no trait needed
- **No `GraphQL/Validators/` folder** — this pattern is not used in this project

## Clarifying Questions
- What is the module name?
- What is the model name?
- What is the table name? (for migration)
- What mutations are needed? (determines which FormRequests to create)
