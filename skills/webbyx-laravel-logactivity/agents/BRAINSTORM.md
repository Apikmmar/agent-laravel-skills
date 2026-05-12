# Brainstorm — Activity Log Design

Design first, code second. Clarify which model(s) need logging and what should be tracked before touching any code.

> **HARD STOP — Do NOT write any code, run any commands, or create any files until the user explicitly confirms the plan. This is non-negotiable.**

## Step 1 — Clarify First

Ask if not already provided:
- Which model(s) need activity logging added?
- What is the log name to use? (default: the model class name in PascalCase — e.g. `ClientBranch`)
- Are there any fillable columns that should be **excluded** from logging (e.g. tokens, secrets, PII)? If yes — use `->logOnly([...])` with an explicit list instead of `$this->fillable`
- Is this being added to an existing model or a new one being scaffolded now?

## Step 2 — Plan

Output this before any code. Ask "Does this plan look correct?" and **wait for explicit confirmation before proceeding to Step 3**. Do not proceed if the user has not yet responded.

```
## Activity Log Plan
### 1. Target Model(s) — module path and class name
### 2. Log Name — useLogName() value
### 3. Logged Fields — $this->fillable or explicit list (note any excluded fields)
### 4. Options — logOnlyDirty + dontSubmitEmptyLogs (always on)
```

## Step 3 — Execute

- Open the target model file — never create a new file
- Add `LogsActivity` trait in alphabetical order with existing traits
- Add `getActivitylogOptions()` after `$fillable`/`$casts` and before relationships
- Follow `webbyx-laravel-logactivity/SKILL.md` for all conventions

## Non-Negotiables

- No code before plan is confirmed
- Never add to BaseModel — opt-in per model only
- Always `->logOnly($this->fillable)` unless columns are explicitly excluded
- Always `->logOnlyDirty()` and `->dontSubmitEmptyLogs()` — never omit either
- `useLogName()` value is PascalCase model name — never a table name
