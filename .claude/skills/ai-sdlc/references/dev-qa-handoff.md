# Dev↔QA Design Handoff

## Contents

- [data-testid handoff (Phase 2, Client Application section)](#data-testid-handoff-phase-2-client-application-section)
- [Test environment requirements (Phase 2, before handoff to Phase 3)](#test-environment-requirements-phase-2-before-handoff-to-phase-3)
- [Schema Consistency Check (Phase 2→3 boundary, both API and DB)](#schema-consistency-check-phase-23-boundary-both-api-and-db)
- [DB seed/verify/cleanup strategy](#db-seedverifycleanup-strategy)
- [Shared fixtures across platforms (API + Web UI + Mobile on one feature)](#shared-fixtures-across-platforms-api--web-ui--mobile-on-one-feature)
- [Domain Language (only when the feature touches new/ambiguous domain terms)](#domain-language-only-when-the-feature-touches-newambiguous-domain-terms)

The concrete conventions that make ai-sdlc's Phase 2 promise ("decide what needs QA
coverage in the same pass as dev design, so dev/QA designs don't quietly diverge")
actually operational. Platform coding patterns (page objects, locator priority) belong to your
test framework's own conventions — don't duplicate them here. This file is only the handoff surface between a dev design and QA automation.

## data-testid handoff (Phase 2, Client Application section)

Every interactive component the design produces needs its `data-testid` map written down
before Phase 3 starts — dev implements these ids, QA's `getByTestId()` calls must match
exactly. Use one naming convention per project
(here `type_name_page`) — don't invent a different scheme per feature.

```text
### Components & testIds
// FlightSearchWidget
data-testid="frm_flightSearch_flightSearchPage"
data-testid="btn_searchFlights_flightSearchPage"

// FlightResultList
data-testid="tbl_flightResults_flightSearchPage"
data-testid="btn_selectFlight-{id}_flightSearchPage"   ← {id} for dynamic list items
```

If a testId needs to change after design is approved, dev and QA agree and update together
— it's a shared contract, not a dev-only implementation detail.

## Test environment requirements (Phase 2, before handoff to Phase 3)

State this explicitly in the design so QA can act on it without re-deriving it:

```text
## Test Environment Requirements
### Required DB Seed Data
- flights: 10 records with various routes and prices
### External Service Strategy
- Visa Check API: mock (slow response simulation needed)
- Payment Gateway: mock (avoid real charges in test)
### Test Account Roles Required
- admin: can approve/reject bookings
### Environment Variables Required
- VISA_CHECK_API_URL: external visa check endpoint
```

QA uses this to build `.env`, pick a mock strategy (see `ai-sdlc-progress-spec.md`'s Mock Strategy
table), and request test accounts before QA-Design starts — not discover the gap mid-Phase-3.

## Schema Consistency Check (Phase 2→3 boundary, both API and DB)

Before test script design starts: extract API request/response fields per endpoint,
extract DB columns per table, diff them, fix mismatches. Persist the result so it's not
re-derived every time a feature is touched:

- `$AODD_PLANS/[FEATURE]/api-spec.md` — `## Endpoints`, `## Request/Response Schema`,
  `## Error Cases`, `## Status` (`assumed` or `verified`)
- `$AODD_PLANS/[FEATURE]/db-schema.md` — `## Tables`, `## Service Methods`
  (seed/verify/cleanup signatures), `## Dependency Order` (FK levels)

Check these files first before re-deriving schema from scratch on a feature that's already
been through this once.

**Additive Contract Rule** (when the endpoint/table already exists and is in use): new
fields must be optional/nullable with a sane default; never rename, retype, or remove an
existing field without a formal deprecation step — a caller relying on today's shape
(Hyrum's Law: enough users, every observable behavior becomes a dependency) breaks
silently otherwise. Map error responses to standard machine-readable codes plus standard
HTTP status (400/401/403/404/409/422/500) rather than ad hoc strings per endpoint.

**Mock-API prefix rule (backend not ready):** point `ApiService` at a mock endpoint under a
`mock-api/` prefix (e.g. `/mock-api/orders`, served by a local mock server/msw/json-server)
derived from the intended contract, instead of blocking QA on the real backend. Mark the
spec's `## Status` `assumed`. When the real backend lands: swap the prefix, re-run the
consistency check, flip `## Status` to `verified` — never leave a test asserting an exact
schema against an `assumed` endpoint without that status as a TODO in the test file header.

## DB seed/verify/cleanup strategy

Per-platform code generation follows your test framework's conventions. This is the cross-platform design decision that precedes it:

**Dependency order example** (FK-dependent seeds, orchestrated in one transaction):
```
Level 1 (no deps): Role, Category
Level 2 (needs L1): User (needs role_id)
Level 3 (needs L2): Order (needs user_id)
seedAll() wraps all levels in one transaction, returns { roleId, userId, orderId }
```

**State-machine-gated or append-only entities** — the dependency-order tree above assumes a
plain FK insert is enough at every level. Some entities aren't reachable that way: a row only
becomes valid after passing through required prior states (e.g. a record that must exist in
an intermediate status for a minimum duration, or after a specific transition event fired),
or the table is append-only/audit-logged and a raw `DELETE` during cleanup violates its own
integrity trigger. For these, seed via the domain's own factory method or event replay (not
a raw insert that skips the state machine), and clean up with a soft-delete/tombstone or an
isolated batch/tenant ID instead of a hard `DELETE` — never bypass an invariant just to make
a test fixture easier to write.

**Mocking fallback when DB is unavailable during test execution** — always log
`⚠️ DB unavailable — using mock data`:
- API tests → hardcoded fixture data, tag the result `[PARTIAL_MOCK]`
- Web UI tests → `page.route()` to mock the API responses instead
- Mobile tests → YAML fixture with a mock flag

**File structure:** shared by default at `tests/db-scripts/[system]/[feature]/`; split under
`tests/[api|web|mobile]-testing/db-scripts/[system]/[feature]/` only when a platform's
seed/cleanup genuinely diverges from the shared one.

## Shared fixtures across platforms (API + Web UI + Mobile on one feature)

When a feature has test scenarios on more than one platform, create
`tests/shared-fixtures/[system]/[feature]/` for what all layers need in common (business
data, auth tokens, seed-data results) — keep layer-specific fixtures (viewport sizes, device
capabilities, request headers) in their own layer's fixture files, not here. Add
`web/`/`mobile/` subfolders under shared-fixtures only for the platform-specific slice of an
otherwise-shared fixture (e.g. an `ApiSetup.ts` that Web UI uses to seed via API).

## Domain Language (only when the feature touches new/ambiguous domain terms)

If Phase 2 design work resolves or challenges a domain term, note it in the plan's
**Terms** list as it is resolved (challenge conflicting terms, propose canonical names, one
term at a time, never batch). After Gate 1, write the list into `CONTEXT.md` (project root,
or per-context under `src/{context}/CONTEXT.md` for multi-context repos) with the other living docs, rather than letting the
term drift undocumented. For genuinely deep DDD work (multiple bounded contexts, explicit
monolith-vs-microservices tradeoffs, aggregate/event modeling) beyond what a normal Phase 2
pass needs, this is model judgment — apply DDD strategic/tactical design directly, there's
no separate skill for it anymore.

**Claude Code only (`EnterPlanMode` is a Claude Code tool):** call `EnterPlanMode` before starting Phase 2 design work on anything
non-trivial — it's the native hard-approval gate. Write the drafted design there, then
`ExitPlanMode`; only after user approval, copy the approved content into
`$AODD_PLANS/[FEATURE]/[FEATURE]-architecture.md` (the the plan-mode file isn't guaranteed to persist
across sessions, the copy is what's durable). Not Claude Code: skip straight to writing
`[FEATURE]-architecture.md` and confirming in chat before continuing.
