---
name: job
description: Use when creating a Laravel Job class. Triggers when user asks to create a job, dispatch async work, queue a heavy operation, or move blocking logic off the request lifecycle.
---

## Rule
Jobs live in `Modules/{ModuleName}/Jobs/`. Every job must implement `handle()` and `failed()`. All performance rules apply inside jobs — no for loops over DB, use bulk operations, chunk large datasets.

## Why
Jobs run async on the queue — they can process large volumes safely. But poorly written jobs cause queue backlogs, memory spikes, and silent failures. The same performance rules that apply to services apply here.

## Conventions

### File Location
```
Modules/{ModuleName}/Jobs/{JobName}Job.php
```

### Class Naming
- PascalCase + `Job` suffix: `SendEmailJob`, `GenerateReportJob`, `BulkUpdatePostsJob`
- Namespace: `Modules\{Module}\Jobs`

### Class Structure
- Implement `ShouldQueue`
- Use traits: `Dispatchable`, `InteractsWithQueue`, `Queueable`, `SerializesModels`
- Always define `$queue` — use `high`, `default`, or `low`
- Always define `$tries` — default `3`
- Always define `$backoff` — default `[10, 30, 60]` (seconds between retries)

### Queue Assignment
| Queue | Use for |
|---|---|
| `high` | Time-sensitive — emails, OTP, notifications |
| `default` | Standard async ops — webhooks, model updates |
| `low` | Heavy/slow — reports, exports, bulk processing |

### handle()
- Single responsibility — one job does one thing
- No for loops over DB operations — use `whereIn`, `insert([])`, `upsert()`, `chunk()`
- Apply chunking thresholds from the performance rules:
  - < 500 records: direct query
  - 500 – 5,000: `chunk(500)`
  - 5,000 – 50,000: `chunkById(1000)`
  - 50,000+: split into multiple dispatched jobs

### failed()
- Always implement — never leave it absent
- Always log the error with context
- Add notification or alert logic if the job is business-critical

### Dispatching
- Standard: `SendEmailJob::dispatch($model)`
- With queue: `->onQueue('low')`
- Delayed: `->delay(now()->addMinutes(10))`

## Reference
See `references/JOB.md` for real examples.

## Clarifying Questions
- What is the async operation being moved to this job?
- Which queue should it use? (`high` / `default` / `low`)
- What is the expected record volume? (determines chunking strategy)
- Does failure need alerting beyond logging?
