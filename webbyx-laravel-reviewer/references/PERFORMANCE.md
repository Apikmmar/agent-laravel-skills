# Performance Review Methodology

Check for:

### 1. N+1 Queries
- Check every loop that accesses a relationship — must use eager loading via `with()`
- Check `detail` and `listing` methods for missing `with()` on accessed relationships
- Check mutators that fetch related models inside loops

### 2. For Loops Over DB Operations
- Check for `foreach` that calls `create()`, `update()`, `delete()`, or `find()` per iteration
- Must be replaced with `whereIn`, `insert([])`, `upsert()`, or `chunk()`

### 3. Unbounded Queries
- Check for `->get()` or `->all()` without pagination on listing endpoints
- Listing resolvers must return `Builder` for `@paginate` — never a collection

### 4. Redundant DB Calls
- Check for the same record being fetched more than once in the same method
- Should fetch once, assign to variable, reuse

### 5. Blocking Heavy Operations
- Check for email sending, report generation, external API calls, or bulk processing inside the request lifecycle
- These must be dispatched as Jobs — never called synchronously in a mutator or service

### 6. Missing Cache
- Check read-heavy queries that run on every request without caching
- Dropdown queries, config lookups, and aggregations are prime candidates for `Cache::remember()`
- Check mutations for missing `Cache::forget()` after writes that affect cached data

### 7. Missing Indexes
- Check migration files for foreign key columns, frequently filtered columns, and sort columns without `$table->index()`
- Flag columns used in `->where()` or `->orderBy()` that have no index

### 8. Inefficient Existence Checks
- Check for `->count() > 0` — must be replaced with `->exists()`

### 9. Collection Filtering Instead of Query Filtering
- Check for `->all()->where()` or `->get()->filter()` — filtering must happen in the query, not on the collection

### 10. Bulk Operation Patterns
- Check bulk inserts using individual `create()` in a loop — must use `insert([])`
- Check bulk updates using individual `save()` in a loop — must use `whereIn()->update()`
- Check bulk upserts — must use `upsert()`

## Output Format

Group findings by severity:

```
[SEVERITY] path/to/File.php:line
Issue: <what is wrong>
Fix: <what to do instead>
```

Severity levels:
- `CRITICAL` — causes significant slowdown at any scale (N+1 in listing, unbounded query, loop over DB writes)
- `HIGH` — causes slowdown at moderate scale (missing index on filtered column, blocking heavy op)
- `MEDIUM` — inefficient but not immediately damaging (missing cache, redundant fetch, collection filtering)
- `LOW` — minor improvement (exists() vs count(), minor eager load gap)

Severity order: `CRITICAL` → `HIGH` → `MEDIUM` → `LOW`

End with a short summary: total findings per severity and one overall performance risk assessment sentence.

If no issues found, state: `No performance issues found.`
