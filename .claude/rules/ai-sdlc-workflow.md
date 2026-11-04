# AI-SDLC — Dev/QA Workflow Spine

Lean AI-SDLC spine — interview → architect (dev+qa) → qa-design (scenario+skeleton,
RED) → dev (implement to GREEN) → qa-verify (confirm GREEN). Mandatory shape for work
that genuinely needs QA coverage; depth per phase, and which phases even apply, is
model judgment. This page carries the workflow shape; mechanics too dense to inline
live in `skills/ai-sdlc/references/` — `ai-sdlc-progress-spec.md` (task
tracking), `dev-qa-handoff.md` (dev↔QA handoff), `ai-sdlc-workflow-guide.md`
(execution guide), `qa-automation-loop.md` (self-heal/reporting).

**Roles (AODD JD — one owner per phase; the main thread switches hats and orchestrates, and dispatches the subagents below):**

| Role | Owns | Out of scope | Subagents | KPI |
|---|---|---|---|---|
| Dev Lead | Phase 2 dev half (design, Existing Asset Scan), Phase 4; dispatches stack-specific skills if you have them, mechanical pieces to Haiku | Writing scenarios; declaring QA pass | Phase 2: Dev design subagent; Phase 4: the implementation subagent | Phase 5 failures sent back to Phase 4 |
| QA Lead | Phase 2 QA half, Phase 3 (RED), Phase 5 (GREEN sign-off); dispatches your scenario, test-framework and performance skills if you have them | Patching product code to make a test pass | Phase 2: QA design subagent | Defects found after Phase 5 sign-off |
| Reviewer | Built-in `/code-review` on the Phase 4 diff before Phase 5 | — | — | — |
| Auditor | `scripts/audit.py` after Phase 5 (cross-family, writes its own report): re-checks evidence vs. the brief, reports to the CEO | Fixing | — | Defects after audit PASS |

Each role follows the same SOP: read brief + progress file → ask once, everything at once → do →
check vs. Definition of Done → hand back to the next owner via the progress/handoff file → leave the record (checkbox).

**Subagents: many eyes for design, one pair of hands for code.**
- **Phase 2 design (Requirement path):** two subagents in parallel, so the views stay independent and the phase stays fast. Dev: structure, file separation, reuse, stack, the invariants that must always hold. QA: failure modes, edge and boundary cases, security boundaries (where untrusted input enters), mocks, testability. The main thread merges both into one plan (plan mode, or a plan file in `$AODD_PLANS/[FEATURE]/`). Logic and UX/UI paths: the main thread designs alone.
- **Phase 4 code:** one subagent by default, so no two agents write the same or a shared file. More than one only when the work splits into parts that touch disjoint files, each given an explicit scope (the files it may edit, the interface it must meet); shared files stay with one owner.

**Documents: plan first, living docs after Gate 1.** Until Gate 1 everything stays in the plan; no repo doc or product code changes. After approval, write the durable decisions into four living docs at the repo root, one owner each, kept short:

| Doc | Owner | Holds |
|---|---|---|
| `PRODUCT.md` | PO | scope, users, outcomes, in/out of scope |
| `ARCHITECTURE.md` | Dev + QA | tech stack, structure, seams, data model, test strategy |
| `DESIGN.md` | UX/UI | tokens, layout, components (UI projects only) |
| `CONTEXT.md` | everyone | domain glossary |

Then propose a `docs:` commit, before any test or code. The second commit point is Phase 4 GREEN (`feat:`/`fix:`), with the test evidence. Architectural invariants and QA automated guard pattern → `skills/ai-sdlc/references/dev-qa-pattern.md`; release checks (security/pen test, performance) → `rules/coding/release.md`; project runner → `rules/coding/project-blueprint.md` § 2.1.

**Shift-left:** QA scenario/test-skeleton design happens BEFORE dev writes
implementation code — dev implements against a known RED state and drives it to
GREEN, QA re-verifies GREEN at the end. TDD applied at the feature level, not just
the unit level.

**Pick the path by what changes, not by size.** Every task, small or large, takes the path for the kind of change; only that path's phases run. A change can carry more than one kind (a new requirement with a new screen runs both). If it is not clear which kind it is, Phase 1 decides that first.

