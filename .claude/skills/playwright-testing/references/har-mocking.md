# HAR-Based Network Mocking

Use HAR (HTTP Archive) files to mock network traffic in Playwright tests — run tests offline without backend dependency.

## When to use
- Backend not ready or unstable
- CI/CD needs to run without external services
- Want deterministic test data (no flaky API responses)
- Performance testing frontend in isolation

## 3-Phase Workflow

```
Phase 1: EXPLORE          Phase 2: CAPTURE           Phase 3: TEST
Chrome DevTools MCP       HAR Record                 Playwright Test
────────────────────      ──────────────────         ─────────────────
navigate + login          npx playwright open        routeFromHAR()
list_network_requests     --save-har=x.har           + assertions
get_network_request       login + navigate           + error mocks
→ know API endpoints      → get a .har file          → CI/CD ready
```

## Phase 2: Recording HAR

### Via Playwright CLI (recommended)
```bash
npx playwright open \
  --save-har=tests/fixtures/har/[system]/[feature].har \
  https://your-app-sit.your-company.com/salesreturn/login
```
- Log in and navigate every page you need to test
- Close the browser → the HAR file is saved

### Via test code (programmatic)
```typescript
const context = await browser.newContext({
  recordHar: {
    path: 'tests/fixtures/har/your-app/dashboard.har',
    urlFilter: '**/api/**'  // capture API calls only
  }
})
// ... navigate, interact ...
await context.close() // HAR saved
```

### Via Chrome DevTools (manual)
- DevTools → Network tab → use the web app → right-click → "Save all as HAR with content"

## Phase 3: Using HAR in Tests

### Basic replay
```typescript
test('dashboard shows correct cards', async ({ page }) => {
  await page.routeFromHAR('tests/fixtures/har/your-app/dashboard.har', {
    url: '**/api/**'
  })
  await page.goto('/salesreturn/dashboard')
  await expect(page.getByText('125')).toBeVisible()
})
```

### Auto-fallback: real service → HAR
```typescript
import { isServiceUp } from '../../shared/mocks/healthCheck'

test.beforeAll(async ({ request, page }) => {
  const up = await isServiceUp(request, BASE_URL)
  if (!up) {
    console.log('⚠️ Service unavailable — using HAR mock [HAR_MOCK]')
    await page.routeFromHAR('tests/fixtures/har/your-app/dashboard.har', {
      url: '**/api/**'
    })
  }
})
```

### Update HAR when API changes
```typescript
// update: true → re-record URLs not found in existing HAR
await page.routeFromHAR('tests/fixtures/har/your-app/dashboard.har', {
  url: '**/api/**',
  update: true  // fetch from real server + merge into HAR
})
```

### Error cases — always use page.route() (not HAR)
```typescript
test('should show error toast on 500', async ({ page }) => {
  await page.route('**/api/dashboard/list', route =>
    route.fulfill({ status: 500, body: JSON.stringify({ error: 'Internal Server Error' }) })
  )
  await page.goto('/salesreturn/dashboard')
  await expect(page.getByText('An error occurred')).toBeVisible()
})
```

## File Structure

```
tests/
├── fixtures/
│   └── har/
│       └── [SYSTEM_KEBAB]/
│           └── [FEATURE_KEBAB].har     ← HAR files (git-tracked)
├── shared/
│   └── mocks/
│       └── healthCheck.ts              ← isServiceUp() utility
│       └── [SYSTEM_KEBAB]/
│           └── [feature]Mock.ts        ← page.route() error mocks
```

## Mock Strategy Decision Table

| Scenario | Strategy | Why |
|----------|----------|-----|
| Happy path, service UP | Real API | Most accurate |
| Happy path, service DOWN | HAR replay | Deterministic fallback |
| Error cases (4xx, 5xx) | page.route() | Can't rely on server to produce errors |
| Edge cases (timeout, slow) | page.route() with delay | Controlled timing |
| Performance test (frontend) | HAR replay | Eliminate network variance |

## HAR vs page.route() — When to use which

| | HAR | page.route() |
|---|---|---|
| Many endpoints at once | ✅ (one file covers all) | ❌ (must mock each) |
| Specific error response | ❌ | ✅ |
| Dynamic response per test | ❌ (static snapshot) | ✅ |
| Quick setup | ✅ (record once) | ❌ (write code) |
| Maintenance | Re-record when API changes | Update code |

## Rules
- HAR files MUST be git-tracked (they are test fixtures)
- Use `urlFilter` when recording to avoid capturing analytics/tracking
- Tag console output with `[HAR_MOCK]` when using HAR fallback
- Error scenarios MUST use `page.route()` — never rely on HAR for error testing
- Re-record HAR when API contract changes (new fields, changed structure)
- HAR files should be per-feature, not per-test (avoid duplication)
