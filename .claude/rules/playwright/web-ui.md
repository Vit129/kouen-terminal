# Playwright Web UI Testing — Rules

Web UI test automation rules for Playwright: Page Object Model, locator strategy, synchronization. Rules and required coding conventions only; no tutorials or templates. Global standards (environment variables, cross-layer fixtures, zero hard wait, mandatory tags) live in `rules/playwright/pw-coding-standards.md`.

## Structure

```text
tests/web-testing/
├── tests-web/[system-kebab]/[feature-kebab]/[feature].spec.ts
├── pages/[system-kebab]/[feature-kebab]/[feature]Page.ts
├── helpers/[system-kebab]/[feature-kebab]/[feature]Helper.ts
├── fixtures/[system-kebab]/[feature-kebab]/[feature]Data.ts
└── fixtures/[system-kebab]/[feature-kebab]/[feature]Labels.ts
```

- Shared UI components: `pages/shared-pages/` or `pages/common/`. Cross-layer shared fixtures: `tests/shared-fixtures/[system-kebab]/[feature-kebab]/`.
- Suffix: `*Page.ts` screen or major view · `*Component.ts` reusable sub-component (Header, Sidebar, Modal, DatePicker) · `*Helper.ts` multi-step UI workflow · `*Labels.ts` multi-language UI text · `*Data.ts` test data.
- Each test is Arrange → Act → Assert, written with `async`/`await`.
- Login: shared `pages/common/loginPage.ts`, or per feature `pages/[system-kebab]/[feature-kebab]/login/[feature]LoginPage.ts`. No ID sub-folders in a login module.

## Page object design

- Layout-based: `BasePage` → component classes for reused UI → a `NavigationPage` for layout (Header, Sidebar) → content pages for the content area; shared components live in one place.
- Split by feature or flow (login, list, form); 5–10 methods per file, descriptive names; never one `all_in_one.ts` (50+ methods, 100+ label keys).
- Reusable helpers (auth, dialog/toast, file, form/dropdown, navigation, table) start from the project's UI helper templates rather than being rewritten.

## Locators

- Priority: `getByTestId` (container or unique element; naming per `rules/data-testid-mapping.md`) → `getByRole(…, { name: L.key })` → `getByLabel(L.key)` → `getByPlaceholder(L.key)` → `locator('css')` last resort only. Scope with `getByTestId`, then target with `getByRole` inside it.
- Multi-language apps: UI text lives in `[feature]Labels.ts` with every supported language; select with `process.env.LANG`; never hard-code visible text in one language.
- Anti-patterns (zero tolerance): `waitForTimeout()`, `.nth(0)` / `.first()` without filtering (use `filter({ hasText })`), `{ force: true }`, `waitForLoadState('networkidle')` (wait for the specific API response), XPath by position, `waitForTimeout` for WebSocket (wait on the frame or event).

## Synchronization and assertions

- Web-first, auto-retrying assertions only (`toBeVisible`, `toHaveURL`, `toHaveText`); never generic `toBeTruthy()` on a locator.
- Loading overlay covers the element → wait for the overlay to be hidden, then act. UI depends on an API response → `Promise.all([page.waitForResponse(...), click])`.
- Timeout → check the selector, then timing (API or loading), then state (disabled, hidden, covered); fix the cause, never add a hard wait.
- Same user, different action → no re-login; re-login only when the role differs.

## Advanced

- Time-dependent UI uses Playwright's clock mocking; network faults and mocks via `page.route()`, but never for OAuth.
- Bot-detection bypass only where the project's security policy explicitly allows it.

## Login / auth

- Login follows real user steps with `getByRole` / `getByPlaceholder` and accessible names. Never `page.route()` an OAuth call, `waitUntil: 'networkidle'`, or `waitForTimeout()` for login.
- `storageState` only if the app supports cookie sessions; otherwise log in per test through a helper.
- Login fails only in the pipeline → compare with a working project's config (pool, browser, shell) before changing login code. Pipeline: Windows agent, real Chrome (`BROWSER_CHANNEL: chrome`), `powershell` steps.

## package.json scripts (MANDATORY)

- Name: `ui:[sit|uat]:[SYSTEM_FEATURE_KEBAB]:[cliMode|guiMode]`, plus `ui:sit` and `ui:uat`.
- Generate both envs and both modes for every feature. Always `--config=playwright.config.ts`, test dir `tests-web/[SYSTEM_KEBAB]/[SYSTEM_FEATURE_KEBAB]/`; cliMode adds `--reporter=list`, guiMode adds `--ui`.
- Prefix every script with `cross-env LANG=en ENV=<sit|uat>`.
