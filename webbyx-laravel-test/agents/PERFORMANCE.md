# Performance Rules for Tests

Apply these rules when writing test setup and fixtures. Poorly written tests can cause slow suites, memory spikes, and false failures under load.

## Test Setup — Anti-Patterns to Avoid

- **No factory loops** — never call `User::factory()->create()` inside a `foreach` or `for` loop in `setUp()`; use `factory()->count(N)->create()` instead
- **No redundant DB calls in setUp** — create shared fixtures once in `setUp()`, not inside each individual test method
- **No eager loading bypassed in assertions** — if asserting on a relationship, load it explicitly; never rely on lazy loading inside an assertion chain

## setUp() Pattern

Use `setUp()` to create shared fixtures once per test class. Do not recreate the same user or parent record in every test method:

```php
protected function setUp(): void
{
    parent::setUp();
    $this->user = User::factory()->create();
}
```

## Factory Usage

- Use `Model::factory()->create()` for persisted records
- Use `Model::factory()->make()` for in-memory instances when DB persistence is not needed
- Use `Model::factory()->count(N)->create()` for bulk fixture creation — never loop over `create()`

## Pagination Tests

- Always seed enough records to exceed `first: 1` when testing pagination — assert `paginatorInfo.total` matches the seeded count
- Do not seed thousands of records in tests — keep fixture counts minimal (3–10 records is sufficient)

## Assertion Efficiency

- Prefer `assertDatabaseCount` and `assertDatabaseHas` over fetching records and asserting in PHP
- Use `assertJsonStructure` for structure checks and `assertJson` for value checks — do not mix them on the same response for the same field
