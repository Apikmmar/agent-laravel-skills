---
name: webbyx-laravel-media
description: Use when the user asks to add media support to the project. Adds upload, delete, and retrieval methods to BaseModel and BaseController.
---

## Rule

Add all media methods directly to `App\Models\BaseModel` and `App\Http\Controllers\Controller`. This is the only place media logic lives — modules inherit it automatically.

## What to Add

**BaseModel** (`app/Models/BaseModel.php`)
- `HasMedia` interface + `InteractsWithMedia` trait
- `getFirstMediaUrlInCollection()` — returns `{ id, full_url, thumb_url, type }`
- `getAllMediaUrlInCollection()` — returns array of the same shape
- `registerMediaConversions()` — registers `thumb` (640px, JPG, non-queued)

**BaseController** (`app/Http/Controllers/Controller.php`)
- `uploadMedia()` — accepts model, field name, collection name; returns updated media shape
- `deleteMedia()` — accepts model, collection, media ID; verifies ownership then deletes; returns updated media shape

## Steps

1. Read `app/Models/BaseModel.php` and `app/Http/Controllers/Controller.php`
2. Add only what is missing — never duplicate existing methods
3. See `references/MEDIA.md` for the exact implementation of each method
