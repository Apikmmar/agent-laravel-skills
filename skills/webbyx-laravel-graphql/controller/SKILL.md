---
name: graphql-controller
description: Use when creating the HTTP Controller for a GraphQL module. Triggers when user asks to create a controller, implement business logic for a mutation or query, or wire up the execution layer behind a resolver.
---

## Rule
Every module has one Controller at `Http/Controllers/{Model}Controller.php`. It is the execution boundary for all mutations and queries — it owns business logic, DB transactions, and responses. Resolvers (Mutator/Query) are proxies that delegate to it.

## Why
Single Responsibility: Resolvers handle the GraphQL boundary, the Controller handles execution. This keeps Resolvers interchangeable and business logic independently testable.

## File Creation

Run the script first — AI edits the generated stub, never creates from scratch:

**Windows:**
```powershell
.\.claude\scripts\make-controller\make-controller.ps1 -ModuleName {ModuleName} -ControllerName {ModelName}Controller -ProjectPath "{C:\path\to\project}"
```
**Mac / Linux:**
```bash
./.claude/scripts/make-controller/make-controller.sh {ModuleName} {ModelName}Controller {/path/to/project}
```

## Conventions

### File Location
```
Modules/{ModuleName}/Http/Controllers/{ModelName}Controller.php
```

### Class Structure
- Extends `App\Http\Controllers\Controller`
- No constructor injection needed unless a Service is required
- Mutation methods accept a typed `FormRequest` — one per operation
- Query methods accept a plain `Request`
- Returns a raw array for mutations; returns a model or Builder for queries

### Mutation Methods
```php
public function create(CreateUserRequest $request): array
public function update(UpdateUserRequest $request): array
public function delete(DeleteUserRequest $request): array
```
- Get input-wrapped args: `$request->input('input')`
- Get flat args: `$request->all()`
- Always wrap in `DB::beginTransaction()` / `DB::commit()` / `DB::rollBack()`
- Always throw `ExecutionException` on failure — never return a failure array
- Return shape: `['status' => true, 'message' => '...', 'data' => $model]`
- `data` key is optional — omit on delete
- Existence checks before create must use `->exists()` — never `->count() > 0`

### Query Methods
```php
public function paginatedListing(Request $request)   // returns Builder
public function listing(Request $request)             // returns Collection
public function detail(Request $request)              // returns Model
```
- `paginatedListing` must return a `Builder` — `@paginate` requires it
- `listing` calls `->get()` on the builder
- `detail` uses `findOrFail()` — let the exception bubble via `ExecutionException`
- No DB transaction needed for reads
- Always wrap in try/catch and throw `ExecutionException` on failure

### Error Handling
```php
use App\Exceptions\ExecutionException;

throw new ExecutionException("Failed to create user. {$e->getMessage()}", $e);
```
- Always import `App\Exceptions\ExecutionException` — never use `\Nuwave\Lighthouse\Exceptions\DefinitionException`
- Never return `['status' => false, ...]` — throw instead
- Message format: `"Failed to {verb} {model}. {$e->getMessage()}"`

### Private Helpers
- Any CUD method that does more than one operation (e.g. find then update, find then delete) must extract the lookup into a `private` method — never chain `findOrFail()->update()` or `findOrFail()->delete()` inline
- Lookups used across multiple methods → same private method, shared by all
- Logic reused across multiple controllers → move to a Service

```php
// NEVER — chains two operations, hides the model, update() returns bool not the model
User::findOrFail($input['id'])->update($input);

// ALWAYS — fetch first, then act
$user = $this->getUser($input['id']);
$user->update($input);

// private lookup
private function getUser(int|string $id): User
{
    return User::findOrFail($id);
}
```

## Non-Negotiables
- Extends `App\Http\Controllers\Controller` — never a module-local base class
- Every mutation method uses a typed FormRequest — never plain `Request`
- Every CUD method wraps in a DB transaction
- Always throw `ExecutionException` — never return a failure array
- `paginatedListing` must return a `Builder` — never a collection or array

## Clarifying Questions
- What mutations are needed? (determines which FormRequests to import)
- What queries are needed? (paginatedListing / listing / detail / custom)
- Does the controller need a Service injected?

## Reference
See `references/CONTROLLER.md` for real examples.
