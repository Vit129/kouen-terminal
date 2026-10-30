# Fix Generated Playwright Files (Postman Migration)

This reference guide provides the exact patterns and "Gems" to use when AI generates Playwright code from collection.md (or when fixing existing generated files).

---

## 1. URL & Variables Mapping

Postman uses `{{variable}}` syntax, which must be converted to Template Literals using `process.env`.

| Pattern | Postman Style | Playwright Standard (Fix to this) |
| :--- | :--- | :--- |
| **URL** | `{{baseUrl}}/api/v1/users` | `` `${process.env['BASE_URL']}/api/v1/users` `` |
| **Query Param** | `?id={{userId}}` | `` `?id=${process.env['USER_ID']}` `` |
| **Path Param** | `/accounts/{{id}}` | `` `/accounts/${process.env['ID']}` `` |

**⚠️ AI Mandate:** Always check if the variable name in `process.env` should be `SCREAMING_SNAKE_CASE` per `rules/playwright/`.

---

## 2. Authentication Gems 🔐

Script 3 might miss inherited Auth from Postman folders. AI must ensure every request has proper authentication.

### Standard Bearer Token Fix
```typescript
// ❌ Generated (Missing Auth)
const response = await request.get(url.toString(), { headers: dynamicHeaders });

// ✅ Fixed Standard
const response = await request.get(url.toString(), {
  headers: {
    ...dynamicHeaders,
    'Authorization': `Bearer ${process.env['ACCESS_TOKEN']}`,
  }
});
```

### Standard Basic Auth Fix
```typescript
const authBuffer = Buffer.from(`${process.env['USERNAME']}:${process.env['PASSWORD']}`).toString('base64');
const response = await request.get(url.toString(), {
  headers: {
    ...dynamicHeaders,
    'Authorization': `Basic ${authBuffer}`,
  }
});
```

---

## 3. Response Handling & Parsing 🔍

Ensure response bodies are parsed correctly before assertions.

```typescript
// ━━━ 🔍 Response Parse ━━━
const contentType = response.headers()['content-type'] || '';
let responseJson: any;

if (contentType.includes('application/json')) {
  responseJson = await response.json();
} else {
  const responseText = await response.text();
  // Handle text or throw error if JSON was expected
}
```

---

## 4. Assertions Mapping Cheat Sheet ✅

| Postman (pm.*) | Playwright Standard (expect.*) |
| :--- | :--- |
| `pm.response.to.have.status(200)` | `expect(response.status()).toBe(200)` |
| `pm.response.to.be.success` | `expect(response.ok()).toBe(true)` |
| `pm.expect(res.id).to.eql(1)` | `expect(res.id).toEqual(1)` |
| `pm.expect(res.name).to.be.a('string')` | `expect(typeof res.name).toBe('string')` |
| `pm.expect(res.tags).to.include('new')` | `expect(res.tags).toContain('new')` |
| `pm.expect(res).to.have.property('id')` | `expect(res).toHaveProperty('id')` |

---

## 5. Complex Logic & Workflow "Gems" 💎

### Polling (Replacement for `setNextRequest` to self)
If a request polls for a status (e.g., waiting for an invoice to be 'PAID'), use `expect.poll`.

```typescript
// 💎 Polling Gem
await expect.poll(async () => {
  const res = await request.get(`${process.env['BASE_URL']}/api/status/${id}`, {
    headers: { 'Authorization': `Bearer ${process.env['ACCESS_TOKEN']}` }
  });
  const body = await res.json();
  return body.status;
}, {
  message: 'Wait for status to be PAID',
  intervals: [2000, 5000, 10000], // Exponential backoff
  timeout: 60000,
}).toBe('PAID');
```

### Date Manipulation (Replacement for Moment.js)
```typescript
// 💎 Native Date Gem (Replace Moment.js)
const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
const nextWeek = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
```

---

## 6. Schema Validation (AJV Gem) 📦

Instead of checking field-by-field, validate the entire contract.

```typescript
import { validateSchema } from '../../helpers/schema.validator';
import { userSchema } from '../../schemas/user/userSchema';

// 💎 AJV Contract Gem
const body = await response.json();
validateSchema(body, userSchema);
```

---

## 7. Variable Persistence (State Store)

If Postman uses `pm.environment.set` to pass data between requests, use a global `stateStore` for parallel safety.

```typescript
// ⚠️ Parallel Risk Fix
const stateStore = (global as any).__stateStore ??= {};
stateStore['sharedId'] = responseJson.id;

// Use in next test
const id = stateStore['sharedId'];
```

