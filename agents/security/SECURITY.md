# Security Rules

Always apply these rules during code generation. These are not optional — enforce them by default.

---

## Authentication

- Default auth is **Laravel Sanctum** — use it unless user specifies otherwise
- If user requires JWT or another provider, ask before implementing
- Never hardcode tokens, secrets, or credentials in code
- Always protect routes with the appropriate auth middleware

---

## Rate Limiting

- Apply rate limiting on all sensitive endpoints: login, password reset, token generation, OTP
- Default: use Laravel's built-in throttle middleware (`throttle:60,1`)
- Ask user if a custom rate limit is needed for specific endpoints

---

## Input Validation

- For **GraphQL endpoints**: always validate via Laravel FormRequests in the Controller — never use Lighthouse `@validator`
- For **REST/HTTP endpoints**: always validate via Laravel Form Requests — never trust raw `$request->all()`
- Sanitize output when rendering user-generated content

---

## SQL Injection

- Always use Eloquent ORM or the Query Builder — never concatenate user input into raw SQL
- If raw queries are unavoidable, always use parameter binding

```php
// NEVER do this
DB::select("SELECT * FROM users WHERE email = '$email'");

// ALWAYS do this
DB::select("SELECT * FROM users WHERE email = ?", [$email]);
// or
User::where('email', $email)->first();
```

---

## Mass Assignment

- Always define explicit `$fillable` on models — never use `$guarded = []`
- Never pass raw `$request->all()` directly to `create()` or `update()`

```php
// Never do this
User::create($request->all());

// Always do this
User::create($request->validated());
// or
User::create($request->only(['name', 'email']));
```

---

## File Uploads

- No default file upload rule — always ask the user about upload requirements during development
- When implementing: validate MIME type, file size, and store outside the public directory

---

## Debug & Environment

- Never enable `APP_DEBUG=true`
- Never expose stack traces or internal paths to end users
- Never log sensitive data (passwords, tokens, PII)

---

## HTTPS

- Always redirect HTTP to HTTPS
- Never serve sensitive endpoints over plain HTTP

---

## CORS

- Never use wildcard `*` for `allowed_origins`
- Always ask user whether the app is public-facing or internal — CORS config differs
  - Public-facing: restrict to known frontend domains
  - Internal: restrict to internal service origins only
- Configure in `config/cors.php` — never bypass via middleware directly

---

## Password Hashing

- Always hash passwords using Laravel's `Hash` facade — never store plain text
- Never use `md5()` or `sha1()` for passwords

```php
// Never do this
$user->password = $request->password;

// Always do this
$user->password = Hash::make($request->password);
```

---

## Session Hardening

- Always enforce HTTPS-only cookies (`'secure' => true` in `config/session.php`)
- Always enable HTTP-only flag (`'http_only' => true`)
- Always set SameSite to `strict` or `lax` — never `none` unless explicitly required

---

## Sensitive Data Encryption

- Encrypt sensitive columns using Eloquent's `'encrypted'` cast or `Crypt::encryptString()`
- Ask user which columns contain sensitive data (PII, secrets, tokens) before defining casts

```php
// Eloquent encrypted cast
protected $casts = [
    'secret_key' => 'encrypted',
];

// Manual encryption
$value = Crypt::encryptString($sensitiveData);
```

---

## CSRF

- Never disable `VerifyCsrfToken` middleware globally
- Only exclude routes under `webhook/*` when third-party services cannot send CSRF tokens
- Add exclusions to the `$except` array — never comment out or remove the middleware

```php
// Only acceptable exclusion
protected $except = [
    'webhook/*',
];
```

---

## Open Redirect

- Never redirect to a URL taken directly from user input without validation
- Always validate redirect targets against `config('app.url')` or a whitelist of trusted origins

```php
// Never do this
return redirect($request->input('redirect_to'));

// Always do this
$url = $request->input('redirect_to');
if (!str_starts_with($url, config('app.url'))) {
    $url = '/';
}
return redirect($url);
```