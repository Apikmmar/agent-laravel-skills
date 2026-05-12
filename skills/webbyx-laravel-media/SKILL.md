---
name: webbyx-laravel-media
description: Use when adding media or file upload support to the project. Triggers when user asks to add media, implement file uploads, manage file collections, add image support, or set up Spatie media library integration on BaseModel or BaseController.
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
3. See the reference implementation below and add only what is missing

@references/MEDIA.md
