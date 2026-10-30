# API Design

Guidelines for designing consistent, maintainable APIs.

## REST Conventions
- Resources as nouns: `/users`, `/orders`, `/products`
- HTTP methods: GET (read), POST (create), PUT (full update), PATCH (partial update), DELETE (remove)
- Plural nouns: `/accounts/123` not `/user/123`
- Nested resources for relationships: `/accounts/123/orders`
- Query params for filtering/sorting: `?status=active&sort=-createdAt&limit=20`

## Versioning
- URL prefix: `/api/v1/users` (recommended for simplicity)
- Header: `Accept: application/vnd.api+json;version=1` (alternative)
- Never break existing clients — add new fields, don't remove old ones

## Response Format
```json
{
  "data": { ... },
  "meta": { "total": 100, "page": 1, "limit": 20 },
  "errors": null
}
```

## Error Handling
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": [
      { "field": "email", "message": "must not be empty" }
    ]
  }
}
```

Standard HTTP status codes:
- 200 OK, 201 Created, 204 No Content
- 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 409 Conflict, 422 Unprocessable
- 500 Internal Server Error

## GraphQL (when applicable)
- Use for complex, nested data requirements
- Queries for reads, Mutations for writes
- Pagination: cursor-based (recommended) or offset-based
- Error handling via `errors` array in response

## Tips
- Always validate input — never trust client data
- Use pagination for list endpoints — never return unbounded results
- Include `createdAt` and `updatedAt` on all resources
- Log request ID for traceability across services
- Rate limiting on public endpoints

## gRPC (when applicable)
- Use for service-to-service communication where performance matters
- Define contracts in `.proto` files — single source of truth
- Unary (request/response), Server streaming, Client streaming, Bidirectional streaming
- Use Protocol Buffers for serialization — smaller and faster than JSON
- Error handling via gRPC status codes: OK, NOT_FOUND, INVALID_ARGUMENT, INTERNAL
- Generate client/server code from `.proto` using `protoc` compiler
- Use gRPC-Gateway to expose REST endpoints alongside gRPC

## Hyrum's Law

> "With a sufficient number of users of an API, it does not matter what you promise in the contract: all observable behaviors of your system will be depended on by somebody."

**Practical implications:**

- Every behavior you expose — including bugs, response ordering, timing, error message wording — becomes an implicit contract
- Changing "undocumented" behavior still breaks clients
- The larger your user base, the more conservative you must be with changes

**Design rules that follow from Hyrum's Law:**

| Rule | Why |
|------|-----|
| Version your API from day one | Changing behavior without versioning breaks implicit contracts |
| Treat response field ordering as stable | Some clients depend on it even if you didn't promise it |
| Never change error message text without a major version | Clients parse error strings |
| Deprecate before removing | Give clients time to migrate |
| Document what you DON'T guarantee | Explicitly mark fields as unstable to set expectations |

## Contract-First API Design

Design the contract (schema/spec) before writing implementation code.

### Why contract-first?

- Forces clarity on what the API does before you're invested in implementation
- Enables parallel frontend/backend development
- Catches design mistakes early (cheap to fix in spec, expensive in code)
- Generates documentation, mocks, and validation automatically

### Contract-First Checklist

**Before writing any implementation code:**

- [ ] Define resource schemas (request + response shapes)
- [ ] Define all error codes and when they occur
- [ ] Define pagination strategy (cursor vs offset)
- [ ] Define versioning strategy
- [ ] Define authentication/authorization requirements per endpoint
- [ ] Review with consumers (frontend, mobile, other services) before finalizing
- [ ] Generate mock server from spec for parallel development

**Schema design:**

- [ ] All fields have explicit types (no implicit coercion)
- [ ] Optional vs required fields are explicit
- [ ] Nullable fields are explicitly marked (not just absent)
- [ ] Enum values are documented with meaning
- [ ] Date/time fields use ISO 8601 format
- [ ] IDs are strings (not integers — avoids overflow + easier to change format)

**Backward compatibility:**

- [ ] New fields are optional (never required in a minor version)
- [ ] Removed fields are deprecated first (at least one version)
- [ ] Changed field types get a new field name (not in-place change)
- [ ] Error codes are stable (don't rename them)

**One-Version Rule:**

Maintain exactly one supported version at a time when possible. Multiple live versions multiply maintenance burden. Deprecate aggressively, migrate clients, then remove.

### Tools

| Tool | Use |
|------|-----|
| OpenAPI / Swagger | REST API spec — generates docs, mocks, client SDKs |
| Zod / Joi | Runtime schema validation (TypeScript/Node) |
| Pydantic | Runtime schema validation (Python) |
| Prism | Mock server from OpenAPI spec |
| Spectral | OpenAPI linting — enforce design rules |
