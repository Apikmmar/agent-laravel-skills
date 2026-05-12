---
name: webbyx-laravel-logactivity
description: Use when the user asks to add activity logging to a model. Triggers when user asks to log model events, track changes, audit a model, or add Spatie activity log to a module model.
---

## Rule
Activity logging is **opt-in per model** — not every model uses it. When requested, add the `LogsActivity` trait and `getActivitylogOptions()` method directly to the target model. Never add it to a BaseModel.

## Why
Not all models need audit trails. Adding it selectively keeps the `activity_log` table lean and avoids logging noise from models that don't require change tracking.

## Package
Uses `spatie/laravel-activitylog` v5.

## What to Add

Add to the target model class only:

```php
use Spatie\Activitylog\LogOptions;
use Spatie\Activitylog\Traits\LogsActivity;

class YourModel extends ...
{
    use LogsActivity;

    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()
            ->logOnly($this->fillable)
            ->logOnlyDirty()
            ->dontSubmitEmptyLogs()
            ->useLogName('ModelName'); // use the model name for easy filtering
    }
}
```

## Options Explained

| Method | Purpose |
|---|---|
| `->logOnly($this->fillable)` | Log only fillable attributes — prevents logging `updated_at` changes with no real content change |
| `->logOnlyDirty()` | Only include attributes that actually changed in the `properties` payload |
| `->dontSubmitEmptyLogs()` | Skip creating a log row when no attribute changed on update |
| `->useLogName('ModelName')` | Tag log rows with the model name for easier filtering in queries |

## Steps

1. Open the target model file
2. Add the `use LogsActivity;` trait (keep trait list alphabetical)
3. Add the `getActivitylogOptions()` method after `$fillable` / `$casts` and before relationships
4. Set `useLogName()` to the model class name (PascalCase, no suffix)
5. Do **not** modify any other model or BaseModel

## Non-Negotiables
- Never add `LogsActivity` to BaseModel — opt-in per model only
- Always use `->logOnly($this->fillable)` — never `->logAll()`
- Always use `->logOnlyDirty()` and `->dontSubmitEmptyLogs()` together
- `useLogName()` value must be the model name in PascalCase — never a table name or arbitrary string
- Trait list must remain alphabetical after adding `LogsActivity`

## Reference
See `references/LOGACTIVITY.md` for real examples.

Spatie docs: https://spatie.be/docs/laravel-activitylog/v5/advanced-usage/logging-model-events