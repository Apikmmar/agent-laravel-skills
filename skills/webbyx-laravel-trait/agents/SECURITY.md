# Security Rules

Always apply during code generation — not optional. These are enforced by default on every task.

## Authentication
- Default auth: Laravel Sanctum — ask before using JWT or any other provider
- Never hardcode tokens, secrets, or credentials anywhere in code
- Always protect mutations/queries with `@guard` in the GraphQL schema
- Never assume a route is public — always ask if auth requirement is unclear

## Rate Limiting
- Apply throttle on all sensitive endpoints: login, password reset, token generation, OTP
- Default: `throttle:60,1` — ask user if a custom limit is needed
- Rate limiting goes on the route or middleware level — not inside the controller

## Input Validation
- GraphQL: always validate via Laravel FormRequests in the Controller — never `@validator`, never raw `Request` on CUD
- REST: always use Form Requests — never trust raw `$request->all()`
- Sanitize output when rendering user-generated content

## SQL Injection
- Always use Eloquent ORM or Query Builder — never concatenate user input into raw SQL
- If raw queries are unavoidable, always use parameter binding (`?` placeholders)
- Never use string interpolation inside `DB::select()`, `DB::statement()`, etc.

## Mass Assignment
- Always define explicit `$fillable` on every model — never use `$guarded = []`
- Never pass raw `$request->all()` directly to `create()` or `update()`
- Use `$request->validated()` or `$request->only([...])` when passing to model methods

## Password Hashing
- Always `Hash::make()` — never store plain text
- Never use `md5()` or `sha1()` for passwords under any circumstance

## Sensitive Data Encryption
- Encrypt sensitive columns using Eloquent `'encrypted'` cast or `Crypt::encryptString()`
- Ask user which columns contain PII, secrets, or tokens before defining casts
- Never log or return encrypted values in plain text

## Debug & Environment
- Never `APP_DEBUG=true` in production
- Never expose stack traces, file paths, or internal errors to end users
- Never log passwords, tokens, PII, or any sensitive input/output

## HTTPS
- Always redirect HTTP to HTTPS
- Never serve sensitive endpoints over plain HTTP

## CORS
- Never use wildcard `*` for `allowed_origins`
- Ask user if the app is public-facing or internal — config differs
- Always configure in `config/cors.php` — never bypass via middleware directly

## CSRF
- Never disable `VerifyCsrfToken` middleware globally
- Only exclude `webhook/*` routes when third-party services cannot send CSRF tokens
- Add exclusions to the `$except` array only — never remove the middleware

## Session Hardening
- Cookies must be: `secure: true`, `http_only: true`, `same_site: strict or lax`
- Never set `same_site: none` unless explicitly required and justified

## Sensitive Data Exposure
- Never return sensitive fields (passwords, tokens, secrets) in GraphQL responses
- Always review what fields are exposed on a type before finalising the schema

## Open Redirect
- Never redirect to a URL taken directly from user input
- Always validate redirect targets against `config('app.url')` or a trusted whitelist

## File Uploads
- No default rule — always ask user about upload requirements before implementing
- When implementing: validate MIME type and file size, store outside the public directory