# Postman → Playwright Migration (AI-Driven)

Pure AI Logic pipeline — no external parser scripts or dependencies. AI parses the collection and environment JSON directly into Markdown IR, verifies correctness with the user, and progressively transforms into clean Playwright tests.

Always read `rules/playwright/api.md` before writing or reviewing any generated Playwright code.

## When to Load Each Reference

| User says | Load |
|-----------|------|
| "generate Playwright", "convert folder", "write tests from collection.md" | `references/fix-generated-files.md` + `rules/playwright/api.md` + `playwright-testing/references/workflow.md` |
| "fix URL", "add auth", "stateStore", "polling", "pm.sendRequest" | `references/fix-generated-files.md` |
| "review code", "run tests", "fix failures" | `playwright-testing/references/playwright-code-review.md` + `playwright-testing/references/workflow.md` |

---

## Migration Flow

```text
Phase 1:   AI reads Collection & Env JSON → generates Markdown IR (collection.md + env.md)
Phase 2:   AI verifies data completeness & designs structure → user approves
Phase 3:   AI progressively generates Playwright files (folder-by-folder)
Phase 4:   Run tests in terminal → AI inspects results & auto-heals failures
```

---

## Phase 1: AI Parse JSON → Markdown IR

AI directly inspects the `.postman_collection.json` and `.postman_environment.json` files and creates two intermediate representation (IR) markdown documents in `tests-api/<collection>/`:

### 1. `collection.md` (API Structure & Endpoints)
Must contain:
- **`## 🏗️ Structure Summary`**:
  - Total requests, top-level folders
  - Auth Strategy detected (Bearer, Basic, API Key, Inherited from collection/folder)
  - Base URLs extracted from endpoints
  - Runtime-Set Variables (variables set in `Pre-request` or `Tests` scripts requiring `stateStore`)
- **`## 📁 Folder: <FolderName>`** (for each folder/subfolder):
  - Request Name, HTTP Method, Path/URL
  - Headers, Query Parameters, Request Body (sample payload / schema)
  - Pre-request Script logic (e.g. token generation, dynamic timestamp)
  - Test Script logic (status assertions, body assertions, `pm.environment.set` extractions)

### 2. `env.md` (Environment Variables)
Must contain:
- **`## 🏗️ Env Summary`**:
  - Base URLs (domain variables used in requests)
  - Secrets (variables needing credentials, tokens, API keys)
  - Runtime-set variables (populated dynamically by tests)
  - Static configs vs empty variables
- Variable table: `Key | Initial Value | Type (Config / Dynamic / Secret)`

---

## Phase 2: AI Verification & Structure Alignment (HITL Gate)

Before writing any Playwright code, AI performs an automated sanity check of the Markdown IR against the raw JSON, and aligns with the user:

### Sanity Audit Checklist
1. **Endpoint Coverage**: Confirm every item in the Postman JSON is represented in `collection.md`.
2. **Auth Inheritance**: Trace auth from collection-level down to folders and requests.
3. **Variable Dependency Graph**: Map requests that set variables (`pm.environment.set`) to the downstream requests that consume them (determines `stateStore` usage and test execution order).
4. **Data Completeness & Secrets**: Identify values left blank in the Postman export (e.g., passwords, client secrets, current session tokens).

### User Alignment (Decision Point)
AI presents the structured summary to the user:
- Total requests and folder breakdown
- Detected Auth strategy and recommendations
- Missing secrets or environment variables needed
- Proposed Playwright file tree (`fixtures/`, `schemas/`, `helpers/`, `tests-api/`)

> ⚠️ **Gate:** Obtain user approval on the proposed structure and missing configuration before generating Playwright code.

---

## Phase 3: Progressive Playwright Generation

AI generates Playwright code folder-by-folder (or domain-by-domain) to maintain high precision and prevent context overflow.

### Generation Order (MANDATORY per `api.md`)

> ⚠️ **HARD RULE:** Never generate spec files before fixtures and schemas exist.

