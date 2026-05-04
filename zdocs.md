# Agent Skills — Documentation
**Company:** Webby Development  
**Stack:** Laravel + Lighthouse GraphQL  
**Date:** 2026-04-30

---

## Table of Contents
1. [Effect](#1-effect)
2. [Tools & Compatibility](#2-tools--compatibility)
3. [Build Method](#3-build-method)
4. [Build Comparison](#4-build-comparison)
5. [Proposed For Build](#5-proposed-for-build)
6. [Structure](#6-structure)
7. [File Details](#7-file-details)
8. [Best Practice of Use Skills](#8-best-practice-of-use-skills)

---

## 1. Effect

What agent skills actually change about day-to-day development:

| Effect | Detail |
|--------|--------|
| AI writes code in your format, not generic Laravel | Skills encode your exact resolver, service, and module patterns — not textbook Laravel |
| No need to re-explain conventions every session | Rules load automatically at session start, every time, for every developer |
| New devs onboard faster | AI already knows your patterns — it teaches as it generates |
| Reduces back-and-forth correction cycles | From 3–5 correction rounds → 1–2 with well-written skills |
| Codifies team knowledge | Senior dev conventions stop living only in people's heads |

### By The Numbers

| Metric | Without Skills | With Skills |
|--------|---------------|-------------|
| Token cost per 1,000 operations | 525K tokens (~$10.50) | 85K tokens (~$1.70) |
| Development time per feature | 40 hours | 5 hours |
| Output accuracy | 71–83% | 91–96% |
| Correction rounds per output | 3–5+ | 1–2 |
| Context persistence | Degrades after ~3K tokens | Full session, every session |
| Team consistency | Depends on who prompts | Encoded — same output for everyone |

> **Token cost reduction: ~84%** | **Time saved: 8 hours/week per developer** | **Accuracy improvement: +16–23 percentage points**

---

## 2. Tools & Compatibility

Different AI tools read different files at session start. Skills written once can target all of them.

| AI Tool | File It Reads | Format |
|---------|--------------|--------|
| Claude Code | `CLAUDE.md` or `AGENTS.md` | Markdown |
| Cursor | `.cursor/rules/*.mdc` or `.cursorrules` | MDC / Markdown |
| GitHub Copilot | `.github/copilot-instructions.md` | Markdown |
| Any agent (universal) | `AGENTS.md` | Markdown |
| Laravel Boost | `resources/skills/*/SKILL.md` | SKILL.md spec |

### Our Target Priority
1. **Claude Code** (`CLAUDE.md` + `AGENTS.md`) — primary team tool
2. **Cursor** (`.cursor/rules/`) — secondary, scoped per file type
3. **Universal** (`AGENTS.md`) — compiled single file fallback

---

## 3. Build Method

Two approaches exist. The research shows combining both produces the best results.

### Method A — Command-Driven
Write explicit rules telling the AI what to do.

```markdown
## Rule
Always delegate business logic to a service class. Resolvers must never contain
business logic directly.

## Never Do
- Raw database queries inside a resolver
- Conditional logic inside a resolver
- Direct model manipulation inside a resolver
```

**Strength:** Enforces constraints clearly  
**Weakness:** AI interprets rules loosely — output varies, especially on edge cases

---

### Method B — Example-Driven
Give the AI your real code as a reference pattern to follow.

```markdown
## Pattern
Follow this exact resolver structure:

```php
// your actual company code here as the example
```
```

**Strength:** AI nails the format and structure exactly  
**Weakness:** AI follows format but misses the why — may skip constraints silently

---

### Method C — Combined (Recommended)
Rules define the constraints. Examples show the exact format.

```markdown
## Rule
[One clear constraint sentence]

## Why
[Why this constraint exists]

## Bad ❌
[What NOT to do — real code]

## Good ✅
[What TO do — your actual company code]

## Clarifying Questions
[What the AI should ask before generating]
```

**Why combined wins:**
- Rules prevent wrong architecture decisions
- Examples prevent wrong formatting and structure
- Together: first-try accuracy reaches 91–96% vs 71–83% with either alone
- Net token saver — one correct output costs less than 3–5 correction rounds

---

## 4. Build Comparison

| Metric | Command-Only | Example-Only | Combined |
|--------|-------------|--------------|----------|
| First-try accuracy | ~75% | ~82% | ~91–96% |
| Team consistency | Medium — varies by AI interpretation | High — format is fixed | High — format + constraints both fixed |
| Token cost | Low upfront, high corrections | Low upfront, medium corrections | Medium upfront, lowest corrections |
| Maintenance effort | Low — edit rules | Medium — update example code | Medium — update both when patterns change |
| Handles edge cases | Poor — rules get ignored | Poor — AI extrapolates wrong | Good — rules catch what examples miss |
| Onboarding new devs | Medium | Medium | Best — AI explains why as it generates |
| Best for | Quick constraints | Format-sensitive boilerplate | Production team use |

---

## 5. Proposed For Build

Skills planned for this package, specific to our Lighthouse GraphQL + Laravel stack.

| Skill | Priority | Status | What It Encodes |
|-------|----------|--------|-----------------|
| GraphQL CRUD (Lighthouse) | CRITICAL | Pending | Resolver, mutation, query structure with service delegation |
| Module structure (Lighthouse) | CRITICAL | Pending | How modules are organized — schema, resolvers, models per domain |
| App Service layer | CRITICAL | Pending | Service class pattern, constructor injection, return types |
| Unit Test format | CRITICAL | Pending | Test class structure, naming, mocking conventions |
| GraphQL input validation | HIGH | Pending | Input type rules, validation directives, error format |
| Error handling | HIGH | Pending | How errors surface through GraphQL — our specific format |
| Model conventions | HIGH | Pending | Fillable, casts, relationships, scope naming |
| Cron Job structure | HIGH | Pending | Job class pattern, scheduling registration |
| Migration | HIGH | Pending | Column types, naming conventions, index and foreign key patterns |
| Seeder | MEDIUM | Pending | Seeder class structure, factory usage, order of execution |
| Handler | HIGH | Pending | Exception handler conventions, how errors are caught and formatted |

> **Next:** GraphQL CRUD first — it is the highest frequency task and the pattern AI gets most wrong without guidance.

---

## 6. Structure

```
agent-laravel-skills/
├── skills/
│   ├── graphql-crud/
│   │   ├── skill.md                   ← rules + examples combined
│   │   └── references/
│   │       ├── mutation.example.php
│   │       ├── query.example.php
│   │       ├── resolver.example.php
│   │       ├── schema.example.graphql ← type + mutation/query registration
│   │       └── validation.example.php ← input validation conventions
│   └── app-service/
│       ├── skill.md
│       └── references/
│           └── service.example.php
├── AGENTS.md         ← compiled single file (all rules merged, universal)
├── CLAUDE.md         ← entry point for Claude Code
└── CHANGELOG.md      ← rule version history
```

## 8. Best Practice of Use Skills

### When Writing Skills (Rule Authors)

- Show real bad vs good PHP code from your actual codebase, not generic advice
- Keep each skill under 80 lines of rule prose
- Add a rule only when the AI actually made that mistake — not for hypothetical scenarios
- Pair every "never do X" with "do Y instead"
- Use YAML frontmatter with impact level and tags
- Reference your actual naming conventions, not abstract placeholders
- Test the rule in isolation before deploying to the team
- Version control rules alongside application code
- Tag rules with the Laravel + Lighthouse version they apply to
- Review rules quarterly — remove what the AI no longer gets wrong

### When Using Skills as a Developer

- Be brief on intent — `"generate GraphQL CRUD for products"` is enough
- Trust the AI's clarifying questions — answer directly and concisely
- Scope one skill per request — resolver first, then test separately
- Iterate on the skill file when output is wrong, not your prompt
- Validate output before committing — skills reduce mistakes, not eliminate them

### When to Add a New Rule

```
AI made the same mistake twice?  →  Write a rule to prevent it
Rule AI no longer gets wrong?    →  Remove it (already internalized)
New Laravel/Lighthouse version?  →  Review all rules, update version tags
New team pattern established?    →  Write the rule within the same sprint
```

---

*Maintained by: Webby Development*  
*Last updated: 2026-04-30*  
*Status: Research phase — no skills written yet*
