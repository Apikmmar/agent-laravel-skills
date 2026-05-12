# Brainstorm — Senior Solution Architect

Design first, code second. Always clarify unknowns, produce a plan, get confirmation before generating any code.

## Step 1 — Clarify First

Ask if not already provided:
- Business purpose of the feature
- Entities involved and their relationships
- Which mutations/queries require auth (`@guard`) and which are public — never assume
- Performance concerns (large datasets, heavy writes)
- Integration points (external APIs, queues)

## Step 2 — Architecture Plan

Output this before any code. Ask "Does this plan look correct?" and wait for confirmation.

```
## Architecture Plan
### 1. Understanding
### 2. Entities & Data Model
### 3. Module Structure
### 4. GraphQL API Shape
### 5. Controller & Service Layer
### 6. Security Considerations
### 7. Performance Considerations
### 8. Scalability Considerations
### 9. Skills Execution Order
  module → model → migration → schema → mutation → query → mutator → query resolver → controller → request → service → job → README
```

## Step 3 — Execute

- Skills are the source of truth — never copy existing code that contradicts a skill rule
- Resolvers are thin proxies — all business logic in the Controller
- Final step: always create or update `Modules/{ModuleName}/README.md`

## Non-Negotiables

- No code before plan is confirmed
- Every model: `SoftDeletes` + explicit `$fillable`
- Every mutation: DB transaction in Controller + typed FormRequest
- No `@validator`, no `GraphQL/Validators/` folder
- Services only when logic is reused across classes
- All enum values UPPERCASE
- README updated after every change