**Variable scope mapping:**

| Postman | Scope | Playwright Equivalent |
|---------|-------|-----------------------|
| `pm.environment.set/get('key')` | Current environment | `stateStore['key']` |
| `pm.variables.set/get('key')` | Collection run (local) | `stateStore['key']` (same — scoped to run) |
| `pm.globals.set/get('key')` | Across all collections | `(global as any)['key']` directly (true global) |

---

## 8. pm.sendRequest() → async/await 🔄

Generated files with `// ⚡ [CPS→ASYNC]` warnings need manual conversion.

```typescript
// ❌ Postman (CPS callback style)
pm.sendRequest({
  url: pm.environment.get('baseUrl') + '/auth/token',
  method: 'POST',
  header: { 'Content-Type': 'application/json' },
  body: { mode: 'raw', raw: JSON.stringify({ clientId: pm.environment.get('clientId') }) }
}, (err, res) => {
  pm.environment.set('accessToken', res.json().token);
});

// ✅ Playwright (async/await)
const tokenRes = await request.post(`${process.env['BASE_URL']}/auth/token`, {
  headers: { 'Content-Type': 'application/json' },
  data: { clientId: process.env['CLIENT_ID'] },
});
const { token } = await tokenRes.json();
const stateStore = (global as any).__stateStore ??= {};
stateStore['accessToken'] = token;
```

> ⚠️ Files marked `// ⚠️ [MANUAL]` are too complex for auto-conversion — review logic and rewrite manually.

---

## 9. pm.test() → test.step() 🧪

Postman inline test blocks map to Playwright `test.step()` for named grouping.

```typescript
// ❌ Postman
pm.test('Status code is 200', () => {
  pm.response.to.have.status(200);
});

pm.test('Response has userId', () => {
  const json = pm.response.json();
  pm.expect(json).to.have.property('userId');
});

// ✅ Playwright
await test.step('Status code is 200', () => {
  expect(response.status()).toBe(200);
});

await test.step('Response has userId', () => {
  expect(responseJson).toHaveProperty('userId');
});
```

---

## 10. Request Body Types 📦

| Postman Body Mode | Playwright Equivalent |
|-------------------|-----------------------|
| `raw` (JSON) | `data: { key: value }` or `data: JSON.stringify({})` with `Content-Type: application/json` |
| `form-data` | `multipart: { field: 'value', file: { name, mimeType, buffer } }` |
| `x-www-form-urlencoded` | `form: { key: 'value' }` |
| `raw` (plain text) | `data: 'text'` with `Content-Type: text/plain` |
| `binary` | `data: buffer` with appropriate `Content-Type` |

```typescript
// form-data (multipart)
const response = await request.post(`${process.env['BASE_URL']}/api/upload`, {
  headers: { 'Authorization': `Bearer ${process.env['ACCESS_TOKEN']}` },
  multipart: {
    userId: '123',
    file: {
      name: 'document.pdf',
      mimeType: 'application/pdf',
      buffer: Buffer.from('...'),
    },
  },
});

// x-www-form-urlencoded
const response = await request.post(`${process.env['BASE_URL']}/api/login`, {
  form: {
    username: process.env['USERNAME']!,
    password: process.env['PASSWORD']!,
  },
});
```

---

## 11. Response Headers 📋

```typescript
// ❌ Postman
const token = pm.response.headers.get('x-auth-token');

// ✅ Playwright
const headers = response.headers();
const token = headers['x-auth-token'];

// Common use case — capture token from response header into stateStore
const stateStore = (global as any).__stateStore ??= {};
stateStore['authToken'] = response.headers()['x-auth-token'];
```

---

## 12. Path Parameters & Query Parameters 🔗

### Path Parameters
Path params come from runtime values (stateStore) — not `process.env`.

```typescript
// ❌ Postman
GET /api/v1/accounts/{{userId}}/orders/{{orderId}}

// ✅ Playwright — runtime value from stateStore
const stateStore = (global as any).__stateStore ??= {};
const url = `${process.env['BASE_URL']}/api/v1/accounts/${stateStore['userId']}/orders/${stateStore['orderId']}`;
const response = await request.get(url, {
  headers: { 'Authorization': `Bearer ${process.env['ACCESS_TOKEN']}` },
});
```

### Query Parameters
Use `params` option — Playwright handles encoding automatically.

