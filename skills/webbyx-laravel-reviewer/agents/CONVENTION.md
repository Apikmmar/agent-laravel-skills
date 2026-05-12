# Naming Conventions

## PHP

| What | Convention | Example |
|---|---|---|
| Files | PascalCase | `UserController.php` |
| Migration files | timestamp_snake_case | `2024_01_01_000000_create_users_table.php` |
| Classes | PascalCase | `UserController` |
| Methods | camelCase | `getUsers()` |
| Variables | camelCase | `$userId` |
| Constants | ALL_CAPS | `STATUS_ACTIVE` |

## Database

| What | Convention |
|---|---|
| Table names | snake_case |
| Column names | snake_case |

## Class Suffixes

| What | Pattern | Example |
|---|---|---|
| Mutation resolver | `{Model}Mutator` | `PostMutator` |
| Query resolver | `{Model}Query` | `PostQuery` |
| Controller | `{Model}Controller` | `PostController` |
| FormRequest | `{Action}{Model}Request` | `CreatePostRequest` |
| Service | `{Name}Service` | `PostService` |

## GraphQL

| What | Convention | Example |
|---|---|---|
| Types | PascalCase | `User` |
| Inputs | PascalCase + `Input` | `CreateUserInput` |
| Enums | PascalCase | `WEStatus` |
| Mutations / Queries | camelCase | `createUser`, `paginatedUsers` |
| Fields | snake_case | `workflow_id` |
| Enum values | UPPERCASE | `ACTIVE`, `PENDING` |
