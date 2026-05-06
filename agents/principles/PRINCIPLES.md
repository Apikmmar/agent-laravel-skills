# Coding Principles

These principles apply globally to all code generation tasks.

---

## DRY (Don't Repeat Yourself)
- Never duplicate logic — extract reusable code into services, traits, or helpers
- If the same logic appears more than once, it belongs in a shared class

## SOLID
- **S** — Single Responsibility: each class does one thing only
- **O** — Open/Closed: open for extension, closed for modification
- **L** — Liskov Substitution: subclasses must be replaceable for their parent
- **I** — Interface Segregation: prefer small focused interfaces over large ones
- **D** — Dependency Inversion: depend on abstractions, not concrete implementations

## Modularity
- Code is organized by domain under `Modules\`
- Each module owns its models, resolvers, services, and schema
- A module may contain multiple models — group by domain, not by one model per module
- Cross-module model access is allowed — import and use models from other modules when a relationship requires it
