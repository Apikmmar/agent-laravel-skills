# Trait References

---

## Example 1 — Model capability trait (HasCustomField)

Gives a model the ability to sync and read custom fields.

```php
<?php

namespace App\Traits;

use Exception;
use Modules\CustomFields\Models\CustomFields;

trait HasCustomField
{
    public function syncCustomFields(array $fields): void
    {
        if (empty($fields)) {
            $this->member_custom_fields()->delete();

            return;
        }

        $normalizedFields = array_map(function ($field) {
            return [
                'custom_field_id' => $field['member_custom_field_id'] ?? $field['custom_field_id'] ?? null,
                'value'           => $field['value'] ?? null,
                'collection_id'   => $field['collection_id'] ?? null,
            ];
        }, $fields);

        $customFieldIds = array_column($normalizedFields, 'custom_field_id');

        // Bulk fetch — avoids N+1
        $definitions = CustomFields::whereIn('id', $customFieldIds)->get()->keyBy('id');

        foreach ($normalizedFields as $fieldData) {
            $fieldId = $fieldData['custom_field_id'];

            if (! $fieldId) {
                throw new Exception('Custom field ID is missing.');
            }

            if (! isset($definitions[$fieldId])) {
                throw new Exception("Custom field definition ID {$fieldId} not found.");
            }

            $definition = $definitions[$fieldId];
            $value      = $fieldData['value'];
            $collectionId = $fieldData['collection_id'];

            if ($definition->required_field && (is_null($value) || $value === '')) {
                throw new Exception("Field '{$definition->field_name}' is required.");
            }

            if ($definition->field_type === 'predefined') {
                if (! $collectionId) {
                    throw new Exception("Collection ID required for '{$definition->field_name}'.");
                }

                $isValidOption = $definition->custom_field_collections()
                    ->where('collection_id', $collectionId)
                    ->exists();

                if (! $isValidOption) {
                    throw new Exception("Invalid collection option selected for '{$definition->field_name}'.");
                }
            }

            $this->member_custom_fields()->updateOrCreate(
                ['custom_field_id' => $fieldId],
                ['value' => $value, 'collection_id' => $collectionId]
            );
        }
    }

    public function getCustomFieldsListAttribute(): array
    {
        $this->loadMissing('member_custom_fields.definition');

        return $this->member_custom_fields
            ->map(fn ($field) => [
                'id'                     => $field->id,
                'member_custom_field_id' => $field->custom_field_id,
                'name'                   => $field->definition?->field_name ?? 'Unknown',
                'value'                  => $field->value,
                'collection_id'          => $field->collection_id,
            ])
            ->values()
            ->toArray();
    }
}
```

**What this shows:**
- Bulk fetch with `whereIn` before the loop — avoids N+1
- `keyBy('id')` allows O(1) lookup inside the loop instead of repeated DB calls
- Throws `Exception` explicitly — never swallows errors
- `loadMissing()` prevents redundant eager loads if relation is already loaded
- Used on models: `use HasCustomField;`

---

## Example 2 — Service behaviour trait (SendPushNotification)

Gives a Job or Service the ability to send push notifications.

```php
<?php

namespace App\Traits;

use App\Services\EngageLabService;
use Exception;
use Illuminate\Support\Facades\Log;

trait SendPushNotification
{
    protected function sendPushNotification(array $notificationData): array
    {
        try {
            $pushNotiService = EngageLabService::from_tenant_provider('push_notification');
            $body            = $this->buildPushNotificationBody($notificationData);
            $response        = $pushNotiService->send_push_notification($body);
            $responseData    = $response->json();

            if (isset($responseData['code']) && $responseData['code'] !== 0) {
                throw new Exception(
                    'Failed to send push notification: ' .
                    ($responseData['message'] ?? 'Unknown error') .
                    " (Code: {$responseData['code']})"
                );
            }

            return $responseData;
        } catch (Exception $e) {
            Log::error('Push notification failed: ' . $e->getMessage(), [
                'notification_data' => $notificationData,
            ]);
            throw $e;
        }
    }

    private function buildPushNotificationBody(array $data): array
    {
        $defaults = [
            'from'       => 'push',
            'to'         => 'all',
            'body'       => [
                'platform'     => 'all',
                'notification' => [
                    'alert'   => $data['alert'] ?? 'Hello, Push!',
                    'android' => [
                        'alert'      => $data['android']['alert'] ?? $data['alert'] ?? 'Hi, Push!',
                        'title'      => $data['android']['title'] ?? $data['title'] ?? 'Notification',
                        'builder_id' => $data['android']['builder_id'] ?? 1,
                        'extras'     => $data['android']['extras'] ?? [],
                    ],
                    'ios'     => [
                        'alert'  => $data['ios']['alert'] ?? $data['alert'] ?? 'Hi, Push!',
                        'sound'  => $data['ios']['sound'] ?? 'default',
                        'badge'  => $data['ios']['badge'] ?? '+1',
                        'extras' => $data['ios']['extras'] ?? [],
                    ],
                ],
                'options'      => [
                    'time_to_live'    => $data['options']['time_to_live'] ?? 60,
                    'apns_production' => $data['options']['apns_production'] ?? false,
                ],
            ],
            'request_id' => $data['request_id'] ?? uniqid('push_', true),
            'custom_args' => $data['custom_args'] ?? [],
        ];

        return array_merge($defaults, $data);
    }
}
```

**What this shows:**
- `sendPushNotification()` is `protected` — accessible by the class using the trait but not publicly
- `buildPushNotificationBody()` is `private` — internal helper, not part of the trait's public API
- Logs error with context before rethrowing — never swallows silently
- No constructor, no DI — service is instantiated via static factory inside the method
- Used on Jobs or Services: `use SendPushNotification;`

---

## Example 3 — Query helper trait (ApplyFilter)

Gives Query resolvers reusable filter methods.

```php
<?php

namespace App\Traits;

use Illuminate\Database\Eloquent\Builder;

trait ApplyFilter
{
    protected function applyStringFilter(Builder $query, string $column, array $filter): Builder
    {
        return match ($filter['operator'] ?? 'like') {
            'eq'   => $query->where($column, $filter['value']),
            'like' => $query->where($column, 'like', '%' . $filter['value'] . '%'),
            default => $query,
        };
    }

    protected function applyBooleanFilter(Builder $query, string $column, array $filter): Builder
    {
        return $query->where($column, (bool) $filter['value']);
    }

    protected function applyDateFilter(Builder $query, string $column, array $filter): Builder
    {
        if (isset($filter['from'])) {
            $query->whereDate($column, '>=', $filter['from']);
        }

        if (isset($filter['to'])) {
            $query->whereDate($column, '<=', $filter['to']);
        }

        return $query;
    }
}
```

**What this shows:**
- Methods are `protected` — used by the class via `$this->`, not called externally
- Each method has a single responsibility (string, boolean, date)
- Returns the `Builder` — chainable, does not execute the query
- Used on Query resolvers: `use ApplyFilter;`

---

## Bad ❌ — What NOT to do

```php
// Multiple unrelated concerns in one trait — split into separate files
trait Helpers
{
    public function sendEmail() { ... }
    public function applyFilter() { ... }
    public function formatDate() { ... }
}

// Trait placed inside a module — must be in app/Traits/
namespace Modules\Post\Traits;
trait HasSlug { }

// DB call inside a loop — N+1
foreach ($ids as $id) {
    $record = Model::find($id); // fires one query per iteration
}

// Swallowing exceptions silently
try {
    $this->doSomething();
} catch (Exception $e) {
    // nothing — wrong
}
```