| What changes | Path | Dev | QA | Gates | Living docs |
|---|---|---|---|---|---|
| Wording, typo, config value | Just do it | edit | existing tests still pass | — | — |
| **Logic**: a bug, a rule inside an existing requirement, a refactor | TDD | Phase 4 unit loop: failing test first → GREEN → refactor; Existing Asset Scan when it adds a helper | a regression test that fails without the fix; the cases next to it (boundary, null, error path); callers in the blast radius still pass | — | `ARCHITECTURE.md` only if a seam or the data model changes |
| **UX/UI**: look, layout, an on-screen flow | Design | read `DESIGN.md` → change | look at every affected screen in a browser/screenshot (sizes, long text, dark mode); a Playwright test when a user flow changes | show the mock or screenshot first for a new screen | `DESIGN.md` |
| **Requirement**: a new or changed capability, a rule users see, a new integration | Full | Phase 2 Dev subagent, Phase 4 | Phase 2 QA subagent (NFRs), Phase 3 scenarios RED, Phase 5 traceability + sign-off | Gates 1-3 | `PRODUCT.md`, `ARCHITECTURE.md`, `CONTEXT.md` (+ `DESIGN.md` with UI) |
| Unclear which | Interview | Phase 1 resolves the kind, then the path above | | — | — |

**Look before you pick.** Size is not known from the request; it comes from the code. Before choosing, check: the blast radius (graphify `blast_radius`/`affected`, or grep the token, component or function), how many screens or callers it reaches, and whether this was already "fixed" before (git log, past sessions). Then weigh it:
- one place, first attempt → the path as it is;
- wide reach (a color token used on 30 screens, a shared helper with many callers) → list every affected place in a short plan; QA checks each one (a regression list, not a spot check), even on the Logic or UX/UI path;
- already failed once, or many small symptoms on one screen (clipping, wrapping, spacing) → stop patching symptom by symptom: Phase 1 lists all the symptoms first (QA turns each into a check that fails now), find the shared cause, then fix and re-run every check together (UI: `rules/gui-fixes.md`, 2 rounds then options).

Size still matters for orchestration and audit (`rules/aodd.md` triage): a change that adds or splits files states its file separation plan on any path.

**Four independent baseline rules — a floor, not a free pass (single authoritative version — other files point back to this list):**
1. **Only the Requirement path runs the full ceremony.** Any path that adds or splits files states the file separation plan before coding.
2. **ARCHITECTURE.md never collapses.** Every project gets one regardless of task
   size. This is a standing
   per-project artifact, not a per-task ceremony step, so it isn't something a small
   task "skips": if the project doesn't have one yet, this is where it gets created
   (one bullet is enough), collapsed task or not.
3. **The Existing Asset Scan never collapses** for any task that adds a new
   function/component/helper/query. § Existing Asset Scan (`skills/ai-sdlc/phases/phase2-existing-asset-scan.md`) and its
   Reuse-Table/Nth-Occurrence rule (`skills/ai-sdlc/phases/phase2-reuse-table.md`) run regardless of task size — exempt only when
   there's genuinely nothing to scan (a single-line edit to an existing line).
4. **Verification never collapses.** `rules/aodd.md`'s Test-Before-Deliver (build
   passes + relevant tests pass) is a baseline outside this file's
   phase shape — every task runs it regardless of what collapsed.

## Phase map — load only the phase you are on