```typescript
// ❌ Postman
GET /api/v1/products?page={{page}}&size={{size}}&status=ACTIVE

// ✅ Playwright — use params object (auto URL-encoded)
const response = await request.get(`${process.env['BASE_URL']}/api/v1/products`, {
  headers: { 'Authorization': `Bearer ${process.env['ACCESS_TOKEN']}` },
  params: {
    page: 1,
    size: 20,
    status: 'ACTIVE',
  },
});

// ✅ With runtime value from stateStore
params: {
  categoryId: stateStore['categoryId'],
  page: 1,
}
```

---

## 13. Postman Dynamic Variables 🎲

| Postman Dynamic Variable | Playwright Equivalent |
|---|---|
| `{{$randomInt}}` | `Math.floor(Math.random() * 1000)` |
| `{{$randomFloat}}` | `Math.random() * 100` |
| `{{$guid}}` | `crypto.randomUUID()` |
| `{{$timestamp}}` | `Math.floor(Date.now() / 1000)` (Unix seconds) |
| `{{$isoTimestamp}}` | `new Date().toISOString()` |
| `{{$randomFirstName}}` | `['Alice', 'Bob', 'Charlie'][Math.floor(Math.random() * 3)]` or use `@faker-js/faker` |
| `{{$randomEmail}}` | `` `test_${Date.now()}@example.com` `` or `faker.internet.email()` |
| `{{$randomPhoneNumber}}` | `faker.phone.number()` |
| `{{$randomBoolean}}` | `Math.random() > 0.5` |

```typescript
// 💎 Faker Gem — install: npm i -D @faker-js/faker
import { faker } from '@faker-js/faker';

const payload = {
  id:        crypto.randomUUID(),
  name:      faker.person.fullName(),
  email:     faker.internet.email(),
  phone:     faker.phone.number(),
  createdAt: new Date().toISOString(),
};
```

---

## 14. Folder-level Auth Inheritance 🔐

Postman allows auth set on a folder to be inherited by all child requests. In Playwright, centralize auth in `beforeAll` or a shared helper.

```typescript
// ❌ Postman — folder "Orders" has Bearer auth, all 10 requests inside inherit it

// ✅ Playwright — centralize in beforeAll, add to every request via helper
import { test, expect, APIRequestContext } from '@playwright/test';

let authHeaders: Record<string, string>;

test.beforeAll(async ({ request }) => {
  // fetch token once for the entire describe block
  const res = await request.post(`${process.env['BASE_URL']}/auth/token`, {
    data: { clientId: process.env['CLIENT_ID'], clientSecret: process.env['CLIENT_SECRET'] },
  });
  const { accessToken } = await res.json();
  authHeaders = { 'Authorization': `Bearer ${accessToken}` };
});

test('GET order list', async ({ request }) => {
  const response = await request.get(`${process.env['BASE_URL']}/api/orders`, {
    headers: authHeaders,
  });
  expect(response.status()).toBe(200);
});
```

---

## 15. Folder-level Pre-request Script → beforeAll / beforeEach 🔧

| Postman Script Location | Playwright Equivalent |
|---|---|
| Collection Pre-request Script | `test.beforeAll()` in root fixture or `playwright.config.ts` globalSetup |
| Folder Pre-request Script (runs once per folder) | `test.beforeAll()` inside `test.describe()` |
| Request Pre-request Script (runs before each request) | `test.beforeEach()` or inline setup inside test |
| Collection Test Script | `test.afterAll()` in root fixture |
| Folder Test Script | `test.afterAll()` inside `test.describe()` |
| Request Test Script | assertions inside the `test()` body |

```typescript
// ❌ Postman — Folder "Payments" Pre-request Script
// pm.environment.set('idempotencyKey', pm.variables.replaceIn('{{$guid}}'));

// ✅ Playwright
test.describe('Payments', () => {
  let idempotencyKey: string;

  test.beforeEach(() => {
    idempotencyKey = crypto.randomUUID(); // fresh key per request
  });

  test('POST create payment', async ({ request }) => {
    const response = await request.post(`${process.env['BASE_URL']}/api/payments`, {
      headers: {
        'Authorization': `Bearer ${process.env['ACCESS_TOKEN']}`,
        'Idempotency-Key': idempotencyKey,
      },
      data: { amount: 100, currency: 'THB' },
    });
    expect(response.status()).toBe(201);
  });
});
```

---

## 16. Nested Folders → File Structure 📁

