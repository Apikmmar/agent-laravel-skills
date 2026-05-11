# Test References

---

## Example 1 — Mutation test class (create, update, delete)

```php
<?php

namespace Modules\Post\Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Modules\Post\Models\Post;
use Modules\User\Models\User;
use Nuwave\Lighthouse\Testing\MakesGraphQLRequests;
use Tests\TestCase;

class PostMutationTest extends TestCase
{
    use RefreshDatabase, MakesGraphQLRequests;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
    }

    // CREATE — happy path
    public function test_create_post_successfully(): void
    {
        $this->actingAs($this->user);

        $response = $this->graphQL('
            mutation {
                createPost(input: {
                    title: "Hello World"
                    body: "Some body text"
                    user_id: ' . $this->user->id . '
                }) {
                    status
                    message
                    data {
                        id
                        title
                        body
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

        $this->assertDatabaseHas('posts', ['title' => 'Hello World']);
    }

    // CREATE — validation error
    public function test_create_post_fails_validation_when_title_is_missing(): void
    {
        $this->actingAs($this->user);

        $response = $this->graphQL('
            mutation {
                createPost(input: { body: "Some body text" }) {
                    status
                }
            }
        ');

        $response->assertGraphQLValidationError('input.title', 'The title field is required.');
    }

    // CREATE — unauthorized
    public function test_create_post_fails_when_unauthenticated(): void
    {
        $response = $this->graphQL('
            mutation {
                createPost(input: { title: "Hello", body: "Body" }) {
                    status
                }
            }
        ');

        $response->assertGraphQLErrorMessage('Unauthenticated.');
    }

    // UPDATE — happy path
    public function test_update_post_successfully(): void
    {
        $this->actingAs($this->user);

        $post = Post::factory()->create(['user_id' => $this->user->id]);

        $response = $this->graphQL('
            mutation {
                updatePost(input: {
                    id: ' . $post->id . '
                    title: "Updated Title"
                }) {
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
                'updatePost' => [
                    'status'  => true,
                    'message' => 'Successfully updated a post.',
                ],
            ],
        ]);

        $this->assertDatabaseHas('posts', ['id' => $post->id, 'title' => 'Updated Title']);
    }

    // UPDATE — unauthorized
    public function test_update_post_fails_when_unauthenticated(): void
    {
        $post = Post::factory()->create();

        $response = $this->graphQL('
            mutation {
                updatePost(input: { id: ' . $post->id . ', title: "x" }) {
                    status
                }
            }
        ');

        $response->assertGraphQLErrorMessage('Unauthenticated.');
    }

    // DELETE — happy path
    public function test_delete_post_successfully(): void
    {
        $this->actingAs($this->user);

        $post = Post::factory()->create(['user_id' => $this->user->id]);

        $response = $this->graphQL('
            mutation {
                deletePost(id: ' . $post->id . ') {
                    status
                    message
                }
            }
        ');

        $response->assertJson([
            'data' => [
                'deletePost' => [
                    'status'  => true,
                    'message' => 'Successfully deleted a post.',
                ],
            ],
        ]);

        $this->assertSoftDeleted('posts', ['id' => $post->id]);
    }

    // DELETE — unauthorized
    public function test_delete_post_fails_when_unauthenticated(): void
    {
        $post = Post::factory()->create();

        $response = $this->graphQL('
            mutation { deletePost(id: ' . $post->id . ') { status } }
        ');

        $response->assertGraphQLErrorMessage('Unauthenticated.');
    }
}
```

**What this shows:**
- `setUp()` creates the shared user once per class — avoids repetition
- `actingAs()` called before each authenticated request
- Unauthorized tests do NOT call `actingAs()`
- Validation error tests pass incomplete input and assert specific field + message
- Delete uses `assertSoftDeleted()` because `Post` uses `SoftDeletes`
- Factory IDs are always used — never hardcoded integers

---

## Example 2 — Query test class (paginated listing, detail)

```php
<?php

namespace Modules\Post\Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Modules\Post\Models\Post;
use Modules\User\Models\User;
use Nuwave\Lighthouse\Testing\MakesGraphQLRequests;
use Tests\TestCase;

class PostQueryTest extends TestCase
{
    use RefreshDatabase, MakesGraphQLRequests;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
    }

    // PAGINATED LISTING — happy path
    public function test_paginated_posts_returns_correct_structure(): void
    {
        $this->actingAs($this->user);

        Post::factory()->count(3)->create(['user_id' => $this->user->id]);

        $response = $this->graphQL('
            {
                paginatedPosts(first: 10) {
                    data {
                        id
                        title
                    }
                    paginatorInfo {
                        total
                        currentPage
                    }
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

        $response->assertJsonPath('data.paginatedPosts.paginatorInfo.total', 3);
    }

    // PAGINATED LISTING — unauthorized
    public function test_paginated_posts_fails_when_unauthenticated(): void
    {
        $response = $this->graphQL('
            { paginatedPosts(first: 10) { data { id } } }
        ');

        $response->assertGraphQLErrorMessage('Unauthenticated.');
    }

    // DETAIL — found
    public function test_post_detail_returns_correct_data(): void
    {
        $this->actingAs($this->user);

        $post = Post::factory()->create(['user_id' => $this->user->id]);

        $response = $this->graphQL('
            {
                post(id: ' . $post->id . ') {
                    id
                    title
                    body
                }
            }
        ');

        $response->assertJson([
            'data' => [
                'post' => [
                    'id'    => (string) $post->id,
                    'title' => $post->title,
                ],
            ],
        ]);
    }

    // DETAIL — not found
    public function test_post_detail_returns_error_when_not_found(): void
    {
        $this->actingAs($this->user);

        $response = $this->graphQL('
            { post(id: 99999) { id title } }
        ');

        $response->assertGraphQLError();
    }

    // DETAIL — unauthorized
    public function test_post_detail_fails_when_unauthenticated(): void
    {
        $post = Post::factory()->create();

        $response = $this->graphQL('
            { post(id: ' . $post->id . ') { id } }
        ');

        $response->assertGraphQLErrorMessage('Unauthenticated.');
    }
}
```

**What this shows:**
- Paginated query asserts both `data` structure and `paginatorInfo` fields
- `assertJsonPath()` verifies exact values like total count
- Detail test casts `$post->id` to string — GraphQL returns IDs as strings
- Not-found test uses a non-existent ID (99999) and asserts any GraphQL error
- Unauthorized tests skip `actingAs()` entirely

---

## Bad ❌ — What NOT to do

```php
// Hardcoded ID — breaks when factory generates a different ID
$this->graphQL('{ post(id: 1) { id } }');

// Missing actingAs on a protected query — test always passes for wrong reason
public function test_paginated_posts(): void
{
    $response = $this->graphQL('{ paginatedPosts(first: 10) { data { id } } }');
    $response->assertJsonStructure([...]);
}

// Not using RefreshDatabase — test data bleeds between tests
class PostMutationTest extends TestCase
{
    use MakesGraphQLRequests; // missing RefreshDatabase
}

// Asserting status false instead of throwing — wrong pattern
$response->assertJson(['data' => ['createPost' => ['status' => false]]]);
// Controllers must throw ExecutionException, never return status: false
```
