# Backend Code Review

Static code audit checklist for backend services. No dedicated framework-specific reference exists in this workspace (see `backend-dev/SKILL.md` Inline Process step 1) — this checklist is language/framework-agnostic and self-contained, apply it directly.

## When to Use

- After implementing API endpoints or services (before PR)
- After AI generates backend code (verify quality)
- Sprint code review sessions

## Checklist — All Frameworks

### Architecture
- [ ] Clean layers: controller/route → service → repository → model
- [ ] No business logic in controllers/routes — delegate to service layer
- [ ] Repository pattern for data access — no raw ORM queries in services
- [ ] Dependency injection used (FastAPI Depends / NestJS @Injectable / Express middleware)

### API Design (see `api-design.md`)
- [ ] RESTful conventions: proper HTTP methods, status codes, resource naming
- [ ] Consistent error response format: `{ error: { code, message } }`
- [ ] Pagination for list endpoints: `?page=1&limit=20`
- [ ] API versioning: `/api/v1/` prefix

### Input Validation (see `validation-standards.md`)
- [ ] All inputs validated at controller/route level — never trust client
- [ ] Pydantic models (FastAPI) / Joi/Zod (Node.js) / DRF Serializers (Django)
- [ ] Validation errors return 400 with field-level details
- [ ] No SQL injection vectors — parameterized queries only

### Authentication (see `authentication.md`)
- [ ] JWT tokens validated on every protected route
- [ ] Token expiry handled — refresh token flow if applicable
- [ ] RBAC: role checks at route level, not in business logic
- [ ] Passwords hashed (bcrypt/argon2) — never stored plain

### Database (see `database-design.md`)
- [ ] Migrations for all schema changes — no manual DDL
- [ ] Indexes on frequently queried columns
- [ ] Foreign keys and constraints defined
- [ ] N+1 query prevention: eager loading or batch queries
- [ ] Connection pooling configured

### Error Handling (see `error-handling-standards.md`)
- [ ] Global error handler catches unhandled exceptions
- [ ] Business errors: proper HTTP status (400, 404, 409, 422)
- [ ] Server errors: 500 with generic message — no stack trace to client
- [ ] All errors logged with context (endpoint, user, request ID)

### Security
- [ ] No secrets in code — environment variables only
- [ ] CORS configured — not `*` in production
- [ ] Rate limiting on auth endpoints
- [ ] Input sanitization for user-generated content
- [ ] No sensitive data in logs (passwords, tokens, PII)

### Logging (see `logging-standards.md`)
- [ ] Structured logging with levels (debug/info/warn/error)
- [ ] Request ID in all log entries for tracing
- [ ] No `print()` / `console.log()` — use project logger
- [ ] Error logs include original exception

---

## Framework-Specific Checks

### FastAPI (Python)
- [ ] `async def` for I/O-bound endpoints
- [ ] Pydantic v2 models with `Field` constraints
- [ ] SQLAlchemy 2.0 async: `Mapped`, `mapped_column`
- [ ] Alembic migrations — not manual schema changes
- [ ] `Depends()` for auth, DB session, shared logic
- [ ] Type hints on all functions — FastAPI uses them for docs
- [ ] `black` + `ruff` formatting applied

### Node.js (Express / NestJS)
- [ ] TypeScript — no plain JavaScript for new code
- [ ] Async/await — no callback hell
- [ ] Error middleware: `(err, req, res, next)` handler
- [ ] Request validation: Zod / Joi / class-validator
- [ ] Prisma / TypeORM / Drizzle for DB — not raw SQL
- [ ] ESLint + Prettier applied

### Django
- [ ] DRF serializers for all API endpoints
- [ ] `select_related` / `prefetch_related` for related queries
- [ ] Custom managers for complex queries — not in views
- [ ] Django migrations — not `syncdb`
- [ ] `pytest-django` tests for all endpoints

---

## Docker (see `docker.md`)
- [ ] Multi-stage build — separate build and runtime stages
- [ ] Non-root user in production image
- [ ] `.dockerignore` excludes node_modules, .git, tests
- [ ] Health check endpoint defined
- [ ] No secrets in Dockerfile — use build args or runtime env

---

## Review Report Format & Severity Guide

Shared shape across every code-review checklist in this workspace — see
`rules/coding/review-report.md`'s Code Review Report Format (Dev column of the severity table).
This file adds only the `Framework: FastAPI / Express / NestJS / Django` header line.

**Severity criteria specific to backend:**

| Severity | Criteria |
|----------|----------|
| 🔴 High | Security vulnerability, no validation, no error handling, secrets in code |
| 🟡 Medium | N+1 queries, missing indexes, no pagination, missing logs |
| 🟢 Low | Missing comments, naming conventions, import order |
