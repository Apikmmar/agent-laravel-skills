# Performance — Fast Function Design

This agent activates on every code generation request alongside the other global agents. It enforces performance-first patterns across all functions — mutators, query resolvers, services, and jobs.

---

## Core Rule

**No function is generated without considering its performance impact.** Every method that touches the database, cache, or external service must follow the rules below.

---

## Anti-Patterns — Never Generate These

### No for loops over DB operations
```php
// NEVER — fires one query per iteration
foreach ($ids as $id) {
    Post::find($id)->update(['status' => 'published']);
}

// ALWAYS — single query
Post::whereIn('id', $ids)->update(['status' => 'published']);
```

### No N+1 queries
```php
// NEVER — fires one query per post
$posts = Post::all();
foreach ($posts as $post) {
    $post->user->name;
}

// ALWAYS — eager load
$posts = Post::with('user')->get();
```

### No redundant DB calls
```php
// NEVER — fetches same record twice
$post = Post::find($id);
Post::find($id)->update([...]);

// ALWAYS — fetch once, reuse
$post = Post::findOrFail($id);
$post->update([...]);
```

### No blocking heavy operations in the request lifecycle
```php
// NEVER — blocks the response
$this->sendEmail($user);
$this->generateReport($data);

// ALWAYS — dispatch to queue
SendEmailJob::dispatch($user);
GenerateReportJob::dispatch($data);
```

---

## Bulk Operations — Chunking Thresholds

Always clarify record volume during brainstorm and apply the correct pattern:

| Record Count | Pattern |
|---|---|
| < 500 | `->get()` or `->update()` directly |
| 500 – 5,000 | `->chunk(500, fn)` |
| 5,000 – 50,000 | `->chunkById(1000, fn)` |
| 50,000+ | Dispatch a Job, process in chunks inside the job |

For bulk inserts, always use `insert([])` over individual `create()` calls:
```php
// NEVER
foreach ($rows as $row) {
    Post::create($row);
}

// ALWAYS
Post::insert($rows);
```

For bulk upserts, use `upsert()`:
```php
Post::upsert($rows, ['id'], ['title', 'content', 'status']);
```

---

## Caching — Redis

Default cache driver is **Redis**. Apply caching on:
- Frequently read, rarely written data (dropdowns, config, lookups)
- Expensive aggregation queries
- External API responses

### Pattern
```php
$result = Cache::remember("posts:user:{$userId}", now()->addMinutes(30), function () use ($userId) {
    return Post::where('user_id', $userId)->get();
});
```

### Cache Invalidation
Always invalidate on mutation:
```php
Cache::forget("posts:user:{$userId}");
```

### Cache Key Convention
```
{module}:{entity}:{identifier}
// e.g. post:listing:user_5, workflow:detail:42
```

---

## Jobs — Async Operations

Dispatch a Job when the operation:
- Sends email, SMS, or push notification
- Calls an external API
- Generates a report or export
- Processes more than 1,000 records
- Has side effects that do not need to block the response

### Default Queue
- Driver: `redis`
- Queue name: `default` for standard, `high` for time-sensitive, `low` for reports/exports

```php
SendEmailJob::dispatch($user)->onQueue('high');
GenerateReportJob::dispatch($filters)->onQueue('low');
```

### Job Structure
Every job must implement:
- `handle()` — main logic
- `failed(Throwable $e)` — failure handling (log, notify, or retry logic)

```php
public function failed(Throwable $e): void
{
    Log::error('JobName failed', ['error' => $e->getMessage()]);
}
```

---

## Query Optimisation

- Always select only needed columns — avoid `SELECT *` on large tables
- Always paginate listing queries — never return unbounded collections
- Always index foreign keys and frequently filtered columns (flag in migration plan)
- Use `exists()` instead of `count()` for existence checks

```php
// NEVER
if (Post::where('user_id', $id)->count() > 0)

// ALWAYS
if (Post::where('user_id', $id)->exists())
```

---

## Collections vs Queries

- Filter, sort, and group **in the query** — not on a PHP collection after fetching
- Only use Collection methods when data is already in memory and a second query would be wasteful

```php
// NEVER — fetches all then filters in PHP
Post::all()->where('status', 'published');

// ALWAYS — filter in query
Post::where('status', 'published')->get();
```

---

## Brainstorm Integration

During the architecture plan, the brainstorm agent must include a **Performance Considerations** section covering:

- Expected record volume for each query
- Which queries need eager loading
- Which operations need chunking and at what threshold
- Which operations should be async (Jobs)
- Which data should be cached and for how long
- Which columns need database indexes
