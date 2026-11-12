# Playwright Code Review

Static code audit checklist — run BEFORE executing tests.
MUST read `rules/playwright/` first to know the full standards.

## When to Use

- After writing/generating test code (before first run)
- After healing loop fixes (verify fix quality)
- PR review for test code changes

## Review Process

Load standards first: `rules/playwright/pw-coding-standards.md` + `api.md` or `web-ui.md` + `rules/data-testid-mapping.md`.
Then follow `rules/coding/review-report.md`'s Code Review Report Format process shape.

## Checklist

### Structure & Naming
- [ ] AAA pattern: `// Arrange`, `// Act`, `// Assert` comments in every test
- [ ] Test names: `test('[TS-xxx] descriptive name')` with scenario ID
- [ ] Tags: `@tag` annotations for filtering (smoke, regression, feature)
- [ ] One spec file per feature/endpoint — not one giant file
- [ ] File naming: `lowerCamelCase.spec.ts` (e.g. `shopeePayment.spec.ts`) — no hyphens

### Locators (Critical)
- [ ] Primary: `getByTestId` for scoping containers
- [ ] Secondary: `getByRole` + `getByLabel` for semantic elements
- [ ] Hybrid: `getByTestId('container').getByRole('button', { name: L.key })`
- [ ] Labels from `Labels.ts` — never hardcoded Thai/English text
- [ ] No CSS selectors, no XPath, no `nth()` without filter
- [ ] No `page.locator('.class-name')` — use semantic locators

### API Tests (if applicable)
- [ ] Request/response types defined
- [ ] Status code assertions: `expect(response.status()).toBe(200)`
- [ ] Response body validation: check required fields, not entire object
- [ ] Auth token handling via fixture or helper — not inline

### Web UI Tests (if applicable)
- [ ] `waitForLoadState` or auto-wait — no `page.waitForTimeout()`
- [ ] No `Sleep` or hardcoded delays
- [ ] Form interactions: fill → verify → submit → assert result
- [ ] Navigation: verify URL or page element after navigation

### Database (if applicable)
- [ ] Seed before test, verify after action, teardown in `afterEach` (or transaction rollback) — not `afterAll`, which lets one test's data pollute the next
- [ ] DB methods in service class — not raw SQL in spec files
- [ ] Connection config from env — not hardcoded

### Performance & Reliability
- [ ] No flaky patterns: no race conditions, no timing-dependent assertions
- [ ] Retry logic for known flaky external dependencies
- [ ] Parallel-safe: tests don't share mutable state
- [ ] Timeout configured per test if needed (not global override)

### Code Quality
- [ ] JSDoc/TSDoc comments on helper functions (Thai description OK)
- [ ] No console.log — use test.info() or custom logger
- [ ] No commented-out code
- [ ] No TODO without ticket reference
- [ ] Import order: playwright → helpers → fixtures → constants

## Review Report Format & Severity Guide

Shared shape across every code-review checklist in this workspace — see
`rules/coding/review-report.md`'s Code Review Report Format (QA column of the severity table).
This file adds only the `Mode: API / Web UI` header line and a `Line` column
(playwright specs are single-file enough that line numbers stay useful).

**Severity criteria specific to Playwright:**

| Severity | Criteria |
|----------|----------|
| 🔴 High | Breaks tests, wrong locator strategy, missing assertions |
| 🟡 Medium | Style violation, missing tags, suboptimal pattern |
| 🟢 Low | Missing comments, import order, naming nitpick |
