# Dev + QA Pattern — Unified Architectural & Testing Standard

> **Pattern Type:** Architectural & Engineering Standard (Dev & QA)  
> **Status:** Active Canonical Standard across all projects  
> **Parent:** `rules/ai-sdlc-workflow.md`  
> **Principle:** "A Pattern, not a copy-paste template" — defines boundaries, invariants, tagging conventions, and automated test barriers rather than rigid boilerplate.

---

## 1. Tagging: `[LAYER-KIND]`

Applies to every project and stack (web, mobile, game, tooling). Load when naming a scenario, test, or task, or when deciding which kind of test a behavior needs.

| Part | Value | Meaning |
|---|---|---|
| **Layer** | `BE` | Logic and data with no UI: services, APIs, domain rules, pure calculations |
| | `FE` | What the user sees or touches: screens, components, game actors/shaders |
| **Kind** | `BL` | Business Logic: one rule, possibly several steps, inside one module |
| | `UT` | Unit Test: one function, known input → known output (parity/golden-value checks are UT) |
| | `IT` | Integration Test: two or more modules, persistence, or a real boundary (API + DB, state + save/load) |

Combine freely: `[BE-BL]`, `[BE-UT]`, `[BE-IT]`, `[FE-IT]`. Rule of thumb:
- One function → `UT`
- One business rule across a few steps → `BL`
- Two or more modules or persistence → `IT`

Scenario title: `[LAYER-KIND][Success|Alternative|Edge|Security] verb + object + context`. Where the scenario tool's `[UI]/[API]/[Mobile]` TestType is also useful, put it first: `[API][BE-BL][Success] …`. The scenario/test ID (`[TS-…]`/`[TC-…]`, per `rules/ai-sdlc-workflow.md`) is unchanged; the tag is in addition to it.

---

## 2. Dev Pattern — The 5 Structural Layers

To prevent calculation drift, missing translations, and visual styling erosion, Dev code follows a **5-Layer Separation of Concerns**:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      5. QA Architecture Guard                           │
│     (Automated regex/AST scanner running in unit test runner < 100ms)    │
│   • 0 Missing Keys  • 0 Language Literals  • 0 Hex  • 0 Raw Font Sizes  │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ verifies invariants
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         4. Presentation UI (FE)                         │
│              (React / Vue / Svelte / SwiftUI / Flutter)                 │
│         Visual composition only • Dispatches user actions               │
└──────────────┬─────────────────────┬─────────────────────┬──────────────┘
               │                     │                     │
               ▼                     ▼                     ▼
┌─────────────────────────┐ ┌─────────────────┐ ┌─────────────────────────┐
│     1. Domain Core (BE) │ │ 2. Design Tokens│ │ 3. Translator / Strings │
│   (Math / Rules / DCA)  │ │ (Colors / Fonts)│ │  (TH_STRINGS / EN_...)  │
│  • Pure Functions       │ │ • Semantic Hex  │ │ • Single source of text │
│  • Headless & Portable  │ │ • Type Scale    │ │ • Parameterized Labels  │
│  • Zero DOM or React    │ │ • Theme Mapping │ │ • Zero hardcoded text   │
└─────────────────────────┘ └─────────────────┘ └─────────────────────────┘
```

1. **Domain Core (`*-core` / `logic/`):** Pure mathematical & business rules (zero DOM, zero framework dependencies).
2. **Design Tokens (`config/colors.*`, `config/typography.*`):** Central visual contract (zero raw hex or font sizes in components).
3. **Translator Dictionary (`strings.*`, `translations/`):** Central textual contract (zero language literals in logic or UI).
4. **Presentation UI (`ui/`, `components/`):** Visual assembly & event dispatching (delegates math to Core, styling to Tokens, labels to Translator).
5. **QA Architecture Guard (`tests/architectureGuard.test.*`):** Automated static/regex assertions running in CI/Vitest that fail immediately if any layer boundary is breached.

---

## 3. Dev Implementation Invariants & Rules

1. **The Headless Domain Core:**
   - Rules live in the BE layer; FE calls them and never computes a rule itself.
   - *Placement Test:* Can this function run in a plain Node/Python process without a browser, DOM, React context, or network mocks? If yes → belongs in Core.
   - *Language Decoupling:* Core logic must NEVER hardcode human language strings. If a calculation produces labeled output, it accepts an optional `labels` parameter with defaults imported from a string module.
   - *Formula Parsing:* User formula inputs (e.g. `"65000+2500"`) must be evaluated through a safe arithmetic parser (`evalExpression`) in Core, never raw `eval()`.
2. **Check Before Adding (Reuse Analysis):**
   - Check what exists before adding (Existing Asset Scan / Reuse Table: `skills/ai-sdlc/phases/phase2-existing-asset-scan.md`, `skills/ai-sdlc/phases/phase2-reuse-table.md`).
   - Extending a shared function: additive and backward compatible, then re-run its callers' tests.
3. **Single Source of Visual Truth (Tokens):**
   - All colors resolve from `COLORS.*` or semantic CSS variables (`var(--bg)`, `var(--surface)`). Never inline `#hex` or `rgba()`.
   - All font styles resolve from `TYPOGRAPHY.*`. No numeric font sizes (`fontSize: 14` ❌) or arbitrary Tailwind classes (`text-[10px]` ❌).
