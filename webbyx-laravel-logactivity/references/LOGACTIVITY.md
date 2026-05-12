# Activity Log Reference Examples

---

## Example 1 — Standard model with activity logging

```php
<?php

namespace Modules\Client\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Activitylog\LogOptions;
use Spatie\Activitylog\Traits\LogsActivity;

class ClientBranch extends Model
{
    use LogsActivity, SoftDeletes;

    protected $table = 'client_branches';

    protected $fillable = [
        'client_id',
        'name',
        'address',
        'phone',
        'status',
    ];

    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()
            ->logOnly($this->fillable)
            ->logOnlyDirty()
            ->dontSubmitEmptyLogs()
            ->useLogName('ClientBranch');
    }

    public function client(): BelongsTo
    {
        return $this->belongsTo(Client::class);
    }
}
```

**What this shows:**
- `LogsActivity` trait added alphabetically alongside `SoftDeletes`
- `getActivitylogOptions()` placed after `$fillable`, before relationships
- `->logOnly($this->fillable)` — tracks all fillable fields
- `->logOnlyDirty()` — only changed attributes appear in `properties.attributes`
- `->dontSubmitEmptyLogs()` — no empty log rows on updates with no real change
- `->useLogName('ClientBranch')` — PascalCase model name for easy filtering

---

## Example 2 — Model with excluded sensitive fields

When `$fillable` contains tokens, secrets, or PII that must not be logged, pass an explicit list instead:

```php
public function getActivitylogOptions(): LogOptions
{
    return LogOptions::defaults()
        ->logOnly(['name', 'email', 'status', 'role'])  // 'api_token' excluded
        ->logOnlyDirty()
        ->dontSubmitEmptyLogs()
        ->useLogName('User');
}
```

**When to use:** Ask the user if any fillable column should be excluded before defaulting to `$this->fillable`.

---

## Bad ❌ — What NOT to do

```php
// logAll() — captures updated_at, created_at, deleted_at — creates noise
->logAll()

// Missing logOnlyDirty — logs unchanged attributes on every update
LogOptions::defaults()->logOnly($this->fillable)->dontSubmitEmptyLogs()

// Missing dontSubmitEmptyLogs — creates empty log rows on untouched updates
LogOptions::defaults()->logOnly($this->fillable)->logOnlyDirty()

// useLogName with table name — hard to filter, breaks naming convention
->useLogName('client_branches')

// Added to BaseModel — logging activates on ALL models, pollutes activity_log
class BaseModel extends Model
{
    use LogsActivity;
    ...
}

// Traits not alphabetical
use SoftDeletes, LogsActivity;
```
