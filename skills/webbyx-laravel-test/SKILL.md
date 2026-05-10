---
name: laravel-test-generator
description: Use when generating PHPUnit tests for a Laravel GraphQL module. Triggers when user asks to write tests, generate test files, or cover a module's mutations and queries with tests.
---

## Rule
Tests live in `Modules/{ModuleName}/Tests/Feature/`. One test class per operation group — mutations in `{Model}MutationTest.php`, queries in `{Model}QueryTest.php`. All tests use PHPUnit via `Tests\TestCase`, `RefreshDatabase`, and Lighthouse's `MakesGraphQLRequests` trait.

**Tests must run against MySQL — never SQLite.** Controllers use `DB::beginTransaction()` which conflicts with SQLite under `RefreshDatabase` (SQLite does not support nested transactions). Before generating any test, run the config check script and confirm it passes:

This repo is used as a git submodule at `{project}/.claude/`. Run from the **project root**:

**Windows:** `.\.claude\scripts\check-test-config\check-test-config.ps1 -ProjectPath "{C:\path\to\project}"`
**Mac / Linux:** `chmod +x ./.claude/scripts/check-test-config/check-test-config.sh && ./.claude/scripts/check-test-config/check-test-config.sh {/path/to/project}`

If the script fails, update `DB_CONNECTION` in `phpunit.xml` to `mysql` before proceeding.

## File Creation

Run the script first — AI edits the generated stubs, never creates from scratch:

**Windows:**
```powershell
.\.claude\scripts\make-test\make-test.ps1 -ModuleName {ModuleName} -ModelName {ModelName} -ProjectPath "{C:\path\to\project}"
```
**Mac / Linux:**
```bash
./.claude/scripts/make-test/make-test.sh {ModuleName} {ModelName} {/path/to/project}
```

Creates both `{ModelName}MutationTest.php` and `{ModelName}QueryTest.php`.

## Why
Tests are scoped per module so they run independently and travel with the module. Separating mutation tests from query tests keeps each class focused and easy to scan. MySQL matches the production database — SQLite has subtle differences in type handling, JSON support, and transaction behaviour that can mask real bugs.

## Conventions

### File Location
```
Modules/{ModuleName}/Tests/Feature/{ModelName}MutationTest.php
Modules/{ModuleName}/Tests/Feature/{ModelName}QueryTest.php
```

### Class Structure
```php
namespace Modules\{Module}\Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Nuwave\Lighthouse\Testing\MakesGraphQLRequests;
use Tests\TestCase;

class {Model}MutationTest extends TestCase
{
    use RefreshDatabase, MakesGraphQLRequests;
}
```

- Extends `Tests\TestCase` — the project base class
- Always use `RefreshDatabase` — never share state between tests
- Always use `MakesGraphQLRequests` — gives access to `$this->graphQL()`
- Auth via `$this->actingAs($user)` before the request

### Required Coverage — Mutations

For every mutation (`create`, `update`, `delete`, custom):

| Test | What to assert |
|---|---|
| Happy path | `status: true`, correct `message`, `data` fields present |
| Validation error | Missing or invalid input returns GraphQL validation error |
| Unauthorized | Unauthenticated request returns `Unauthenticated.` error |
| DB rollback | Forced failure does NOT persist data — assert DB count unchanged |

### Required Coverage — Queries

| Test | What to assert |
|---|---|
| Paginated listing | Returns `data` array and `paginatorInfo` fields |
| Listing | Returns correct array of records |
| Detail — found | Returns correct model fields |
| Detail — not found | Returns a GraphQL error |
| Unauthorized | Unauthenticated request returns `Unauthenticated.` error |

### GraphQL Mutation Pattern
```php
$user = User::factory()->create();
$this->actingAs($user);

$response = $this->graphQL('
    mutation {
        createPost(input: { title: "Test Title", body: "Body text", user_id: ' . $user->id . ' }) {
            status
            message
            data {
                id
                title
            }
        }
    }
');

$response->assertJson([
    'data' => [
        'createPost' => [
            'status'  => true,
            'message' => 'Successfully created a post.',
        ],
    ],
]);
```

### GraphQL Query Pattern
```php
$user = User::factory()->create();
$this->actingAs($user);

$response = $this->graphQL('
    {
        paginatedPosts(first: 10) {
            data { id title }
            paginatorInfo { total currentPage }
        }
    }
');

$response->assertJsonStructure([
    'data' => [
        'paginatedPosts' => [
            'data'          => [['id', 'title']],
            'paginatorInfo' => ['total', 'currentPage'],
        ],
    ],
]);
```

### Unauthorized Pattern
```php
// Do NOT call actingAs — send unauthenticated request
$response = $this->graphQL('mutation { createPost(input: { title: "x" }) { status } }');
$response->assertGraphQLErrorMessage('Unauthenticated.');
```

### Validation Error Pattern
```php
$this->actingAs(User::factory()->create());

$response = $this->graphQL('mutation { createPost(input: { title: "" }) { status } }');
$response->assertGraphQLValidationError('input.title', 'The title field is required.');
```

### DB Rollback Pattern
```php
// Assert record count is unchanged after a forced failure
$this->assertDatabaseCount('posts', 0);
```

### setUp Pattern
Use `setUp()` to create shared fixtures across methods in the same class:
```php
protected function setUp(): void
{
    parent::setUp();
    $this->user = User::factory()->create();
}
```

## Non-Negotiables
- Always `RefreshDatabase` — never let data bleed between tests
- Always MySQL — never SQLite; verify `phpunit.xml` before writing tests and flag if `DB_CONNECTION=sqlite` is set
- Always `MakesGraphQLRequests` — never use raw HTTP for GraphQL
- Always test unauthorized access — never assume `@guard` works without a test
- Always test validation — every required field must have a missing/invalid case
- Never hardcode IDs — always use factory-created model IDs
- `paginatedListing` tests must assert `paginatorInfo`
- `detail` tests must cover both found and not-found cases

## Clarifying Questions
- What is the module and model name?
- What mutations exist? (determines MutationTest methods)
- What queries exist? (determines QueryTest methods)
- What fields does each input require? (determines validation cases)
- Is there a User factory already set up?

## Reference
See `references/TEST.md` for real examples.