4. **Single Source of Textual Truth (Translator):**
   - Every user-visible word, button label, table header, aria-label, and AI prompt template lives in translation dictionaries (`strings.js` or `translations/*.js`).
   - Dynamic interpolations use pure formatter functions (`LBL_MONTHS_LEFT: (m) => ...`).
   - No inline fallbacks (`label || 'Default'` ❌). If a key is missing, CI must fail.
5. **Shared UI Primitives (`*-ui`):**
   - When UI elements are reused across distinct applications (`Card`, `MoneyInput`, `BreakdownTile`, `ChipButton`, `ProgressBar`, `Stepper`), extract them to a shared package (`@<scope>/<domain>-ui`).

---

## 4. QA Verification Pattern — Dual-Layer Testing

QA mirrors the 5-layer separation rather than creating ad-hoc test monoliths. Align directly with `rules/playwright/pw-coding-standards.md` and `skills/ai-sdlc/references/dev-qa-handoff.md`:

```
tests/
├── fixtures/[feature]/[feature]Data.js   # 1. Single Source of Truth: Business Scenarios & Matrix
├── pages/[feature]/[feature]Page.js       # 2. Page Object Model: Encapsulates Layer 4 DOM & Actions
├── tests-api/[feature].api.spec.js        # 3. Headless Core Engine: 100% permutation testing in ms
└── tests-web/[feature].ui.spec.js         # 4. Web E2E: Key user journeys via Page Object on Chrome
```

1. **Three Batches (Scenario Design):**
   - Success, Alternative, Edge — approved one by one, then test data, then the scenario table.
2. **Skeleton RED First:**
   - Skeleton RED first at an agreed seam; no test at a seam nobody agreed to.
3. **Shared Scenario Fixtures (`fixtures/`):**
   - Business test scenarios (e.g. tax brackets, job switches, bonus types, boundary values) live in `fixtures/` as pure data.
   - Zero DOM locators and zero assertions inside fixtures.
   - Shared between headless logic tests and browser UI tests.
4. **Headless Core Engine Tests (`tests-api/`):**
   - Directly executes Layer 1 (Pure Domain Core) without launching a browser.
   - Exhaustively tests the entire scenario matrix (tax brackets 0%–35%, ceilings, overflow rules) in milliseconds.
5. **Page Object Model (`pages/`):**
   - Encapsulates Layer 4 (Presentation UI) DOM locators (`getByTestId`, semantic buttons, form controls).
   - Test specs must NEVER call raw `page.locator(...)` directly; all interactions go through domain methods (e.g. `await pageObj.fillSalary('65000')`).
6. **Browser E2E Tests (`tests-web/`):**
   - Runs against real browsers via Playwright to verify rendering, reactive state recalculations, and visual badges.
   - Tests key representative journeys (not exhaustive math permutations) to keep test runs fast and resilient.
7. **Negative Controls & Self-Heal:**
   - A parity/comparison harness needs a negative control: break one reference value and the run must FAIL.
   - No fixed delays (`waitForTimeout` forbidden); one fix attempt on a failing test, then root-cause debugging.

---

## 5. Continuous Architecture Guard (Automated Static Invariants)

Instead of relying on human vigilance or manual review checklists, QA implements an automated **Architecture Guard** test file (`tests/architectureGuard.test.js` or `tests/architecture_guard_test.py`) running in Vitest/Jest (<100ms):

