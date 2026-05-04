# Agent Skills Research & Strategy
**Company:** Webby Development  
**Stack:** Laravel + Lighthouse GraphQL (Backend)  
**Goal:** Build company-specific agent skills package / MCP  
**Date:** 2026-04-29

---

## Table of Contents
1. [What Are Agent Skills](#1-what-are-agent-skills)
2. [Available Agent Skills in the Market](#2-available-agent-skills-in-the-market)
3. [Pros of Using Agent Skills](#3-pros-of-using-agent-skills)
4. [Problems It Solves](#4-problems-it-solves)
5. [How Effective Is It](#5-how-effective-is-it)
6. [Skills vs Normal Prompting](#6-skills-vs-normal-prompting)
7. [Best Practices When Using Agent Skills](#7-best-practices-when-using-agent-skills)
8. [Best Practices When NOT Using Agent Skills](#8-best-practices-when-not-using-agent-skills)
9. [Best Practices for Building Agent Skills](#9-best-practices-for-building-agent-skills)
10. [Our Build Plan](#10-our-build-plan)
11. [CTO Pitch Summary](#11-cto-pitch-summary)

---

## 1. What Are Agent Skills

Agent skills are configuration/rule files that package reusable knowledge for AI coding agents. They solve the core problem that LLMs cannot infer unstated conventions — project structure, code style, commands, and domain-specific best practices get lost across sessions.

Different AI tools read different files at session start:

| AI Tool | File It Reads |
|---|---|
| Claude Code | `CLAUDE.md` or `AGENTS.md` |
| Cursor | `.cursorrules` or `.cursor/rules/*.mdc` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Any agent (universal) | `AGENTS.md` |

**Key concept:** Skills use *progressive disclosure* — loads name/description first (~50 tokens), full instructions only when a matching task is triggered (~500 tokens). This is fundamentally different from dumping all context into every prompt.

---

## 2. Available Agent Skills in the Market

| Package / Platform | Type | Notable |
|---|---|---|
| [skills.sh](https://dev.to/stevengonsalvez/skillssh-npm-for-agent-skills-35jc) | Package manager | 350K+ packages by Feb 2026, Vercel/Stripe/Supabase ships here |
| [laravel/agent-skills](https://github.com/laravel/agent-skills) | Official Laravel | PHP backend specific |
| [agent-nestjs-skills](https://github.com/Kadajett/agent-nestjs-skills) | Community reference | NestJS, best example of rule structure |
| [awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) | Curated list | 36.9K stars, multi-framework |
| [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) | MCP reference | Official MCP implementations |
| [NestJS Expert Skill](https://agentskills.so/skills/jeffallan-claude-skills-nestjs-expert) | Specialized | TypeScript backend specialist |
| [gh skill](https://thesyntaxdiaries.com/gh-skill-github-cli-agent-skills-security) | GitHub CLI | Shipped natively April 2026 |
| [skillmatic-ai/awesome-agent-skills](https://github.com/skillmatic-ai/awesome-agent-skills) | Curated collection | Framework-agnostic |

> **Ecosystem scale:** Thousands in Dec 2025 → 350,000+ packages by Feb 2026. Explosive growth.

---

## 3. Pros of Using Agent Skills

- **Token efficiency** — Progressive disclosure: 50 tokens for discovery, 500 for full load. Normal prompting loads everything every time.
- **Team consistency** — Encodes your conventions so every dev gets the same output quality regardless of how they phrase their prompt.
- **Speed** — 40 hours traditional prompting per feature → 5 hours with skills.
- **Accuracy improvements** — Real benchmark data:
  - Sentiment detection: 78% → 94%
  - Data extraction: 71% → 96%
  - Classification: 83% → 97%
  - Intent recognition: 76% → 93%
- **Context persistence** — Skills reload on every session. Normal prompting degrades after ~3,000 tokens in long sessions.
- **Knowledge codification** — Captures senior dev knowledge that otherwise lives only in people's heads.

---

## 4. Problems It Solves

| Problem | How Skills Solve It |
|---|---|
| AI forgets your conventions mid-session | Skills reload context every session |
| "Almost right" code (66% of dev frustration) | Encodes exact patterns so AI reproduces correctly first time |
| Junior devs getting inconsistent AI output | Everyone reads from the same rulebook |
| Repeating yourself every session | Write the rule once, used forever |
| Framework drift (AI uses outdated patterns) | You control the version of the pattern |
| Code review catching the same AI mistakes | Rules prevent the mistake at generation time |
| New dev onboarding takes too long | AI already knows your conventions, teaches as it generates |

---

## 5. How Effective Is It

| Benchmark | Result |
|---|---|
| Average pass rate improvement | **+16.2 percentage points** |
| Claude Code with Opus | **+23.3 percentage points** |
| Software engineering tasks | +4.5pp |
| Specialized domain (e.g. healthcare) | +51.9pp |
| Enterprise ROI | **3–6x within first year** |
| Developer time saved | **8 hours/week per developer** |

Source: [SkillsBench](https://arxiv.org/html/2602.12670v1), [Anthropic Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)

---

## 6. Skills vs Normal Prompting

| Metric | With Skills | Normal Prompting |
|---|---|---|
| Tokens per 1,000 operations | **85K tokens ($1.70)** | 525K tokens ($10.50) |
| Development time per feature | **5 hours** | 40 hours |
| Output accuracy | **91–96%** | 71–83% |
| Context persistence | Full session | Degrades after ~3K tokens |
| Team consistency | High — encoded in rules | Low — depends on who prompts |
| Correction rounds per output | 1–2 | 3–5+ |

> **Token cost reduction: ~84%** when skills replace repeated prompting across 1,000 operations.

### Token Trade-off Explained

Skills **cost** tokens upfront (injected at session start) but **save** tokens by eliminating correction round-trips.

```
Without skills:
  Round 1: generate → wrong format        (+2,000 tokens)
  Round 2: correct → still slightly off   (+1,500 tokens)
  Round 3: correct again → finally right  (+1,000 tokens)
  Total: ~4,500 tokens per feature

With skills:
  Round 1: generate → correct first try   (+800 tokens)
  Total: ~800 tokens per feature
```

Net result: Skills are a **net token saver** only when rules are specific and well-written. Vague rules cost tokens AND reduce accuracy by ~3% while spiking costs ~20%.

---

## 7. Best Practices When Using Agent Skills

How developers should interact with AI when skills are loaded:

- **Be brief on intent** — The skill already knows the format. Say `"generate GraphQL CRUD for products"` not `"generate GraphQL CRUD using our service layer with lighthouse mutations and..."`. Over-explaining creates conflicting context.
- **Trust the clarifying questions** — When AI asks for function name, table, fields — answer directly and concisely.
- **Don't re-explain what the skill covers** — If your skill defines the service layer pattern, repeating it in the prompt confuses the AI.
- **Iterate on the skill, not the prompt** — If output is wrong, fix the rule file. Don't add more words to your prompt as a workaround.
- **Scope requests to one skill at a time** — "Generate the resolver" then separately "Generate the test" — not both at once.
- **Validate output** — Even with skills, review generated code before committing. Skills reduce mistakes, they don't eliminate them.

---

## 8. Best Practices When NOT Using Agent Skills

How developers should interact with AI using only normal prompting:

- **Provide full context upfront** — Framework, pattern, file structure, naming conventions — all in one message.
- **Include a real code example** — `"follow this exact pattern: [paste your existing code]"` is the most effective technique.
- **Optimal prompt length: 150–300 words** — Below is too vague, above starts getting ignored by the AI.
- **Break into sequential steps** — Don't ask for a full feature at once. Ask for service layer first → resolver second → test third.
- **Validate every output manually** — Without rules, AI invents conventions. Never trust first output blindly, especially for architecture-sensitive code.
- **Re-anchor on long sessions** — After 3,000+ tokens of conversation, paste your convention reminder again. AI drifts in long sessions.
- **Name your constraints explicitly** — `"Use PHP 8.2, Laravel 11, Lighthouse 6, no raw SQL"` reduces wrong assumptions.

---

## 9. Best Practices for Building Agent Skills

### Rule File Format

```markdown
---
title: GraphQL CRUD Resolver
impact: CRITICAL
tags: [graphql, crud, resolver, lighthouse]
---

## Rule
[One clear sentence describing the convention]

## Why
[Why this convention exists — the reason matters for edge cases]

## Bad ❌
```php
// what NOT to do with explanation
```

## Good ✅
```php
// what TO do with explanation
```

## Clarifying Questions to Ask
- What is the resolver/function name?
- Which model/table?
- What fields to expose?
```

### Rule Writing Rules

| Do | Don't |
|---|---|
| Show real bad vs good PHP code | Write generic advice ("write clean code") |
| Keep each rule under 80 lines | Dump everything in one file |
| Add rules when AI actually made the mistake | Write rules for hypothetical scenarios |
| Pair "never do X" with "do Y instead" | Just ban things without alternatives |
| Use YAML frontmatter with impact level | Skip metadata |
| Reference your actual naming conventions | Use abstract placeholder examples |
| Test rule in isolation before deploying | Deploy untested rules to whole team |

### Impact Levels
- `CRITICAL` — Architecture decisions, patterns that affect the whole codebase
- `HIGH` — Conventions that affect readability and maintainability
- `MEDIUM` — Style preferences, naming conventions
- `LOW` — Minor optimizations

### Progressive Loading Pattern
```
Skill discovery   → 50 tokens    (name + description only)
Skill activation  → ~500 tokens  (full instructions loaded when task matches)
Skill execution   → as needed    (reference examples pulled on demand)
```
Only load full skill when the task matches — do not inject all rules into every context.

### Versioning & Maintenance
- Version control rules alongside application code in the same repo
- When AI makes the same mistake twice → write a rule to prevent it
- Review rules quarterly — remove rules the AI no longer gets wrong (they've been internalized)
- Tag rules with the version of Laravel/Lighthouse they apply to
- Keep a `CHANGELOG.md` for rule changes so team knows what changed

### Security Note
36.82% of public skills packages carry at least one security issue, 13.4% have critical flaws (Snyk research). Since this is an internal package, you control quality — but still audit any external skills before adopting.

---

## 10. Our Build Plan

### Proposed Structure

```
agent-laravel-skills/
    skills/
        graphql-crud/
            skill.md
            references/
                mutation.example.php
                query.example.php
                resolver.example.php
        unit-test/
            skill.md
            references/
                test.example.php
        app-service/
            skill.md
            references/
                service.example.php
        cron-job/
            skill.md
            references/
                job.example.php
        module-structure/
            skill.md
    AGENTS.md           ← compiled single file (all rules merged, for Claude Code)
    CLAUDE.md           ← entry point for Claude Code
    .cursor/
        rules/          ← MDC format for Cursor (scoped per file type)
    RESEARCH.md         ← this file
    CHANGELOG.md        ← rule version history
```

### Planned Skills (to be defined)

| Skill | Priority | Status |
|---|---|---|
| GraphQL CRUD (Lighthouse) | CRITICAL | Pending — awaiting code style input |
| App Service layer | CRITICAL | Pending |
| Unit Test format | CRITICAL | Pending |
| Cron Job structure | HIGH | Pending |
| Module structure (Lighthouse) | CRITICAL | Pending |
| Model conventions | HIGH | Pending |
| Error handling | HIGH | Pending |
| GraphQL input validation | HIGH | Pending |

### MCP Integration Plan

Since the goal is to build this as an MCP (not just static rules), the interaction flow becomes:

```
Dev request
    ↓
MCP server reads matching skill
    ↓
AI asks clarifying questions (function name? table? fields?)
    ↓
MCP fetches relevant DB schema or existing module structure (dynamic)
    ↓
AI generates code in exact company format
    ↓
Output matches codebase conventions first try
```

**Advantage over static rules:** MCP can be dynamic — fetch actual DB schema, validate against existing modules, auto-detect Lighthouse directives already in use, enforce naming consistency with existing resolvers.

### Next Steps
1. Define code style (developer to provide examples of existing code)
2. Write first rule file: `graphql-crud/skill.md`
3. Test against Claude Code — generate a sample resolver
4. Compare output to manually written code
5. Iterate on rule until output matches exactly
6. Repeat for each skill
7. Compile into `AGENTS.md`
8. Test team-wide adoption

---

## 11. CTO Pitch Summary

> **"This is not a prompt collection. This is encoding our team's architecture decisions into a reusable, versioned, measurable system that every developer and AI tool in our team reads from."**

### The Numbers
- **84% token cost reduction** vs repeated prompting
- **8x faster** feature generation (5 hrs vs 40 hrs)
- **+16–23 percentage point** improvement in output correctness
- **3–6x ROI** within first year (enterprise benchmark)
- **8 hours/week saved** per developer

### Why Not Just Use Good Prompts?
| Argument | Counter |
|---|---|
| "Just use a good prompt" | Prompts die every session. Rules persist across the whole team permanently. |
| "Maintenance overhead" | Update once, applies everywhere. Less overhead than fixing repeated AI mistakes in PRs. |
| "AI already knows Laravel" | It knows generic Laravel. It does not know our GraphQL + Lighthouse + Service layer pattern. |
| "How do we measure ROI?" | Count correction rounds per PR before vs after. Track generation time per feature. |
| "Developers will just ignore it" | It's loaded automatically — they don't have to remember to use it. |

### Why This Matters Specifically for Us
- We use **Lighthouse GraphQL with Modules** — a specific pattern AI consistently gets wrong without guidance
- We have **our own code style** — without rules, every dev gets different AI output, creating inconsistency in the codebase
- We want **all team members to apply the same conventions** — this enforces it at the AI generation level, not just code review
- Building this as **MCP** means it can be dynamic — not just static rules but an intelligent assistant that understands our actual schema and module structure

---

*Document maintained by: Webby Development*  
*Last updated: 2026-04-29*  
*Next review: When code style is defined and first rule is written*
