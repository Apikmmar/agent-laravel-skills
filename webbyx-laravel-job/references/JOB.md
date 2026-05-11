# Job References

---

## Example 1 — Standard notification job (high queue)

```php
<?php

namespace Modules\Blog\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Modules\Blog\Models\Post;
use Throwable;

class NotifyPostPublishedJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public string $queue = 'high';
    public int $tries = 3;
    public array $backoff = [10, 30, 60];

    public function __construct(private readonly Post $post) {}

    public function handle(): void
    {
        // send notification logic
    }

    public function failed(Throwable $e): void
    {
        Log::error(self::class . ' failed', [
            'post_id' => $this->post->id,
            'error'   => $e->getMessage(),
        ]);
    }
}
```

**What this shows:**
- All four traits always present
- `$queue`, `$tries`, `$backoff` always defined
- Constructor receives model via `SerializesModels` — no raw IDs
- `failed()` always logs with context — never silent

---

## Example 2 — Bulk processing job (low queue, chunking)

```php
<?php

namespace Modules\Blog\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Modules\Blog\Models\Post;
use Throwable;

class BulkPublishPostsJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public string $queue = 'low';
    public int $tries = 3;
    public array $backoff = [10, 30, 60];

    public function __construct(private readonly array $filters) {}

    public function handle(): void
    {
        Post::where($this->filters)
            ->chunkById(1000, function ($posts) {
                Post::whereIn('id', $posts->pluck('id'))
                    ->update(['status' => 'published']);
            });
    }

    public function failed(Throwable $e): void
    {
        Log::error(self::class . ' failed', [
            'filters' => $this->filters,
            'error'   => $e->getMessage(),
        ]);
    }
}
```

**What this shows:**
- `low` queue for heavy/slow operations
- `chunkById(1000)` for large datasets — never `->get()` on unbounded result
- Bulk `update()` inside chunk — never individual `save()` per record
- No for loop — DB operation is a single `whereIn()->update()`

---

## Dispatching examples

```php
// Standard dispatch
NotifyPostPublishedJob::dispatch($post);

// Explicit queue
BulkPublishPostsJob::dispatch($filters)->onQueue('low');

// Delayed dispatch
SendReminderJob::dispatch($user)->delay(now()->addMinutes(10));
```

---

## Bad ❌ — What NOT to do

```php
// For loop over DB — kills queue performance
public function handle(): void
{
    foreach ($this->ids as $id) {
        Post::find($id)->update(['status' => 'published']); // N queries
    }
}

// No failed() — silent failure, impossible to debug
public function handle(): void
{
    // logic
}
// failed() missing entirely

// Unbounded get() — memory spike on large datasets
public function handle(): void
{
    $posts = Post::where('status', 'draft')->get(); // could be millions
    foreach ($posts as $post) { ... }
}

// Heavy op not dispatched as job — blocks the request
public function create($_, array $args): array
{
    Post::create($args['input']);
    $this->generateReport($args); // blocking — should be a job
    return $this->createResponse(true, 'Created.');
}
```
