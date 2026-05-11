# Service References

---

## Example 1 — Standard service

```php
<?php

namespace Modules\Blog\Services;

use Modules\Blog\Models\Post;

class PostService
{
    public function createPost(array $args): Post
    {
        return Post::create($this->buildPayload($args));
    }

    public function updatePost(Post $post, array $args): Post
    {
        $post->update($this->buildPayload($args, $post));
        return $post;
    }

    public function deletePosts(array $ids): void
    {
        $posts = $this->getPosts($ids);
        $posts->each->delete();
    }

    private function getPosts(array $ids)
    {
        $posts = Post::whereIn('id', $ids)->get();

        if ($posts->isEmpty()) {
            throw new \Exception('No posts found for the given IDs.');
        }

        return $posts;
    }

    private function buildPayload(array $args, ?Post $post = null): array
    {
        return [
            'title'   => $args['title'] ?? $post?->title,
            'content' => $args['content'] ?? $post?->content,
            'status'  => $args['status'] ?? $post?->status,
        ];
    }
}
```

**What this shows:**
- No `extends BaseService` unless shared utilities are needed
- Public methods map to operations called from the mutator
- Every fetch is a private method — `getPosts()` not inline `Post::whereIn(...)->get()`
- Private `buildPayload()` — shared sub-operation used by both create and update (DRY)
- Throws `\Exception` for validation/not-found errors
- No GraphQL concerns — no `createResponse`, no `DB::transaction`

---

## Bad ❌ — What NOT to do

```php
// GraphQL response building in service — belongs in mutator
public function createPost(array $args): array
{
    Post::create($args);
    return ['status' => true, 'message' => 'Created.'];
}

// DB transaction in service — belongs in mutator
public function createPost(array $args): Post
{
    DB::beginTransaction();
    $post = Post::create($args);
    DB::commit();
    return $post;
}

// Inline fetch — must be a private method
public function deletePosts(array $ids): void
{
    $posts = Post::whereIn('id', $ids)->get(); // inline, not private
    $posts->each->delete();
}

// Wrong namespace
namespace App\Services;
class PostService { }

// Single-use logic extracted to service unnecessarily — keep it private in the mutator
class PostService {
    public function getPost(int $id): Post { ... } // only called from one mutator method
}
```
