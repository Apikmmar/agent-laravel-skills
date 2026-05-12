---
name: webbyx-laravel-model
description: Use when creating or updating an Eloquent model inside a module. Triggers when user asks to create a model, add relationships, define fillable fields, or set up model properties.
---

@agents/BRAINSTORM.md
@agents/CONVENTION.md
@agents/PRINCIPLES.md
@agents/SECURITY.md
@agents/PERFORMANCE.md

## Rule
All models live inside `Modules\{ModuleName}\Models\`, must always use `SoftDeletes`, and must explicitly define `$table` and `$fillable`. Never use `$guarded`.

## Why
Without explicit `$table`, Laravel pluralizes incorrectly for some names.

## File Creation

Run this command from the project root first — AI edits the generated stub, never creates from scratch:

```bash
php artisan module:make-model {ModelName} {ModuleName}
```

## Conventions

### Base Class
- All models live inside `Modules\{ModuleName}\Models\` — never import or extend from `app/Models/`
- If a `BaseModel.php` exists inside the same module (`Modules\{ModuleName}\Models\BaseModel.php`), extend it
- If no module-level `BaseModel` exists, extend `Illuminate\Database\Eloquent\Model` directly
- Never guess — check inside the module's `Models/` folder before deciding which to extend

### Traits
- Always add `SoftDeletes`
- Add `HasFactory` only when a factory exists or will be created
- Always list traits after `use` in alphabetical order

### Fillable
- Always define `$fillable` as an explicit array — never leave it empty or use `$guarded`

### Casts
- Cast JSON columns as `'array'`
- Only define `$casts` when at least one column needs it

### Relationships
- Method names in camelCase matching the related model name
- Always specify foreign key and local key explicitly on non-conventional column names

### Timestamps
- AVOID override `CREATED_AT` / `UPDATED_AT` unless the column names differ from Laravel defaults

## Clarifying Questions
- What module does this model belong to?
- What is the exact table name?
- Does the table have any JSON columns? (adds `$casts`)
- What relationships are needed?

## Reference
See `references/MODEL.md` for real examples.