Postman allows folders nested 3–4 levels deep. Map to Playwright file structure as follows:

```
Postman Collection: "iuser-convert"
├── 📁 Auth                        → tests-api/iuser-convert/auth/
│   ├── POST Login                 →   auth.spec.ts (test inside)
│   └── POST Refresh Token         →   auth.spec.ts (test inside)
├── 📁 Orders                      → tests-api/iuser-convert/orders/
│   ├── 📁 Create                  →   helpers/orders/CreateService.ts
│   │   └── POST Create Order      →   orders.spec.ts (test inside)
│   └── 📁 Query                   →   helpers/orders/QueryService.ts
│       ├── GET Order by ID        →   orders.spec.ts (test inside)
│       └── GET Order List         →   orders.spec.ts (test inside)
```

**Rules:**
- Top-level Postman folder → 1 spec file + 1 helper file
- Sub-folder → 1 `*Service.ts` per sub-folder (already handled by Script 3)
- Sub-sub-folder → flatten into parent service, add comment `// Sub: <name>`
- Request order within folder → preserve as `test()` order inside `test.describe.serial()`

---

## 17. Collection Runner + Data File (Data-Driven) 📊

Postman Collection Runner accepts CSV/JSON to iterate requests with different data sets. Map to Playwright fixtures.

```typescript
// ❌ Postman — Collection Runner with data.csv
// userId, amount, expectedStatus
// 101, 500, 200
// 102, 0, 400
// 103, 99999, 422

// ✅ Playwright — fixtures/orders/ordersData.ts
export const createOrderCases = [
  { userId: '101', amount: 500,   expectedStatus: 200 },
  { userId: '102', amount: 0,     expectedStatus: 400 },
  { userId: '103', amount: 99999, expectedStatus: 422 },
];

// ordersSpec.ts
import { createOrderCases } from '../../fixtures/orders/ordersData';

for (const tc of createOrderCases) {
  test(`POST create order — userId:${tc.userId} amount:${tc.amount}`, async ({ request }) => {
    const response = await request.post(`${process.env['BASE_URL']}/api/orders`, {
      headers: { 'Authorization': `Bearer ${process.env['ACCESS_TOKEN']}` },
      data: { userId: tc.userId, amount: tc.amount },
    });
    expect(response.status()).toBe(tc.expectedStatus);
  });
}
```

---

## 18. setNextRequest → Flow Control ⚡

`pm.setNextRequest()` controls which request runs next (or skips). Map to `test.describe.serial` + `test.skip`.

```typescript
// ❌ Postman
// In "POST Create Order" test script:
if (pm.response.code !== 201) {
  pm.setNextRequest(null); // stop the run
}

// ✅ Playwright — use serial + conditional skip via stateStore flag
test.describe.serial('Order Flow', () => {
  test('POST Create Order', async ({ request }) => {
    const response = await request.post(`${process.env['BASE_URL']}/api/orders`, {
      headers: { 'Authorization': `Bearer ${process.env['ACCESS_TOKEN']}` },
      data: { amount: 100 },
    });
    const stateStore = (global as any).__stateStore ??= {};
    if (response.status() !== 201) {
      stateStore['orderFlowFailed'] = true;
    }
    stateStore['orderId'] = (await response.json()).id;
    expect(response.status()).toBe(201);
  });

  test('GET Order by ID', async ({ request }) => {
    const stateStore = (global as any).__stateStore ??= {};
    test.skip(!!stateStore['orderFlowFailed'], 'Skipped — previous step failed');
    const response = await request.get(
      `${process.env['BASE_URL']}/api/orders/${stateStore['orderId']}`,
      { headers: { 'Authorization': `Bearer ${process.env['ACCESS_TOKEN']}` } },
    );
    expect(response.status()).toBe(200);
  });
});
```

---

## 19. Extended Assertions (Chai → Playwright) ✅

Extended mapping beyond Section 4 for less common Chai assertions.

