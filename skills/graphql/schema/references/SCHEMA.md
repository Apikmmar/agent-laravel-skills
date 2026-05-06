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
- `relation:` used when PHP method name differs from field name (e.g. `featuredImage` → `relation: "featuredImage"`)
- `@belongsTo` with no `relation:` when field name matches the PHP method exactly (e.g. `user` → `belongsTo()`)
- Enum defined in same file as the type that uses it
- Enum values lowercase

---

## Example 3 — @belongsTo with explicit `relation:` argument

Use `relation:` when the GraphQL field name and the PHP relationship method name differ.

```graphql
# Modules/Shop/GraphQL/Schema/Components/OrderSchema.graphql

type Order {
    id: ID!
    placed_by_id: ID!
    billing_address_id: ID!

    # PHP method is placedBy(), field name is placed_by — must use relation:
    placed_by: User @belongsTo(relation: "placedBy")

    # PHP method is billingAddress(), field name is billing_address — must use relation:
    billing_address: Address @belongsTo(relation: "billingAddress")

    # PHP method is items(), field name matches — no relation: needed
    items: [OrderItem!]! @hasMany(relation: "items")

    created_at: DateTime!
    updated_at: DateTime!
}
```

**When to use `relation:`:**
- Only when the GraphQL field name differs from the PHP relationship method name
- Example: field `placed_by` maps to PHP method `placedBy` — use `@belongsTo(relation: "placedBy")`
- If the field name already matches the PHP method name exactly, omit `relation:`

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
