---
title: Service Layer
impact: CRITICAL
tags: [service, business-logic, dry, solid]
---

## Rule
Business logic and validation that is reused across multiple classes belongs in a service. Services live in `Modules/{Module}/Services/`. Services are created only when needed — there is no default service per module.

## Why
Single Responsibility: mutators own the GraphQL boundary and transaction lifecycle, services own reusable business logic. Extracting shared logic into services keeps mutators thin and makes logic independently testable.

## Conventions

### File Location
```
Modules/{ModuleName}/Services/{ServiceName}Service.php
```

### Class Naming
- Name by what it does, not strictly by model — `PostService`, `NodeTypeRegistryService`, `WorkflowNodesService`
- Must follow PascalCase + `Service` suffix
- Namespace: `Modules\{Module}\Services`

### BaseService
- No default `BaseService` per module — create one only when shared utility methods are needed across multiple services in the module
- When created: `Modules/{Module}/Services/BaseService.php`
- Extend only when the service needs those shared utilities

### Private Methods
- Break complex logic into private methods for readability (DRY, SRP)
- Every fetch/lookup (e.g. `getPost`, `getPosts`) must be a private method — never inline

### What Belongs in a Service
- Business logic reused by more than one class
- Validation that involves model lookups or cross-entity rules
- Bulk operations (bulk create, bulk update)

### What Does NOT Belong in a Service
- Single-use logic tied to one mutator/query — keep that as a private method in the caller
- GraphQL response building — that belongs in the mutator via `GraphQLResponse` trait
- DB transactions — that belongs in the mutator

## Clarifying Questions
- What business logic or validation is being reused?
- Is a `BaseService` needed, or is this a standalone service?

## Reference
See `references/service.md` for real examples.