| Postman (Chai/pm.expect) | Playwright (expect) |
|---|---|
| `pm.expect(res).to.be.an('array')` | `expect(Array.isArray(res)).toBe(true)` |
| `pm.expect(res).to.have.lengthOf(3)` | `expect(res).toHaveLength(3)` |
| `pm.expect(res).to.be.null` | `expect(res).toBeNull()` |
| `pm.expect(res).to.be.undefined` | `expect(res).toBeUndefined()` |
| `pm.expect(res).to.be.true` | `expect(res).toBe(true)` |
| `pm.expect(res).to.be.above(0)` | `expect(res).toBeGreaterThan(0)` |
| `pm.expect(res).to.be.below(100)` | `expect(res).toBeLessThan(100)` |
| `pm.expect(res).to.be.at.least(1)` | `expect(res).toBeGreaterThanOrEqual(1)` |
| `pm.expect(res).to.be.at.most(99)` | `expect(res).toBeLessThanOrEqual(99)` |
| `pm.expect(res.name).to.be.empty` | `expect(res.name).toBe('')` or `expect(res.name).toHaveLength(0)` |
| `pm.expect(res).to.match(/^[A-Z]+$/)` | `expect(res).toMatch(/^[A-Z]+$/)` |
| `pm.expect(res).to.not.be.null` | `expect(res).not.toBeNull()` |
| `pm.expect(res).to.deep.equal({a:1})` | `expect(res).toEqual({ a: 1 })` |
| `pm.response.to.have.header('Content-Type')` | `expect(response.headers()['content-type']).toBeDefined()` |
| `pm.response.to.have.header('Content-Type', 'application/json')` | `expect(response.headers()['content-type']).toContain('application/json')` |
| `pm.response.to.be.json` | `expect(response.headers()['content-type']).toContain('application/json')` |
| `pm.response.responseTime < 500` | `// Not directly supported — use Date.now() delta` |

```typescript
// 💎 Response time measurement (no direct Postman equivalent)
const start = Date.now();
const response = await request.get(url, { headers });
const elapsed = Date.now() - start;
expect(elapsed).toBeLessThan(500); // assert under 500ms
```

---

## 20. Multiple Environments (SIT / UAT) 🌍

Postman manages environments via the Environment dropdown. Playwright uses `.env` files per environment.

```
Postman:                          Playwright:
├── Environment: SIT      →       .env.sit
├── Environment: UAT      →       .env.uat
└── Environment: PROD     →       .env.prod (optional)
```

```bash
# .env.sit
BASE_URL=https://api-sit.example.com
ACCESS_TOKEN=sit-token-here
CLIENT_ID=sit-client-id

# .env.uat
BASE_URL=https://api-uat.example.com
ACCESS_TOKEN=uat-token-here
CLIENT_ID=uat-client-id
```

```typescript
// playwright.config.ts — load env by ENV flag
import { defineConfig } from '@playwright/test';
import dotenv from 'dotenv';

dotenv.config({ path: `.env.${process.env['ENV'] ?? 'sit'}` });

export default defineConfig({ /* ... */ });
```

```bash
# Run against SIT (default)
npx cross-env ENV=sit npx playwright test

# Run against UAT
npx cross-env ENV=uat npx playwright test
```

---

## 21. OAuth 2.0 Authentication 🔑

### Client Credentials Grant (most common in API testing)
```typescript
// ❌ Postman — OAuth 2.0 tab: Client Credentials
// Grant Type: Client Credentials
// Token URL: {{authUrl}}/oauth/token
// Client ID: {{clientId}}, Client Secret: {{clientSecret}}

// ✅ Playwright — fetch token in beforeAll, reuse across tests
let accessToken: string;

test.beforeAll(async ({ request }) => {
  const res = await request.post(`${process.env['AUTH_URL']}/oauth/token`, {
    form: {
      grant_type:    'client_credentials',
      client_id:     process.env['CLIENT_ID']!,
      client_secret: process.env['CLIENT_SECRET']!,
      scope:         process.env['OAUTH_SCOPE'] ?? '',
    },
  });
  expect(res.status()).toBe(200);
  const body = await res.json();
  accessToken = body.access_token;
});

test('GET protected resource', async ({ request }) => {
  const response = await request.get(`${process.env['BASE_URL']}/api/resource`, {
    headers: { 'Authorization': `Bearer ${accessToken}` },
  });
  expect(response.status()).toBe(200);
});
```

### Authorization Code Grant (user-facing, use stateStore for token)
```typescript
// Fetch token once via API, store in stateStore for use across describe blocks
test.beforeAll(async ({ request }) => {
  const res = await request.post(`${process.env['AUTH_URL']}/oauth/token`, {
    form: {
      grant_type:   'authorization_code',
      code:         process.env['AUTH_CODE']!,
      redirect_uri: process.env['REDIRECT_URI']!,
      client_id:    process.env['CLIENT_ID']!,
    },
  });
  const { access_token, refresh_token } = await res.json();
  const stateStore = (global as any).__stateStore ??= {};
  stateStore['accessToken']  = access_token;
  stateStore['refreshToken'] = refresh_token;
});
```