```text
1. .env / .env.sit                                    ← environment variables
2. helpers/schema.validator.ts                        ← AJV validator (create once per project)
3. helpers/stateStore.ts                              ← runtime cross-request state
4. fixtures/[collection]/[folder]/[folder]Data.ts     ← test data (SIT/UAT)
5. schemas/[collection]/[folder]/[folder]Schema.ts    ← AJV response schemas
6. helpers/[collection]/[folder]/[folder]Helper.ts    ← API service / client methods
7. tests-api/[collection]/[folder].spec.ts            ← spec file (imports 1-6)
```

### Key Conversion Patterns (Read `references/fix-generated-files.md` for 30+ examples)

| Postman Feature | Playwright Target |
|-----------------|-------------------|
| `{{var}}` in URL / Body | Template literal: `` `${process.env['VAR_NAME']}` `` |
| `pm.environment.set('key', val)` | `stateStore['key'] = val;` (never `process.env`) |
| `pm.response.to.have.status(200)` | `expect(response.status()).toBe(200);` |
| `pm.expect(jsonData.id).to.eql(1)` | `expect(body.id).toBe(1);` |
| `pm.sendRequest(...)` CPS | `await request.fetch(...)` async/await |
| Collection / Folder Auth | `beforeAll` token acquisition + shared `extraHTTPHeaders` |
| Request Chaining | `test.describe.serial` + sequential steps |

### Standard Code Patterns

AI applies these patterns when generating Playwright code. For 30+ examples, read `references/fix-generated-files.md`.

### 1. URL Placeholders

Replace all Postman `{{var}}` syntax with template literals.

```typescript
// ❌ Generated
`{{user-service-url}}/api/v1/users`
// ✅ Fixed
`${process.env['user-service-url']}/api/v1/users`
```

### 2. Auth Header

Add `Authorization` header to every request. Missing auth is the most common cause of 401 failures.

```typescript
headers: {
  ...dynamicHeaders,
  'Authorization': `Bearer ${process.env['accessToken']}`,
}
```

### 3. Fixtures & Schemas (MANDATORY — create before spec file)

Per `workflow.md` Step 5-6 and `api.md` § Structure, fixtures and schemas MUST exist before generating spec files.

**Fixture file** (`fixtures/[collection]/[folder]/[folder]Data.ts`):

```typescript
// Minimal fixture — expand with actual test data from collection.md
export const <folder>Data = {
  sit: { /* SIT environment test data */ },
  uat: { /* UAT environment test data */ },
}

// Helper functions for request bodies
export function defaultBody(overrides = {}) {
  return { /* base request body from collection.md */ ...overrides };
}
```

**Schema file** (`schemas/[collection]/[folder]/[folder]Schema.ts`):

```typescript
import { validateSchema } from '../../helpers/schema.validator';

// AJV schema for response validation (fix-generated-files.md Section 6)
export const successResponseSchema = {
  type: 'object',
  required: ['success', 'result', 'errorMessage', 'traceId'],
  properties: {
    success:      { type: 'boolean', const: true },
    result:       { },
    errorMessage: { type: 'null' },
    traceId:      { type: 'null' },
  },
};

export const errorResponseSchema = {
  type: 'object',
  required: ['success', 'result', 'errorMessage'],
  properties: {
    success:      { type: 'boolean', const: false },
    result:       { type: 'null' },
    errorMessage: { type: 'string' },
  },
};
```

**Schema validator** (`helpers/schema.validator.ts`) — create once per project:

```typescript
import Ajv from 'ajv';
import addFormats from 'ajv-formats';
import { expect } from '@playwright/test';

const ajv = new Ajv({ allErrors: true });
addFormats(ajv);

export function validateSchema(data: unknown, schema: object): void {
  const validate = ajv.compile(schema);
  const valid = validate(data);
  if (!valid) {
    const errors = validate.errors?.map(e => `${e.instancePath} ${e.message}`).join('; ') ?? 'unknown';
    expect(valid, `Schema validation failed: ${errors}`).toBe(true);
  }
}
```

### 4. Runtime State (stateStore)

Any `pm.environment.set('key', value)` must use `stateStore`, not `process.env`.

```typescript
// ❌ Wrong — process.env is read-only at runtime
process.env['ORDER_ID'] = responseJson.id
// ✅ Correct — stateStore for runtime-set values
const stateStore = (global as any).__stateStore ??= {}
stateStore['orderId'] = responseJson.id
```

> ⚠️ Never use `process.env` for values shared between requests at runtime — use `stateStore` only.

