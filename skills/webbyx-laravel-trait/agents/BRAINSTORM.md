# Brainstorm — Trait Design

Design first, code second. Clarify the reusable behaviour before generating any code.

## Step 1 — Clarify First

Ask if not already provided:
- What is the reusable behaviour or capability this trait provides?
- Which classes or modules will use it? (must be more than one — otherwise keep it as a private method)
- How should the trait be named? (verb-based for behaviour: `SendsPushNotification`; noun-based for capability: `HasCustomField`)
- Does the trait perform any DB operations? If yes — what tables and relationships are involved?
- Does the trait interact with external services (cache, queue, APIs)? If yes — which ones?
- Are there complex steps that should be broken into private helper methods?

## Step 2 — Trait Plan

Output this before any code. Ask "Does this plan look correct?" and wait for confirmation.

```
## Trait Plan
### 1. Name & Purpose (what the trait gives to the class using it)
### 2. Consumers (which classes/modules use it — must be 2+)
### 3. Public Methods (name, inputs, return type)
### 4. Private Helpers (break complex logic here — keeps public methods readable)
### 5. DB Operations (tables, relationships, eager loading strategy)
### 6. External Dependencies (cache keys, queue names, API clients)
```

## Step 3 — Execute

- No artisan command exists — create the file directly at `app/Traits/{TraitName}.php`
- Namespace must be `App\Traits` — never inside a module folder
- Follow `webbyx-laravel-trait/SKILL.md` for all conventions

## Non-Negotiables

- No code before plan is confirmed
- One trait per file — one concern only; split if the trait does two unrelated things
- Never create a trait for single-use logic — that belongs as a private method in the class
- No constructor, no dependency injection — use `new ClassName()` or static calls
- No DB loops — use `whereIn`, bulk operations, eager loading
- No raw SQL — always Eloquent or Query Builder with parameter binding
- Namespace must be `App\Traits`
