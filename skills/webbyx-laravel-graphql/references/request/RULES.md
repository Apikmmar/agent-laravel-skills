# FormRequest — Rules & Conventions

## Rule
All mutation input validation uses Laravel FormRequests. One FormRequest per mutation operation, stored at `Http/Requests/` inside the module. No Lighthouse `@validator`, no validator classes, no `@validator` directive anywhere.

## Why
FormRequests are typed per Controller method — validation is co-located with execution and independently testable. The GraphQL schema defines the shape; the FormRequest enforces the rules.

## File Creation
Run this command from the project root first — AI edits the generated stub, never creates from scratch:

```bash
php artisan module:make-request {RequestName} {ModuleName}
```

## File Location
```
Modules/{ModuleName}/Http/Requests/{Action}{ModelName}Request.php
```

## Naming
| Operation | Class name |
|---|---|
| Create | `Create{Model}Request` |
| Update | `Update{Model}Request` |
| Delete | `Delete{Model}Request` |
| Custom | `{Action}{Model}Request` |

## Class Structure
- Extends `Illuminate\Foundation\Http\FormRequest`
- Two methods: `rules()` and `authorize()`
- `authorize()` always returns `true` — auth is handled by `@guard` and `@hasPermission` in the schema
- `rules()` returns standard Laravel validation rules

## Input Prefixing
The prefix used in `rules()` depends on how the mutation passes args:

**With an `input:` argument** (e.g. `createUser(input: CreateUserInput!)`) — prefix with `input.`:
```php
public function rules(): array
{
    return [
        'input.name'     => ['required', 'string', 'max:255'],
        'input.email'    => ['required', 'email', 'unique:users,email'],
        'input.password' => ['required', 'string', 'min:8'],
    ];
}
```
Controller reads with: `$request->input('input')`

**With flat args** (e.g. `deleteUser(id: ID!)`) — use field name directly:
```php
public function rules(): array
{
    return [
        'id' => ['required', 'exists:users,id'],
    ];
}
```
Controller reads with: `$request->all()`

## Non-Negotiables
- One FormRequest per mutation operation — never share across create and update
- `authorize()` always returns `true`
- No `@validator` on any GraphQL input — ever
- Query methods (listing, detail) do not need FormRequests — use plain `Request`

## Clarifying Questions
- What fields does each input contain?
- What validation rules apply to each field?
- Does the mutation use an `input:` argument or flat args?
