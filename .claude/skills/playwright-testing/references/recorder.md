# Playwright Recorder Analyzer

Transform Playwright Codegen recordings (test-*.spec.ts) into proper Page Object Model code.

## Record First

Codegen always needs a real (headed) browser — run it on your own machine, not in an agent's headless environment.

```bash
npx playwright codegen <url> \
  --target playwright-test \
  --output tests/recordings/test-recording.spec.ts \
  --save-har=tests/recordings/[feature].har
```

- Opens a browser + inspector — every click/fill/navigate gets recorded as raw Playwright code, and network traffic is captured into the same HAR in one pass (don't split into two separate recording runs — one combined pass catches API + UI together and avoids re-driving the same flow twice)
- Don't filter with `--save-har-glob` — capture every request first; the agent filters down to the relevant API calls later when converting to POM
- `--save-storage=auth.json` to also capture a logged-in session (reuse via `storageState`)
- Save output under a scratch path (`tests/recordings/`) — it's a transform *input*, never a final spec file; delete the raw files after conversion, before committing
- No GUI browser available (CI/headless env) → skip codegen, write the spec by hand using the Locator priority + Pattern Transformations below as the target shape

## When to use
- Have a Playwright recording that needs to be converted to POM
- Need to extract locators, actions, and flows from recorded tests

## Extraction Checklist

| Category | Extract | Pattern |
|----------|---------|---------|
| Locators | getByRole, getByLabel, getByPlaceholder, getByText, getByTestId | `page.getBy*()` |
| Actions | click, fill, selectOption, check | `await page.*()` |
| Flow | Navigation order | `goto()`, `click()` chain |
| Waits | waitForURL, waitForSelector, waitForLoadState | `waitFor*()` |
| Data | Input values | `fill()`, `selectOption()` values |

## Process
1. Read recording file (test-*.spec.ts)
2. Extract: locators, actions, navigation flow, waits, form data
3. Validate locator priority (see Locator priority below — `getByTestId` is priority #1, not a violation) — flag violations:
   - XPath, CSS-only → flag as violation
   - `getByTestId` used on a leaf form/semantic element that has a stable role/label → suggest `getByRole`/`getByLabel` instead (reserve `getByTestId` for containers/lists/dynamic items per the Hybrid pattern)
4. Identify patterns:
   - Forms → `fillForm(data)`
   - Tables → `clickRowAction(row, action)`
   - Wizards → `completeWizard(steps)`
5. Transform to Page Object — methods from actions, improved locators, test data as JSON
6. Replace hard waits with smart waits

## Locator priority
1. `getByTestId` — containers, lists, dynamic items, translatable elements (most stable)
2. `getByRole` + `L.keyName` from `Labels.ts` — semantic elements with stable name
3. `getByLabel` — form fields
4. `getByPlaceholder` — inputs
5. `getByText` — non-interactive text
6. XPath/CSS — avoid

**Hybrid pattern (standard):**
```typescript
// scope by testId, target by role + label from Labels.ts
page.getByTestId('flight-result-item-FL001')
    .getByRole('button', { name: L.btnSelectFlight }).click()
```

## Pattern Transformations

### Form Filling
```typescript
// ❌ Recording: getByTestId('username').fill('admin')
// ✅ POM: getByLabel('Username').fill(username)  // if <label> exists
```

### Table Interaction
```typescript
// ❌ Recording: locator('button[title="Edit"]').click()
// ✅ POM: row.getByRole('button', { name: 'Edit' }).click()
```

### Hard Waits
```typescript
// ❌ Recording: waitForTimeout(3000)
// ✅ POM: waitForSelector('.data-loaded') or waitForResponse()
```

## Rules
- Never copy recordings directly into spec files
- Every recording must be analyzed and transformed to POM first
- Replace all `waitForTimeout()` with smart waits
- Extract repeated sequences into reusable methods
- Flag all locator violations with suggestions
