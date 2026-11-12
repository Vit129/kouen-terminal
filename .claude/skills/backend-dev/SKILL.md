---
name: backend-dev
description: >
  Thai triggers: "ออกแบบ API", "ทำ backend", "ออกแบบ database", "ทำ auth/login", "ทำ Docker".
  This skill should be used when the user asks to "design an API",
  "set up authentication", "design the database schema",
  "build a backend service", "create a REST endpoint",
  "dockerize the app", or needs guidance on API design, database schema
  design, authentication, or Docker — language-agnostic backend architecture,
  not language-specific implementation syntax.
version: 1.0.0
---

# Backend Development

Build and maintain backend services and APIs.

## When to Load Each Reference

| User says | Load |
| --- | --- |
| "design API", "REST endpoint", "GraphQL", "versioning", "error handling" | `references/api-design.md` |
| "design schema", "normalization", "indexing", "migrations" | `references/database-design.md` |
| "set up auth", "JWT", "OAuth2", "RBAC", "sessions" | `references/authentication.md` |
| "Docker", "Dockerfile", "docker-compose", "multi-stage build" | `references/docker.md` |
| "code review", "review backend code", "check quality", "audit code" | `references/backend-code-review.md` |

## Core

- **API Design** — REST/GraphQL/gRPC conventions, versioning, error handling. (Read `references/api-design.md`)
- **Database Design** — Schema design, normalization, indexing, migrations. (Read `references/database-design.md`)
- **Authentication** — JWT, OAuth2, sessions, role-based access control. (Read `references/authentication.md`)

## Infrastructure

- **Docker** — Dockerfile, docker-compose, multi-stage builds. (Read `references/docker.md`)

## Code Quality

- **Backend Code Review** — Static audit checklist: architecture, validation, auth, DB, security, logging. (Read `references/backend-code-review.md`)

## Inline Process

1. **Identify the concern** — Match to ONE area: API Design, Database Design, Authentication, or Docker. Load the corresponding reference. Framework-specific syntax (Node.js/Python/C#/.NET/C++) has no dedicated reference in this workspace — apply general knowledge, matching the existing codebase's actual framework/version.
2. **Design contract first (API)** — Define resource schemas (request + response), error codes, pagination, versioning, and auth requirements per endpoint BEFORE writing implementation.
3. **Implement with validation** — Every endpoint MUST validate input (Zod/Pydantic/FluentValidation) before processing. Apply auth middleware on all routes. No secrets in source code.
4. **Database discipline** — Create migration files for EVERY schema change. Use batch queries (WHERE IN, JOIN) — never DB calls inside loops. Include timestamps on all resources.
5. **Write LLM-friendly comments** — Every non-trivial function gets: what + why + who calls + params/return/throws.
6. **Framework patterns** — Node.js: Express/Fastify/NestJS. Python: FastAPI/Django. C#: ASP.NET Core + EF Core + Clean Architecture. C++: Modern C++17/20, CMake, RAII.
7. **Code review** — Static audit: validation present, auth applied, no N+1, no secrets, migrations exist, comments present.
8. **Verify build** — `npm run build` / `dotnet build` / `python -m py_compile` passes clean.

## ⚠️ Gotchas

- **Missing input validation on new endpoints** — agent adds endpoint without validation layer. Fix: every endpoint must validate input with Zod/Pydantic before processing.
- **Auth middleware skipped on new routes** — new routes added without attaching auth middleware. Fix: always check auth middleware is applied when adding any protected route.
- **N+1 query in loops** — agent writes DB queries inside loops instead of batch queries. Fix: always use `WHERE id IN (...)` or JOIN instead of per-item queries.
- **Secrets hardcoded in code** — agent puts API keys or passwords directly in source. Fix: always use environment variables; never commit secrets.
- **Migration not created for schema change** — agent edits model without creating a migration file. Fix: every schema change requires a corresponding migration.

## LLM-Friendly Code Comments

Write comments that AI agents can understand — not just humans:

```python
# ❌ Old style:
# validate input

# ✅ New style:
# Validates user input against business rules before saving to DB.
# Returns structured error dict with field-level messages on failure.
# Called by: POST /api/users endpoint handler.
```

**Principles:**

- State **what** + **why** + **who calls** — not just what
- Include context AI needs to edit correctly (dependencies, side effects, constraints)
- Add docstrings/JSDoc with params + return + raises/throws
- Complex business logic: add comment block explaining the rule before the code

---

## Required Context

| Dependency | Type | Purpose |
| --- | --- | --- |
| Framework docs (Express/FastAPI/ASP.NET) | Official documentation | Verify API patterns against current version |
| Existing API patterns in codebase | Source code | Match conventions, avoid inconsistency |
| DB schema / migrations folder | Database | Understand current data model |
| `references/*.md` (one per concern) | Skill reference | API design, DB, auth, Docker — no framework-specific reference, see Inline Process step 1 |
| `rules/coding.md` & `rules/aodd.md` | Rule | Core engineering principles and verification gates |
| `knowledge/` | Lessons learnt | Check before execute |

Related: drive the implementation test-first (Red→Green), then review the diff before merge against `references/backend-code-review.md`'s checklist.

## Human-in-the-Loop Points

| Step | Approval Type | When |
| --- | --- | --- |
| After API design (endpoints + schemas) | Checkbox (confirm contract) | Before writing implementation code |
| After implementation approach selection | Single select (framework/pattern choice) | When multiple valid approaches exist |
| After security review | Open field | Before deploying auth/data changes |

**Rule:** At decision points, always present 2-3 options with tradeoffs — never a single answer.

## Self-Update (after every use)

This skill is its own memory. When using it brought a correction, a gotcha,
or a wrong/missing step, and the fix was verified, patch this file in place: an API/DB pattern or pitfall goes in its section; depth goes to `references/<topic>.md`.
Then bump `version` (patch) and `last_improved`. Procedure: `docs/skill-learning.md`.
