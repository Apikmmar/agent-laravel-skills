# Controller References

---

## Example 1 — Standard mutations and queries

```php
<?php

namespace Modules\User\Http\Controllers;

use App\Exceptions\ExecutionException;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Modules\User\Http\Requests\CreateUserRequest;
use Modules\User\Http\Requests\DeleteUserRequest;
use Modules\User\Http\Requests\UpdateUserRequest;
use Modules\User\Models\User;

class UserController extends Controller
{
    /**
     * Query functions
     */
    public function paginatedListing(Request $request)
    {
        try {
            return User::filter();
        } catch (\Exception $e) {
            throw new ExecutionException("Failed to retrieve paginated list of users. {$e->getMessage()}", $e);
        }
    }

    public function listing(Request $request)
    {
        try {
            return User::filter()->get();
        } catch (\Exception $e) {
            throw new ExecutionException("Failed to retrieve list of users. {$e->getMessage()}", $e);
        }
    }

    public function detail(Request $request)
    {
        try {
            $input = $request->all();
            return User::findOrFail($input['id']);
        } catch (\Exception $e) {
            throw new ExecutionException("Failed to retrieve user. {$e->getMessage()}", $e);
        }
    }

    /**
     * Mutator functions
     */
    public function create(CreateUserRequest $request): array
    {
        try {
            $input = $request->input('input');
            DB::beginTransaction();
            $user = User::create($input);
            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw new ExecutionException("Failed to create user. {$e->getMessage()}", $e);
        }

        return [
            'status'  => true,
            'message' => 'Successfully created a user.',
            'data'    => $user,
        ];
    }

    public function update(UpdateUserRequest $request): array
    {
        try {
            $input = $request->input('input');
            DB::beginTransaction();
            $user = User::findOrFail($input['id']);
            $user->update($input);
            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw new ExecutionException("Failed to update user. {$e->getMessage()}", $e);
        }

        return [
            'status'  => true,
            'message' => 'Successfully updated a user.',
            'data'    => $user,
        ];
    }

    public function delete(DeleteUserRequest $request): array
    {
        try {
            $input = $request->all();
            DB::beginTransaction();
            User::findOrFail($input['id'])->delete();
            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw new ExecutionException("Failed to delete user. {$e->getMessage()}", $e);
        }

        return [
            'status'  => true,
            'message' => 'Successfully deleted a user.',
        ];
    }
}
```

**What this shows:**
- Extends `App\Http\Controllers\Controller` — not a module-local base
- Query methods use plain `Request`, mutation methods use typed `FormRequest`
- `paginatedListing` returns `Builder` (no `->get()`) — required for `@paginate`
- `listing` calls `->get()` on the builder — returns a Collection
- Mutation args wrapped in `input:` are read with `$request->input('input')`
- Flat args (like `id` on delete) are read with `$request->all()`
- Every CUD method wraps in `DB::beginTransaction / commit / rollBack`
- Errors always rethrown as `ExecutionException` — never swallowed or returned as failure array
- Mutation response is a raw array with `status`, `message`, and optionally `data`
- `data` key is omitted on delete

---

## Example 2 — Custom operation

```php
public function activate(ActivateUserRequest $request): array
{
    try {
        $input = $request->all();
        DB::beginTransaction();
        $user = User::findOrFail($input['id']);
        $user->update(['status' => 'ACTIVE']);
        DB::commit();
    } catch (\Exception $e) {
        DB::rollBack();
        throw new ExecutionException("Failed to activate user. {$e->getMessage()}", $e);
    }

    return [
        'status'  => true,
        'message' => 'Successfully activated the user.',
        'data'    => $user,
    ];
}
```

**What this shows:**
- Custom operations follow the same pattern as create/update/delete
- Still uses a typed FormRequest even for custom operations
- Method name matches the Mutator method and `@field(resolver: "UserMutator@activate")`

---

## Bad ❌ — What NOT to do

```php
// No DB transaction on a mutation
public function create(CreateUserRequest $request): array
{
    $user = User::create($request->input('input'));
    return ['status' => true, 'message' => 'Created.', 'data' => $user];
}

// Returning a failure array instead of throwing
public function create(CreateUserRequest $request): array
{
    try {
        // ...
    } catch (\Exception $e) {
        DB::rollBack();
        return ['status' => false, 'message' => $e->getMessage()]; // wrong — throw instead
    }
}

// Using plain Request on a mutation method — must use typed FormRequest
public function create(Request $request): array { }

// paginatedListing calling ->get() — breaks @paginate
public function paginatedListing(Request $request)
{
    return User::filter()->get(); // wrong — return Builder, not Collection
}

```
