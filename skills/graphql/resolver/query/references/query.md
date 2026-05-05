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
    public function listing($_, array $args): Builder
    {
        return Post::query();
    }

    public function detail($_, array $args): mixed
    {
        $post = Post::find($args['id']);

        if (!$post) {
            throw new \Exception('Post not found.');
        }

        return $post;
    }

    public function dropdown($_, array $args): mixed
    {
        return Post::query()
            ->where('status', true)
            ->get()
            ->map(fn($item) => [
                'id'   => $item->id,
                'name' => $item->title,
            ]);
    }
}
```

**What this shows:**
- `listing` returns `Builder` — required for `@paginate`
- `detail` throws `\Exception` if model not found — never return null silently
- `dropdown` returns simplified collection (id + label only)
- Method signature: `($_, array $args)` not `(mixed $root, array $args)`

---

## Bad ❌ — What NOT to do

```php
// listing returns Collection instead of Builder — breaks @paginate
public function listing($_, array $args): Collection
{
    return Post::all();
}

// Wrong method signature — use ($_, array $args)
public function listing(mixed $root, array $args): Builder { }

// detail with no exception — must throw if not found
public function detail($_, array $args): mixed
{
    return Post::find($args['id']); // returns null silently
}

// Wrong class name — must be Query not Queries
class PostQueries { }

// Wrong namespace
namespace App\GraphQL\Queries;
class PostQuery { }
```
