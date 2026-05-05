---
name: laravel-migration
description: Use when creating a database migration. Triggers when user asks to create a migration, add a table, add columns, define foreign keys, or run make:migration.
---

## Rule
All migrations must always include `softDeletes()` and use named foreign key constraints following `fk_{shortTable}_{referencedTable}` with explicit delete behaviour.

## Why
`softDeletes()` is required on all tables to match the model convention. Named foreign keys make constraints easier to identify and drop.

## Conventions

### Structure
- Always anonymous class `return new class extends Migration`
- `up()` and `down()` must both be implemented — `down()` uses `Schema::dropIfExists()`

### Columns Order
1. `$table->id()`
2. Regular columns
3. `$table->timestamps()`
4. `$table->softDeletes()`
5. Foreign key definitions

### Columns
- Use `unsignedBigInteger` for foreign key columns
- Use `enum` for fixed value sets — values in lowercase
- Nullable columns always chain `->nullable()`

### Foreign Keys
- Always name the constraint: `fk_{shortTable}_{referencedTable}`
- Always specify delete behaviour: `cascadeOnDelete()`, `restrictOnDelete()`, or `nullOnDelete()`
- Define all foreign keys after all columns

## Clarifying Questions
- What is the table name?
- What columns are needed?
- Are there foreign keys? If yes — which tables do they reference?
- For each foreign key — what is the delete behaviour? (`cascadeOnDelete`, `nullOnDelete`, or `restrictOnDelete`)
- Any enum columns? If yes — what are the allowed values?

## Reference
See `references/MIGRATION.md` for real examples.
