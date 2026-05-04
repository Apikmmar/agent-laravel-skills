# Laravel Agent Skills — Market Research
**Company:** Webby Development  
**Purpose:** Research existing Laravel agent skills before building our own  
**Date:** 2026-04-30

---

## Table of Contents
1. [CTO Reference Examples](#1-cto-reference-examples)
2. [Official Laravel Packages](#2-official-laravel-packages)
3. [Community Packages — Curated Collections](#3-community-packages--curated-collections)
4. [Key Finding — The Gap](#4-key-finding--the-gap)
5. [Structure Patterns Observed](#5-structure-patterns-observed)
6. [Approach: Command-Driven vs Example-Driven](#6-approach-command-driven-vs-example-driven)
7. [Recommended Resources to Study Next](#7-recommended-resources-to-study-next)

---

## 1. CTO Reference Examples

Three repos given as structural references before we build our own.

### agent-nestjs-skills
- **URL:** https://github.com/Kadajett/agent-nestjs-skills
- **Structure:** `rules/` directory with prefixed files — `arch-`, `di-`, `error-`, `security-`
- **Approach:** Command + example paired (bad/good code blocks)
- **Notable:** Uses YAML frontmatter with impact levels (CRITICAL → LOW), compiles all rules into `AGENTS.md`
- **Verdict:** Best structural reference for how to organize rules

### react-best-practices (Vercel)
- **URL:** https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices
- **Structure:** Section-prefixed rules — `async-`, `bundle-`, `server-`, `client-`, `rerender-`
- **Approach:** Mostly example-driven, less command-heavy
- **Notable:** Shows how Vercel ships skills at scale — clean, minimal, opinionated
- **Verdict:** Good for seeing the example-driven pattern in practice

### laravel-specialist (Jeffallan)
- **URL:** https://github.com/Jeffallan/claude-skills/blob/main/skills/laravel-specialist
- **Structure:** Single `SKILL.md` with YAML frontmatter
- **Approach:** Command-driven, no code examples
- **Notable:** Laravel-specific but generic — covers basic conventions only
- **GraphQL/Lighthouse:** None
- **Verdict:** Too shallow for our needs, but good to see the SKILL.md format

---

## 2. Official Laravel Packages

### laravel/agent-skills
- **URL:** https://github.com/laravel/agent-skills
- **Coverage:** Code review, PSR-12 standards, Laravel Cloud deployment, Nightwatch monitoring
- **GraphQL/Lighthouse:** Not covered
- **Quality:** High — official, authoritative
- **Notes:** The canonical reference for what Laravel officially endorses

### Laravel Boost MCP
- **Coverage:** Full AI-assisted development framework, 17,000+ ecosystem docs API
- **GraphQL/Lighthouse:** Mentions Lighthouse MCP server separately
- **Quality:** High — core Laravel feature
- **Notes:** `php artisan boost:add-skill` for installing skills from the marketplace

### skills.laravel.cloud
- **URL:** https://skills.laravel.cloud
- **Type:** Community skill marketplace
- **Scale:** 162+ skills and growing
- **Coverage:** Pest testing, Eloquent optimization, PHP 8.3+, security, TDD, verification
- **GraphQL/Lighthouse:** None found
- **Notes:** Skills installable via `php artisan boost:add-skill`

---

## 3. Community Packages — Curated Collections

### iSerter/laravel-claude-agents
- **URL:** https://github.com/iSerter/laravel-claude-agents
- **Structure:** 10 specialized agents + 15 reusable skills
- **Coverage:** TDD, API resources, validation, queuing, caching, notifications, Blade components, scheduling
- **GraphQL/Lighthouse:** None
- **Quality:** High — most comprehensive community package found
- **Verdict:** Best community reference for depth and domain coverage

### jpcaparas/superpowers-laravel
- **URL:** https://github.com/jpcaparas/superpowers-laravel
- **Coverage:** Form requests, authorization, Eloquent relationships, transaction handling, HTTP resilience, file uploads
- **Laravel version:** 11.x / 12.x focused
- **GraphQL/Lighthouse:** None
- **Quality:** High — modern Laravel focus
- **Verdict:** Good for seeing how modern Laravel 11/12 conventions are encoded

### masterfermin02/laravel-agent-skill
- **URL:** https://github.com/masterfermin02/laravel-agent-skill
- **Coverage:** 12+ backend rules, Inertia+React/Vue frontend rules, single responsibility, N+1 prevention
- **Multi-tool:** Supports Laravel Boost, Codex, VS Code, JetBrains
- **GraphQL/Lighthouse:** Not explicitly mentioned
- **Quality:** Medium-High
- **Verdict:** Good for multi-tool distribution pattern

### thienanblog/awesome-ai-agent-skills
- **URL:** https://github.com/thienanblog/awesome-ai-agent-skills
- **Coverage:** Laravel 11/12 workflow guidelines, optional Sail/Inertia/Livewire, Pint/PHPStan, Laravel Boost integration
- **GraphQL/Lighthouse:** None
- **Quality:** Medium — workflow-oriented, less opinionated

### truthanb/laravel-ai-skills
- **Coverage:** Laravel AI SDK integration, skill loading, tool wiring
- **GraphQL/Lighthouse:** Not specified
- **Quality:** Medium — SDK-focused, not convention-focused

### anilcancakir/laravel-ai-sdk-skills
- **Coverage:** Modular reusable capabilities, lite/full mode loading, caching
- **GraphQL/Lighthouse:** Not specified
- **Quality:** Medium — Laravel AI SDK native

---

## 4. Key Finding — The Gap

> **Zero existing packages cover Lighthouse GraphQL.**

Every Laravel skill found covers the same set: Eloquent, validation, queues, testing, form requests, authorization. None encode:

- Lighthouse resolver structure
- GraphQL mutation pattern with service layer
- Lighthouse module organization
- Input type conventions
- GraphQL error handling
- Directive usage patterns

**This is the gap.** And it is exactly why a custom package is needed — not because general Laravel skills don't exist, but because our specific Lighthouse + modules + service layer pattern is not covered anywhere in the market.

---

## 5. Structure Patterns Observed

### Pattern A — Rules Directory (NestJS / React style)
```
skills/
    graphql-crud/
        rules/
            arch-resolver-pattern.md
            arch-service-layer.md
            error-handling.md
        AGENTS.md   ← compiled output
```
Each rule file has YAML frontmatter + bad/good code blocks. Rules compile into one `AGENTS.md`.

### Pattern B — SKILL.md (Laravel Boost style)
```
resources/
    skills/
        graphql-crud/
            SKILL.md        ← frontmatter + full instructions
            references/     ← example code files
            scripts/        ← optional tooling
```
Progressive disclosure: lite mode loads name/description (~50 tokens), full mode loads complete content (~500 tokens) only when task matches.

### Pattern C — Single File (Jeffallan / minimal style)
```
skills/
    laravel-specialist.md   ← everything in one file
```
Simple, no structure. Good for quick testing, not for production team use.

---

## 6. Approach: Command-Driven vs Example-Driven

| | Command-Driven | Example-Driven |
|---|---|---|
| **What it is** | Explicit rules: "always do X, never do Y" | Real code as reference: "follow this pattern exactly" |
| **Best for** | Constraints, architecture decisions, naming conventions | Format, structure, boilerplate patterns |
| **Risk** | AI interprets rules loosely — output varies | AI follows format but misses the why |
| **Market finding** | Most skills use both | Best skills lead with examples |

**Conclusion from market research:** The most effective skills use rules for the WHY and examples for the HOW. A rule that says "resolvers must delegate to a service layer" paired with a real resolver example is more effective than either alone.

**Our test plan:** Build command-only first → example-only second → combined third. Measure which produces output closest to our existing code without correction.

---

## 7. Recommended Resources to Study Next

| Resource | Why |
|---|---|
| [iSerter/laravel-claude-agents](https://github.com/iSerter/laravel-claude-agents) | Deepest coverage — read actual rule content |
| [jpcaparas/superpowers-laravel](https://github.com/jpcaparas/superpowers-laravel) | Modern Laravel 11/12 conventions — read their Eloquent rules |
| [agent-nestjs-skills](https://github.com/Kadajett/agent-nestjs-skills) | Best structure reference — copy their frontmatter format |
| [laravel/agent-skills](https://github.com/laravel/agent-skills) | Official baseline — understand what Laravel endorses |
| [skills.laravel.cloud](https://skills.laravel.cloud) | Browse for any GraphQL skills that may have been added |
| [Freek Van der Herten's CLAUDE.md](https://freek.dev/3026-my-claude-code-setup) | Real-world senior Laravel dev setup |
| [Laravel News — Skills Launch](https://laravel-news.com/laravel-skills) | Context on how the ecosystem is evolving |

---

*Maintained by: Webby Development*  
*Last updated: 2026-04-30*  
*Next step: Pull actual rule content from iSerter and jpcaparas repos, then write first draft of graphql-crud skill*