---

## 22. API Key Authentication 🗝️

Postman supports API Key in header or query param.

```typescript
// ❌ Postman — Auth tab: API Key
// Key: x-api-key, Value: {{apiKey}}, Add to: Header

// ✅ Playwright — Header
const response = await request.get(`${process.env['BASE_URL']}/api/data`, {
  headers: {
    'x-api-key': process.env['API_KEY']!,
  },
});

// ✅ Playwright — Query Param
const response = await request.get(`${process.env['BASE_URL']}/api/data`, {
  params: { api_key: process.env['API_KEY']! },
});
```

---

## 23. Client Certificate (mTLS) 🔒

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';
import fs from 'fs';

export default defineConfig({
  use: {
    clientCertificates: [{
      origin: process.env['BASE_URL']!,
      certPath: './certs/client.crt',
      keyPath:  './certs/client.key',
      passphrase: process.env['CERT_PASSPHRASE'],
    }],
  },
});

// Or per-request (APIRequestContext level only via config)
// Note: Playwright does not support per-request cert override —
// configure at project level in playwright.config.ts
```

---

## 24. Request Options: Timeout / SSL / Redirects ⚙️

| Postman Setting | Playwright Equivalent |
|---|---|
| Request Timeout | `timeout` option in request call |
| Disable SSL certificate verification | `ignoreHTTPSErrors: true` in config or request |
| Follow redirects (on/off) | `maxRedirects` option |

```typescript
// Timeout per request
const response = await request.get(`${process.env['BASE_URL']}/api/slow-endpoint`, {
  headers: { 'Authorization': `Bearer ${process.env['ACCESS_TOKEN']}` },
  timeout: 30_000, // 30 seconds
});

// Disable SSL verification (per request context)
// playwright.config.ts
export default defineConfig({
  use: { ignoreHTTPSErrors: true },
});

// Disable redirect following
const response = await request.post(`${process.env['BASE_URL']}/api/login`, {
  data: { username: 'user', password: 'pass' },
  maxRedirects: 0, // do not follow redirects — useful for testing 301/302
});
expect(response.status()).toBe(302);
expect(response.headers()['location']).toContain('/dashboard');
```

---

## 25. Pre-request Script: Modify Request Dynamically 🔧

```typescript
// ❌ Postman Pre-request Script
pm.request.addHeader({ key: 'X-Trace-Id', value: pm.variables.replaceIn('{{$guid}}') });
pm.request.body.update(JSON.stringify({ ...JSON.parse(pm.request.body.raw), timestamp: Date.now() }));

// ✅ Playwright — build headers and body before calling request
const traceId  = crypto.randomUUID();
const payload  = {
  userId:    stateStore['userId'],
  amount:    100,
  timestamp: Date.now(),
};

const response = await request.post(`${process.env['BASE_URL']}/api/orders`, {
  headers: {
    'Authorization': `Bearer ${process.env['ACCESS_TOKEN']}`,
    'X-Trace-Id':   traceId,
    'X-Request-Id': crypto.randomUUID(),
  },
  data: payload,
});
```

---

## 26. Custom Assertion Function (pm.expect.satisfy) ✅

```typescript
// ❌ Postman
pm.expect(responseJson.score).to.satisfy((val: number) => val >= 0 && val <= 100);

// ✅ Playwright — use expect with custom condition
expect(responseJson.score).toBeGreaterThanOrEqual(0);
expect(responseJson.score).toBeLessThanOrEqual(100);

// ✅ Or inline with custom message
expect(
  responseJson.score >= 0 && responseJson.score <= 100,
  `score ${responseJson.score} must be between 0 and 100`
).toBe(true);
```

---

## 27. pm.info — Request Metadata 📋

```typescript
// ❌ Postman
pm.info.requestName   // → name of current request
pm.info.iteration     // → current iteration index (0-based) in Collection Runner
pm.info.iterationCount // → total iterations

// ✅ Playwright — no direct equivalent; use test title and loop index
for (const [index, tc] of testCases.entries()) {
  test(`[${index + 1}/${testCases.length}] ${tc.name}`, async ({ request }) => {
    // index = pm.info.iteration equivalent
    // test title = pm.info.requestName equivalent
  });
}
```

---

## 28. Cookie Management (pm.cookies) 🍪

```typescript
// ❌ Postman
const sessionCookie = pm.cookies.get('session_id');
pm.cookies.set('session_id', 'abc123');

