# Brainstorm — Service Design

Design first, code second. Clarify what the service is for before generating any code.

## Step 1 — Clarify First

Ask if not already provided:
- What business logic or validation is being extracted into this service?
- Which classes currently contain this logic (or will need it)? (must be more than one — otherwise keep it as a private method in the Controller)
- Does the logic involve model lookups or cross-entity validation? (service is justified)
- What module does this service belong to?
- Is a `BaseService` needed — i.e., are there multiple services in this module that share utility methods?
- Does this service interact with external APIs, queues, or the cache?

## Step 2 — Service Plan

Output this before any code. Ask "Does this plan look correct?" and wait for confirmation.

```
## Service Plan
### 1. Purpose (what shared logic this service owns)
### 2. Callers (which classes will inject or use it)
### 3. Class Name & Namespace
### 4. BaseService (yes/no — justify if yes)
### 5. Public Methods (name, inputs, return type)
### 6. Private Helpers (fetch/lookup methods — every DB fetch must be a private method)
### 7. External Dependencies (cache, queue, APIs)
```

## Step 3 — Execute

- No artisan command exists — create the file directly at `Modules/{ModuleName}/Services/{ServiceName}Service.php`
- Follow `webbyx-laravel-service/SKILL.md` for all conventions
- DB transactions stay in the Controller — never move them into the service

## Non-Negotiables

- No code before plan is confirmed
- Services exist only when logic is reused across more than one class — single-use logic stays as a private method in the Controller
- No DB transactions inside services — those belong in the Controller
- No response building inside services — Controllers return raw arrays
- Every DB fetch must be a private method — never inline
- No N+1 queries — eager load relationships explicitly
