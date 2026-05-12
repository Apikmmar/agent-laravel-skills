# Brainstorm — Migration Design

Design first, code second. Clarify the table structure before generating any code.

## Step 1 — Clarify First

Ask if not already provided:
- What is the exact table name? (snake_case)
- What columns are needed? For each column: name, type, nullable or not
- Are there any enum columns? If yes — what are the allowed values?
- Are there any JSON columns?
- Are there foreign keys? If yes — which tables do they reference, and what is the exact column name?
- For each foreign key — what is the delete behaviour? (`cascadeOnDelete`, `nullOnDelete`, or `restrictOnDelete`)
- Which columns will be frequently filtered or sorted? (determines indexes)
- Are any columns required to be unique?

## Step 2 — Migration Plan

Output this before any code. Ask "Does this plan look correct?" and wait for confirmation.

```
## Migration Plan
### 1. Table Name
### 2. Columns (in order: id → regular columns → timestamps → softDeletes)
### 3. Enum Values (if any — confirm values are lowercase in migration)
### 4. Foreign Keys (constraint name: fk_{shortTable}_{referencedTable}, delete behaviour)
### 5. Indexes (foreign key columns, filtered/sorted columns, unique columns)
```

## Step 3 — Execute

- Run `php artisan make:migration "create_{table_name}_table"` first — edit the stub, never create from scratch
- Follow `webbyx-laravel-migration/SKILL.md` for column order and foreign key naming
- Flag any index that may be missing based on the expected query patterns

## Non-Negotiables

- No code before plan is confirmed
- Always `softDeletes()` — no exceptions
- Always anonymous class: `return new class extends Migration`
- Always implement both `up()` and `down()`
- Always name foreign key constraints: `fk_{shortTable}_{referencedTable}`
- Always specify delete behaviour on every foreign key — never leave it implicit
- Enum values are lowercase in migration, UPPERCASE in GraphQL schema
