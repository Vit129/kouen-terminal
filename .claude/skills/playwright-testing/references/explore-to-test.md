# Explore-to-Test Workflow

Combined workflow using Chrome DevTools MCP + HAR + Extension + AI to produce complete test suites (API + Web UI) from scratch.

## When to use
- Starting QA automation for a new feature with no existing tests
- Need both API and Web UI tests
- Want to capture real API behavior before writing tests
- Feature has complex login/auth flow

## Tool Roles

| Tool | Role | Token Cost | Output |
|------|------|-----------|--------|
| Chrome DevTools MCP | **Explore** — discover APIs + UI state | Medium | API spec knowledge |
| HAR Record (Playwright CLI) | **Capture** — record network for replay | 0 (CLI) | `.har` file |
| Extension Record & Play | **Scaffold** — record user actions | 0 (human) | `.spec.ts` skeleton |
| Playwright CLI (`@playwright/cli`) | **AI Navigate** — agent browses when needed | Low (file-based) | snapshots on disk |
| AI agent | **Complete** — assertions + edge cases | Token-efficient | Final test code |

## Full Workflow

### Step 1: Explore with Chrome DevTools MCP

AI agent explores the app to discover API contracts:

```
1. navigate_page → login page
2. take_snapshot → see form elements
3. fill + click → login
4. list_network_requests (xhr, fetch) → see all API calls
5. get_network_request (reqid) → get request/response body
```

**Output:** API knowledge document:
```markdown
## API Endpoints Discovered
| Method | Endpoint | Request Body | Response |
|--------|----------|-------------|----------|
| POST | /api/profile/get-user-info | {"email":"...","state":"normal"} | user profiles |
| POST | /api/dummy/dashboard/list | {"page":1,"size":20,...} | paginated list |
| GET | /api/dummy/dashboard/cards | — | card counts |
```

### Step 2: Capture HAR

Record network traffic for offline replay:

```bash
npx playwright open \
  --save-har=tests/fixtures/har/[system]/[feature].har \
  https://[app-url]/login
```

- Login → navigate all pages that need testing → close browser
- HAR captures all API responses for replay

### Step 3: Scaffold with Extension (optional)

Human records happy path actions in VS Code:
- Click Record → interact with app → Stop
- Gets `.spec.ts` with actions (no assertions)

### Step 4: AI Completes the Test

Using knowledge from Step 1 + HAR from Step 2 + scaffold from Step 3:

```typescript
import { test, expect } from '@playwright/test'
import { isServiceUp } from '../../shared/mocks/healthCheck'

test.describe('Dashboard', () => {
  test.beforeAll(async ({ request, page }) => {
    const up = await isServiceUp(request, BASE_URL)
    if (!up) {
      await page.routeFromHAR('tests/fixtures/har/your-app/dashboard.har', {
        url: '**/api/**'
      })
    }
  })

  test('shows correct card counts', async ({ page }) => {
    // Arrange — from Extension scaffold
    await page.goto('/salesreturn/dashboard')

    // Assert — AI adds from Chrome DevTools knowledge
    await expect(page.getByText('125')).toBeVisible()  // returns
    await expect(page.getByText('50')).toBeVisible()   // credit notes
    await expect(page.getByText('200')).toBeVisible()  // debit notes
  })

  test('disabled buttons for completed requests', async ({ page }) => {
    await page.goto('/salesreturn/dashboard')

    // AI knows from snapshot that "Completed" rows have disabled buttons
    const completedRow = page.getByTestId('request-row-REQ20230901010')
    await expect(completedRow.getByRole('button').first()).toBeDisabled()
  })

  test('shows error on API failure', async ({ page }) => {
    // Error case — always mock
    await page.route('**/api/dummy/dashboard/list', route =>
      route.fulfill({ status: 500, body: '{"error":"Internal"}' })
    )
    await page.goto('/salesreturn/dashboard')
    await expect(page.getByText('An error occurred')).toBeVisible()
  })
})
```

## Decision Matrix: Which Tool When

```
"I do not know the API at all"
  → Chrome DevTools MCP (explore)

"I know the API and want to mock it"
  → HAR Record (capture once)

"I want a test script fast"
  → Extension Record (scaffold actions)

"I want assertions + edge cases"
  → AI agent (complete from knowledge)

"The AI needs to see the page state"
  → Playwright CLI (token-efficient navigate)
```

## Comparison: Explore Tools

| Capability | Chrome DevTools MCP | Playwright CLI | HAR |
|---|---|---|---|
| See network requests | ✅ | ❌ | ✅ (after record) |
| See request/response body | ✅ | ❌ | ✅ (after record) |
| See DOM/UI state | ✅ (snapshot) | ✅ (snapshot) | ❌ |
| See console logs | ✅ | ❌ | ❌ |
| Interactive (real-time) | ✅ | ✅ | ❌ |
| Replay in test | ❌ | ❌ | ✅ |
| Token cost | Medium | Low | 0 |

## Integration with Existing Skills

This workflow feeds into:
- **`rules/ai-sdlc-workflow.md`'s Architect phase** → API spec from Step 1 informs the design (`skills/ai-sdlc/references/dev-qa-handoff.md`'s Schema Consistency Check)
- **playwright-testing/workflow.md** → Step 4 follows Write → Review → Execute → Heal
- **playwright-testing/har-mocking.md** → Step 2-3 HAR patterns

## Rules
- Always explore (Step 1) before designing architecture — never assume API contracts
- HAR files are per-feature, stored in `tests/fixtures/har/[system]/`
- Extension scaffold is optional — AI can write from scratch using explore data
- Error cases MUST use `page.route()` not HAR
- Re-explore when API changes (new version, new fields)
- Document discovered APIs in `agent-memory/plans/` for team reference