```javascript
describe('Architecture Guard (Logic / UI / Translator / Tokens)', () => {
  const allSrcFiles = getAllSourceFiles('src');

  // Guard 1: Zero Missing Translation Keys
  it('enforces that all referenced UI string keys exist in translation dictionary', () => {
    const missing = [];
    for (const file of allSrcFiles) {
      const code = stripComments(fs.readFileSync(file, 'utf8'));
      for (const m of code.matchAll(/\b(?:STRINGS|UI_STRINGS)\.([A-Z0-9_]+)\b/g)) {
        if (!(m[1] in STRINGS)) missing.push(`${file}: ${m[1]}`);
      }
    }
    expect(missing).toEqual([]);
  });

  // Guard 2: Zero Hardcoded Language Literals Outside Translation Files
  it('enforces zero hardcoded language characters outside designated strings files', () => {
    const violations = [];
    const languageRegex = /[\u0E01-\u0E3A\u0E40-\u0E7F]/; // Thai Unicode range
    for (const file of allSrcFiles) {
      if (isTranslationFile(file)) continue;
      const lines = stripComments(fs.readFileSync(file, 'utf8')).split('\n');
      lines.forEach((line, idx) => {
        if (languageRegex.test(line)) violations.push(`${file}:${idx + 1}: ${line.trim()}`);
      });
    }
    expect(violations).toEqual([]);
  });

  // Guard 3: Zero Hardcoded #Hex Colors Outside Design Tokens
  it('enforces zero #hex color literals outside config/colors', () => {
    const violations = [];
    const hexRegex = /#[0-9a-fA-F]{3,8}\b/;
    for (const file of allSrcFiles) {
      if (isColorConfigFile(file)) continue;
      const lines = stripComments(fs.readFileSync(file, 'utf8')).split('\n');
      lines.forEach((line, idx) => {
        if (hexRegex.test(line)) violations.push(`${file}:${idx + 1}: ${line.trim()}`);
      });
    }
    expect(violations).toEqual([]);
  });

  // Guard 4: Zero Hardcoded Font Sizes or Inline Font Stacks
  it('enforces that all fontSize and fontFamily reference TYPOGRAPHY tokens', () => {
    const violations = [];
    const fontRegex = /\b(fontSize|fontFamily)\s*:(?!\s*TYPOGRAPHY\.)/;
    for (const file of allSrcFiles) {
      if (isTypographyConfigFile(file)) continue;
      const lines = stripComments(fs.readFileSync(file, 'utf8')).split('\n');
      lines.forEach((line, idx) => {
        if (fontRegex.test(line)) violations.push(`${file}:${idx + 1}: ${line.trim()}`);
      });
    }
    expect(violations).toEqual([]);
  });
});
```

---

## 6. Anti-Patterns & Traps

| Anti-Pattern | Why It Fails | Pattern Solution |
|---|---|---|
| **The Inline Fallback Trap** (`UI_STRINGS.FOO \|\| 'Default'`) | Masking missing keys. Defeats bilingual translation and leaks untracked strings into the UI. | Remove fallback. If key is missing, let Architecture Guard fail in CI. |
| **The Chart/Canvas Hex Trap** (`backgroundColor: '#10b981'`) | Breaks dark/light theme switching and fractures color updates. | Import `COLORS` and use `COLORS.EMERALD` or `withOpacity(COLORS.EMERALD, 0.2)`. |
| **The Template Duplication Trap** (Copying a calculation helper into 3 components) | Calculation drift. When formulas update, duplicate files diverge. | Extract logic to `*-core` or `src/logic/` with 100% unit test coverage. |
| **The Arbitrary CSS Override Trap** (`text-[10.5px]`, `fontSize: 13`) | Destroys typographical rhythm and causes visual clutter. | Map to nearest semantic type scale token (`TYPOGRAPHY.TEXT_MICRO` or `TEXT_LABEL`). |
| **The Monolithic State-Math Hook** (Mixing 400 lines of math inside a React hook) | Impossible to test in headless CI without DOM mocks. | Separate into pure calculation functions (`taxLogic.js`) called by a slim state hook (`useTaxState.js`). |
| **The Ad-Hoc Test Monolith Trap** (Creating one-off scenario folders with hardcoded locators and assertions) | Fractures test standards and makes tests brittle to DOM refactors. | Follow `pw-coding-standards.md`: shared `fixtures/` + Page Object `pages/` + fast headless `tests-api/` + browser `tests-web/`. |

---

## 7. Definition of Done Checklist (Dev & QA)

A feature adhering to this pattern is only **Done** when:
- [ ] **Pure Core:** All business calculations and validation formulas live in headless modules with 100% unit test coverage.
- [ ] **Zero Language Literals:** All UI text, error alerts, and aria-labels are declared in translation files.
- [ ] **Zero Rogue Hex:** All color styles resolve through semantic tokens or CSS variables.
- [ ] **Zero Rogue Fonts:** All font sizes and stacks resolve through typography tokens.
- [ ] **Automated Guard Green:** `tests/architectureGuard.test.*` executes and passes cleanly with 0 violations.
- [ ] **Decoupled Tests:** Headless matrix tests exist in `tests-api/`, Web E2E flows use Page Objects in `tests-web/`, and scenarios reside in `fixtures/`.
- [ ] **Per-Project Mapping:** Each project specifies which folders are BE and FE in its own docs (`ARCHITECTURE.md` or `DEV_QA_PATTERN.md`).
