# GraphQL Mutator References

---

## Example 1 — Standard CRUD mutator

```php
<?php

namespace Modules\Blog\GraphQL\Mutations;

class PostMutator
{
    public function create(mixed $root, array $args): mixed
    {
        // delegate to service
    }

    public function update(mixed $root, array $args): mixed
    {
        // delegate to service
    }

    public function delete(mixed $root, array $args): mixed
    {
        // delegate to service
    }
}
```

---

## Example 2 — CRUD + custom operations

```php
<?php

namespace Modules\Blog\GraphQL\Mutations;

class PostMutator
{
    public function create(mixed $root, array $args): mixed
    {
        // delegate to service
    }

    public function update(mixed $root, array $args): mixed
    {
        // delegate to service
    }

    public function delete(mixed $root, array $args): mixed
    {
        // delegate to service
    }

    public function publish(mixed $root, array $args): mixed
    {
        // delegate to service
    }

    public function archive(mixed $root, array $args): mixed
    {
        // delegate to service
    }
}
```

**What this shows:**
- Custom operations follow same method signature
- Method names camelCase matching `@` suffix in resolver path

---

## Bad ❌ — What NOT to do

```php
// Wrong class name — must be Mutator not Mutation
class PostMutation { }

// Business logic inside mutator — delegate to service instead
public function create(mixed $root, array $args): mixed
{
    $post = new Post();
    $post->title = $args['title'];
    $post->save();
    return $post;
}

// Wrong namespace
namespace App\GraphQL\Mutations;
class PostMutator { }
```
