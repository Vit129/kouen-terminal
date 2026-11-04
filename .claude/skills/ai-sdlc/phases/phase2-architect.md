# Phase 2 — Architect (Dev + QA combined)

> Load when you start Phase 2 (Requirement path, or a file separation plan on any path). Parent: `rules/ai-sdlc-workflow.md`.


Entry check (Requirement path): Phase 1 closed with a stated scope, and — Claude Code — plan
mode is active (end of `skills/ai-sdlc/phases/phase1-interview.md`). If either is missing, go back and do it first.

No template. Write however much design the task needs — a sentence for a small fix,
more for something with a real trade-off — then stop. Read `PRODUCT.md`/`ARCHITECTURE.md`
first if the project has them. The plan (architecture/design) lives at
`$AODD_PLANS/[FEATURE]/[FEATURE]-architecture.md`, next to `ai-sdlc-task-progress.md`;
the repo's `ARCHITECTURE.md` is updated after Gate 1 (below). A project without one gets it
then, one bullet is enough.

**Two design subagents (Requirement path):** dispatch in parallel, each with the brief and Phase 1 spec:
- **Dev:** file separation, structure, stack, API/data interfaces; runs the Existing Asset Scan (`phase2-existing-asset-scan.md`) and the Reuse Table (`phase2-reuse-table.md`).
- **QA:** failure modes, edge and boundary values, security/auth, testability, which externals need mocks (`dev-qa-handoff.md`); and the **NFRs** the release gate will check: a performance budget for each hot path (k6 thresholds, e.g. p95 latency and error rate at a stated load) and which surfaces need a pen test. None → say "no NFR" so the gate knows.

The main thread merges both into the one plan. Logic and UX/UI paths: design it yourself. Combined with the old
pipeline's separate Dev/QA architecture split: decide here, in the same pass, **what
needs QA coverage and why** — not the scenarios themselves (that's Phase 3), just
which behaviors are worth a test at all. A design done in isolation from QA concerns
is how the old pipeline ended up with dev and QA designs that quietly diverged. The
concrete handoff conventions that make this work (data-testid map, test-environment
requirements, schema consistency) → `skills/ai-sdlc/references/dev-qa-handoff.md`.

## Closing Phase 2 (always, whichever Phase 2 files you loaded)

**Approval Gate 1 applies here on the Requirement path** — see § Approval Gates in `rules/ai-sdlc-workflow.md`: don't start Phase 3/4
until the user has approved this phase's design/implementation plan. Logic and UX/UI paths skip the gate and only state a file separation plan when they add or split files (§ Pick the path).

**After Gate 1:** write the approved decisions into the living docs (owners and contents: § Documents in `rules/ai-sdlc-workflow.md`): `PRODUCT.md`, `ARCHITECTURE.md`, `DESIGN.md` (UI only), `CONTEXT.md`. Keep each short; record decisions, not the discussion. Then propose a `docs:` commit before Phase 3.

Deep DDD work (bounded contexts, aggregates/events, sync-vs-async integration tradeoffs)
is model judgment applied directly here — there's no separate skill for it. Domain-term
discipline specifically (writing/updating `CONTEXT.md`) →
`skills/ai-sdlc/references/dev-qa-handoff.md`'s Domain Language note.

Task breakdown: for multi-step tasks, slice the design and spec into vertical slices and
write them straight into `$AODD_PLANS/[FEATURE]/ai-sdlc-task-progress.md` (checkbox per
slice; see `skills/ai-sdlc/references/ai-sdlc-progress-spec.md`). For a multi-session epic
too big for that, write a decision map first (open decisions, what blocks what).

If the feature touches auth, permissions, or sensitive data → flag it for a security review
here (the `security` skill), in this same pass (its own coverage decision, same reasoning as "what needs QA
coverage"), not discovered later during implementation. If it's a core/load-sensitive
API → flag it for performance testing too, to run after Phase 5 confirms GREEN.

**Update `ai-sdlc-task-progress.md` now** — mark the design/implementation plan approved,
record approver/scope/timestamp for Approval Gate 1, and log the vertical-slice task
breakdown if multi-step (§ Incremental Update Rule, `skills/ai-sdlc/references/ai-sdlc-progress-spec.md`).