// ✅ Playwright — use storageState to persist cookies across requests
// Capture cookies from login response
const loginRes = await request.post(`${process.env['BASE_URL']}/auth/login`, {
  data: { username: process.env['USERNAME'], password: process.env['PASSWORD'] },
});

// Save storage state (cookies + localStorage) to file
await (request as any).storageState({ path: 'auth.json' });

// Reuse cookies in next context
// playwright.config.ts
export default defineConfig({
  use: { storageState: 'auth.json' },
});

// ✅ Or read Set-Cookie header manually
const setCookie = loginRes.headers()['set-cookie'];
const sessionId = setCookie?.match(/session_id=([^;]+)/)?.[1];
const stateStore = (global as any).__stateStore ??= {};
stateStore['sessionId'] = sessionId;

// Pass cookie in subsequent requests
const response = await request.get(`${process.env['BASE_URL']}/api/profile`, {
  headers: {
    'Cookie': `session_id=${stateStore['sessionId']}`,
  },
});
```

---

## 29. GraphQL Requests 📡

Postman has a dedicated GraphQL request type. In Playwright, send as standard POST with JSON body.

```typescript
// ❌ Postman — GraphQL request type
// Query:
// query GetUser($id: ID!) {
//   user(id: $id) { id name email }
// }
// Variables: { "id": "{{userId}}" }

// ✅ Playwright — POST with GraphQL body
const stateStore = (global as any).__stateStore ??= {};

const response = await request.post(`${process.env['GRAPHQL_URL']}`, {
  headers: {
    'Authorization': `Bearer ${process.env['ACCESS_TOKEN']}`,
    'Content-Type':  'application/json',
  },
  data: {
    query: `
      query GetUser($id: ID!) {
        user(id: $id) {
          id
          name
          email
        }
      }
    `,
    variables: { id: stateStore['userId'] },
  },
});

expect(response.status()).toBe(200);
const { data, errors } = await response.json();
expect(errors).toBeUndefined();
expect(data.user).toHaveProperty('id', stateStore['userId']);
```

### GraphQL Mutation
```typescript
const response = await request.post(`${process.env['GRAPHQL_URL']}`, {
  headers: {
    'Authorization': `Bearer ${process.env['ACCESS_TOKEN']}`,
    'Content-Type':  'application/json',
  },
  data: {
    query: `
      mutation CreateOrder($input: OrderInput!) {
        createOrder(input: $input) { id status }
      }
    `,
    variables: { input: { userId: stateStore['userId'], amount: 100 } },
  },
});
const { data } = await response.json();
stateStore['orderId'] = data.createOrder.id;
expect(data.createOrder.status).toBe('PENDING');
```

---

## 30. WebSocket ⚡

> ⚠️ **`// ⚠️ [MANUAL]`** — Script 3 cannot auto-convert WebSocket requests. These require manual implementation.

