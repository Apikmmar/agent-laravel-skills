# Coding Principles for Tests

## Single Responsibility
- One test method tests one thing — never combine happy path + validation error in a single method
- Method names must describe the scenario: `test_create_post_returns_success`, `test_create_post_fails_without_title`, `test_create_post_returns_unauthenticated`

## DRY
- Shared fixtures (user, parent model) belong in `setUp()` — never duplicated across methods
- Shared GraphQL query strings used in multiple methods should be extracted to a private method or constant
- Never copy-paste assertion blocks — if the same assertions appear in three methods, extract a private assertion helper

## Clarity Over Brevity
- Test method names should be readable without looking at the body — name the scenario explicitly
- Prefer `assertJson(['data' => ['createPost' => ['status' => true]]])` over asserting the full response — assert only what the test is verifying

## Isolation
- Every test must be independent — `RefreshDatabase` handles DB state, but avoid any static or shared state between methods
- Never rely on test execution order — each method must work in isolation
- Never use `$this->assertTrue(true)` as a placeholder — every test must have a meaningful assertion

## Modularity
- MutationTest and QueryTest are separate classes — never mix mutation and query tests in one file
- If a model has many mutations, group related methods with `/** @group create */` annotations for clarity
