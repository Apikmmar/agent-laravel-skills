# GraphQL Mutation References

---

## Example 1 — Standard CRUD mutations

```graphql
# Modules/Blog/GraphQL/Schema/Mutations/PostMutation.graphql

extend type Mutation
    @namespace(field: "Modules\\Blog\\GraphQL\\Mutations")
    @guard {
    """
    Create a new post
    """
    createPost(input: CreatePostInput!): SuccessResponse!
        @hasPermission(name: "create-post")
        @field(resolver: "PostMutator@create")

    """
    Update existing post
    """
    updatePost(input: UpdatePostInput!): SuccessResponse!
        @hasPermission(name: "update-post")
        @field(resolver: "PostMutator@update")

    """
    Delete existing post
    """
    deletePost(id: ID!): SuccessResponse!
        @hasPermission(name: "delete-post")
        @field(resolver: "PostMutator@delete")
}

input CreatePostInput {
    user_id: ID!
    category_id: ID!
    title: String!
    body: String!
    status: PostStatus!
    meta: JSON
    published_at: String
}

input UpdatePostInput {
    id: ID!
    category_id: ID
    title: String
    body: String
    status: PostStatus
    meta: JSON
    published_at: String
}
```

**What this shows:**
- `@namespace` on the `extend type` block — enables shorthand `@field(resolver: "PostMutator@create")`
- `@guard` on the block — protects all mutations
- `@hasPermission` on each individual mutation
- Always return `SuccessResponse!`
- No `@validator`, no `@spread` on inputs
- Update input: `id: ID!` first, all other fields optional
- Delete uses flat `id: ID!` — no input type

---

## Example 2 — Custom operation

```graphql
extend type Mutation
    @namespace(field: "Modules\\Blog\\GraphQL\\Mutations")
    @guard {
    """
    Publish a post
    """
    publishPost(id: ID!): SuccessResponse!
        @hasPermission(name: "publish-post")
        @field(resolver: "PostMutator@publish")
}
```

**What this shows:**
- Custom operations follow same pattern — camelCase name, flat args, return `SuccessResponse!`
- Same `@namespace` + `@guard` + `@hasPermission` pattern

---

## Example 3 — Public mutations (no auth)

```graphql
extend type Mutation
    @namespace(field: "Modules\\Auth\\GraphQL\\Mutations") {
    """
    Register a new account
    """
    register(input: RegisterInput!): SuccessResponse!
        @field(resolver: "AuthMutator@register")
}

input RegisterInput {
    name: String!
    email: String!
    password: String!
}
```

**What this shows:**
- No `@guard` when mutations are explicitly public
- No `@hasPermission` on public mutations
- Input still plain — no `@validator`, no `@spread`

---

## Bad ❌ — What NOT to do

```graphql
# Full resolver path — wrong, @namespace makes this redundant
@field(resolver: "Modules\\Blog\\GraphQL\\Mutations\\PostMutator@create")

# @validator on input — not used in this project
input CreatePostInput @validator {
    title: String!
}

# @spread on input — not used
createPost(input: CreatePostInput! @spread): SuccessResponse!

# Missing @guard when mutations should be protected
extend type Mutation
    @namespace(field: "Modules\\Blog\\GraphQL\\Mutations") {
    createPost(input: CreatePostInput!): SuccessResponse!

# PascalCase mutation name — must be camelCase
CreatePost(input: CreatePostInput!): SuccessResponse!

# Not returning SuccessResponse!
createPost(input: CreatePostInput!): Post
```
