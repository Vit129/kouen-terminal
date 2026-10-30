# Visual Regression Testing — Playwright

Catch unintended UI changes by comparing screenshots against baselines.

## Setup

```bash
npm install @playwright/test
# Built-in — no extra package needed for basic screenshot comparison
```

## Basic Screenshot Comparison

```typescript
import { test, expect } from '@playwright/test'

test('flight search form looks correct', async ({ page }) => {
  await page.goto('/flights/search')
  await page.waitForLoadState('networkidle')

  // Full page
  await expect(page).toHaveScreenshot('flight-search.png')

  // Specific element
  const form = page.getByTestId('flight-search-form')
  await expect(form).toHaveScreenshot('flight-search-form.png')
})
```

## Playwright Config for Screenshots

```typescript
// playwright.config.ts
export default defineConfig({
  expect: {
    toHaveScreenshot: {
      maxDiffPixels: 100,          // allow minor anti-aliasing differences
      threshold: 0.2,              // 0-1 color difference threshold
      animations: 'disabled',      // disable CSS animations for stable shots
    },
  },
  use: {
    viewport: { width: 1280, height: 720 },
  },
})
```

## Update Baselines

```bash
# First run — creates baseline screenshots
npx playwright test --update-snapshots

# CI — compare against committed baselines
npx playwright test
```

## Masking Dynamic Content

```typescript
test('dashboard screenshot', async ({ page }) => {
  await page.goto('/dashboard')

  await expect(page).toHaveScreenshot('dashboard.png', {
    mask: [
      page.getByTestId('current-time'),    // mask dynamic timestamps
      page.getByTestId('user-avatar'),     // mask user-specific content
    ],
    maskColor: '#ff00ff',  // visible mask color for debugging
  })
})
```

## Multi-Viewport Testing

```typescript
const viewports = [
  { name: 'mobile', width: 375, height: 812 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'desktop', width: 1440, height: 900 },
]

for (const vp of viewports) {
  test(`flight search — ${vp.name}`, async ({ page }) => {
    await page.setViewportSize({ width: vp.width, height: vp.height })
    await page.goto('/flights/search')
    await expect(page).toHaveScreenshot(`flight-search-${vp.name}.png`)
  })
})
```

## Cross-Browser Visual Testing

```typescript
// playwright.config.ts
projects: [
  { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  { name: 'firefox',  use: { ...devices['Desktop Firefox'] } },
  { name: 'webkit',   use: { ...devices['Desktop Safari'] } },
  { name: 'mobile',   use: { ...devices['iPhone 14'] } },
]
```

## Best Practices

- Store baseline screenshots in version control (`__screenshots__/` folder)
- Disable animations and transitions before taking screenshots
- Use `waitForLoadState('networkidle')` to ensure page is fully loaded
- Mask dynamic content (timestamps, user data, ads)
- Run visual tests in a separate suite — don't mix with functional tests
- Use consistent viewport sizes across team and CI
- Review screenshot diffs in Playwright HTML report before updating baselines

## CI Integration

```yaml
# GitHub Actions
- name: Run visual tests
  run: npx playwright test --project=chromium visual/

- name: Upload screenshots on failure
  if: failure()
  uses: actions/upload-artifact@v4
  with:
    name: playwright-screenshots
    path: test-results/
```

## Folder Structure

```
tests/
├── visual/
│   ├── flight-search.spec.ts
│   └── booking-flow.spec.ts
└── __screenshots__/
    ├── flight-search.png          ← baseline
    └── flight-search-mobile.png   ← baseline
```
