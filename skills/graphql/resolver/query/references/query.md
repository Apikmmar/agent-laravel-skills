# GraphQL Query Resolver References

---

## Example 1 — Standard listing, detail, dropdown

```php
<?php

namespace Modules\Blog\GraphQL\Queries;

use Illuminate\Database\Eloquent\Builder;
use Modules\Blog\Models\Post;

class PostQuery
{
    public function listing(mixed $root, array $args): Builder
    {
        return Post::query();
    }

    public function detail(mixed $root, array $args): mixed
    {
        // return single model
    }

    public function dropdown(mixed $root, array $args): mixed
    {
        // return simplified list
    }
}
```

**What this shows:**
- `listing` returns `Builder` — required for `@paginate`
- `detail` and `dropdown` return model or collection — used with `@field`
- Namespace: `Modules\{Module}\GraphQL\Queries`
- Class name: `{Model}Query`

---

## Bad ❌ — What NOT to do

```php
// listing returns Collection instead of Builder — breaks @paginate
public function listing(mixed $root, array $args): Collection
{
    return Post::all();
}

// Wrong class name — must be Query not Queries
class PostQueries { }

// Wrong namespace
namespace App\GraphQL\Queries;
class PostQuery { }
```
