# GraphQL Mutator References

---

## Example 1 — Standard CUD with service injection

```php
<?php

namespace Modules\Blog\GraphQL\Mutations;

use Illuminate\Support\Facades\DB;
use Modules\Blog\Models\Post;
use Modules\Blog\Services\PostService;
use Modules\Blog\Traits\GraphQLResponse;

class PostMutator
{
    use GraphQLResponse;

    public function __construct(
        private PostService $postService
    ) {}

    public function create($_, array $args)
    {
        try {
            DB::beginTransaction();

            $this->postService->createPost($args);

            DB::commit();

            return $this->createResponse(true, 'Post created successfully.');
        } catch (\Exception $e) {
            DB::rollBack();
            return $this->createResponse(false, $e->getMessage());
        }
    }

    public function update($_, array $args)
    {
        try {
            DB::beginTransaction();

            $post = $this->getPost($args['id']);
            $this->postService->updatePost($post, $args);

            DB::commit();

            return $this->createResponse(true, 'Post updated successfully.');
        } catch (\Exception $e) {
            DB::rollBack();
            return $this->createResponse(false, $e->getMessage());
        }
    }

    public function delete($_, array $args)
    {
        try {
            DB::beginTransaction();

            $ids = array_filter($args['ids'], fn($id) => !empty($id));

            if (empty($ids)) {
                return $this->createResponse(false, 'No valid IDs provided.');
            }

            $this->postService->deletePosts($ids);

            DB::commit();

            return $this->createResponse(true, 'Post(s) deleted successfully.');
        } catch (\Exception $e) {
            DB::rollBack();
            return $this->createResponse(false, $e->getMessage());
        }
    }

    private function getPost(int $id): Post
    {
        $post = Post::find($id);

        if (!$post) {
            throw new \Exception('Post not found.');
        }

        return $post;
    }
}
```

**What this shows:**
- `use GraphQLResponse` from `Modules\{Module}\Traits\GraphQLResponse`
- Constructor injects service — Dependency Injection
- Every CUD method wraps in `DB::beginTransaction / commit / rollBack`
- Returns `$this->createResponse(bool, message)`
- Private `getPost()` — non-reusable logic stays in mutator
- Method signature: `($_, array $args)` not `(mixed $root, array $args)`

---

## Example 2 — Custom operation

```php
public function publish($_, array $args)
{
    try {
        DB::beginTransaction();

        $ids = array_filter($args['ids'], fn($id) => !empty($id));

        if (empty($ids)) {
            return $this->createResponse(false, 'No valid IDs provided.');
        }

        $posts = $this->getPosts($ids);

        foreach ($posts as $post) {
            $this->validatePostPublishable($post);
            $post->update(['is_published' => true]);
        }

        DB::commit();

        return $this->createResponse(true, 'Post(s) published successfully.');
    } catch (\Exception $e) {
        DB::rollBack();
        return $this->createResponse(false, $e->getMessage());
    }
}

private function getPosts(array $ids)
{
    $posts = Post::whereIn('id', $ids)->get();

    if ($posts->isEmpty()) {
        throw new \Exception('No posts found for the given IDs.');
    }

    return $posts;
}

private function validatePostPublishable(Post $post): void
{
    if ($post->is_published) {
        throw new \Exception('Post "' . $post->title . '" is already published.');
    }
}
```

**What this shows:**
- Custom operations follow the same DB transaction pattern
- Every fetch/lookup is a private method — `getPosts()` not inline `Post::whereIn(...)->get()`
- Private validation method for logic not reused elsewhere
- Method name camelCase matching `@` suffix in resolver path

---

## Bad ❌ — What NOT to do

```php
// Wrong class name — must be Mutator not Mutation
class PostMutation { }

// Wrong method signature — use ($_, array $args) not (mixed $root, ...)
public function create(mixed $root, array $args): mixed { }

// No DB transaction — all CUD must be wrapped
public function create($_, array $args)
{
    $this->postService->createPost($args);
    return $this->createResponse(true, 'Created.');
}

// Business logic directly in mutator — delegate reusable logic to service
public function create($_, array $args)
{
    $post = new Post();
    $post->title = $args['title'];
    $post->save();
    return $this->createResponse(true, 'Created.');
}

// Missing GraphQLResponse trait — never return raw array manually
public function create($_, array $args)
{
    return ['status' => true, 'message' => 'Created.'];
}

// Wrong namespace
namespace App\GraphQL\Mutations;
class PostMutator { }
```
