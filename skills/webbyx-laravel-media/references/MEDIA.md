# Media Reference — BaseModel & BaseController

---

## Current State — BaseModel (`app/Models/BaseModel.php`)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;
use Spatie\MediaLibrary\MediaCollections\Models\Media;

class BaseModel extends Model implements HasMedia
{
    use InteractsWithMedia;

    public function getFirstMediaUrlInCollection(string $collectionName = 'default'): array
    {
        if ($this->hasMedia($collectionName)) {
            $media = $this->getFirstMedia($collectionName);

            return [
                'id'        => $media->id,
                'full_url'  => $media->getFullUrl(),
                'thumb_url' => $media->hasGeneratedConversion('thumb') ? $media->getFullUrl('thumb') : $media->getFullUrl(),
                'type'      => $media->mime_type,
            ];
        }

        return [
            'id'        => null,
            'full_url'  => null,
            'thumb_url' => null,
            'mime_type' => null,
        ];
    }

    public function getAllMediaUrlInCollection(string $collectionName = 'default'): array
    {
        if ($this->hasMedia($collectionName)) {
            $medias = $this->getMedia($collectionName);
            $media_data = [];

            foreach ($medias as $media) {
                $media_data[] = [
                    'id'        => $media->id,
                    'full_url'  => $media->getFullUrl(),
                    'thumb_url' => $media->getFullUrl('thumb'),
                    'type'      => $media->mime_type,
                ];
            }

            return $media_data;
        }

        return [];
    }

    public function registerMediaConversions(?Media $media = null): void
    {
        $this->addMediaConversion('thumb')
            ->width(640)
            ->format('jpg')
            ->nonQueued();
    }

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('status', 'active');
    }
}
```

---

## Current State — BaseController (`app/Http/Controllers/Controller.php`)

```php
<?php

namespace App\Http\Controllers;

abstract class Controller
{
    //
}
```

> BaseController has no media methods yet. New upload/delete helpers should be added here.

---

## Example — Adding an upload helper to BaseController

```php
public function uploadMedia(BaseModel $model, string $field, string $collection): array
{
    $model->addMediaFromRequest($field)->toMediaCollection($collection);

    return $model->getFirstMediaUrlInCollection($collection);
}
```

---

## Example — Adding a delete helper to BaseController

```php
public function deleteMedia(BaseModel $model, string $collection, int $mediaId): array
{
    $media = $model->getMedia($collection)->firstWhere('id', $mediaId);
    abort_if(!$media, 403);
    $media->delete();

    return $model->getFirstMediaUrlInCollection($collection);
}
```

---

## Example — Module model extending BaseModel collection config

```php
// Modules/Member/Models/Member.php
class Member extends BaseModel
{
    protected $connection = 'tenant';

    protected $fillable = ['name', 'email'];

    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('avatars')
            ->singleFile()
            ->acceptsMimeTypes(['image/jpeg', 'image/png', 'image/webp']);
    }
}
```

The module only configures the collection — it never re-implements upload, delete, or conversion logic.

---

## Bad ❌ — What NOT to do

```php
// Adding media logic directly to a module model instead of BaseModel/BaseController
class Member extends BaseModel
{
    public function uploadAvatar(Request $request): array // ❌ belongs in BaseController
    {
        $this->addMediaFromRequest('file')->toMediaCollection('avatars');
        return $this->getFirstMediaUrlInCollection('avatars');
    }
}

// Implementing HasMedia/InteractsWithMedia on a module model directly
class Reward extends Model implements HasMedia // ❌ extend BaseModel instead
{
    use InteractsWithMedia;
}

// Deleting media by raw ID without ownership check
$media = Media::find($request->media_id); // ❌ no model ownership verification
$media->delete();
```
