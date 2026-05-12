# Activity Log Conventions

## Log Name

| What | Convention | Example |
|---|---|---|
| `useLogName()` value | PascalCase model name | `ClientBranch`, `WorkflowExecution` |

- Never use a table name (`client_branches`) — always the model class name
- Never use a generic label (`model`, `record`, `log`) — always the specific model name
- Consistent log name makes it easy to filter: `Activity::where('log_name', 'ClientBranch')`

## Trait Order

Traits must remain alphabetical after adding `LogsActivity`:

```php
// Correct
use HasFactory, LogsActivity, SoftDeletes;

// Wrong — not alphabetical
use SoftDeletes, LogsActivity, HasFactory;
```

## Method Placement

`getActivitylogOptions()` goes after `$fillable`/`$casts` and before any relationship methods:

```php
protected $fillable = [...];

protected $casts = [...];

public function getActivitylogOptions(): LogOptions { ... }

public function someRelationship(): HasMany { ... }
```

## Import Order

Add these imports in alphabetical order with existing imports:

```php
use Spatie\Activitylog\LogOptions;
use Spatie\Activitylog\Traits\LogsActivity;
```
