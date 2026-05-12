# Coding Principles

## DRY
- Never duplicate logic — extract into services, traits, or helpers

## SOLID
- **S** — Single Responsibility: each class does one thing
- **O** — Open/Closed: open for extension, closed for modification
- **L** — Liskov Substitution: subclasses replaceable for their parent
- **I** — Interface Segregation: small focused interfaces
- **D** — Dependency Inversion: depend on abstractions

## Modularity
- Code organized by domain under `Modules\`
- Each module owns its models, resolvers, services, and schema
- A module may contain multiple models — group by domain
- Cross-module model access is allowed when a relationship requires it
