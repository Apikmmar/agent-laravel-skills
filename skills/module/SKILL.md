---
name: laravel-module
description: Use when creating a new Laravel module. Triggers when user asks to create a module, scaffold a new feature, set up a new domain, or run module:make commands.
---

## Rule
All features are organized as modules under `Modules\`. Always follow the 5-step creation flow — scaffold, model, GraphQL, migration, GraphQLResponse trait.

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

**Step 4 — Create the migration**
```bash
php artisan make:migration create_{table_name}_table
```
> Migration goes in `database/migrations/` — NOT inside the module.

**Step 5 — Create the GraphQLResponse trait**

No artisan command — generate this file manually:

```
Modules/{ModuleName}/Traits/GraphQLResponse.php
```

```php
<?php

namespace Modules\{ModuleName}\Traits;

trait GraphQLResponse
{
    private function createResponse(bool $status, string $message, $data = null): array
    {
        return [
            'status'  => $status,
            'message' => $message,
            'data'    => $data,
        ];
    }
}
```

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
    ├── Models/
    │   └── {ModelName}.php
    ├── Services/           ← not scaffolded; create as needed (see skills/service/SKILL.md)
    └── Traits/
        └── GraphQLResponse.php

database/
└── migrations/
    └── {timestamp}_create_{table_name}_table.php
```

## After Scaffolding
Once commands are run, apply the relevant skill conventions:
- Model file → follow `skills/models/SKILL.md`
- Migration file → follow `skills/migration/SKILL.md`
- GraphQL type/enum → follow `skills/graphql/schema/SKILL.md`
- GraphQL mutation schema → follow `skills/graphql/mutation/SKILL.md`
- GraphQL query schema → follow `skills/graphql/query/SKILL.md`
- Mutator resolver → follow `skills/graphql/resolver/mutator/SKILL.md`
- Query resolver → follow `skills/graphql/resolver/query/SKILL.md`
- Input validation → follow `skills/graphql/validation/SKILL.md`
- Service layer → follow `skills/service/SKILL.md` (create only when logic is reused across classes)

## Non-Negotiables

- **Step 5 is mandatory** — `Traits/GraphQLResponse.php` must always be created. It is not scaffolded by artisan; generate it manually every time. Never skip it.
- **Never use a Controller as a proxy for Mutator or Query logic** — mutation and query logic belongs directly in the Mutator and Query classes. AVOID create a controller and call it via `$this->resolve()` or any similar delegation pattern.
- **Never use FormRequests for GraphQL input validation** — use Lighthouse `@validator` on input types and create the corresponding validator classes under `GraphQL/Validators/`.

## Clarifying Questions
- What is the module name?
- What is the model name?
- What is the table name? (for migration)

## Reference
No separate reference file — commands and structure are defined above.
