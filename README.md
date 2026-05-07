# agent-laravel-skills

Webby Development agent skills package for Laravel + Lighthouse GraphQL projects. Encodes team conventions so AI tools generate code in the correct format without correction rounds.

---

## How It Works

Point your AI tool to `AGENTS.md` at the project root. It loads global rules (always active) and skills (triggered per task). The agent then generates code that matches Webby conventions exactly.

---

## Structure

```
AGENTS.md                          ← entry point, loaded by AI tool
agents/
├── brainstorm/BRAINSTORM.md       ← architect agent: plan before code (always active)
├── convention/CONVENTION.md       ← naming conventions (always active)
├── principles/PRINCIPLES.md       ← DRY, SOLID, Modularity (always active)
├── security/SECURITY.md           ← security rules (always active)
├── performance/PERFORMANCE.md     ← performance rules (always active)
└── review/
    ├── SECURITY.md                ← security review agent
    ├── TESTING.md                 ← test review agent
    └── PERFORMANCE.md             ← performance review agent
skills/
├── module/SKILL.md                ← module creation flow
├── models/SKILL.md                ← Eloquent model conventions
├── migration/SKILL.md             ← migration conventions
├── service/SKILL.md               ← service layer conventions
├── job/SKILL.md                   ← async job conventions
└── graphql/
    ├── schema/SKILL.md            ← GraphQL types, enums
    ├── mutation/SKILL.md          ← GraphQL mutation definitions
    ├── query/SKILL.md             ← GraphQL query definitions
    ├── controller/SKILL.md        ← Controller: business logic + execution boundary
    ├── request/SKILL.md           ← FormRequest: mutation input validation
    └── resolver/
        ├── mutator/SKILL.md       ← Mutator class (thin proxy → Controller)
        └── query/SKILL.md         ← Query class (thin proxy → Controller)
```

Each skill has a companion `references/` folder with real code examples.

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

| | Global Rules (`agents/`) | Skills (`skills/`) |
|---|---|---|
| When active | Always, every session | Triggered per task |
| Purpose | Conventions, principles | Task-specific patterns |
| Examples | Naming, DRY/SOLID | Model, migration, GraphQL |
