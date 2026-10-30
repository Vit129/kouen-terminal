# Property-Based Testing (Playwright + fast-check)

```bash
npm install --save-dev fast-check
```

```typescript
import * as fc from 'fast-check';
import { test, expect } from '@playwright/test';

test('property: [invariant description] @property', async ({ page }) => {
  await fc.assert(
    fc.asyncProperty(
      fc.record({ amount: fc.integer({ min: 1, max: 100000 }) }),
      async ({ amount }) => {
        await page.goto('/checkout');
        await page.fill('[data-testid="amount"]', String(amount));
        const total = await page.textContent('[data-testid="total"]');
        expect(Number(total)).toBeGreaterThanOrEqual(amount);
      }
    ),
    { numRuns: 20 } // E2E: 20 runs; unit/integration: 100
  );
});
```

**Rules:**
- Tag `@property` to filter separately from example-based tests
- When property fails, fast-check auto-shrinks to minimal failing input — read output before debugging
- Invariants come from Quick Review Summary Properties section (test-scenario Step 1.5)
- Only write when AC has business logic / calculation invariants — skip for pure UI flows
