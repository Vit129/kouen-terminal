# Playwright API Testing — Rules

API test automation rules for Playwright: Service Layer architecture, AJV schema validation, mock isolation. Rules and required coding conventions only; no tutorials or templates. Global standards (environment variables, cross-layer fixtures, zero hard wait, locator priority, mandatory tags) live in `rules/playwright/pw-coding-standards.md`.

## Structure

```text
tests/api-testing/
├── tests-api/[system-kebab]/[feature-kebab]/[feature].spec.ts
├── helpers/[system-kebab]/[feature-kebab]/[feature]Helper.ts
├── schemas/[system-kebab]/[feature-kebab]/[feature]Schema.ts
└── fixtures/[system-kebab]/[feature-kebab]/[feature]Data.ts
```

- Folders `kebab-case`, files `camelCase`; shared code in `shared-*` folders; no ID sub-folders.
- One Service per business domain (auth, user, order, …), each taking `APIRequestContext` and owning its endpoints; a feature `[feature]Helper.ts` composes services. A Service knows endpoints; a Helper is a pure utility. Never one monolithic client.
- Specs call helpers and services only; no raw HTTP calls or endpoint strings in a spec.
- Each test is Arrange → Act → Assert, written with `async`/`await`.

## Fixtures and auth

- Extend `test` with fixtures for authenticated clients, one per role; log in once per role (setup project or `globalSetup`) and reuse the token from `process.env` or `storageState`.
- Re-login only when the role or permission differs. For a fail case change the data sent to the API, not the token.
- DB, response-cache and mock fixtures only when project complexity justifies them. Cache only slowly changing reference data.
- Token acquisition stays simple: call the login endpoint, extract the token, store it in `process.env`. No refresh logic, interceptors or middleware.
- Pipeline auth failure → compare with a working project's config before changing auth code. Pipeline credentials come from `.env` only.

## Mocking

- Mock to isolate a test or simulate errors and edge cases (success / error / delay); fall back to a mock only when the real endpoint is down. Wrap repeated `route.fulfill()` in a `mockAPI` fixture instead of repeating boilerplate in specs.

## Assertions and concurrency

- Assert specific things: status code, `content-type` and other headers, body fields, array shape and length. Never `response.ok()` / `toBeTruthy()` as the only check.
- Full-body contract checks use the feature's AJV `*Schema.ts`: request and response schemas, required fields, shared definitions in a shared schema file.
- Timeout → check the endpoint and data first; fix the cause rather than raising the timeout.
- Eventual consistency (a GET right after a POST returns stale data) → predicate waiting (`expect.poll` or retry until the condition holds), never a fixed sleep.
- Race conditions: fire requests with `Promise.all()` (not sequentially), sort the statuses before asserting (you cannot know which request wins), seed in `beforeEach` not `beforeAll`, and use the correct DB isolation level or the test passes while production breaks.
- Response-time assertions (`toBeLessThan(threshold)`) belong in tagged `@Performance` tests, not every functional test. Clock-dependent behaviour uses Playwright's clock mocking.

## package.json scripts (MANDATORY)

- Name: `api:[sit|uat]:[SYSTEM_FEATURE_KEBAB]:[cliMode|guiMode]`, plus `api:sit` and `api:uat`.
- Generate both envs and both modes for every feature. Always `--config=playwright.config.api.ts`, test dir `tests-api/[SYSTEM_KEBAB]/[SYSTEM_FEATURE_KEBAB]/`; cliMode adds `--reporter=list`, guiMode adds `--ui`.
- Prefix every script with `cross-env LANG=en ENV=<sit|uat>` (`npm install -D cross-env`).
