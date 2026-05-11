# Testing Review Methodology

## Required Coverage — Mutations

For every mutation (`create`, `update`, `delete`, custom):

| Test | What to assert |
|---|---|
| Happy path | `status: true`, correct `message`, `data` fields present |
| Validation error | Missing or invalid input returns GraphQL validation error |
| Unauthorized | Unauthenticated request returns `Unauthenticated.` error |
| DB rollback | Forced failure does NOT persist data — assert DB count unchanged |

## Required Coverage — Queries

| Test | What to assert |
|---|---|
| Paginated listing | Returns `data` array and `paginatorInfo` fields |
| Listing | Returns correct array of records |
| Detail — found | Returns correct model fields |
| Detail — not found | Returns a GraphQL error |
| Unauthorized | Unauthenticated request returns `Unauthenticated.` error |

## Bad Practices to Flag

- Hardcoded IDs instead of factory-created model IDs
- Missing `RefreshDatabase` — data bleeding between tests
- SQLite instead of MySQL (`DB_CONNECTION` in `phpunit.xml`)
- Raw HTTP requests instead of `$this->graphQL()`
- Missing `paginatorInfo` assertion on paginated queries
- Missing `actingAs()` before authenticated requests

## Output Format

Group findings by type:

```
[TYPE] path/to/TestFile.php:line
Issue: <what is missing or wrong>
Fix: <what to do instead>
```

Types: `MISSING COVERAGE` | `WRONG ASSERTION` | `BAD PRACTICE` | `IMPROVEMENT`

End with a short summary: total findings and one overall test quality assessment sentence.

If no issues found, state: `Test coverage looks good.`
