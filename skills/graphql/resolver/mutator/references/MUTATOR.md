# GraphQL Mutator References

---

## Example 1 — Standard CUD

```php
<?php

namespace Modules\User\GraphQL\Mutations;

use App\GraphQL\Mutations\Mutator;
use Modules\User\Http\Controllers\UserController;
use Nuwave\Lighthouse\Execution\ResolveInfo;
use Nuwave\Lighthouse\Support\Contracts\GraphQLContext;

class UserMutator extends Mutator
{
    protected $controller = UserController::class;

    public function create(mixed $_, array $args, GraphQLContext $graphqlContext, ResolveInfo $resolveInfo)
    {
        return $this->resolve(__FUNCTION__, $args, $graphqlContext, $resolveInfo);
    }

    public function update(mixed $_, array $args, GraphQLContext $graphqlContext, ResolveInfo $resolveInfo)
    {
        return $this->resolve(__FUNCTION__, $args, $graphqlContext, $resolveInfo);
    }

    public function delete(mixed $_, array $args, GraphQLContext $graphqlContext, ResolveInfo $resolveInfo)
    {
        return $this->resolve(__FUNCTION__, $args, $graphqlContext, $resolveInfo);
    }
}
```

**What this shows:**
- Extends `App\GraphQL\Mutations\Mutator` — not a standalone class
- `protected $controller = UserController::class` — no constructor injection
- Every method calls `$this->resolve(__FUNCTION__, ...)` — `__FUNCTION__` maps to the matching Controller method
- Zero business logic in the Mutator — it is a proxy only
- Method signature: `(mixed $_, array $args, GraphQLContext $graphqlContext, ResolveInfo $resolveInfo)`

---

## Example 2 — Custom operation

```php
<?php

namespace Modules\User\GraphQL\Mutations;

use App\GraphQL\Mutations\Mutator;
use Modules\User\Http\Controllers\UserController;
use Nuwave\Lighthouse\Execution\ResolveInfo;
use Nuwave\Lighthouse\Support\Contracts\GraphQLContext;

class UserMutator extends Mutator
{
    protected $controller = UserController::class;

    public function create(mixed $_, array $args, GraphQLContext $graphqlContext, ResolveInfo $resolveInfo)
    {
        return $this->resolve(__FUNCTION__, $args, $graphqlContext, $resolveInfo);
    }

    public function activate(mixed $_, array $args, GraphQLContext $graphqlContext, ResolveInfo $resolveInfo)
    {
        return $this->resolve(__FUNCTION__, $args, $graphqlContext, $resolveInfo);
    }
}
```

**What this shows:**
- Custom operations follow the exact same pattern as CRUD methods
- Method name (`activate`) must match the Controller method name and the `@field(resolver: "UserMutator@activate")` in the schema

---

## Bad ❌ — What NOT to do

```php
// Not extending the base Mutator class
class UserMutator
{
    public function create(mixed $_, array $args, ...) { }
}

// Constructor injection instead of protected $controller
class UserMutator extends Mutator
{
    public function __construct(private UserController $controller) {} // wrong
}

// Business logic directly in the Mutator — belongs in the Controller
public function create(mixed $_, array $args, GraphQLContext $graphqlContext, ResolveInfo $resolveInfo)
{
    DB::beginTransaction();
    $user = User::create($args['input']); // wrong — logic must live in the Controller
    DB::commit();
    return ['status' => true, 'message' => 'Created.', 'data' => $user];
}

// Wrong method signature — missing GraphQLContext and ResolveInfo
public function create($_, array $args)
{
    return $this->resolve(__FUNCTION__, $args); // wrong
}

// Method name does not match Controller method
public function createUser(mixed $_, array $args, ...) // wrong — schema has @field(resolver: "UserMutator@create")
{
    return $this->resolve(__FUNCTION__, $args, ...);
}

// Wrong namespace
namespace App\GraphQL\Mutations;
class UserMutator extends Mutator { }
```
