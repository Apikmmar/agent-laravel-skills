# Brainstorm — Model Design

Design first, code second. Clarify the model's structure before generating any code.

> **HARD STOP — Do NOT write any code, run any commands, or create any files until the user explicitly confirms the plan. This is non-negotiable.**

## Step 1 — Clarify First

Ask if not already provided:
- What module does this model belong to?
- What is the exact table name? (Laravel pluralizes incorrectly for some names — always confirm)
- Does a `BaseModel.php` exist inside `Modules/{ModuleName}/Models/`? (determines which class to extend)
- What columns exist on the table? (determines `$fillable`)
- Are there any JSON columns? (adds `$casts`)
- Are there any sensitive columns (PII, tokens, secrets)? (adds `'encrypted'` cast — ask before defining)
- What relationships are needed? (hasOne, hasMany, belongsTo, belongsToMany)
- For non-conventional foreign key or local key column names — confirm exact names

## Step 2 — Model Plan

Output this before any code. Ask "Does this plan look correct?" and **wait for explicit confirmation before proceeding to Step 3**. Do not proceed if the user has not yet responded.

```
## Model Plan
### 1. Module & Table
### 2. Base Class (BaseModel or Illuminate\Database\Eloquent\Model)
### 3. Traits (SoftDeletes always; HasFactory only if factory exists)
### 4. Fillable Columns
### 5. Casts (JSON columns → array; encrypted columns; others as needed)
### 6. Relationships (method name, type, foreign key, local key)
```

## Step 3 — Execute

- Run `php artisan module:make-model {ModelName} {ModuleName}` first — edit the stub, never create from scratch
- Check `Modules/{ModuleName}/Models/` for an existing `BaseModel.php` before deciding what to extend
- Follow `webbyx-laravel-model/SKILL.md` for all conventions

## Non-Negotiables

- No code before plan is confirmed
- Always `SoftDeletes` — no exceptions
- Always explicit `$fillable` — never `$guarded`
- Always explicit `$table` — never rely on Laravel's pluralization
- Never use `$request->all()` in model methods — always `$request->validated()`
