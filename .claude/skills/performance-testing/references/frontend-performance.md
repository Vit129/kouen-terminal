# Frontend Performance & Core Web Vitals

Measure client-side performance, Core Web Vitals, and network waterfalls via Playwright during automated test runs.

---

## 1. Core Web Vitals Targets

| Metric | Good | Needs Improvement | Poor |
|--------|------|-------------------|------|
| LCP (Largest Contentful Paint) | ≤ 2.5s | ≤ 4.0s | > 4.0s |
| INP (Interaction to Next Paint) | ≤ 200ms | ≤ 500ms | > 500ms |
| CLS (Cumulative Layout Shift) | ≤ 0.1 | ≤ 0.25 | > 0.25 |
| TTFB (Time to First Byte) | ≤ 800ms | ≤ 1.5s | > 1.5s |

---

## 2. Playwright Tracing & Profiling Pattern

Capture performance metrics during functional test execution without launching separate browser sessions:

```typescript
import { test, expect } from '@playwright/test';

test.describe('@Performance Frontend Profiling', () => {
  test('measure page load + API latency', async ({ page, context }) => {
    await context.tracing.start({ screenshots: true, snapshots: true });

    // 1. Collect API latencies
    const latencies: { url: string; duration: number; status: number }[] = [];
    page.on('response', (res) => {
      if (res.url().includes('/api/')) {
        latencies.push({
          url: new URL(res.url()).pathname,
          duration: res.timing().responseEnd,
          status: res.status(),
        });
      }
    });

    // 2. Navigate and collect Web Vitals
    await page.goto('/dashboard');
    await page.waitForLoadState('networkidle');

    const vitals = await page.evaluate(() => {
      return new Promise<Record<string, number>>((resolve) => {
        const metrics: Record<string, number> = {};
        new PerformanceObserver((entryList) => {
          for (const entry of entryList.getEntries()) {
            if (entry.entryType === 'largest-contentful-paint') metrics.LCP = entry.startTime;
            if (entry.entryType === 'layout-shift' && !(entry as any).hadRecentInput) {
              metrics.CLS = (metrics.CLS || 0) + (entry as any).value;
            }
          }
        }).observe({ type: 'largest-contentful-paint', buffered: true });
        setTimeout(() => resolve(metrics), 2000);
      });
    });

    await context.tracing.stop({ path: 'test-results/performance-trace.zip' });

    // 3. Performance Budget Assertions (CI Gates)
    expect(vitals.LCP ?? 0, 'LCP should be <= 2500ms').toBeLessThanOrEqual(2500);
    expect(vitals.CLS ?? 0, 'CLS should be <= 0.1').toBeLessThanOrEqual(0.1);
    for (const l of latencies) {
      expect(l.duration, `API ${l.url} too slow`).toBeLessThan(1000);
    }
  });
});
```

---

## 3. Performance Report Format

Save reports to `test-results/performance/`:
- `performance-report.md` (markdown summary)
- `performance-report.html` (self-contained HTML with embedded styles)

### Markdown Report Schema
```markdown
# 📊 Performance Report — {Feature}

- **Date:** {YYYY-MM-DD}
- **URL:** {target_url}

### Core Web Vitals
| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| LCP | {x}ms | ≤ 2500ms | ✅/❌ |
| CLS | {x} | ≤ 0.1 | ✅/❌ |
| TTFB | {x}ms | ≤ 800ms | ✅/❌ |

### API Latency (Top Slowest)
| Method | Endpoint | Duration (ms) | Status |
|--------|----------|---------------|--------|
| GET | /api/v1/orders | 420 | 200 |
```

---

## 4. Common Frontend Bottlenecks & Fixes

| Bottleneck | Metric Impact | Fix |
|------------|---------------|-----|
| Render-blocking JS bundle | LCP > 2.5s | Code-split, dynamic `import()`, defer scripts |
| Un-optimized Hero image | LCP > 2.5s | Add `fetchpriority="high"`, WebP format, responsive sizes |
| Web fonts causing layout shift | CLS > 0.1 | Preload font, `font-display: swap` |
| Cumulative DOM re-renders | INP > 200ms | Memoize handlers, virtualize long lists |
