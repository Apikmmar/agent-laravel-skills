---
name: laravel-model
description: Use when creating or updating an Eloquent model inside a module. Triggers when user asks to create a model, add relationships, define fillable fields, or set up model properties.
---

## Rule
All models live inside `Modules\{ModuleName}\Models\`, must always use `SoftDeletes`, and must explicitly define `$table` and `$fillable`. Never use `$guarded`.

## Why
Without explicit `$table`, Laravel pluralizes incorrectly for some names.

## Conventions

### Base Class
- Extend `Illuminate\Database\Eloquent\Model` for standard models

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
