# Playwright Testing — Global Coding Standards

## Contents

- [1. Global Standards & Tooling Facts](#1-global-standards--tooling-facts)
- [2. Automation & Execution Strategy](#2-automation--execution-strategy)
- [3. Reference Links](#3-reference-links)

Shared environment, tooling, and architectural facts for Playwright test automation across API and Web UI.

---

## 1. Global Standards & Tooling Facts

### Environment Configuration
- Environment files: `.env`, `.env.local`, `.env.sit`, `.env.uat` (loaded via `dotenv.config({ path: \`.env.\${process.env.ENV || 'sit'}\` })`).
- **Sensitive data (MUST be in `.env`):** credentials, tokens, passwords, secrets, login emails, API keys, OAuth URLs.
- **Non-sensitive business data (MUST be in `.ts` fixture):** `companyCode`, `customerCode`, `invoiceNumber`, `productCode`, user roles.
- `process.env.X` inside fixture files is allowed ONLY for sensitive data. Business data must be hardcoded in fixtures.
- **Double Login Rule:** If a feature requires SSO + project-level auth, SSO credentials/URL go in `.env`; project-level user identifiers go in `fixtures/`.

### Test Data & Fixtures
- Test data files live in `fixtures/[system-kebab]/[feature-kebab]/[featureCamel]Data.ts`.
- **Cross-Layer Shared Fixtures:** Data used across both API and Web UI MUST live in `tests/shared-fixtures/[system-kebab]/[feature-kebab]/` as a single source of truth.
- Dynamic data: Use `Date.now()` or `Math.random()` for dynamic identifiers (reference numbers, unique emails).

### Locators & Wait Rules
- **Zero hard wait (MANDATORY):** `waitForTimeout()` is strictly forbidden. Use Playwright Web-First Assertions (`await expect(...)...`) or explicit wait conditions (`waitForResponse`, `waitForURL`).
- **Locator Priority Order:**
  1. `getByTestId('x')` — scope container or unique element (see `rules/data-testid-mapping.md` for naming rules)
  2. `getByRole('button', { name: L.key })` — buttons, links, headings (using `Labels.ts` for text)
  3. `getByLabel(L.key)` — form controls with associated `<label>`
  4. `getByPlaceholder(L.key)` — inputs without visible label
  5. `locator('css')` — last resort only when semantic locator is impossible. Never use raw XPath or `.nth()` without filter.

### Mandatory Naming & Tags
- **Describe Block:** MUST include `[TS-xxxx]` or `[ID-xxxx]` scenario/feature ID.
  ```typescript
  test.describe('@Critical [TS-0001] User Authentication', () => { ... });
  ```
- **Test Case:** MUST include `[TC-xxxx]` testcase ID prefix.
  ```typescript
  test('[TC-0001] User logs in successfully with valid credentials @Feature @Important @Scenario', async ({ page }) => { ... });
  ```
- **Mandatory Tags:**
  - `@Important`: `Critical` | `High` | `Medium` | `Low`
  - `@Scenario`: `Success` | `Alternative` | `Error`
  - `@Feature`: feature name identifier

### Project Structure & Layer Roles
```
tests/api-testing/
├── tests-api/[system-kebab]/[feature-kebab]/[feature].spec.ts
├── helpers/[system-kebab]/[feature-kebab]/[feature]Helper.ts
├── schemas/[system-kebab]/[feature-kebab]/[feature]Schema.ts
└── fixtures/[system-kebab]/[feature-kebab]/[feature]Data.ts

tests/web-testing/
├── tests-web/[system-kebab]/[feature-kebab]/[feature].spec.ts
├── pages/[system-kebab]/[feature-kebab]/[feature]Page.ts
├── helpers/[system-kebab]/[feature-kebab]/[feature]Helper.ts
├── fixtures/[system-kebab]/[feature-kebab]/[feature]Data.ts
└── fixtures/[system-kebab]/[feature-kebab]/[feature]Labels.ts

tests/shared-fixtures/
└── [system-kebab]/[feature-kebab]/[feature]SharedData.ts
```
- **Terminology:**
  - **Service:** Atomic API callers (`UserService.ts`), single responsibility, returns typed response.
  - **Page:** Encapsulates UI elements and interactions for a page or component (`LoginPage.ts`).
  - **Helper:** Orchestrates multi-step business flows combining services or pages (`CheckoutHelper.ts`).

### Architecture-First for QA
Before writing a suite, declare the layer split: Page Objects (`pages/`), Helpers (`helpers/`), Test Fixtures (`fixtures/`), Test Specs (`tests-*/`). Size target and the no-monolith rule: § Anti-Monolith & Separation Pattern in `rules/coding.md`.

---

## 2. Automation & Execution Strategy

### Priority & Scope
| Priority | API Automation | Web UI Automation | Strategy |
| :--- | :--- | :--- | :--- |
| **Critical** | Mandatory | Mandatory | E2E Full Coverage |
| **High** | Mandatory | Mandatory | Core flows |
| **Medium** | Mandatory | Optional | API first; UI secondary |
| **Low** | Mandatory | Skip | API contract only |

### Hybrid Execution Strategy
- **High-Speed Auth:** Do not perform UI login in every test. Authenticate via API `POST /login`, generate `storageState.json`, and inject into browser context (except for tests verifying the login UI itself).
- **API Setup for UI Tests:** Seed preconditions via API calls before UI execution to keep UI tests atomic, fast, and resilient.
- **Worker-Scoped Fixtures:** For expensive setup (database connection, master data seeding), use `scope: 'worker'` to execute once per Worker.
- **Test Independence:** Every test must manage its own state (create and clean up its data in `afterEach`). Tests must run in parallel without order dependency.

## 3. Reference Links

- 🌐 **Web UI Detailed Rules & Templates:** `rules/playwright/web-ui.md`
- 🔌 **API Detailed Rules & Templates:** `rules/playwright/api.md`
- 🏷️ **data-testid Naming Standard:** `rules/data-testid-mapping.md`

---
- 🧪 **Design-technique test patterns** (Base-Choice, pairwise, state transition, W-method, stateful helpers, security): `rules/playwright/test-patterns.md`
- 🖥️ **`playwright-cli` session continuity:** `rules/playwright/cli-session.md`
