# Model Reference Examples

---

## Example 1 — Full model covering all relationship types (1-1, 1-M, M-M)

```php
<?php

namespace Modules\Blog\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;

class Post extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'posts';

    protected $fillable = [
        'user_id', 'category_id', 'title', 'body', 'meta', 'published_at', 
    ];

    protected $casts = [
        'meta'         => 'array',
        'published_at' => 'datetime',
    ];

    // 1-1: Post has one featured image
    public function featuredImage(): HasOne
    {
        return $this->hasOne(PostImage::class, 'post_id');
    }

    // M-1: Post belongs to a user
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    // M-1: Post belongs to a category
    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class, 'category_id');
    }

    // 1-M: Post has many comments
    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class, 'post_id');
    }

    // M-M: Post belongs to many tags via pivot
    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(Tag::class, 'post_tag', 'post_id', 'tag_id')
            ->withTimestamps();
    }
}
```

**What this shows:**
- `SoftDeletes` always present
- Traits in alphabetical order
- `$fillable` one field per line
- `$casts` for JSON (`array`) and datetime columns
- Return types on all relationship methods
- All relationship types: `HasOne`, `BelongsTo`, `HasMany`, `BelongsToMany`
- `belongsToMany` with explicit pivot table and keys, chained on new line

---

## Example 2 — Simple model, no extra traits

```php
<?php

namespace Modules\Blog\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Comment extends Model
{
    use SoftDeletes;

    protected $table = 'comments';

    protected $fillable = [
        'post_id', 'user_id', 'body',
    ];

    public function post(): BelongsTo
    {
        return $this->belongsTo(Post::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
```

**What this shows:**
- Minimal model — no casts, no extra traits beyond `SoftDeletes`
- `SoftDeletes` always present even on the simplest model

---

## Bad ❌ — What NOT to do

```php
// Missing SoftDeletes
class Post extends Model
{
    protected $fillable = ['title', 'body'];
}

// Using $guarded — never do this
class Post extends Model
{
    protected $guarded = [];
}

// Missing $connection and $table
class Post extends Model
{
    protected $fillable = ['title', 'body'];
}

// Wrong namespace — not inside Modules
namespace App\Models;
class Post extends Model {}

// No return types on relationships
public function comments()
{
    return $this->hasMany(Comment::class);
}

// Traits not in alphabetical order
use SoftDeletes, HasFactory, HasAuditBy;
```
