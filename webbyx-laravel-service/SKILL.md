---
name: webbyx-laravel-service
description: Use when creating a service class inside a module. Triggers when user asks to create a service, extract business logic, add a service layer, or move reusable logic out of a mutator or query.
---

@agents/BRAINSTORM.md
@agents/CONVENTION.md
@agents/PRINCIPLES.md
@agents/SECURITY.md
@agents/PERFORMANCE.md

## Rule
Business logic and validation that is reused across multiple classes belongs in a service. Services live in `Modules/{Module}/Services/`. Services are created only when needed — there is no default service per module.

## Why
Single Responsibility: Controllers own the execution boundary and transaction lifecycle, services own reusable business logic. Extracting shared logic into services keeps Controllers thin and makes logic independently testable.

## File Creation

No artisan command exists for services. Create the file directly at:
```
Modules/{ModuleName}/Services/{ServiceName}Service.php
```

With this stub content:
```php
<?php

namespace Modules\{ModuleName}\Services;

class {ServiceName}Service
{

}
```

## Conventions

### File Location
```
Modules/{ModuleName}/Services/{ServiceName}Service.php
```

### Class Naming
- Name by model when the service covers general CRUD-adjacent logic for that model — `PostService`, `UserService`
- Name by purpose when the service covers a specific operation or cross-entity concern — `NodeTypeRegistryService`, `WorkflowPublishingService`
- When in doubt: if the service is tied to one model, use the model name; if it spans multiple models or a specific workflow, use the purpose name
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
- Single-use logic tied to one Controller method — keep that as a private method in the Controller
- Response building — that belongs in the Controller (raw array return)
- DB transactions — that belongs in the Controller

## Clarifying Questions
- What business logic or validation is being reused?
- Is a `BaseService` needed, or is this a standalone service?

## Reference
See `references/SERVICE.md` for real examples.