| Phase | Load when | File |
|---|---|---|
| Phase 1 — Interview | when you start Phase 1 | `skills/ai-sdlc/phases/phase1-interview.md` |
| Phase 2 — Architect | when you start Phase 2 (Requirement path, or a file separation plan on any path) | `skills/ai-sdlc/phases/phase2-architect.md` |
| Phase 2 — Existing Asset Scan | before designing any new module, component, service, query or test helper (never collapses) | `skills/ai-sdlc/phases/phase2-existing-asset-scan.md` |
| Phase 2 — Reuse-Table Artifact & Nth-Occurrence Centralization Rule | whenever Phase 2 touches more than one file or adds a function/component/query/helper (the table is Gate 1's review artifact, even for create-new), and when a pattern now occurs a third time | `skills/ai-sdlc/phases/phase2-reuse-table.md` |
| Phase 2 — Reuse Modification Retest | when a design modifies an existing shared component (decided in Phase 2, executed in Phase 4) | `skills/ai-sdlc/phases/phase2-reuse-retest.md` |
| Phase 3 — QA-Design | when you start Phase 3 | `skills/ai-sdlc/phases/phase3-qa-design.md` |
| Phase 4 — Dev | when you start Phase 4 | `skills/ai-sdlc/phases/phase4-dev.md` |
| Phase 5 — QA-Verify | when you start Phase 5 | `skills/ai-sdlc/phases/phase5-qa-verify.md` |

Approval Gates, Core facts and Status below stay in force in every phase.

## Approval Gates (mandatory on the Requirement path)

Three checkpoints carry a real hard stop — everything else stays Auto Mode default
(don't stop to ask). These three have a uniquely expensive undo: get one wrong and
everything built on top of it gets thrown away.

1. **After Phase 2 (Architect) produces its design/implementation plan** — do not start
   Phase 3 or Phase 4 until the user has explicitly approved it. A wrong architecture
   discovered after Dev has built against it means redoing the build, not just the doc.
2. **After Phase 3's scenario list is written** (the `[TS-XXXX]`/`[TC-XXXX]`
   output of your scenario skill or tool) — do not move on to skeleton/automation until the
   user has explicitly approved the scenario list. A wrong scenario found after
   automation is built against it means rewriting the automation, not just the list.
3. **After Phase 3's seam/automation-architecture agreement** (which public seam —
   API endpoint, function, UI element — each scenario tests at, and how the automation
   is structured) — write no test at a seam not explicitly agreed to. A real HITL gate,
   not a formality.

No mechanical hook enforces these — treat "the user hasn't objected" as different from
"the user approved"; ask directly and wait for a real answer before crossing the gate.

## Core facts (non-negotiable, not model-inferable — everything else is judgment)

- QA scenario/test ID (`[TS-XXXX]`/`[TC-XXXX]`) in every automated test name — the only
  link between a scenario, its automation, and any tracker. Without it, nothing traces.
- Scenario/test titles also carry a `[LAYER-KIND]` tag (`BE|FE` × `BL|UT|IT`, e.g. `[BE-BL]`) — layer/kind
  definitions and Dev + QA rules → `skills/ai-sdlc/references/dev-qa-pattern.md`.
- Multi-step/multi-session work: track in `$AODD_PLANS/[FEATURE]/ai-sdlc-task-progress.md`
  (legacy `dev-task-progress.md`/`qa-task-progress.md` supported), vertical slices not phases, resume at first unchecked `[ ]`.
  Skip entirely for single-sitting work. Full mechanics (tags, sensitive-data/mock rules,
  rollback, resume protocol) → `skills/ai-sdlc/references/ai-sdlc-progress-spec.md`.
- Project/Feature Architecture Planning: the architecture document always goes in `$AODD_PLANS/[FEATURE]/[FEATURE]-architecture.md` (or `[FEATURE]-architecture/`), next to `ai-sdlc-task-progress.md` and the feature's other artifacts, never scattered.
- Test automation: zero hard waits — whatever fixed-delay primitive the framework in
  use offers is forbidden, use its wait-for-condition primitive instead. 1 self-heal attempt max then
  route to a root-cause debugging pass (`9arm-skills:debug-mantra` if installed) — both are anti-flakiness facts, not
  code-quality opinions a model would guess.
- Interactive UI elements carry a stable test identifier (`data-testid` etc., naming
  convention fixed once per project) — a
  contract QA automation depends on existing, not something to rediscover per task. Full
  dev→QA handoff conventions (testid map, test-env requirements, schema consistency,
  DB strategy) → `skills/ai-sdlc/references/dev-qa-handoff.md`.
- Graph-before-edit (if graphify is installed) and surgical changes (no drive-by refactors) apply in every phase.
- **Skill visibility + Self-Update, every phase:** name every skill invoked in the response text — never call one silently. Every
  skill learns the same way: when a phase hit a correction, a gotcha, or a
  wrong/missing step in the invoked skill, and the fix was verified, patch that skill's
  `SKILL.md` (or its `references/`) in place and bump `version`/`last_improved` — see its
  `## Self-Update` section and `docs/skill-learning.md`.
  A phase's attention being on the workflow doesn't excuse skipping whichever loop the
  invoked skill actually uses. Log which skill(s) ran in each phase into
  `ai-sdlc-task-progress.md` per
  `skills/ai-sdlc/references/ai-sdlc-progress-spec.md`'s Skill Invocation Log.

## Status

Default route for new/unclear-scope Dev/QA feature work. Stack-specific coding skills (`backend-dev`, `frontend-dev`, `macos-swiftui`) and `rules/coding.md` still own coding conventions.