---

## Phase 4: Run Tests & Auto-Heal

> ⚠️ Run tests in terminal (or via Bash). AI inspects the test output and heals failures.

### Run Command

```bash
# Run all tests for a folder / collection
npx cross-env ENV=sit npx playwright test --config=playwright.config.ts tests-api/<collection>/

# Run a specific spec file
npx cross-env ENV=sit npx playwright test --config=playwright.config.ts tests-api/<collection>/<folder>.spec.ts
```

### AI Auto-Heal Workflow

1. Inspect error message + stack trace from test execution.
2. Cross-reference `references/fix-generated-files.md` for the known conversion pattern.
3. Apply fix directly to generated spec, service, schema, or fixture.
4. Re-run test to verify GREEN. Repeat until all tests pass.

### Common Failure Patterns & Remedies

| Error | Likely Cause | Fix |
|-------|-------------|-----|
| 401 Unauthorized | Missing/wrong auth header | Add `Authorization` header (Section 2 in `fix-generated-files.md`) |
| `{{variable}}` in URL | Unresolved Postman variable | Replace with `` `${process.env['VAR']}` `` template literal |
| `stateStore is not defined` | Missing stateStore declaration | Add `const stateStore = (global as any).__stateStore ??= {};` |
| `Cannot read property of undefined` | Response not parsed | Add response type check (Section 3 in `fix-generated-files.md`) |
| `expect(...).toHaveStatus is not a function` | Wrong assertion API | Use `expect(response.status()).toBe(200)` |
| Timeout | Slow API or polling needed | Add `timeout` option or use `expect.poll` (Section 5 in `fix-generated-files.md`) |

---

## ⚠️ Gotchas

- **Progress tracking:** At migration start, AI creates a `progress.md` (migration plan + per-folder status checklist) in `tests-api/<collection>/`. Update status (⬜→✅/❌) after each phase completes. This file is the cross-session continuity mechanism; read it back when resuming a migration.
- **Postman exports lack Current Values** — only "Initial Values" are exported. Secrets and runtime-set values will be empty. Always check with user.
- **`pm.environment.set()` chains** — requests that set variables used by later requests need `stateStore` + `test.describe.serial`, not `process.env`.
- **Auth inheritance missed** — Postman folder-level auth is invisible in individual request items. AI must check `resolveAuth` chain from collection/folder root down.
- **`pm.sendRequest` in pre-request** — CPS callback pattern must be converted to async/await `request.fetch()`.

---

## Verification

Before declaring a migration complete, confirm:

- [ ] `rules/playwright/api.md` loaded before writing any Playwright code
- [ ] Files generated in order: config/env → stateStore → fixtures → schemas → helpers/services → spec
- [ ] `{{var}}` → `process.env['VAR']`; auth header present; `stateStore` (not `process.env`) used for runtime-set values; AJV schema validation present
- [ ] Data completeness check done in Phase 2 (missing values verified with user); all tests pass in Phase 4

---

## Required Context

| Dependency | Type | Purpose |
|-----------|------|---------|
| Postman collection JSON | Migration input | Source of API requests and test logic |
| Playwright project structure (`tests-api/`) | Target | Where generated files are written |
| `rules/playwright/api.md` | Coding standards | API test patterns, AAA, assertions |
| `references/fix-generated-files.md` | Migration patterns | 30+ Postman→Playwright conversion rules |
| `knowledge/` (project memory) | Lessons learnt | Check before execute |

## Human-in-the-Loop Points

| Phase | Approval Type | When |
|-------|--------------|------|
| Migration Plan (Phase 2) | Structured review — approve folder structure & auth strategy | Before generating any code |
| Data Completeness Gaps (Phase 2) | Input request — provide missing credentials / secrets | When missing secrets/tokens detected |
| First Converted Spec (Phase 3) | Code review — confirm style & conventions | After first folder's spec file generated |

**Rule:** At decision points, always present clear options with tradeoffs — never a single forced answer.

## Self-Learning

After user approves the output, per the `agent-memory` skill's promotion flow (or `docs/skill-learning.md`):

1. **Record good example:** Patch the approved output pattern into this file (or `SKILL.md`), not a separate lessons log
2. **Record failures:** If output required manual correction → note what went wrong for next time
