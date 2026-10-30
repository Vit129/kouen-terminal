# Component Testing — Playwright

Test React/Vue/Svelte components in isolation inside a real browser — faster than E2E, more realistic than jsdom.

## Setup

```bash
npm init playwright@latest -- --ct
# Choose: React / Vue / Svelte
```

This creates `playwright/index.html` and `playwright/index.tsx` (React).

## Basic Component Test

```typescript
// FlightCard.spec.tsx
import { test, expect } from '@playwright/experimental-ct-react'
import { FlightCard } from './FlightCard'

test('renders flight info correctly', async ({ mount }) => {
  const component = await mount(
    <FlightCard
      flight={{ id: 'FL001', origin: 'BKK', destination: 'NRT', price: 15000 }}
    />
  )

  await expect(component.getByTestId('flight-origin')).toHaveText('BKK')
  await expect(component.getByTestId('flight-destination')).toHaveText('NRT')
  await expect(component.getByTestId('flight-price')).toHaveText('$150.00')
})
```

## Testing Interactions

```typescript
test('select button triggers callback', async ({ mount }) => {
  let selectedId = ''

  const component = await mount(
    <FlightCard
      flight={{ id: 'FL001', origin: 'BKK', destination: 'NRT', price: 15000 }}
      onSelect={(id) => { selectedId = id }}
    />
  )

  await component.getByTestId('btn-select-flight-FL001').click()
  expect(selectedId).toBe('FL001')
})
```

## Testing States

```typescript
test('shows loading skeleton', async ({ mount }) => {
  const component = await mount(<FlightResultList status="loading" />)
  await expect(component.getByTestId('flight-result-loading')).toBeVisible()
})

test('shows empty state', async ({ mount }) => {
  const component = await mount(<FlightResultList status="empty" flights={[]} />)
  await expect(component.getByTestId('flight-result-empty-state')).toBeVisible()
})

test('shows error state', async ({ mount }) => {
  const component = await mount(
    <FlightResultList status="error" message="Service unavailable" />
  )
  await expect(component.getByTestId('flight-result-error-state')).toBeVisible()
  await expect(component.getByTestId('btn-retry-search')).toBeVisible()
})
```

## Testing Forms

```typescript
test('search form submits with correct values', async ({ mount }) => {
  let submitted: any = null

  const component = await mount(
    <FlightSearchForm onSubmit={(values) => { submitted = values }} />
  )

  await component.getByTestId('origin-input').fill('BKK')
  await component.getByTestId('destination-input').fill('NRT')
  await component.getByTestId('btn_searchFlights_flightSearchPage').click()

  expect(submitted).toEqual({ origin: 'BKK', destination: 'NRT' })
})
```

## Update Props (Re-render)

```typescript
test('updates when props change', async ({ mount }) => {
  const component = await mount(<StatusBadge status="loading" />)
  await expect(component).toHaveText('Loading...')

  await component.update(<StatusBadge status="success" />)
  await expect(component).toHaveText('Done')
})
```

## With Providers (Context, Router)

```typescript
// playwright/index.tsx — wrap all tests with providers
import { beforeMount } from '@playwright/experimental-ct-react/hooks'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { MemoryRouter } from 'react-router-dom'

beforeMount(async ({ App }) => {
  const queryClient = new QueryClient()
  return (
    <QueryClientProvider client={queryClient}>
      <MemoryRouter>
        <App />
      </MemoryRouter>
    </QueryClientProvider>
  )
})
```

## Config

```typescript
// playwright-ct.config.ts
import { defineConfig } from '@playwright/experimental-ct-react'

export default defineConfig({
  testDir: './src',
  testMatch: '**/*.spec.tsx',
  use: {
    ctPort: 3100,
    viewport: { width: 1280, height: 720 },
  },
})
```

## Run Component Tests

```bash
# Run all component tests
npx playwright test --config=playwright-ct.config.ts

# Run specific file
npx playwright test FlightCard.spec.tsx --config=playwright-ct.config.ts
```

## When to Use Component vs E2E

| Use Component Testing | Use E2E Testing |
|----------------------|-----------------|
| Testing component in isolation | Testing full user flows |
| Testing all UI states (loading/empty/error) | Testing integration between pages |
| Testing props/events | Testing real API calls |
| Fast feedback during development | Regression testing before release |

## Best Practices

- Test all 4 UI states (loading, success, empty, error) for every data-driven component
- Test user interactions (click, type, submit) not implementation details
- Use `data-testid` locators — same as E2E tests for consistency
- Keep component tests next to the component file (`FlightCard.spec.tsx` beside `FlightCard.tsx`)
- Mock external dependencies (API calls, context) at the component boundary
