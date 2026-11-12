# Code Review Report Format

Sub-file of `rules/coding.md`; read when producing a code review.

Shared shape across every automated code-review checklist
(`backend-dev`, `frontend-dev`, `playwright-testing`, `robotframework-testing`) — found
duplicated near-verbatim across the coding-standards skills, extracted here as the one source.
Each skill's own checklist content (what to actually check) stays in that skill's own
reference file — this is only the process shape, report format, and severity-to-action
mapping.

## How to review (before filling the report)

Review like the developer who will be paged when it breaks. Order: correct, safe, holds under the expected load, tested, fast, lean.

1. **Understand first:** read the diff, then the connected code: callers of every changed function, what it calls, its tests. Trace where data comes in, what is stored, what goes out. A changed signature, return value or behavior means grep every caller. Find the expected load in the repo (README, deploy config: one person running a script, or many users and processes) and say which load you assumed.
2. **Look for:**
   - **Bug:** wrong result, crash, missed edge case (empty, zero, last item, rounding, time zones), a caller broken by the change, a fix in one caller while the shared function stays broken.
   - **Risk:** injection, weak randomness, secrets, unchecked user input; data loss (swallowed errors, writes in the wrong order, no transaction).
   - **Scale:** check-then-write races, the same work done by every process, memory or lists that only grow, a query per item, O(n^2) on big input, per-process state that must be shared.
   - **Missing test:** risky new logic (branch, parser, money, security, data writes, bug fix) with no test that fails when it breaks. One good test, not coverage.
   - **Speed:** big slowdowns are findings; small wins are suggestions.
   - **Design:** passing tests are not enough; the abstraction must fit the problem (right place, right shape), not just work.
   - **Lean:** dead code, unused options, speculative features; a helper the repo already has (name the path); stdlib/platform already does it; abstraction with one implementation; near-copies that must change together; a function doing several unrelated jobs (split by job, not line count).
3. **Check before you report:** every finding needs a concrete case ("this input leads to this wrong result"); no case, no finding. Re-read the lines: the caller exists, the value can be empty, the code is really unused (grep tests, fixtures, config, dynamic references). A `shortcut:` (or `ponytail:`) marker that names its limit is a decision, not a finding, unless the expected load already crosses it. Propose the smallest fix; prefer fixes that delete code. No style taste, no "consider", no vague worries.
4. **Write it plainly:** start with `What this change does:` in two or three sentences. Number findings across all severities so the user can say "fix 2 and 5"; each gives what it is, the problem, the fix, and what happens if skipped. End with `Verdict:` (ship, or which numbers to fix first), `Lean: -N lines possible` when lean findings exist, and `Not checked:` for anything that mattered but was not read or run.
**Whole-repo audit:** same method, but map first (README, entry points, deploy config, tests), trace the main flows, and go deep where a mistake costs most instead of file by file; say which parts you did not read. At most 20 findings.

**Process (after loading the platform's own coding-standards reference and checklist):**
check every file against the checklist → output the review report below → if
NEEDS_FIX and auto-fixable → fix immediately, re-review → if APPROVED → proceed
(to execution for QA test code, to PR for Dev code).

```markdown
### 🔍 [Skill] Code Review
- Spec Fidelity: ✅ MATCHES SPEC / ⚠️ GAPS / ❌ SCOPE CREEP — checked against the originating
  task/spec end-to-end, reported separately from the standards table below (clean code that
  doesn't match what was asked, and a faithful implementation that's badly written, are two
  different findings — don't conflate them)
- Status: APPROVED ✅ / NEEDS FIX ⚠️
- Files Reviewed: {N}
- [Framework: X / Platform: Android|iOS / Mode: API|Web UI — whichever applies]

| Severity | File | Issue | Fix |
|----------|------|-------|-----|
| 🔴 High | ... | ... | ... |
| 🟡 Med | ... | ... | ... |
| 🟢 Low | ... | ... | ... |

[Auto-Fixable: {Y/N} — QA test-code review only, not Dev code review]
Critical Blockers: {N}
```

Severity → action (Dev vs QA phrasing differs slightly, meaning is identical):

| Severity | Dev action (backend-dev/frontend-dev) | QA action (playwright/robotframework) |
|---|---|---|
| 🔴 High | Must fix before merge | Must fix before run |
| 🟡 Medium | Fix before PR approval | Fix before PR |
| 🟢 Low | Fix when convenient | Fix when convenient |

