# Phase 3 — QA-Design (scenario + skeleton, RED)

> Load when you start Phase 3. Parent: `rules/ai-sdlc-workflow.md`.


Only when Phase 2 flagged real QA coverage needed — skip entirely otherwise.

Scenario: use your scenario skill or tool, or write it by hand — it produces the
`[TS-XXXX]`/`[TC-XXXX]`-tagged scenario list Phase 4 implements
against. If Phase 2 flagged a security concern, fold the security QA scenarios into this same scenario list rather than a separate pass.

**Approval Gate 2 applies here** — see § Approval Gates in `rules/ai-sdlc-workflow.md`: don't move on to skeleton
work until the user has approved the scenario list.

**Update `ai-sdlc-task-progress.md` now** — mark the scenario list approved, record
approver/scope/timestamp for Approval Gate 2 (§ Incremental Update Rule, `skills/ai-sdlc/references/ai-sdlc-progress-spec.md`).

Test skeleton: before stubbing any test, state the public seam(s) each scenario will
test at (the boundary — an API endpoint, a public function, a UI element — not the
internal steps behind it) and get the user's confirmation; write no test at a seam not
agreed to (**Approval Gate 3**). Then stub the automated test(s) from that scenario list, before
Dev implements — failing/RED is expected and correct at this point.

**Framework pick — check what the project already uses first, never assume:**
1. Repo already has a test framework installed/configured → use that one, matching
   its existing conventions.
2. Nothing installed yet (genuinely greenfield) → a sensible default:
   Web UI/API → Playwright (`playwright-testing`, `rules/playwright/`); Mobile → Robot Framework (`robotframework-testing`, `rules/robot/`). Say this is a
   default, not the only valid choice, and ask if the user wants something else
   before scaffolding it.
3. Still ambiguous → check repo signals (dependency manifests, build config, existing
   test folders) before asking the user.
- Every framework shares the same self-heal/reporting discipline (1-attempt heal,
  Impact Analysis tiers, Reflexion Log, Test Results format) →
  `skills/ai-sdlc/references/qa-automation-loop.md` — framework-agnostic,
  applies whichever framework was picked above.

**Update `ai-sdlc-task-progress.md` now** — mark Approval Gate 3's seam agreement recorded,
mark each skeleton file `[ ]` (RED, not yet green) as it's stubbed (§ Incremental Update Rule, `skills/ai-sdlc/references/ai-sdlc-progress-spec.md`).