Postman supports WebSocket (ws://) connections. Playwright does not have a built-in WebSocket client for API testing — use the `ws` npm package.

```typescript
// npm i -D ws @types/ws
import WebSocket from 'ws';

test('WebSocket — receive order status update', async () => {
  await new Promise<void>((resolve, reject) => {
    const ws = new WebSocket(`${process.env['WS_URL']}/orders/stream`, {
      headers: { 'Authorization': `Bearer ${process.env['ACCESS_TOKEN']}` },
    });

    ws.on('open', () => {
      ws.send(JSON.stringify({ action: 'subscribe', orderId: '12345' }));
    });

    ws.on('message', (data) => {
      const msg = JSON.parse(data.toString());
      expect(msg).toHaveProperty('status');
      expect(['PENDING', 'PROCESSING', 'COMPLETED']).toContain(msg.status);
      ws.close();
      resolve();
    });

    ws.on('error', reject);
    setTimeout(() => reject(new Error('WebSocket timeout')), 10_000);
  });
});
```


---

## 31. Collection Variables with eval() 🧮

Postman uses `eval(pm.collectionVariables.get('fnName'))` to load reusable functions stored as collection variables. Script 3 converts these to `CollectionHelpers` class methods.

```typescript
// ❌ Postman — eval pattern
var verifyError = eval(pm.collectionVariables.get('verifyErrorMessage'));
verifyError(jsonData, "Invalid data", "Invalid data");

// ✅ Playwright — CollectionHelpers class
import { CollectionHelpers } from '../helpers/CollectionHelpers';

// Call directly
CollectionHelpers.verifyErrorMessage(responseJson, "Invalid data", "Invalid data");
```

### Creating the CollectionHelpers class

Script 3 generates `// 📌 CollectionHelpers.xxx()` comments. AI must create the actual class from the raw Postman logic in the collection `.md` file (Section `🧰 Function Variables → Playwright Helpers`).

```typescript
// helpers/<collection>/CollectionHelpers.ts
import { expect } from '@playwright/test';

export class CollectionHelpers {

  static verifyErrorMessage(responseJson: any, expectedTH: string, expectedEN: string) {
    expect(responseJson.success).toBe(false);
    expect(responseJson.result).toBeNull();
    const lang = process.env['lang'] || 'th-TH';
    if (lang === 'th-TH') {
      expect(responseJson.errorMessage).toEqual(expectedTH);
    } else {
      expect(responseJson.errorMessage).toEqual(expectedEN);
    }
    expect(responseJson.traceId).toBeDefined();
  }

  static verifySuccessMessage(responseJson: any) {
    expect(responseJson.success).toBe(true);
    expect(responseJson.errorMessage).toBeNull();
  }

  static verifyResultMessage(responseJson: any, expectedResult: any) {
    expect(responseJson.success).toBe(true);
    expect(responseJson.result).toEqual(expectedResult);
  }

  static verifyObjectFn(responseJson: any, expectedObj: Record<string, any>) {
    for (const [key, value] of Object.entries(expectedObj)) {
      expect(responseJson.result).toHaveProperty(key, value);
    }
  }

  static async deleteUserFn(request: any, keyword: string) {
    const url = `${process.env['user-service-url']}/AMFW01000/delete?keyword=${keyword}`;
    const response = await request.delete(url, {
      headers: {
        'Authorization': `Bearer ${process.env['accessToken']}`,
        'Accept-Language': process.env['lang'] || 'th-TH',
      },
    });
    expect(response.status()).toBe(200);
  }
}
```

### Common eval patterns from iuser-convert collection

| Postman eval variable | CollectionHelpers method | Purpose |
|---|---|---|
| `verifyErrorMessage` | `CollectionHelpers.verifyErrorMessage(json, thMsg, enMsg)` | Assert error response (success=false, errorMessage matches lang) |
| `verifySuccessMessage` | `CollectionHelpers.verifySuccessMessage(json)` | Assert success=true, no error |
| `verifyResultMessage` | `CollectionHelpers.verifyResultMessage(json, expected)` | Assert success + result matches |
| `verifyObjectFn` | `CollectionHelpers.verifyObjectFn(json, expectedObj)` | Deep property check on result |
| `deleteUserFn` | `CollectionHelpers.deleteUserFn(request, keyword)` | Cleanup — delete test user by keyword |

> AI should read the `🧰 Function Variables` section in the collection `.md` to get the raw Postman logic, then convert each to a static method in `CollectionHelpers`.

---

## 32. Knowledge Check (Before Generating) 🧠

Before generating code for each folder, check the project's `knowledge/` notes for postman-related lessons learned from previous migrations. Apply known fixes proactively instead of waiting for failures.

### What to check

- `knowledge/` — scan for entries with keywords: postman, playwright, migration, stateStore, auth, collection
- This migration's own `progress.md` (see SKILL.md § Gotchas → Progress tracking) — check for in-progress migration context from a prior session

### Known lessons to apply (examples)

| Lesson | Pattern | Fix |
|--------|---------|-----|
| Filename collision | `toCamelCase` strips numbers → duplicate filenames | Use `toKebabCase` for unique filenames |
| stateStore vs process.env | `pm.environment.set()` at runtime | Always use `stateStore`, never `process.env` for runtime values |
| Auth inheritance | Folder-level auth invisible in request JSON | Check `resolveAuth` chain in collection.md |
| pm.sendRequest CPS | Callback pattern in pre-request scripts | Convert to `await request.fetch()` async |
| Interactive prompt hang | Multiple folders in `tests-api/` | Use `--folder` or `--output` flag to skip prompt |

### When to check

- Once at migration start (Step 2.5 — before designing structure)
- Once per folder (Step 3 — before generating code)
- After test failures (Step 4 — check if lesson already exists before debugging)

> 💡 If a new pattern/fix is discovered during migration, patch it into this skill (`references/postman-migration.md` or this file) for future migrations.
