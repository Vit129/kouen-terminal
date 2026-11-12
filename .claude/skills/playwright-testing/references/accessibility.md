# Accessibility Testing — Playwright + axe-core

Automated accessibility scanning integrated into Playwright tests using `@axe-core/playwright`.

## Setup

```bash
npm install @axe-core/playwright
```

## Basic Accessibility Scan

```typescript
import { test, expect } from '@playwright/test'
import AxeBuilder from '@axe-core/playwright'

test('flight search page has no accessibility violations', async ({ page }) => {
  await page.goto('/flights/search')

  const results = await new AxeBuilder({ page }).analyze()

  expect(results.violations).toEqual([])
})
```

## Scan Specific Component

```typescript
test('booking form is accessible', async ({ page }) => {
  await page.goto('/flights/booking')

  const results = await new AxeBuilder({ page })
    .include('[data-testid="booking-form"]')
    .analyze()

  expect(results.violations).toEqual([])
})
```

## Filter by WCAG Level

```typescript
test('page meets WCAG 2.1 AA', async ({ page }) => {
  await page.goto('/flights/search')

  const results = await new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa', 'wcag21aa'])
    .analyze()

  expect(results.violations).toEqual([])
})
```

## Exclude Known Issues (Temporary)

```typescript
test('page accessibility — excluding known issues', async ({ page }) => {
  await page.goto('/flights/search')

  const results = await new AxeBuilder({ page })
    .exclude('#third-party-widget')          // exclude third-party content
    .disableRules(['color-contrast'])        // disable specific rule temporarily
    .analyze()

  expect(results.violations).toEqual([])
})
```

## Readable Violation Report

```typescript
import { test, expect } from '@playwright/test'
import AxeBuilder from '@axe-core/playwright'

function formatViolations(violations: any[]) {
  return violations.map(v => ({
    id: v.id,
    impact: v.impact,
    description: v.description,
    nodes: v.nodes.map((n: any) => n.html),
  }))
}

test('accessibility scan with readable output', async ({ page }) => {
  await page.goto('/flights/search')
  const { violations } = await new AxeBuilder({ page }).analyze()

  if (violations.length > 0) {
    console.log('Violations:', JSON.stringify(formatViolations(violations), null, 2))
  }

  expect(violations).toEqual([])
})
```

## Scan All Pages in a Flow

```typescript
test('booking flow is accessible throughout', async ({ page }) => {
  const pages = [
    '/flights/search',
    '/flights/results',
    '/flights/booking/BK-001',
    '/flights/booking/BK-001/confirmation',
  ]

  for (const url of pages) {
    await page.goto(url)
    const { violations } = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa'])
      .analyze()

    expect(violations, `Violations on ${url}`).toEqual([])
  }
})
```

## Common Accessibility Rules to Check

| Rule ID | Description |
|---------|-------------|
| `color-contrast` | Text must have sufficient color contrast |
| `image-alt` | Images must have alt text |
| `label` | Form inputs must have labels |
| `button-name` | Buttons must have accessible names |
| `link-name` | Links must have accessible names |
| `aria-required-attr` | ARIA roles must have required attributes |
| `heading-order` | Headings must be in logical order |
| `focus-trap` | Focus must not be trapped in modals |

## Playwright Accessibility Assertions (Built-in)

```typescript
// Check ARIA roles
await expect(page.getByRole('dialog')).toBeVisible()
await expect(page.getByRole('button', { name: 'Search Flights' })).toBeEnabled()

// Check ARIA attributes
await expect(page.getByTestId('loading-spinner')).toHaveAttribute('aria-busy', 'true')
await expect(page.getByTestId('error-message')).toHaveAttribute('role', 'alert')

// Check focus management
await page.keyboard.press('Tab')
await expect(page.getByTestId('first-focusable')).toBeFocused()
```

## CI Integration

```yaml
- name: Run accessibility tests
  run: npx playwright test tests/accessibility/ --reporter=html

- name: Upload accessibility report
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: accessibility-report
    path: playwright-report/
```

## Best Practices

- Run accessibility scans on every page in critical user flows
- Fix `critical` and `serious` violations before merging — `moderate` and `minor` can be tracked
- Don't disable rules permanently — create tickets for known issues
- Test keyboard navigation manually for complex interactions (modals, dropdowns)
- Test with screen reader for critical flows (VoiceOver on iOS, TalkBack on Android)
- Accessibility tests should run in CI on every PR
