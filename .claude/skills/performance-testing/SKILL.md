---
disable-model-invocation: true
name: performance-testing
description: >
  This skill should be used when the user asks to "load test", "ทำ load test",
  "stress test", "ทำ stress test", "performance test", "ทดสอบ performance",
  "k6", "write k6 script", "เขียน k6 script", "test API under load", "ทดสอบ API ภายใต้ load",
  "check response time", "เช็ค response time", "find bottleneck", "หา bottleneck",
  "simulate concurrent users", "จำลอง concurrent users",
  "spike test", "soak test", or needs to validate system performance before release.
version: 2.0.0
---

# Performance Testing

Load and performance testing with K6 and Playwright — script, profile, triage bottlenecks, and gate in CI/CD.

## When to Load Each Reference

| User says | Load |
|-----------|------|
| "write k6 script", "load test API", "simulate users", "k6 thresholds", "run in CI", "k6 CI gate" | `references/k6-scripting.md` |
| "frontend performance", "Core Web Vitals", "LCP", "CLS", "playwright performance", "render performance" | `references/frontend-performance.md` |
| "find bottleneck", "high TTFB", "slow query", "database performance", "mobile performance", "analyze k6 results", "p95/p99" | `references/triage.md` |

- **K6 Scripting & CI Gates** — Standard SLA thresholds, ramping VUs, dynamic auth in `setup()`, pipeline gating on code 99. (Read `references/k6-scripting.md`)
- **Frontend Performance** — Core Web Vitals targets, Playwright tracing/timing capture, self-contained reports. (Read `references/frontend-performance.md`)
- **Bottleneck Triage & Analysis** — Quick layer isolation, API/Database profiling (EXPLAIN, connection pools), payload/mobile triage. (Read `references/triage.md`)

## Inline Process

1. **Define test scope** — Identify endpoints/flows to test. Include auth, search, file uploads — not just the "main" endpoint. Determine test type: Smoke, Load, Stress, Spike, or Soak.
2. **Write k6 script** — Use `setup()` for dynamic auth → define scenarios with ramping VUs → add `thresholds` block (p95, p99, error_rate) → parameterize test data from CSV/JSON.
3. **Add performance gates** — Thresholds ARE the test: `http_req_duration: ['p(95)<500', 'p(99)<1000']`, `http_req_failed: ['rate<0.01']`. K6 exits code 99 on failure.
4. **Run locally first** — Smoke test with 1-2 VUs to verify script works before scaling.
5. **Integrate into CI** — Configure pipeline with k6 step. Performance gates prevent regressions from reaching production.
6. **Analyze results** — Interpret p95/p99, error rate, throughput. Compare against baseline or SLA targets.
7. **Verify** — Thresholds exist, scenarios use ramping VUs, auth is dynamic, CI configured, results compared against baseline, analysis report produced.

---

## Anti-Rationalization Table

| Excuse to Skip | Counter-Argument |
|---|---|
| "I'll just test the main endpoint — the others are simple" | Bottlenecks hide in unexpected places (auth token refresh, file uploads, search queries). Test all endpoints that users hit in a realistic scenario, not just the "main" one. |
| "I'll use a fixed number of virtual users instead of ramping scenarios" | Fixed VU count doesn't simulate real traffic patterns (ramp-up, sustained, spike). Without scenarios, you can't identify at what load the system degrades. |

---

## Red Flags

- 🚩 Results reported without comparing against baseline → Numbers without context are meaningless; always compare against previous run or SLA targets.
- 🚩 Load test uses hardcoded auth tokens → Tokens expire; use k6's `setup()` function to authenticate dynamically before test execution.

---


## Consistency Contract

> These steps MUST execute in the same order every time this skill runs.
> Output may vary, but the workflow is fixed.
> If any step is skipped, document the skip condition explicitly.

## Verification

Before declaring performance testing complete, confirm:

- [ ] k6 script has `thresholds` block (p95, p99, error_rate)
- [ ] Scenarios use ramping VUs (not fixed count)
- [ ] Auth tokens generated dynamically in `setup()` (not hardcoded)
- [ ] CI pipeline config exists (not just local runs)
- [ ] Results compared against baseline or SLA targets
- [ ] Analysis report produced (p95/p99/error rate/throughput interpreted)


---

## Required Context

| Dependency | Type | Purpose |
|-----------|------|---------|
| k6 / Artillery documentation | Tool reference | Script syntax, scenarios, thresholds |
| Target SLAs (p95, p99, error rate) | Performance criteria | Define pass/fail thresholds |
| Infrastructure specs (server capacity, limits) | System context | Inform realistic load levels |
| `references/*.md` (one per phase) | Skill reference | Scripting, CI integration, analysis |
| `rules/coding.md` & `rules/aodd.md` | Rule | Core engineering principles and verification gates |
| `knowledge/` | Lessons learnt | Check before execute |

Related: when a bottleneck needs falsification-driven root-cause triage (reproduce, trace the failing path, test one hypothesis at a time) go beyond `references/triage.md`'s layer isolation.

## Human-in-the-Loop Points

| Step | Approval Type | When |
|------|--------------|------|
| After test plan (scope + thresholds) | Checkbox (confirm endpoints + SLAs) | Before writing k6 scripts |
| After baseline results | Single select (acceptable / needs tuning / investigate) | After first successful load test run |
| After analysis report | Open field | Before declaring performance testing complete |

**Rule:** At decision points, always present 2-3 options with tradeoffs — never a single answer.

## Self-Update (after every use)

This skill is its own memory. When using it brought a correction, a gotcha,
or a wrong/missing step, and the fix was verified, patch this file in place: a load-model, threshold or tooling pitfall goes in its section; depth to `references/<topic>.md`.
Then bump `version` (patch) and `last_improved`. Procedure: `docs/skill-learning.md`.
