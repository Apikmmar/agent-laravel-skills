# GraphQL Query References

---

## Example 1 — Paginated listing + detail

```graphql
# Modules/Blog/GraphQL/Schema/Queries/PostQueries.graphql

extend type Query
    @guard
    @namespace(
        field: "Modules\\Blog\\GraphQL\\Queries"
        paginate: "Modules\\Blog\\GraphQL\\Queries"
    ) {
    """
    Fetch specific post detail
    """
    post(id: ID!): Post
        @hasPermission(name: "view-post")
        @field(resolver: "PostQuery@detail")

    """
    Fetch paginated list of posts
    """
    paginatedPosts: [Post!]!
        @hasPermission(name: "view-all-posts")
        @paginate(builder: "PostQuery@paginatedListing")
}
```

**What this shows:**
- `@namespace` with both `field:` and `paginate:` keys — required when mixing `@field` and `@paginate`
- `@guard` on the block — protects all queries
- `@hasPermission` on each individual query
- `@paginate(builder:)` for paginated listing — `paginatedListing` in Controller must return a `Builder`
- `@field(resolver:)` for detail — shorthand, namespace comes from the block
- Detail takes `id: ID!` as a flat arg

---

## Example 2 — Non-paginated listing

```graphql
extend type Query
    @guard
    @namespace(
        field: "Modules\\Blog\\GraphQL\\Queries"
        paginate: "Modules\\Blog\\GraphQL\\Queries"
    ) {
    """
    Fetch all posts as a flat list
    """
    posts: [Post!]!
        @hasPermission(name: "view-all-posts")
        @field(resolver: "PostQuery@listing")
}
```

**What this shows:**
- Non-paginated listing uses `@field(resolver:)` — not `@paginate`
- `listing` in Controller returns a Collection via `->get()`

---

## Example 3 — Dropdown query

```graphql
extend type Query
    @guard
    @namespace(field: "Modules\\Blog\\GraphQL\\Queries") {
    """
    Fetch posts for dropdown
    """
    postDropdown: [PostDropdown!]!
        @hasPermission(name: "view-all-posts")
        @field(resolver: "PostQuery@dropdown")
}
```

**What this shows:**
- Dropdown uses `@field` — no pagination
- When only `@field` is used, only `field:` key needed in `@namespace`
- Returns a simplified type defined in `Components/PostSchema.graphql`

---

## Example 4 — Public queries (no auth)

```graphql
extend type Query
    @namespace(field: "Modules\\Blog\\GraphQL\\Queries") {
    """
    Fetch published posts
    """
    publishedPosts: [Post!]!
        @field(resolver: "PostQuery@listing")
}
```

**What this shows:**
- No `@guard` when queries are explicitly public
- No `@hasPermission` on public queries

---

## Bad ❌ — What NOT to do

```graphql
# Full resolver path — wrong, @namespace makes this redundant
@field(resolver: "Modules\\Blog\\GraphQL\\Queries\\PostQuery@detail")

# Using @field for paginated listing — must use @paginate
posts: [Post!]!
    @field(resolver: "PostQuery@paginatedListing")

# Using @paginate without builder — breaks
paginatedPosts: [Post!]!
    @paginate

# @spread on query input — not used
posts(input: PostListingInput @spread): [Post!]!

# Missing @namespace — shorthand resolver paths break
extend type Query
    @guard {
    post(id: ID!): Post
        @field(resolver: "PostQuery@detail")

# Missing paginate: key when mixing @field and @paginate
@namespace(field: "Modules\\Blog\\GraphQL\\Queries") {
    paginatedPosts: [Post!]! @paginate(builder: "PostQuery@paginatedListing")
```
