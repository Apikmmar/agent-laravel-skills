# GraphQL Schema — Component References

---

## Example 1 — Type with relationships and enums

```graphql
# Modules/Blog/GraphQL/Schema/Components/PostSchema.graphql

type Post {
    id: ID!
    user_id: ID!
    category_id: ID!
    title: String!
    body: String!
    status: PostStatus!
    meta: JSON
    published_at: DateTime
    user: User @belongsTo
    category: Category @belongsTo
    comments: [Comment!]! @hasMany(relation: "comments")
    featured_image: PostImage @hasOne(relation: "featuredImage")
    created_at: DateTime!
    updated_at: DateTime!
}

enum PostStatus {
    draft
    published
    archived
}
```

**What this shows:**
- `id` always first field
- Relationship fields use Lighthouse directives
- `relation:` used when PHP method name differs from field name
- Enum defined in same file as the type that uses it
- Enum values lowercase

---

## Example 2 — Simple type, no relationships

```graphql
# Modules/Blog/GraphQL/Schema/Components/TagSchema.graphql

type Tag {
    id: ID!
    name: String!
    slug: String!
    is_active: Boolean!
    created_at: DateTime!
    updated_at: DateTime!
}
```

---

## Bad ❌ — What NOT to do

```graphql
# Type defined inside mutation file — never do this
extend type Mutation {
    type Post { ... }
    CreatePost(...): SuccessResponse
}

# Enum values in UPPERCASE — wrong for component enums
enum PostStatus {
    DRAFT
    PUBLISHED
}

# camelCase field names — wrong, use snake_case
type Post {
    userId: ID!
    createdAt: DateTime!
}
```
