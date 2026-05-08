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

**Steps 1–4 — Scaffold the module, model, GraphQL files, and migration**

This repo is used as a git submodule at `{project}/.claude/`. Run the scaffold script from the **project root** — the script navigates internally via `-ProjectPath`:

**Windows (PowerShell)**
```powershell
.\.claude\scripts\scaffold-module.ps1 -ModuleName {ModuleName} -ModelName {ModelName} -TableName {table_name} -ProjectPath "{C:\path\to\project}"
```

**Mac / Linux (Bash)**
```bash
chmod +x ./.claude/scripts/scaffold-module.sh  # first time only
./.claude/scripts/scaffold-module.sh {ModuleName} {ModelName} {table_name} {/path/to/project}
```

**Step 5 — Create the HTTP Controller**

The scaffold generates a stub at `Modules/{ModuleName}/app/Http/Controllers/{ModelName}Controller.php` — fill in the content:
```
Modules/{ModuleName}/app/Http/Controllers/{ModelName}Controller.php
```
See `skills/graphql/controller/SKILL.md` for the full Controller convention.

**Step 6 — Create FormRequests**

No artisan command — generate manually under `app/Http/Requests/`, one per mutation operation:
```
Modules/{ModuleName}/app/Http/Requests/Create{ModelName}Request.php
Modules/{ModuleName}/app/Http/Requests/Update{ModelName}Request.php
Modules/{ModuleName}/app/Http/Requests/Delete{ModelName}Request.php
```
See `skills/graphql/request/SKILL.md` for the full FormRequest convention.

### Generated Structure
After running all commands:

```
Modules/
└── {ModuleName}/
    ├── app/
    │   ├── Http/
    │   │   ├── Controllers/
    │   │   │   └── {ModelName}Controller.php   ← stub generated; fill in content
    │   │   └── Requests/
    │   │       ├── Create{ModelName}Request.php   ← create manually
    │   │       ├── Update{ModelName}Request.php   ← create manually
    │   │       └── Delete{ModelName}Request.php   ← create manually
    │   └── Models/
    │       └── {ModelName}.php                 ← stub generated; fill in content
    ├── GraphQL/
    │   ├── schema.graphql
    │   ├── Mutations/
    │   │   └── {ModelName}Mutator.php          ← stub generated; fill in content
    │   ├── Queries/
    │   │   └── {ModelName}Query.php            ← stub generated; fill in content
    │   └── Schema/
    │       ├── Components/
    │       │   └── {ModelName}Schema.graphql   ← renamed by script; fill in content
    │       ├── Mutations/
    │       │   └── {ModelName}Mutation.graphql ← renamed by script; fill in content
    │       └── Queries/
    │           └── {ModelName}Queries.graphql  ← renamed by script; fill in content
    └── Services/           ← not scaffolded; create as needed (see skills/service/SKILL.md)

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
- Controller (mutations + queries) → follow `skills/graphql/controller/SKILL.md`
- FormRequests → follow `skills/graphql/request/SKILL.md`
- Service layer → follow `skills/service/SKILL.md` (create only when logic is reused across classes)

## Non-Negotiables
- **Controller is mandatory** — every module has one; it owns all business logic for both mutations and queries
- **FormRequests are mandatory for mutations** — one per mutation operation; never use raw `Request` for CUD
- **Resolvers are proxies only** — Mutator and Query classes contain no logic beyond `$this->resolve()`
- **No `@validator` anywhere** — validation is entirely in FormRequests
- **No `GraphQL/Validators/` folder** — this pattern is not used in this project

## Clarifying Questions
- What is the module name?
- What is the model name?
- What is the table name? (for migration)
- What mutations are needed? (determines which FormRequests to create)
