# Brainstorm — Job Design

Design first, code second. Clarify the async operation before generating any code.

> **HARD STOP — Do NOT write any code, run any commands, or create any files until the user explicitly confirms the plan. This is non-negotiable.**

## Step 1 — Clarify First

Ask if not already provided:
- What is the operation being moved to this job? (email, API call, report, bulk processing — be specific)
- What module does this job belong to?
- What is the expected record volume? (determines chunking strategy — see thresholds below)
- Which queue should it use?
  - `high` — time-sensitive (notifications, auth events)
  - `default` — standard async work
  - `low` — heavy/slow (reports, exports, bulk processing)
- Is this job business-critical? (does failure need alerting beyond logging?)
- What triggers this job? (mutation, scheduled command, another job)
- What data does the job need injected — model instance, ID, array?

## Step 2 — Job Plan

Output this before any code. Ask "Does this plan look correct?" and **wait for explicit confirmation before proceeding to Step 3**. Do not proceed if the user has not yet responded.

```
## Job Plan
### 1. Operation (what the job does — single responsibility)
### 2. Queue Assignment & Justification
### 3. Constructor Payload (what is injected)
### 4. Record Volume & Chunking Strategy
     < 500       → direct get/update
     500–5k      → chunk(500)
     5k–50k      → chunkById(1000)
     50k+        → dispatch another job, chunk inside
### 5. handle() Logic (steps in order, no loops over DB)
### 6. failed() Logic (logging, alerting if business-critical)
### 7. Retry Config ($tries, $backoff)
```

## Step 3 — Execute

- Run `php artisan module:make-job {JobName}Job {ModuleName}` first — edit the stub, never create from scratch
- Follow `webbyx-laravel-job/SKILL.md` for all conventions

## Non-Negotiables

- No code before plan is confirmed
- Always implement both `handle()` and `failed()` — never leave `failed()` absent
- No for loops over DB inside `handle()` — use `whereIn`, `insert([])`, `upsert()`, `chunk()`
- Always define `$queue`, `$tries`, and `$backoff`
- Always implement `ShouldQueue`
- Always log errors in `failed()` with sufficient context to diagnose the failure
