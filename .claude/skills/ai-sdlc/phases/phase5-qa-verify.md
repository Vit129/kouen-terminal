# Phase 5 — QA-Verify (confirm GREEN)

> Load when you start Phase 5. Parent: `rules/ai-sdlc-workflow.md`.


Run the full scenario suite from Phase 3 against the Phase 4 implementation. Every
test still carries its `[TS-XXXX]`/`[TC-XXXX]` ID and obeys the core facts in `rules/ai-sdlc-workflow.md` (no
hard waits, 1 heal attempt max before routing to `9arm-skills:debug-mantra`). This phase
is verification only — no new scenarios get invented here; a genuinely missing case
found during verification goes back to Phase 3, it doesn't get patched in place.

Pre-merge gate: once all tests confirm GREEN, run `/code-review` (or any review skill you have) on the full diff, checking two axes:
- **Standards Axis**: conforms to the project's coding standards
- **Spec Axis**: faithfully implements the originating spec produced in Phase 1

**Traceability table** (before sign-off, in the progress file): one row per Phase 1 requirement and Phase 2 NFR → the test(s) that cover it → result. A requirement with no test is a gap: add the test or record why not. The auditor checks against this table.

**Release or deploy after this feature:** run the release gate in `rules/coding/release.md` first (security/pen test, performance, audit, version + changelog).

**Knowledge graph sync:** If `graphify-out/` exists in the repository, run `graphify update .` before closing the task (AST-only, keeps the graph fresh for subsequent queries/tools).

**Update `ai-sdlc-task-progress.md` now** — mark the final checkbox, feature Done (§
Incremental Update Rule, `skills/ai-sdlc/references/ai-sdlc-progress-spec.md`; this IS the Done-gate (`rules/aodd.md`) — don't call it Done anywhere
else first).
