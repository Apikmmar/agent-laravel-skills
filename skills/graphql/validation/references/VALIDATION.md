# GraphQL Validation References

---

## Example 1 — Create validator

```php
<?php

namespace Modules\Blog\GraphQL\Validators;

use Nuwave\Lighthouse\Validation\Validator;

class CreatePostInputValidator extends Validator
{
    public function rules(): array
    {
        return [
            'title'      => ['required', 'string', 'max:255'],
            'content'    => ['required', 'string'],
            'status'     => ['required', 'boolean'],
            'tags'       => ['nullable', 'array'],
            'tags.*.tag_id' => ['required', 'integer', 'exists:tags,id'],
        ];
    }

    public function attributes(): array
    {
        return [
            'title'         => 'Title',
            'content'       => 'Content',
            'status'        => 'Status',
            'tags'          => 'Tags',
            'tags.*.tag_id' => 'Tag ID',
        ];
    }
}
```

---

## Example 2 — Update validator (nullable top-level, required nested)

> **Pattern:** Top-level fields are `nullable` — the caller can omit any field they don't want to change. But once a nested array is provided, each item inside it must be valid — so nested fields stay `required`. Example: you can skip `tags` entirely, but if you pass `tags`, every tag must have a valid `tag_id`.

```php
<?php

namespace Modules\Blog\GraphQL\Validators;

use Nuwave\Lighthouse\Validation\Validator;

class UpdatePostInputValidator extends Validator
{
    public function rules(): array
    {
        return [
            'title'      => ['nullable', 'string', 'max:255'],
            'content'    => ['nullable', 'string'],
            'status'     => ['nullable', 'boolean'],
            'tags'       => ['nullable', 'array'],
            'tags.*.tag_id' => ['required', 'integer', 'exists:tags,id'],
        ];
    }

    public function attributes(): array
    {
        return [
            'title'         => 'Title',
            'content'       => 'Content',
            'status'        => 'Status',
            'tags'          => 'Tags',
            'tags.*.tag_id' => 'Tag ID',
        ];
    }
}
```

**What this shows:**
- Create validators use `required` on mandatory top-level fields
- Update validators use `nullable` on top-level fields — nested required fields stay `required`
- `attributes()` covers every key in `rules()` — no exceptions
- Class name matches input name: `UpdatePostInput` → `UpdatePostInputValidator`

---

## Schema — pairing input with validator

```graphql
input CreatePostInput @validator {
    title: String!
    content: String!
    status: Boolean!
    tags: [PostTagInput!]
}

input UpdatePostInput @validator {
    id: ID!
    title: String
    content: String
    status: Boolean
    tags: [PostTagInput!]
}

input PostTagInput {
    tag_id: ID!
}
```

**What this shows:**
- `@validator` on top-level inputs only
- Nested input `PostTagInput` has no `@validator` — validated via `tags.*.tag_id` in parent
- `@validator` on the `input` type, not on the mutation field

---

## Bad ❌ — What NOT to do

```php
// Wrong class name — must match input name exactly
class PostCreateValidator extends Validator { }  // input is CreatePostInput

// attributes() missing fields that are in rules() — must cover all
public function attributes(): array
{
    return [
        'title' => 'Title',
        // missing content, status, tags, tags.*.tag_id
    ];
}

// Wrong namespace
namespace App\GraphQL\Validators;
class CreatePostInputValidator extends Validator { }
```

```graphql
# Wrong — @validator on nested input
input PostTagInput @validator {
    tag_id: ID!
}

# Wrong — @validator on the mutation field instead of input type
extend type Mutation {
    CreatePost(input: CreatePostInput! @spread): SuccessResponse
        @validator
        @field(resolver: "...")
}
```
