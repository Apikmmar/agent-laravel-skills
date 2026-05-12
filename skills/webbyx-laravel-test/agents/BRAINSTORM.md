# Brainstorm — Test Coverage Planning

Plan coverage first, write tests second. Clarify what exists before generating any test code.

> **HARD STOP — Do NOT write any code, run any commands, or create any files until the user explicitly confirms the plan. This is non-negotiable.**

## Step 1 — Clarify First

Ask if not already provided:
- What module and model are being tested?
- What mutations exist? (one test method per mutation operation: create, update, delete, custom)
- What queries exist? (paginated listing, listing, detail — confirm which apply)
- What fields does each mutation input require? (determines validation test cases)
- Is there a `User` factory already set up in the project?
- Is `phpunit.xml` set to `DB_CONNECTION=mysql`? (read it before proceeding — if sqlite, flag it and update to mysql)

## Step 2 — Coverage Plan

Output this before any code. Ask "Does this plan look correct?" and **wait for explicit confirmation before proceeding to Step 3**. Do not proceed if the user has not yet responded.

```
## Test Coverage Plan
### 1. Module & Model
### 2. DB Connection (confirm mysql in phpunit.xml)
### 3. MutationTest Methods
     For each mutation: happy path, validation error, unauthorized, DB rollback
### 4. QueryTest Methods
     For each query: happy path (data + paginatorInfo if paginated), not found (if detail), unauthorized
### 5. Shared Fixtures (setUp() candidates — user factory, related models)
### 6. Validation Cases (one per required field, plus type/format checks)
```

## Step 3 — Execute

- Run `php artisan module:make-test {ModelName}MutationTest {ModuleName}` and `{ModelName}QueryTest {ModuleName}` first — edit the stubs, never create from scratch
- Follow `webbyx-laravel-test/SKILL.md` for all patterns (mutation, query, unauthorized, validation, rollback)

## Non-Negotiables

- No code before plan is confirmed
- Always verify `phpunit.xml` uses `mysql` — flag and update if `sqlite` is set
- Always test unauthorized access for every `@guard`-protected operation
- Always test validation — every required field needs a missing/invalid case
- Always test DB rollback for every mutation
- Always `RefreshDatabase` — never share state between tests
- Never hardcode IDs — always use factory-created model IDs
