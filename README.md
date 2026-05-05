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
├── convention/convention.md       ← naming conventions (always active)
└── principles/principles.md       ← DRY, SOLID, Modularity (always active)
skills/
├── module/skill.md                ← module creation flow
├── models/skill.md                ← Eloquent model conventions
├── migration/skill.md             ← migration conventions
├── service/skill.md               ← service layer conventions
└── graphql/
    ├── schema/skill.md            ← GraphQL types, enums
    ├── mutation/skill.md          ← GraphQL mutation definitions
    ├── query/skill.md             ← GraphQL query definitions
    └── resolver/
        ├── mutator/skill.md       ← Mutator class (create/update/delete)
        └── query/skill.md         ← Query class (listing/detail/dropdown)
```

Each skill has a companion `references/` folder with real code examples.

---

## Skill Format

Every `skill.md` follows this structure:

```
frontmatter   → title, impact, tags
## Rule       → the convention in one sentence
## Why        → reason behind the rule
## Conventions → detailed rules and file structure
## Clarifying Questions → what the agent should ask before generating
## Reference  → points to references/*.md
```

---

## Adding a New Skill

1. Create `skills/{topic}/skill.md`
2. Create `skills/{topic}/references/{topic}.md` with real code examples (Good + Bad)
3. Add the path to `AGENTS.md` under `## Skills`

---

## Global Rules vs Skills

| | Global Rules (`agents/`) | Skills (`skills/`) |
|---|---|---|
| When active | Always, every session | Triggered per task |
| Purpose | Conventions, principles | Task-specific patterns |
| Examples | Naming, DRY/SOLID | Model, migration, GraphQL |
