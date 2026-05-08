# Request References

---

## Example 1 — Create request with input-wrapped args

```php
<?php

namespace Modules\User\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CreateUserRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'input.name'     => ['required', 'string', 'max:255'],
            'input.email'    => ['required', 'email', 'unique:users,email'],
            'input.password' => ['required', 'string', 'min:8'],
        ];
    }

    public function authorize(): bool
    {
        return true;
    }
}
```

**What this shows:**
- Mutation uses `createUser(input: CreateUserInput!)` — args are nested under `input`
- Rules are prefixed with `input.` to match the nested structure
- Controller reads with `$request->input('input')`
- `authorize()` always returns `true` — auth is handled by `@guard` and `@hasPermission` in the schema

---

## Example 2 — Update request

```php
<?php

namespace Modules\User\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateUserRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'input.id'    => ['required', 'exists:users,id'],
            'input.name'  => ['sometimes', 'string', 'max:255'],
            'input.email' => ['sometimes', 'email', 'unique:users,email,' . $this->input('input.id')],
        ];
    }

    public function authorize(): bool
    {
        return true;
    }
}
```

**What this shows:**
- `id` is always required on update
- All other fields use `sometimes` — client only sends what needs updating
- Unique rule excludes the current record using the submitted `id`

---

## Example 3 — Delete request with flat args

```php
<?php

namespace Modules\User\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class DeleteUserRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'id' => ['required', 'exists:users,id'],
        ];
    }

    public function authorize(): bool
    {
        return true;
    }
}
```

**What this shows:**
- Mutation uses `deleteUser(id: ID!)` — flat arg, no `input:` wrapper
- Rules use the field name directly, no `input.` prefix
- Controller reads with `$request->all()`

---

## Bad ❌ — What NOT to do

```php
// authorize() returning false — always return true, auth is in the schema
public function authorize(): bool
{
    return false;
}

// Sharing one Request across create and update — must be separate classes
class UserRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'input.name'  => ['required'], // used for both create and update — wrong
        ];
    }
}

// Missing input. prefix for input-wrapped mutation
class CreateUserRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'name'  => ['required', 'string'], // wrong — should be 'input.name'
            'email' => ['required', 'email'],  // wrong — should be 'input.email'
        ];
    }
}

// Using Lighthouse @validator instead of FormRequest — not used in this project
input CreateUserInput @validator {  // wrong
    name: String!
}
```
