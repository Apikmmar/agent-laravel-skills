# Query Resolver — Examples

## Example 1 — Standard paginated listing, listing, and detail

```php
<?php

namespace Modules\User\GraphQL\Queries;

use App\GraphQL\Queries\Query;
use Modules\User\Http\Controllers\UserController;
use Nuwave\Lighthouse\Execution\ResolveInfo;
use Nuwave\Lighthouse\Support\Contracts\GraphQLContext;

class UserQuery extends Query
{
    protected $controller = UserController::class;

    public function paginatedListing(mixed $_, array $args, GraphQLContext $graphqlContext, ResolveInfo $resolveInfo)
    {
        return $this->resolve(__FUNCTION__, $args, $graphqlContext, $resolveInfo);
    }

    public function listing(mixed $_, array $args, GraphQLContext $graphqlContext, ResolveInfo $resolveInfo)
    {
        return $this->resolve(__FUNCTION__, $args, $graphqlContext, $resolveInfo);
    }

    public function detail(mixed $_, array $args, GraphQLContext $graphqlContext, ResolveInfo $resolveInfo)
    {
        return $this->resolve(__FUNCTION__, $args, $graphqlContext, $resolveInfo);
    }
}
```

**What this shows:**
- Extends `App\GraphQL\Queries\Query` — not a standalone class
- `protected $controller = UserController::class` — no constructor injection
- Every method calls `$this->resolve(__FUNCTION__, ...)` — delegates to the matching Controller method
- Zero business logic in the Query class — it is a proxy only
- `paginatedListing` is used with `@paginate(builder:)` — Controller method must return a `Builder`

---

## Bad ❌ — What NOT to do

```php
// Not extending the base Query class
class UserQuery
{
    public function listing(mixed $_, array $args, ...) { }
}

// Constructor injection instead of protected $controller
class UserQuery extends Query
{
    public function __construct(private UserController $controller) {} // wrong
}

// Business logic directly in the Query class — belongs in the Controller
public function listing(mixed $_, array $args, GraphQLContext $graphqlContext, ResolveInfo $resolveInfo)
{
    return User::filter(); // wrong — logic must live in the Controller
}

// Wrong method signature — missing GraphQLContext and ResolveInfo
public function listing($_, array $args)
{
    return $this->resolve(__FUNCTION__, $args); // wrong
}

// Method name does not match Controller method
public function getUsers(mixed $_, array $args, ...) // wrong
{
    return $this->resolve(__FUNCTION__, $args, ...);
}
```
