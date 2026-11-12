# Performance Bottleneck Triage & Analysis

Diagnose performance bottlenecks across Backend, Database, Frontend, and Mobile layers.

---

## 1. Triage Workflow

```text
Measure (Baseline) → Isolate Layer (TTFB vs Transfer vs Render) → Profile Root Cause → Remediate → Re-test
```

### Quick Layer Isolation Matrix

| Symptom | Primary Suspect | Triage Action |
|---------|-----------------|---------------|
| High TTFB (> 500ms), low transfer time | Backend / Database | Check slow queries, connection pool, CPU saturation, N+1 queries |
| Low TTFB, high transfer time | Network / Payload | Check payload size, missing compression (gzip/brotli), unpaginated lists |
| Low TTFB, slow LCP / High CLS | Frontend Rendering | Check render-blocking JS/CSS, un-optimized images, heavy DOM reconciliation |
| High latency under concurrent VUs | Concurrency Limit | Check thread pool, DB connection pool limit, row locks |

---

## 2. Backend & Database Triage

### API Response Time Profiling
- Measure per-endpoint timing:
  ```bash
  curl -s -o /dev/null -w "DNS: %{time_namelookup}s | Connect: %{time_connect}s | TTFB: %{time_starttransfer}s | Total: %{time_total}s\n" https://api.example.com/endpoint
  ```
- **TTFB > 500ms:** Request is waiting for backend processing or DB execution.
- **Connect > 100ms:** TLS handshake or network routing latency.

### Database Query Analysis
1. **Identify Slow Queries:** Check queries exceeding SLA (default: > 100ms).
2. **Inspect Execution Plan:**
   - PostgreSQL: `EXPLAIN (ANALYZE, BUFFERS) SELECT ...;`
   - Look for: `Seq Scan` on large tables (missing index), high buffer read times, nested loops with high cost.
3. **Common Database Fixes:**
   - **Missing Index:** Add composite index matching `WHERE` + `ORDER BY` predicates.
   - **Connection Pool Exhaustion:** K6 shows errors spiking under load; increase pool size or tune pool timeout.
   - **Lock Contention:** Long transactions holding exclusive locks; shorten transactions or use optimistic locking.
   - **Table Bloat / Vacuum:** Stale tuples causing sequential scans over dead rows.

---

## 3. Frontend & Network Triage

- **Core Web Vitals Thresholds:**
  - LCP (Largest Contentful Paint) ≤ 2.5s
  - INP (Interaction to Next Paint) ≤ 200ms
  - CLS (Cumulative Layout Shift) ≤ 0.1
- **Payload & Compression:**
  - Verify `Content-Encoding: gzip` or `br` headers on responses > 1KB.
  - Check payload size: APIs returning lists should paginate (limit default ≤ 50 items).
- **Network Waterfall:**
  - Look for sequential request waterfalls (Request B waiting for Request A). Convert to parallel `Promise.all` where independent.

---

## 4. Mobile Performance Triage

| Metric | Target | Warning Threshold |
|--------|--------|-------------------|
| Cold Start | < 1.5s | > 3.0s |
| Warm Start | < 500ms | > 1.0s |
| Frame Rate | 60 fps | < 45 fps (Jank) |
| Active Memory | < 200MB | > 350MB |

- **Startup Bottleneck:** Check third-party SDK initializations on the main application thread. Defer non-critical SDKs.
- **UI Jank:** Expensive computations running on the main UI thread. Offload to background workers.

---

## 5. Load Test Result Analysis (k6)

### Key Metrics Interpretation
- **p(95) / p(99) Latency:** 95% or 99% of requests completed below this duration. Averages lie; percentiles expose tail latency.
- **`http_req_failed` Rate:** Percentage of HTTP requests returning error status (≥ 400). Target: `< 0.01` (< 1%).
- **Throughput (RPS):** Requests per second handled without latency degradation.
- **Degradation Knee:** The point where adding more concurrent users causes throughput to plateau and latency to spike exponentially.
