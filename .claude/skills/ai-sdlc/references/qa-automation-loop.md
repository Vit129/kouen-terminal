# QA Automation Loop — Shared Self-Heal & Reporting Discipline

Cross-platform self-heal/reporting discipline shared by any QA automation
framework (Playwright, Robot Framework, ...). Platform-specific mechanics (CLI commands, fix-by-error-type
tables, locator/keyword conventions) stay in your framework's own docs — this file is only the cross-platform loop discipline.

## Test Execution → Heal escalation

If a test run fails: trigger the healer, **1 attempt only — no retry loop**. Still failing
→ stop immediately, route to a root-cause debugging pass (`9arm-skills:debug-mantra` if installed) with the diagnosis (root cause +
suggested fix already written to the Reflexion Log below, not re-derived from scratch).
Apply a fix only after it validates a root cause — this is still gated by the existing
"review healed assertions before committing" HITL step, self-healing never means auto-commit.

## Impact Analysis (mandatory before any fix)

Every fix — however small — gets classified before it's applied, because the fix action
differs by blast radius:

| Classification | Scope | Action |
|---|---|---|
| Isolated | Affects only the one failing test | Fix directly |
| Shared | Affects a helper/page/keyword used by multiple tests | Check all dependent tests, ensure backward compatibility |
| Cross-cutting | Affects shared-fixtures, auth, or a convention used across API+Web+Mobile (or Android+iOS) | Warn user, get approval before fixing |

Each platform's own docs keep its own version of this table with platform-accurate
terminology (e.g. "Cross-platform" for Android/iOS naming, "Cross-layer" for API/Web/Mobile
shared fixtures) — the 3-tier concept and the escalation rule for the top tier are what's
shared, not the exact wording.

## Error triage: Environment vs Code

Before healing, classify the failure:
- **Environment (skip, don't heal)** — service/device/VPN unreachable, connection refused.
  This is not a code bug; healing it would mask a real infra problem.
- **Code (heal)** — element/keyword not found, assertion failed, timeout tied to the app
  under test, not the test environment.

Concrete symptom → fix mappings differ per platform (web locator failures vs mobile
accessibility_id/XML-source issues) — those tables stay in your framework's docs.

## Reflexion Log (every heal attempt, success or fail)

**Location:** append to `audit.md` → `## Reflexion Log` section.

```
## [Timestamp] | Type: [ErrorCategory]
- ❌ Symptom: [brief error description]
- 🔍 Root Cause: [root cause]
- 💊 Applied Fix: [code/keyword/locator change summary]
- 🏁 Outcome: HEALED / FAILED
- 📊 Impact: Isolated / Shared / Cross-cutting
```

Purpose: prevent repeating the same failed fix — a successful heal becomes a reusable
pattern for future features, a failed one is a documented dead end not worth retrying.

## Test Results (every run, appended to the audit trail)

**Location:** `audit.md` → `### Test Results` section.

```
### Test Results — [Timestamp]
- Total: [N] | Passed: [N] | Failed: [N]
- [platform-specific context line — ENV/Mode for web-api, Platform/ENV for mobile]
- Failed tests: [list or "none"]
```

**Chat output (summary only — never dump the full report to chat):**
```
✅ Tests recorded to audit.md
Passed: [N]/[N] | Failed: [N]
```
