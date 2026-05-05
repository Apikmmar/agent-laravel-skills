# Migration Reference Examples

---

## Example 1 — Simple table, no foreign keys

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('posts', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('body')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamp('published_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('posts');
    }
};
```

**What this shows:**
- Anonymous class structure
- Column order: `id()` → columns → `timestamps()` → `softDeletes()`
- No foreign keys — no constraint definitions needed

---

## Example 2 — Table with foreign keys and enum

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('post_comments', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('post_id');
            $table->unsignedBigInteger('user_id');
            $table->text('body');
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('post_id', 'fk_pc_post')->references('id')->on('posts')->cascadeOnDelete();
            $table->foreign('user_id', 'fk_pc_user')->references('id')->on('users')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('post_comments');
    }
};
```

**What this shows:**
- `unsignedBigInteger` for all foreign key columns
- `enum` with lowercase values
- Foreign keys named `fk_{shortTable}_{referencedTable}` defined after all columns
- Mixed delete behaviours: `cascadeOnDelete()` and `restrictOnDelete()`

---

## Example 3 — Table with nullable foreign key

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('post_tags', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('post_id');
            $table->unsignedBigInteger('tag_id')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('post_id', 'fk_pt_post')->references('id')->on('posts')->cascadeOnDelete();
            $table->foreign('tag_id', 'fk_pt_tag')->references('id')->on('tags')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('post_tags');
    }
};
```

**What this shows:**
- Nullable foreign key column with `nullOnDelete()` behaviour

---

## Bad ❌ — What NOT to do

```php
// Missing softDeletes() and missing down()
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('posts', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->timestamps();
        });
    }
};

// Unnamed foreign key constraint
$table->foreign('post_id')->references('id')->on('posts')->cascadeOnDelete();

// Foreign keys defined before columns
Schema::create('comments', function (Blueprint $table) {
    $table->foreign('post_id', 'fk_c_post')->references('id')->on('posts')->cascadeOnDelete();
    $table->id();
    $table->text('body');
    $table->timestamps();
    $table->softDeletes();
});

// Enum values not lowercase
$table->enum('status', ['PENDING', 'APPROVED', 'REJECTED']);
```
