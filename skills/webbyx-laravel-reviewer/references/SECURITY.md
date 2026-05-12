# Security Review Methodology

Check for:
1. **Unprotected mutations/queries** — missing `@guard` on `extend type Mutation/Query` blocks
2. **Missing FormRequest validation** — raw `$request->all()` passed to `create()`/`update()`
3. **Mass assignment** — `$guarded = []` or `User::create($request->all())`
4. **Raw SQL with user input** — concatenated queries instead of parameter binding
5. **Exposed stack traces** — returning raw exceptions instead of `ExecutionException`
6. **Missing DB transactions** — CUD operations without `beginTransaction/commit/rollBack`
7. **Sensitive data** — PII or secrets stored unencrypted, logged, or exposed in responses
8. **Open redirects** — redirecting to unvalidated user-supplied URLs
9. **Missing rate limiting** — login, OTP, password reset endpoints without throttle middleware
10. **CSRF** — `VerifyCsrfToken` disabled globally or excluded beyond `webhook/*`

## Output Format

Group findings by severity:

```
[SEVERITY] path/to/File.php:line
Issue: <what is wrong>
Fix: <what to do instead>
```

Severity order: `CRITICAL` → `HIGH` → `MEDIUM` → `LOW`

End with a short summary: total findings per severity and one overall risk assessment sentence.

If no issues found, state: `No security issues found.`
