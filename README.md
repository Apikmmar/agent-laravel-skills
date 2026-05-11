# webbyx-laravel

Webby Development agent skills package for Laravel + Lighthouse GraphQL projects. Encodes team conventions so AI tools generate code in the correct format without correction rounds.

---

## How It Works

Point your AI tool to `AGENTS.md` at the project root. It loads global rules (always active) and skills (triggered per task). The agent then generates code that matches Webby conventions exactly.

---

## Structure

```
AGENTS.md                                              ← entry point, loaded by AI tool
CLAUDE.md                                              ← points to AGENTS.md
webbyx-laravel-module/
├── SKILL.md                                           ← module creation flow
└── agents/                                            ← embedded global rules (always active)
webbyx-laravel-model/
├── SKILL.md                                           ← Eloquent model conventions
└── agents/
webbyx-laravel-migration/
├── SKILL.md                                           ← migration conventions
└── agents/
webbyx-laravel-service/
├── SKILL.md                                           ← service layer conventions
└── agents/
webbyx-laravel-job/
├── SKILL.md                                           ← async job conventions
└── agents/
webbyx-laravel-trait/
├── SKILL.md                                           ← trait conventions
└── agents/
webbyx-laravel-test/
├── SKILL.md                                           ← test conventions
└── agents/
webbyx-laravel-reviewer/
├── SKILL.md                                           ← code review (security, performance, testing)
├── agents/
└── references/
    ├── SECURITY.md
    ├── PERFORMANCE.md
    └── TESTING.md
webbyx-laravel-graphql/
├── SKILL.md                                           ← unified GraphQL skill
├── agents/
└── references/
    ├── schema/        RULES.md + EXAMPLES.md
    ├── mutation/      RULES.md + EXAMPLES.md
    ├── query/         RULES.md + EXAMPLES.md
    ├── resolver-mutator/  RULES.md + EXAMPLES.md
    ├── resolver-query/    RULES.md + EXAMPLES.md
    ├── controller/    RULES.md + EXAMPLES.md
    └── request/       RULES.md + EXAMPLES.md
```

Each skill is self-contained — the `agents/` folder inside each skill embeds the global rules (BRAINSTORM, CONVENTION, PRINCIPLES, SECURITY, PERFORMANCE) so the skill works correctly when uploaded to a Claude organization.

---

## Skill Format

Every `SKILL.md` follows this structure:

```
frontmatter   → name, description (used by agent to match trigger phrases)
## Rule       → the convention in one sentence
## Why        → reason behind the rule
## Conventions → detailed rules and file structure
## Clarifying Questions → what the agent should ask before generating
## Reference  → points to references/*.md
```

---

## Adding a New Skill

1. Create `skills/{topic}/SKILL.md`
2. Create `skills/{topic}/references/{TOPIC}.md` with real code examples (Good + Bad)
3. Add the path to `AGENTS.md` under `## Skills`

---

## Global Rules vs Skills

| | Global Rules (`agents/`) | Skills |
|---|---|---|
| When active | Always, on every invocation | Triggered per task |
| Purpose | Conventions, principles | Task-specific patterns |
| Examples | Naming, DRY/SOLID, Security | Model, migration, GraphQL |
| Location | Embedded inside each skill's `agents/` folder | Root-level skill folders |
