# Runtime Inspection Workflow

> Use when a test fails and you need to understand what the browser actually saw.
> Playwright test tells you pass/fail. This tells you WHY.

## When to Use

- Test fails but you don't know why
- Element not found — but you think it should be there
- API call returns unexpected data
- Page looks wrong visually
- Performance regression suspected

## 8-Step Workflow

### 1. Reproduce in Browser

```typescript
// Run test in headed mode to see what's happening
npx playwright test --headed --grep "failing test name"

// Or open browser manually at the failing URL
npx playwright open https://your-app.com/failing-page
```

### 2. Inspect Console Errors

```typescript
// Capture all console messages in test
page.on('console', msg => {
  if (msg.type() === 'error') {
    console.log('Console error:', msg.text());
  }
});

// Or check after action
const errors: string[] = [];
page.on('console', msg => {
  if (msg.type() === 'error') errors.push(msg.text());
});
await page.goto('/');
console.log('Errors found:', errors);
```

### 3. Inspect Network Requests/Responses

```typescript
// Intercept and log specific API calls
page.on('response', response => {
  if (response.url().includes('/api/')) {
    console.log(response.status(), response.url());
  }
});

// Wait for specific request and inspect response
const [response] = await Promise.all([
  page.waitForResponse(r => r.url().includes('/api/users')),
  page.click('#load-users'),
]);
const data = await response.json();
console.log('API response:', data);

// Check for failed requests
page.on('requestfailed', request => {
  console.log('Failed:', request.url(), request.failure()?.errorText);
});
```

### 4. Inspect DOM and Accessibility Tree

```typescript
// Check if element exists
const element = page.getByTestId('submit-button');
const count = await element.count();
console.log('Element count:', count); // 0 = not found

// Get element's current state
const isVisible = await element.isVisible();
const isEnabled = await element.isEnabled();
const text = await element.textContent();
console.log({ isVisible, isEnabled, text });

// Dump accessibility tree (useful for screen reader issues)
const snapshot = await page.accessibility.snapshot();
console.log(JSON.stringify(snapshot, null, 2));

// Get all matching elements (find duplicates)
const all = await page.getByRole('button', { name: 'Submit' }).all();
console.log('Found buttons:', all.length);
```

### 5. Check Storage/State

```typescript
// localStorage
const token = await page.evaluate(() => localStorage.getItem('auth_token'));
console.log('Token:', token);

// sessionStorage
const session = await page.evaluate(() => sessionStorage.getItem('session'));

// Cookies
const cookies = await page.context().cookies();
console.log('Cookies:', cookies);

// React state (if React DevTools available)
const state = await page.evaluate(() => {
  const el = document.querySelector('#root');
  // Access React fiber if needed
  return (el as any)?._reactFiber?.memoizedState;
});
```

### 6. Capture Screenshot or Trace

```typescript
// Screenshot at point of failure
await page.screenshot({ path: 'debug-screenshot.png', fullPage: true });

// Screenshot of specific element
await page.getByTestId('error-message').screenshot({ path: 'error.png' });

// Enable trace for full session recording
// In playwright.config.ts:
// trace: 'on-first-retry'

// Or manually:
await page.context().tracing.start({ screenshots: true, snapshots: true });
// ... do actions ...
await page.context().tracing.stop({ path: 'trace.zip' });
// View: npx playwright show-trace trace.zip
```

### 7. Use Evidence to Fix

Based on what you found:

| Evidence | Likely cause | Fix |
|----------|-------------|-----|
| Console error: "Cannot read property of undefined" | Data not loaded yet | Add proper wait or check loading state |
| Network 401 | Auth token missing/expired | Check auth setup in test |
| Network 404 | Wrong URL or route not registered | Check API route |
| Element count: 0 | Wrong selector or element not rendered | Check selector, add wait |
| Element not visible | Hidden by CSS or behind modal | Check z-index, scroll into view |
| API response has wrong shape | Backend changed contract | Update test data or fix backend |

### 8. Add Regression Test

After fixing, write a test that would have caught this:

```typescript
test('should show error message when API fails', async ({ page }) => {
  // Mock the failing API call
  await page.route('/api/users', route => route.fulfill({
    status: 500,
    body: JSON.stringify({ error: 'Internal Server Error' }),
  }));

  await page.goto('/users');

  // Assert the error state is handled
  await expect(page.getByTestId('error-message')).toBeVisible();
  await expect(page.getByTestId('error-message')).toContainText('Something went wrong');
});
```

## Quick Reference: Playwright Debug Commands

```bash
# Run in headed mode (see browser)
npx playwright test --headed

# Run with Playwright Inspector (step through)
npx playwright test --debug

# Run with trace
npx playwright test --trace on

# View trace
npx playwright show-trace test-results/trace.zip

# Open browser at URL for manual inspection
npx playwright open https://your-app.com

# Generate code from browser actions (Codegen)
npx playwright codegen https://your-app.com
```
