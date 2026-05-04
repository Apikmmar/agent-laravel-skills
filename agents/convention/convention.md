# Naming Conventions

These conventions apply globally to all code generation tasks.

---

## PHP

| What | Convention | Example |
|---|---|---|
| Files | PascalCase | `UserController.php`, `PostService.php` |
| Migration files | timestamp_snake_case | `2024_01_01_000000_create_users_table.php` |
| Classes | PascalCase | `UserController`, `PostService` |
| Functions / Methods | camelCase | `getUsers()`, `createPost()` |
| Variables | camelCase | `$userId`, `$postTitle` |
| Constants | ALL_CAPS | `STATUS_ACTIVE`, `MAX_RETRY` |

## Database

| What | Convention | Example |
|---|---|---|
| Table names | snake_case | `workflow_execution`, `user_profiles` |
| Column names | snake_case | `first_name`, `created_at`, `parent_execution_id` |

## GraphQL

| What | Convention | Example |
|---|---|---|
| Type names | PascalCase | `User`, `WorkflowExecution` |
| Input names | PascalCase + `Input` suffix | `CreateWorkflowInput`, `UpdateUserInput` |
| Enum names | PascalCase | `WEStatus`, `TriggerType` |
| Mutation / Query names | PascalCase | `CreateWorkflow`, `DeleteUser` |
| Fields | snake_case | `workflow_id`, `parent_execution_id` |
| Enum values | lowercase | `pending`, `running`, `completed` |
