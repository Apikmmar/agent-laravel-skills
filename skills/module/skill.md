---
title: Module Structure
impact: CRITICAL
tags: [module, laravel, structure, graphql]
---

## Rule
All features are organized as modules under `Modules\`. Always follow the 4-step creation flow — scaffold, model, GraphQL, migration.

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
    │   ├── Mutations/
    │   │   └── {ModelName}Mutator.php
    │   ├── Queries/
    │   │   └── {ModelName}Query.php
    │   └── Schema/
    │       ├── Components/
    │       │   └── {ModelName}.graphql
    │       ├── Mutations/
    │       │   └── {ModelName}.graphql
    │       └── Queries/
    │           └── {ModelName}.graphql
    ├── Models/
    │   └── {ModelName}.php
    └── Traits/
        └── GraphQLResponse.php

database/
└── migrations/
    └── {timestamp}_create_{table_name}_table.php
```

## After Scaffolding
Once commands are run, apply the relevant skill conventions:
- Model file → follow `skills/models/skill.md`
- Migration file → follow `skills/migration/skill.md`
- GraphQL files → follow `skills/graphql/skill.md`

## Clarifying Questions
- What is the module name?
- What is the model name?
- What is the table name? (for migration)

## Reference
No separate reference file — commands and structure are defined above.
