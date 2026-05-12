# Security Rules for Tests

Every `@guard`-protected operation must have an unauthorized test. These rules apply when writing or reviewing test code.

## Authentication Coverage
- Every mutation and query protected by `@guard` must have an `unauthorized` test method
- Unauthorized tests must NOT call `$this->actingAs()` — send the request with no authenticated user
- Assert `Unauthenticated.` error using `$response->assertGraphQLErrorMessage('Unauthenticated.')`
- Never assume `@guard` works without a test proving it

## Validation Coverage
- Every required input field must have a test asserting the validation error when it is missing or invalid
- Use `$response->assertGraphQLValidationError('input.field', 'The field is required.')` — never assert raw JSON for validation
- Test both missing fields and invalid types/formats when the field has format constraints (email, min length, enum values)

## Sensitive Data Exposure
- Never assert that passwords, tokens, or secrets appear in GraphQL response data
- If a mutation returns a token (e.g. login), assert only that the field exists and is non-null — never hardcode an expected token value
- Never log or print sensitive values inside test output (avoid `dd()`, `dump()` on auth tokens or PII)

## Mass Assignment
- Never pass raw arrays with extra fields in test mutations hoping validation catches them — test the validated path, not the bypass path
- Test that fields not in `$fillable` are not persisted by asserting the DB state directly with `assertDatabaseHas` / `assertDatabaseMissing`

## DB Rollback Testing
- Every mutation must have a rollback test: force a failure after the first DB write and assert the record count is unchanged
- Use `assertDatabaseCount('table', 0)` or `assertDatabaseMissing` to confirm no partial data was committed
