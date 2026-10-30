# K6 Load Testing Standards & CI Gates

Core standards for writing and running k6 load tests with automated CI performance gates.

---

## 1. Hard Standards

1. **Thresholds are Mandatory:** Every k6 script MUST define a `thresholds` block. k6 exits with code 99 if thresholds are breached, automatically failing CI pipelines.
2. **Dynamic Auth in `setup()`:** NEVER hardcode auth tokens. Fetch tokens dynamically inside `setup()` and return them to VU iterations via `data`.
3. **Ramping Scenarios (No Flat VUs):** Always use ramping executors (`ramping-vus` or `ramping-arrival-rate`) to test warm-up, sustained load, and recovery.
4. **Think Time (`sleep`):** Add realistic user think time (`sleep(1)` to `sleep(3)`) between actions. Zero-sleep hammering tests socket exhaustion, not realistic user behavior.

---

## 2. Standard SLA Thresholds

```javascript
export const options = {
  thresholds: {
    // Latency gates (tail latency matters)
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    // Error rate gate (< 1% failed requests)
    http_req_failed: ['rate<0.01'],
    // Custom check success rate (> 99% assertions pass)
    checks: ['rate>0.99'],
  },
}
```

---

## 3. Production Script Template

```javascript
import http from 'k6/http'
import { check, sleep, group } from 'k6'

export const options = {
  scenarios: {
    load_test: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '1m', target: 20 },  // Ramp-up
        { duration: '3m', target: 20 },  // Sustained load
        { duration: '30s', target: 0 },  // Ramp-down
      ],
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    http_req_failed: ['rate<0.01'],
  },
}

// 1. Dynamic Setup (runs once before VUs start)
export function setup() {
  const loginRes = http.post(`${__ENV.BASE_URL}/api/v1/auth/login`, JSON.stringify({
    username: __ENV.AUTH_USER,
    password: __ENV.AUTH_PASSWORD,
  }), {
    headers: { 'Content-Type': 'application/json' },
  })
  check(loginRes, { 'auth successful': (r) => r.status === 200 })
  return { token: loginRes.json('accessToken') }
}

// 2. VU Iteration
export default function (data) {
  const headers = {
    Authorization: `Bearer ${data.token}`,
    'Content-Type': 'application/json',
  }

  group('User Flow', () => {
    const res = http.get(`${__ENV.BASE_URL}/api/v1/items`, { headers })
    check(res, {
      'status is 200': (r) => r.status === 200,
      'response time < 500ms': (r) => r.timings.duration < 500,
    })
  })

  sleep(1) // Think time
}
```

---

## 4. CI/CD Performance Gates

k6 returns exit code 99 when any threshold fails. Configure CI to block the pipeline on non-zero exit:

### GitHub Actions
```yaml
- name: Run K6 Performance Test
  run: k6 run --out json=k6-results.json tests/performance/load-test.js
  env:
    BASE_URL: ${{ vars.SIT_BASE_URL }}
    AUTH_USER: ${{ secrets.PERF_USER }}
    AUTH_PASSWORD: ${{ secrets.PERF_PASSWORD }}
```

### Azure DevOps
```yaml
- script: k6 run --out json=$(Build.ArtifactStagingDirectory)/k6-results.json tests/performance/load-test.js
  displayName: "Run K6 Load Tests"
  env:
    BASE_URL: $(SIT_BASE_URL)
    AUTH_USER: $(PERF_USER)
    AUTH_PASSWORD: $(PERF_PASSWORD)
  continueOnError: false  # BLOCKS pipeline on threshold failure (code 99)
```
