# Playwright Workflow

Write → Review → Execute → Heal. The full test automation cycle.

## 1. Code Writer

Generate Playwright test files from architecture design.

**Input:** Architecture Design + Test Structure Blueprint from implementation plan.

**Steps:**
1. Read coding rules from `rules/playwright/` (api.md or web-ui.md + pw-coding-standards.md) + `rules/data-testid-mapping.md` — ALL parts
2. Read architecture and test structure blueprint from implementation plan
3. Check discovery results — if Resources Discovery found reusable templates, import them instead of creating from scratch
4. Create directory structure (mkdir -p) — folders kebab-case
5. Generate fixtures — `[feature]Data.ts` with environment-specific data and `[feature]Labels.ts` with TH/EN UI labels
6. Generate schemas — `[feature]Schema.ts` (API mode, AJV)
7. Generate helpers/pages — implement EXACTLY as designed in architecture
8. **Generate mock interceptors (MANDATORY)** — see Mock Layer rule below
9. Generate spec files — AAA pattern, mandatory tags, test.step()
10. Update package.json — 4 scripts per feature (SIT/UAT × CLI/GUI):
    - `api:sit:[feature]:cliMode` / `api:sit:[feature]:guiMode`
    - `api:uat:[feature]:cliMode` / `api:uat:[feature]:guiMode`
    - (or `ui:` prefix for Web UI)

## Mock Layer (MANDATORY — TDD Red Phase)

Tests MUST be runnable before backend exists. Always create mock interceptors alongside test scripts.

### Rule

Every spec file MUST have a corresponding mock handler. Tests run against mocks by default, switch to real service when available.

### Pattern: health check + auto-fallback

