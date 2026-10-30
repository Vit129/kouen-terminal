# Robot Framework Workflow

Write → Review → Execute → Heal. The full mobile test automation cycle.

## 1. Code Writer

Generate Robot Framework + Appium test files from architecture design.

**Input:** Architecture Design + Test Structure Blueprint from implementation plan.

**Steps:**
1. Read coding rules from `rules/robot/` (rf-coding-standards.md + android.md or ios.md) — ALL parts
2. Read architecture and test structure blueprint
3. Create directory structure (mkdir -p) — folders kebab-case
4. Generate YAML fixtures — `[feature]Data.yaml` with environment-specific data and `[feature]Labels.yaml` with TH/EN UI labels
5. Generate page objects (.robot) — Library imports, locators (accessibility_id priority), Keywords with Thai JSDoc
6. Generate test robot files — AAA pattern, mandatory tags, [TC-xxxx] prefix, Setup/Teardown using DbService
7. Integrate Expert Gems: Hybrid API Setup, Self-Healing, Deep Linking

**Naming:** Folders kebab-case, files lowerCamelCase (.robot) or snake_case (.py)

**Folder Structure:**
```
pages/[platform]/[SYSTEM_KEBAB]/[SYSTEM_FEATURE_KEBAB]/[systemFeature]Page.robot
tests-mobile/[platform]/[SYSTEM_KEBAB]/[SYSTEM_FEATURE_KEBAB]/[systemFeature].robot
fixtures/[platform]/sit.yaml
helpers/shared-services/[system_feature_snake]_db_service.py
```

**Forbidden:**
- Hard-coded test data (use `fixtures/*.yaml`)
- Hard-coded Thai/English text in keywords — use `Labels.yaml` for UI text
- `Sleep` usage (use `Wait Until Element Is Visible`)
- `xpath` as first resort (use `accessibility_id` or `id`)
- Hard-coded credentials (use `.env`)
- Mixed platform locators
- Divergent keyword names between Android and iOS

## 2. Code Review

Static quality audit — no running tests.

**Check against:**
- rules/robot/rf-coding-standards.md (all parts)
- Platform-specific rules (android.md or ios.md)
- Identical Naming across platforms
- AAA pattern, mandatory tags, [TC-xxxx] prefix
- Expert Gems implementation (Hybrid Setup, self-healing logs)
- Architecture compliance: asset reuse, DB strategy, Unified Keyword Mapping
- 1-to-1 mapping between implementation plan test steps and actual Keywords

**Output:** APPROVED or NEEDS_FIX with issue list.

## 3. Test Execution

Run tests and capture results.

**Steps:**
1. Verify .robot file exists and Robot Framework is installed
2. Run: `robot --outputdir results --variable ENV:sit --console dotted [path]`
3. Parse `output.xml` — total, passed, failed, error messages, screenshot paths
4. On failure → `skills/ai-sdlc/references/qa-automation-loop.md`'s Test Execution → Heal escalation
5. Record lessons to Reflexion Log — only technical patterns (custom keyboards, page source quirks, device-specific timeouts, locator stability)

## 4. Self-Healing (Reflexion Pattern)

**Impact Analysis (MANDATORY before any fix)** — 3-tier concept + escalation rule shared
across platforms, see `skills/ai-sdlc/references/qa-automation-loop.md`. Mobile terminology:

| Classification | Scope | Action |
|---|---|---|
| 🟢 Isolated | Only failing test uses this keyword | Fix directly |
| 🟡 Shared | 2+ tests use same keyword/helper | Ensure backward-compatible |
| 🔴 Cross-platform | Used in both Android + iOS | Verify Identical Naming preserved |

**Error triage** (Environment-vs-Code split shared across platforms, see
`skills/ai-sdlc/references/qa-automation-loop.md`): Environment (skip) = Appium server not
reachable, device not found, VPN. Code (heal) = element not found, keyword not found,
assertion failed, timeout.

**Fix by error type:**

| Error | Fix |
|-------|-----|
| Element not found | Use accessibility_id, check XML source, verify setup |
| Timeout | Increase timeout, add 'Wait Until...', check Deep Link |
| Assertion failed | Verify YAML data, check Hybrid setup, fix AAA pattern |
| Keyword not found | Check Library/Resource import, check Identical Naming |
| Flaky mobile | Add small delay, re-fetch locator, device-specific wait |

**Rules:**
- Self-heal discipline (1 attempt, escalation, logging) — `skills/ai-sdlc/references/qa-automation-loop.md`
- Never delete keywords or tests
- Ensure Identical Naming preserved after fix

## Test Results & Reflexion Log — Write to Audit Trail (MANDATORY)

Format, location, and purpose are shared across platforms — see
`skills/ai-sdlc/references/qa-automation-loop.md`'s Test Results and Reflexion Log sections.
This platform's Test Results context line: `Platform: [Android/iOS] | ENV: [SIT/UAT]`.

## 5. Python Database Writer

Generate Python DB config and service for mobile tests.

**Steps:**
1. Read DB Strategy from implementation plan
2. Generate `[system_feature_snake]_db_config.py` — uses `os.getenv` / `python-dotenv`
3. Generate `[system_feature_snake]_db_service.py`:
   - `__init__()` — load config
   - `connect()` — open connection
   - `seed_[feature](**kwargs)` — parameterized INSERT
   - `verify_[feature](**kwargs)` — SELECT
   - `cleanup_[feature](**kwargs)` — DELETE
   - `seed_all(params, test_id)` — if FK dependencies, orchestrate in order

**Rules:**
- PEP8 compliance (snake_case methods, CamelCase classes)
- Parameterized queries — no f-strings
- Context managers or try-except-finally for connection safety
- Atomic business actions, not generic query wrappers
- All credentials from `.env`
