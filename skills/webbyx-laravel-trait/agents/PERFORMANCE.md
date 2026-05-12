# Performance Rules

Apply to every function that touches the database, cache, or external service. No exceptions.

## Anti-Patterns — Never Generate

- **No for loops over DB** — never call `find()`, `update()`, or `create()` inside a loop; use `whereIn`, `insert([])`, `upsert()`
- **No N+1 queries** — always identify relationships that will be accessed and eager load with `with()`
- **No redundant DB calls** — never fetch the same record twice; fetch once, assign to variable, reuse
- **No blocking heavy operations in the request** — anything slow (email, API calls, report generation, bulk processing) must be dispatched as a Job

## Bulk Operations — Chunking Thresholds

Apply based on expected record volume — always clarify during brainstorm:

| Record Count | Pattern |
|---|---|
| < 500 | `->get()` or `->update()` directly |
| 500 – 5,000 | `->chunk(500, fn)` |
| 5,000 – 50,000 | `->chunkById(1000, fn)` |
| 50,000+ | Dispatch a Job, chunk inside the job |

- Bulk inserts: always `Model::insert($rows)` — never `create()` in a loop
- Bulk upserts: `Model::upsert($rows, ['id'], ['col1', 'col2'])`
- Never load all records into memory then loop — always operate at the DB level

## Caching — Redis

Default cache driver is Redis. Apply caching on:
- Frequently read, rarely written data (dropdowns, config, lookups)
- Expensive aggregation or join queries
- External API responses

Rules:
- Pattern: `Cache::remember("module:entity:id", ttl, fn)`
- Always `Cache::forget()` the relevant key on any mutation that affects that data
- Key format: `{module}:{entity}:{identifier}` — e.g. `post:listing:user_5`
- Always set an explicit TTL — never cache indefinitely

## Jobs — When to Dispatch

Dispatch a Job instead of running inline when the operation:
- Sends email, SMS, or push notification
- Calls an external API
- Generates a report or export file
- Processes more than 1,000 records
- Has side effects that don't need to block the response

Queue assignment:
- `high` — time-sensitive (notifications, auth events)
- `default` — standard async work
- `low` — heavy/slow (reports, exports, bulk processing)

Every job must implement both `handle()` and `failed()` — never leave `failed()` absent.

## Query Optimisation

- Select only needed columns — avoid `SELECT *` on large tables
- Always paginate listing queries — never return unbounded collections to the client
- Use `exists()` instead of `count() > 0` for existence checks
- Filter, sort, and group in the query — never fetch all then filter in PHP
- Always index foreign keys and frequently filtered/sorted columns — flag these in the migration plan
- Flag any query that could return unbounded results at scale and add pagination or a hard limit
