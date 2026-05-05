# GraphQL Mutation References

---

## Example 1 — Standard CRUD mutations

```graphql
# Modules/Blog/GraphQL/Schema/Mutations/PostMutation.graphql

extend type Mutation {
    CreatePost(input: CreatePostInput! @spread): SuccessResponse
        @field(resolver: "Modules\\Blog\\GraphQL\\Mutations\\PostMutator@create")

    UpdatePost(input: UpdatePostInput! @spread): SuccessResponse
        @field(resolver: "Modules\\Blog\\GraphQL\\Mutations\\PostMutator@update")

    DeletePost(ids: [ID!]!): SuccessResponse
        @field(resolver: "Modules\\Blog\\GraphQL\\Mutations\\PostMutator@delete")
}

input CreatePostInput @validator {
    user_id: ID!
    category_id: ID!
    title: String!
    body: String!
    status: PostStatus!
    meta: JSON
    published_at: String
}

input UpdatePostInput @validator {
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
- `extend type Mutation` always
- Always return `SuccessResponse`
- Always `@spread` on input
- Always `@validator` on Create/Update inputs
- Update input: `id: ID!` first, all other fields optional
- Delete uses bulk `ids: [ID!]!`

---

## Example 2 — Delete single + custom operation

```graphql
extend type Mutation {
    DeletePost(id: ID!): SuccessResponse
        @field(resolver: "Modules\\Blog\\GraphQL\\Mutations\\PostMutator@delete")

    PublishPost(id: ID!): SuccessResponse
        @field(resolver: "Modules\\Blog\\GraphQL\\Mutations\\PostMutator@publish")
}
```

**What this shows:**
- Single delete uses `id: ID!`
- Custom operations follow same pattern — PascalCase name, return `SuccessResponse`

---

## Example 3 — Nested inputs (no @validator on nested)

```graphql
input CreatePostInput @validator {
    title: String!
    body: String!
    meta: PostMetaInput!
    tags: [PostTagInput!]
}

input PostMetaInput {
    seo_title: String
    seo_description: String
}

input PostTagInput {
    tag_id: ID!
}
```

**What this shows:**
- Only top-level Create/Update inputs get `@validator`
- Nested inputs never get `@validator`

---

## Bad ❌ — What NOT to do

```graphql
# Missing @validator on Create/Update input
input CreatePostInput {
    title: String!
}

# Missing @spread
CreatePost(input: CreatePostInput!): SuccessResponse

# Not returning SuccessResponse
CreatePost(input: CreatePostInput! @spread): Post

# Resolver path wrong format
@field(resolver: "PostMutator@create")
```
