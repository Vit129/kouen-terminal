# Test Scenario — Design Guidelines & Process

Structured QA scenario design standards, coverage techniques, and CSV/Markdown generation.

---

## 1. Scenario Title Convention

**Format:** `[TestType][LAYER-KIND][Prefix] + Verb + Object + Context`

- **TestType:** `[UI]`, `[API]`, `[Mobile]` — optional when the scenario has no UI/API/mobile surface (pure logic, tooling); then start with `[LAYER-KIND]`
- **LAYER-KIND:** `BE|FE` × `BL|UT|IT`, e.g. `[BE-BL]`, `[FE-IT]` — mandatory, definitions in `skills/ai-sdlc/references/dev-qa-pattern.md`
- **Prefix:** `[Success]`, `[Alternative]`, `[Edge]`, `[Security]`
- **Forbidden:** ❌ "Test", "Verify" in Title. ❌ Start with a Noun.
- **Language:** write Action and Object in the project's documentation language; keep technical terms and parameter names in English.
- **Examples:**
  - ✅ `[UI][Success] Show the edit page for a loan-type customer`
  - ✅ `[API][Alternative] Handle the error when logging in with an invalid password`
  - ✅ `[API][Security] Reject access when there is no Authorization token`

---

## 2. Core Structure & Schema (9 Fields)

Every scenario maps 1:1 to Markdown and RFC 4180 CSV:

| Col # | Field | Allowed Values / Format | Description |
|:---:|---|---|---|
| 1 | `TS-ID` | `TS-001`, `TS-002`, ... | Unique identifier |
| 2 | `Title` | `[TestType][Prefix] Verb + Object + Context` | Standard title |
| 3 | `Description` | Plain text (or empty) | Context, business rule, or ticket reference |
| 4 | `Pre-conditions` | Numbered list (Plain text, no HTML) | Roles, data setup, initial state |
| 5 | `Test Steps (with test data)` | Numbered list with concrete test data | Actions with actual sample values |
| 6 | `Expected Result` | Numbered list (Plain text, no HTML) | Observable expected outcomes |
| 7 | `Actual Result` | Empty string | Filled upon execution |
| 8 | `Priority` | `Critical` / `High` / `Medium` / `Low` | Business & operational impact |
| 9 | `Automation Status` | `Automated` / `Automatable` / `Cannot automate` | Default: `Automatable` |

### Priority & Automation Matrix

- **Critical:** Blocks core revenue/security flow (Login, Payment, Order submit). **Must automate (API + UI).**
- **High:** Important business feature/credibility (Approve/Reject, Export, Notifications). **Must automate (API + UI).**
- **Medium:** Supporting feature (Profile update, Filters/Search). **API mandatory, UI optional.**
- **Low:** Cosmetic/styling/typos. **API only or manual.**

---

## 3. Paired Design & File Separation

1. **Paired Design (API + UI):** For features testable both ways, design both pairs and let user choose which platform to implement.
2. **Platform File Separation:** Store scenarios in separate files per platform:
   - `tests/test-scenario/{feature-kebab}/testScenario-{feature-kebab}-api.md` (+ `.csv`)
   - `tests/test-scenario/{feature-kebab}/testScenario-{feature-kebab}-web-ui.md` (+ `.csv`)
   - `tests/test-scenario/{feature-kebab}/testScenario-{feature-kebab}-mobile.md` (+ `.csv`)
3. **Security Scenarios ALWAYS Separate:**
   - `tests/test-scenario/{feature-kebab}/testScenario-{feature-kebab}-security.md` (+ `.csv`)
   - Never mix `[Security]` scenarios into functional files (different review cycle and pipeline).

---

## 4. Test Design Techniques Selection

| Situation | Technique | Rule & Title Tag |
|---|---|---|
| Numeric / string constraints | **EP + BVA** | Test valid/invalid partitions, Min, Max, Min-1, Max+1 |
| Multi-parameter form/API (1 happy path) | **Base-Choice (BC)** | 1 Base E2E (`[Base]`) + 1 variation per parameter (`[Variation]`) |
| Parameters with known interactions | **Multiple-Choice (MC)** | Pairwise matrix via PICT (`[Combo]`) |
| State-dependent transitions | **State Transition (ST)** | ST-1 minimum (all valid transitions) + invalid transitions (`[State]`) |
| Complex state machine (auth, payment) | **W-method / Transition Tree** | Formal FSM tree traversal from root (`[W-method]`) |

---

## 5. 3-Batch Design Process (Human-in-the-Loop)

Generate scenarios in 3 sequential batches. **Pause and await user approval after each batch**:

1. **Batch 1: Success Cases (Happy Path)** — Standard end-to-end positive flows.
2. **Batch 2: Alternative Cases (Negative / Validations)** — Error handling, invalid inputs, constraint failures.
3. **Batch 3: Edge Cases (Boundaries & Robustness)** — Min-1, Max+1, null/empty, concurrency, rollback.

---

## 6. Output Markdown Format

```markdown
<!-- 📋 Quick Review Summary -->
## 📋 Quick Review Summary
| TS-ID | Title | Priority | Automation Status | Domain |
|---|---|---|---|---|
| TS-001 | [UI][Success] Show the edit page for a loan-type customer | Critical | Automatable | Customer |

**Total: N scenarios | Critical: N | High: N | Medium: N | Low: N**

---

#### Test Scenario: TS-[NNN] - [TestType][Prefix] Verb + Object + Context
**Description:** [Optional note or Rule reference]
**Pre-conditions:**
1. [Condition 1 - Role, Initial State]
**Test Steps (with test data):**
1. [Step 1 with concrete test values, e.g. amount = 500]
**Expected Result:**
1. [Observable outcome]
**Actual Result:**
**Priority:** [Critical/High/Medium/Low]
**Automation Status:** [Automatable]
```

---

## 7. CSV Export Requirements (RFC 4180)

- Write `.csv` directly alongside `.md` during each batch.
- Delimiter: Comma `,`, UTF-8 without BOM.
- **Strictly No HTML:** No `<div>`, `<ol>`, `<ul>`, `<li>`, `<br>`. Use plain text with newlines inside quotes.
- Quote any field containing commas or newlines (`"..."`). Escape quotes with `""`.
- Must contain exactly the 9 columns matching §2.
