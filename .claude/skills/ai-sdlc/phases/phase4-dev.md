# Phase 4 — Dev (implement to GREEN)

> Load when you start Phase 4. Parent: `rules/ai-sdlc-workflow.md`.


**If Phase 2's Existing Asset Scan classified anything `extend`, this is where the Reuse
Modification Retest actually executes**: read `skills/ai-sdlc/phases/phase2-reuse-retest.md` now and run it right after this task's own change passes, before
moving on. It was only decided in Phase 2; it runs here, not there.

Implement against the Phase 3 skeleton(s) until they pass, one vertical slice at a time,
with the unit-level loop below. If code structure gets cluttered, refactor toward deep
modules (small interface, real logic behind it) at the seams Phase 2/3 agreed, with tests green.

**One implementation subagent** runs the whole loop below, tests and code together, so no two agents edit the same or a shared file. Split across more subagents only when the parts touch disjoint files; give each its file list and the interface it must meet, and keep shared files with one owner.

**Unit loop (red → green → refactor):**
1. Write one failing test for the next behaviour, through the public seam (not internals). Run it; see it fail for the right reason.
2. Write the least code that makes it pass. Run the suite.
3. Refactor with the suite green; no new behaviour in this step.
4. Repeat. Never write several tests ahead, and never mock the module under test.

Before writing code, read `rules/coding.md` and pick the matching stack-specific coding-standards skill
based on project stack (`backend-dev`, `frontend-dev`, `macos-swiftui`) and apply
its conventions — this phase owns the workflow shape (skeleton → GREEN), the platform
skill only supplies stack-specific syntax/pattern, it does not replace this phase.

If Phase 2 flagged auth/permissions/sensitive-data/security concerns, this phase is where
that flag actually gets acted on: apply secure-coding practice
(input validation at trust boundaries, parameterized queries, secret isolation) while
implementing — don't let the Phase 2 flag sit unaddressed until a QA scenario happens to
catch it later.

**Two test tiers, paired not duplicate:** Phase 3's skeleton is QA's feature/E2E-level
scenario (the acceptance criteria). Phase 4 additionally owns unit-level tests for the
internal logic it writes — derived FROM the same business rules/edge cases QA already
spelled out in Phase 3's scenarios (boundary values, validation rules, error paths), not
invented separately — per the rule that non-trivial logic leaves one
runnable check behind and the unit loop above. Phase 5 verifies the QA scenario suite; it doesn't re-verify Phase 4's own unit
tests — those stay green as part of Phase 4's own Done-gate (`rules/aodd.md`
Test-Before-Deliver).

**Update `ai-sdlc-task-progress.md` now** — mark each skeleton `[x]` as it actually goes
GREEN, not batched at the end (§ Incremental Update Rule, `skills/ai-sdlc/references/ai-sdlc-progress-spec.md`).

**At GREEN, propose a commit** (`feat:`/`fix:`) with the test evidence, before Phase 5.