```typescript
// shared/mocks/[feature]Mock.ts
import { Page, APIRequestContext } from '@playwright/test'

export async function setupMock(page: Page, baseUrl: string, mockData: Record<string, unknown>) {
  await page.route(`${baseUrl}/**`, async route => {
    const url = route.request().url()
    const method = route.request().method()
    const key = `${method}:${new URL(url).pathname}`
    if (mockData[key]) {
      const { status, body } = mockData[key] as { status: number; body: unknown }
      await route.fulfill({ status, contentType: 'application/json', body: JSON.stringify(body) })
    } else {
      await route.continue()
    }
  })
}

export async function isServiceUp(request: APIRequestContext, url: string): Promise<boolean> {
  try {
    const res = await request.get(`${url}/health`, { timeout: 3000 })
    return res.ok()
  } catch {
    return false
  }
}
```

```typescript
// In spec beforeAll — auto-switch mock ↔ real
test.beforeAll(async ({ request, page }) => {
  const up = await isServiceUp(request, BASE_URL)
  if (!up) {
    console.log('⚠️ Service unavailable — using mock data [PARTIAL_MOCK]')
    await setupMock(page, BASE_URL, mockResponses)
  }
})
```

### Mock data location

```
tests/shared/mocks/
└── [system]/
    └── [feature]/
        └── [feature]Mock.ts    ← mock responses + setupMock + isServiceUp
```

### Rules

- NEVER skip tests when service is down — always run with mock
- Tag console output with `[PARTIAL_MOCK]` when using mock
- Mock responses MUST match logical design response shapes exactly
- When service comes up → remove `setupMock` call only, keep mock file for edge case testing
- Error scenarios (4xx, 5xx) MUST always use mock — never depend on real service to produce errors

**Naming:** Folders kebab-case, files lowerCamelCase.

**Folder Structure (MANDATORY):**
```
tests/api-testing/
├── tests-api/[SYSTEM_KEBAB]/[SYSTEM_FEATURE_KEBAB]/[systemFeature].spec.ts
├── helpers/[SYSTEM_KEBAB]/[SYSTEM_FEATURE_KEBAB]/[systemFeature]Helper.ts
├── schemas/[SYSTEM_KEBAB]/[SYSTEM_FEATURE_KEBAB]/[systemFeature]Schema.ts
└── fixtures/[SYSTEM_KEBAB]/[SYSTEM_FEATURE_KEBAB]/[systemFeature]Data.ts

tests/web-testing/
├── tests-web/[SYSTEM_KEBAB]/[SYSTEM_FEATURE_KEBAB]/[systemFeature].spec.ts
├── pages/[SYSTEM_KEBAB]/[SYSTEM_FEATURE_KEBAB]/[systemFeature]Page.ts
├── helpers/[SYSTEM_KEBAB]/[SYSTEM_FEATURE_KEBAB]/[systemFeature]Helper.ts
├── fixtures/[SYSTEM_KEBAB]/[SYSTEM_FEATURE_KEBAB]/[systemFeature]Data.ts
└── fixtures/[SYSTEM_KEBAB]/[SYSTEM_FEATURE_KEBAB]/[systemFeature]Labels.ts  ← TH/EN UI labels
```

**Forbidden:**
- `waitForTimeout()` — use smart waits
- Hardcoded credentials — use `.env`
- CSS/XPath in UI mode — use hybrid: `getByTestId` to scope + `getByRole({ name: L.keyName })` to target
- `nth()`/`first()` — use `filter({ hasText: '...' })`
- Hardcoded test data in spec — use fixtures
- Static import from `pg` — use `await import('pg')` (Windows CI breaks)
- Missing JSDoc comments in Thai on all public methods
- Hardcoded Thai/English text in `getByRole({ name })` — use `L.keyName` from `Labels.ts`

**Labels pattern (MANDATORY for Web UI):**
```typescript
// fixtures/[SYSTEM_KEBAB]/[SYSTEM_FEATURE_KEBAB]/[systemFeature]Labels.ts
export const flightBookingLabels = {
  th: {
    btnSelectFlight:  'Select',
    btnSearchFlights: 'Search flights',
    btnConfirmBooking:'Confirm booking',
  },
  en: {
    btnSelectFlight:  'Select',
    btnSearchFlights: 'Search Flights',
    btnConfirmBooking:'Confirm Booking',
  },
}

// In page object or spec
import { flightBookingLabels } from '../../fixtures/japan/flight-booking/flightBookingLabels'
const L = flightBookingLabels[process.env.LANG ?? 'th']

await page.getByTestId('flight-result-item-FL001')
         .getByRole('button', { name: L.btnSelectFlight }).click()
```

## 2. Code Review

Static quality audit before execution — no running tests.

**Check against:**
- `rules/playwright/` coding standards compliance (all parts)
- Architecture matches blueprint
- DB methods follow strategy (seed/verify/cleanup)
- No forbidden patterns
- JSDoc comments present (Thai)
- Package.json scripts complete (SIT+UAT, CLI+GUI)
- Lessons Applied from implementation plan
- Self-Healing Ready: descriptive actions + proper logging

**Review classification:**

| Type | Description | Priority |
|------|-------------|----------|
| logic_bug | Test logic doesn't match requirement | Fix immediately |
| arch_mismatch | Code doesn't follow architecture design | Fix before next phase |
| code_quality | Style/naming/pattern violation | Fix during review |
| forbidden_pattern | Uses forbidden API | Fix immediately |

**Output:** APPROVED or NEEDS_FIX with issue list (severity, file, line, suggestion).

## 3. Test Execution

Run tests and capture results.

**Steps:**
1. Verify test file exists and Playwright is installed
2. Run with `--reporter=line` (minimal output for AI context)
3. Parse JSON report — total, passed, failed, error messages
4. On failure → `skills/ai-sdlc/references/qa-automation-loop.md`'s Test Execution → Heal escalation
5. Record lessons to Reflexion Log — only technical patterns, ignore env issues
6. Cleanup recordings: if all tests pass and webui_automation, offer to delete test-*.spec.ts recorder files

## 4. Self-Healing (Reflexion Pattern)

Analyze failures and auto-fix code.

**Impact Analysis (MANDATORY before any fix)** — 3-tier concept + escalation rule shared
across platforms, see `skills/ai-sdlc/references/qa-automation-loop.md`. Playwright terminology:

| Classification | Scope | Action |
|---|---|---|
| Isolated | Fix affects only 1 spec file | Fix directly |
| Shared | Fix affects helper/page used by multiple specs | Check all dependent specs, ensure backward compatibility |
| Cross-layer | Fix affects shared-fixtures or auth used by API+Web+Mobile | Warn user, get approval before fixing |

**Visual-First Debugging (before changing code):**

Follow `references/runtime-inspection.md`'s 8-step workflow to inspect the live app before modifying any code. **Take a screenshot after every action (mandatory):**

```bash
# 1. Reproduce in headed/debug mode
npx playwright test --headed --grep "failing test name"
npx playwright test --debug

# 2. Full session trace (view with show-trace)
npx playwright test --trace on
npx playwright show-trace test-results/trace.zip
```

```typescript
// 3. Screenshot at point of failure (see runtime-inspection.md § 6)
await page.screenshot({ path: 'step-01-initial.png', fullPage: true });

// 4. Inspect the DOM/element in question (see runtime-inspection.md § 4)
const count = await page.getByTestId('target-element').count();
```

Checklist:
- Screenshot: is the element actually visible?
- Layout: is the page broken?
- Text: does the text match exactly? (case-sensitivity, whitespace, Thai characters)
- Modal: is there an unexpected popup blocking the element?
- Loading: is the page still loading?

**Error triage** (Environment-vs-Code split shared across platforms, see
`skills/ai-sdlc/references/qa-automation-loop.md`): Environment (skip) = 500 errors, VPN,
connection refused. Code (heal) = element not found, assertion failed, timeout (selector).

**Fix by error type:**

| Error | Fix |
|-------|-----|
| Element not found | Check locator priority, verify case-sensitivity and nested modal layers |
| Timeout | Add waitForResponse, increase timeout |
| Click intercepted | Close modal first, scroll into view |
| Assertion failed | Verify test data, add waitFor assertion |
| Flaky | Use fixed seed, mock external APIs |

**Rules:**
- Self-heal discipline (1 attempt, escalation, logging) — `skills/ai-sdlc/references/qa-automation-loop.md`
- Never delete functions or change architecture
- MUST run impact analysis before fixing shared code

## Test Results & Reflexion Log — Write to Audit Trail (MANDATORY)

Format, location, and purpose are shared across platforms — see
`skills/ai-sdlc/references/qa-automation-loop.md`'s Test Results and Reflexion Log sections.
This platform's Test Results context line: `ENV: [SIT/UAT] | Mode: [CLI/GUI]`.

## Bug Report Template (When QA cannot self-heal)

When the single self-heal attempt fails, or the bug is a logic issue that needs deeper root-causing:

```markdown
## 🐛 Bug Report — [TS-XXX] [Test Name]

**Date:** YYYY-MM-DD
**Reporter:** QA
**Severity:** Critical | High | Medium | Low

### Symptom
[Explain what is observed — error message, wrong behavior]

### Steps to Reproduce
1. [step 1]
2. [step 2]
3. [step 3]

### Expected vs Actual
- Expected: [What should have happened]
- Actual: [What actually happened]

### Environment
- ENV: SIT | UAT
- Test data: [testId or seed data used]
- Browser/Platform: [If relevant]

### Reflexion Log Reference
[Link or paste the entry from the Reflexion Log]

### Hypothesis
[What QA thinks the root cause might be — optional but very helpful for Dev]
```

**Location:** create it in `audit.md` → `## Bug Reports` section
**Notify:** the Dev who owns that feature
