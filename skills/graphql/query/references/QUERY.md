# GraphQL Query References

---

## Example 1 — Listing with filter and sort

```graphql
# Modules/Blog/GraphQL/Schema/Queries/PostQueries.graphql

extend type Query {
    PostListing(input: PostListingInput @spread): [Post!]!
        @paginate(builder: "Modules\\Blog\\GraphQL\\Queries\\PostQuery@listing")

    PostDetail(id: ID! @eq): Post
        @field(resolver: "Modules\\Blog\\GraphQL\\Queries\\PostQuery@detail")
}

input PostListingInput {
    filter: PostFilterInput
    sorts: [PostSortInput!]
}

input PostFilterInput {
    title: String
    status: PostStatus
    user_id: ID
    created_at: String
}

input PostSortInput {
    column: PostSortColumn!
    direction: SortDirection!
}

enum SortDirection {
    ASC
    DESC
}

enum PostSortColumn {
    CREATED_AT
    TITLE
}
```

**What this shows:**
- Listing uses `@paginate` with `builder:`
- Detail uses `@field` with `resolver:`
- Listing input always has `filter` + `sorts`
- `SortDirection` defined per module
- `{Model}SortColumn` includes `CREATED_AT` + additional sortable columns
- Sort column enum values in UPPERCASE

---

## Example 2 — Dropdown query

```graphql
extend type Query {
    PostDropdown: [PostDropdown!]!
        @field(resolver: "Modules\\Blog\\GraphQL\\Queries\\PostQuery@dropdown")
}

type PostDropdown {
    id: ID!
    name: String!
}
```

**What this shows:**
- Dropdown uses `@field` — no pagination, no input needed
- Returns a simplified `{Model}Dropdown` type — always `id` + one label field (usually `name`)
- Define the `{Model}Dropdown` type in the module's `Components/{Model}Schema.graphql`

---

## Bad ❌ — What NOT to do

```graphql
# Using @field for listing — should be @paginate
PostListing(input: PostListingInput @spread): [Post!]!
    @field(resolver: "Modules\\Blog\\GraphQL\\Queries\\PostQuery@listing")

# Missing sorts from listing input
input PostListingInput {
    filter: PostFilterInput
}

# camelCase field names in filter input
input PostFilterInput {
    userId: ID
    createdAt: String
}

# SortColumn values not UPPERCASE
enum PostSortColumn {
    created_at
    title
}
```
