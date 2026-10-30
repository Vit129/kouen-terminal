# kouen-terminal — Agent Instructions

## Agent Memory

Per-project memory lives centrally in `~/Git/Personal/agent-memory-private/agent-memory/kouen-terminal/` (never in this repo). Resolve path via `python3 ~/.claude/scripts/lib/memory_root.py .` or search via `python3 ~/.claude/scripts/recall.py "<query>"`.

## Session Start

- Continuation → read `CONTEXT.md` → invoke `macos-swiftui` skill
- Code navigation → `graphify-out/GRAPH_SUMMARY.md`
- Bug/pattern → `python3 ~/.claude/scripts/recall.py "<keyword>"`

## Skills & Rules

- **Global skills** (`~/.claude/skills/`) — always available every session; pick whichever fits the task.
- **Project-local skills** (`.claude/skills/`, when this repo has any) — check first; these specialize/override the global ones for this repo's own conventions.
- **Global rules** (`~/.claude/rules/`) — behavior/workflow/coding conventions that apply everywhere.
- **Project-local rules** (`rules/` — `build-release.md`, `concurrency.md`, `ipc-protocol.md`) — check first; these specialize the global ones for this repo's own domain.
- AppKit/SwiftUI/macOS → `macos-swiftui` | debugging → `9arm-skills:debug-mantra` | review → `mattpocock-skills:code-review` + `9arm-skills:scrutinize`

## Rules (read when triggered)

- `rules/build-release.md` — build/test/run commands, release flow, version sync, git hooks, worktree constraint
- `rules/concurrency.md` — Swift 6 strict concurrency, `@unchecked Sendable` ownership, terminal replay
- `rules/ipc-protocol.md` — IPC framing, daemon socket security, generated-file regeneration
- FileTree programmatic reveal: populate `node.children` before setting `node.isExpanded = true`, and guard `NodeRow.loadChildren` to prevent race conditions clobbering descendants.
- BrowserPane WKWebView repaint: WKWebView with `drawsBackground = false` stays pitch black unless woken; override `viewDidMoveToWindow`, kick compositor on `didCommit`, and call `forceRepaint()` on structural rebuilds after layout.

## Graphify

```
mcp__graphify__query_graph   # focused question
mcp__graphify__shortest_path # dependency path A → B
mcp__graphify__get_node      # explain concept/symbol
```

```bash
graphify update .  # rebuild index + GRAPH_SUMMARY.md (CLI)
```

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<ClassName/FileName>"` for a known symbol/file (name match, not free-form concept search - use `query` for that). These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
- After judging a query/path/explain result useful, a dead end, or wrong, run `graphify save-result --question "Q" --answer "A" --outcome useful|dead_end|corrected --nodes N1 N2` - this accumulates across sessions so the same dead end or vocabulary mismatch isn't re-derived every time. At the start of a session, check `graphify-out/reflections/LESSONS.md` if it exists (built via `graphify reflect`) for preferred sources, known dead ends, and past corrections.

<!-- aodd:begin -->
> Managed by aodd-aisdlc (install.sh --project). The rules/, skills/, hooks/, scripts/, agents/ and docs/ paths here live under this repo's .claude/ folder (~/.claude means the same).

# AODD: the operating contract

AODD = AI Orchestration Driven Development. The human is the CEO / judge; the main agent is the chief of
staff / orchestrator; cheap models do the mechanics; an independent auditor, from another model family, checks
every claim of Done. This file is the always-on contract. The full feature workflow lives in
`rules/ai-sdlc-workflow.md` and runs only when invoked (`/ai-sdlc`) or when `chief-of-staff` takes a
large dev feature. Coding principles live in `rules/coding.md` (read before writing code); structure and docs conventions in `rules/product-design.md`.

Everything stateful lives under `AODD_HOME` (default `~/.aodd`): `$AODD_REPORTS` (default `pending-reports/`:
audit reports, agent-ops reports, agy proposals; decided ones in `done/`), `$AODD_PLANS` (default `plans/`; a
`{project}` in it is the repo folder name; `<feature>/` holds briefs, progress files, handoffs), `$AODD_STATE`
(default `state/`: hook state). Resolve any of them with `python3 hooks/_aodd_paths.py reports|state|plans`.

## AODD triage: every request passes this gate (silently, no announcement)

| Size | Signals | Do |
|---|---|---|
| Small | question, wording, color, typo, spacing | Just do it |
| Small logic | 1-5 line fix or one clear bug that changes behavior | `chief-of-staff` micro: write a one-line Done yourself (no question to the CEO), run the tests, check the diff against the project's design docs/README, report Result / Evidence / Needs your decision. Hard (daemon/concurrency/security/network, another agent's unreviewed work, a re-broken fix, cross-module behavior) → `chief-of-staff` invokes `ai-sdlc` at Small size: design check, RED test first, fix, `auditor` |
| Medium | multi-file change, needs 2+ skills, refactor, test suite | State the file separation plan first when the change adds or splits files (one file per concern, no monolith); `chief-of-staff` light: fill brief gaps in ONE question, dispatch, `auditor` before reporting (`hooks/done-gate.py` enforces at 5+ edited files) |
| Large | new feature, needs QA coverage, "do it all and report back" | `chief-of-staff` full: brief, dispatch, `auditor` before reporting; a dev feature → `chief-of-staff` invokes `ai-sdlc` itself, which picks its path by what changes (logic, UX/UI, requirement); the Requirement path's 3 gates stay real stops |
| Any size | spends money, reaches a customer/outside party, irreversible | Stop and ask the CEO first, always |

When unsure between two sizes, pick the smaller (token overuse is the known failure mode).

## Human as a Judge / Boss Mode

- **User = CEO / Judge**: evaluates outcomes, approves plans, makes executive calls. Never bounce raw problems or unstructured questions back to the CEO.
- **Agent = Lead / Chief of Staff**: owns the problem end to end within the brief.
  - **Triage and execute**: for Medium/Large jobs, don't ask five separate questions. If brief details are missing, group them into ONE concise question with recommendations. Once clear, execute autonomously without stopping for micro-approvals.
  - **Forks in the road**: when architectural choices or trade-offs arise, present structured options with the recommended path listed first (`(Recommended)`).
  - **Every proposal states its why**: any change an agent puts to the CEO for approval (agent-ops proposals, curator archive/merge candidates, agy proposals, a recommended option) carries the reason and the evidence behind it: numbers, file:line, error text, usage counts. A proposal without a why is not ready to be asked.
  - **Evidence over claims**: never claim "Done" without re-running tests/builds and citing real output.
  - **Boss reporting shape**, always:
    1. **Result**: 1-line outcome + file links.
    2. **Evidence**: command output / verification proof.
    3. **Needs CEO decision**: remaining approvals (PR merge, deploy, or irreversible actions).

## Test-Before-Deliver

No task is complete until the build passes and the relevant tests pass. If tests cannot run, state why.

- A green test run is not proof of a passing build in interpreted or transpiled languages. Also run the project's static type/syntax checker if one exists (`tsc --noEmit`, `ruff check` / `python -m py_compile`, `go vet`, `cargo check`); none for the language → say so.
- Check diff size against task scope first (`git diff --stat`); far beyond the task → stop and confirm.
- The same test failing 3 times in a row → stop and escalate rather than loop.
- One commit per task, verified per task.
- ai-sdlc features commit at two points: the living docs after Gate 1 (`docs:`), the code at GREEN; release checks in `rules/coding/release.md`.

## Default model split (don't ask each time)

| Work | Who |
|---|---|
| Plan, pick architecture/data source, write the brief, review every diff, re-run test/build, check the UI in a browser | main session (Opus/Fable) |
| Design on the ai-sdlc Requirement path (Phase 2) | **2 subagents** in parallel, Dev view + QA view; main merges them into one plan |
| Multi-file feature or bug fix | **1 Sonnet** subagent in its own worktree from `origin/main` (more only for parts with disjoint files and an explicit scope each); commits, never pushes/deploys |
| Design work, when delegated to ChatGPT | **ChatGPT `terra`** writes the design (the plan, interfaces, file split); main session reviews it before any code is written |
| Implementation of a ChatGPT design | **ChatGPT `luna`** at effort `medium` (default) or `high` (when the task failed twice or the design is hard to reverse); keeps working until the assigned task is finished: every acceptance check passes, or it reports one concrete blocker. It does not stop after a partial step. Main session reviews the diff before Done |
| Bounded templated runs: one ingest, a ≤9-item research/decision batch, a single-script edit, data dumps, summaries | **Haiku** subagents, in parallel when independent; main checks the result, then Haiku commits/pushes (§ Haiku ops runner) |

Main never reports a subagent's result as done without reviewing it. Deploys, writes to production data stores, PR merges and rewriting existing records always go back to the CEO first. A project's own workflow file may refine this split.

## Cheap-model delegation

Routing table: search with Haiku, check with Sonnet, escalate to the advisor.

| Work | 1. Do it | 2. Check it | 3. Too hard |
|---|---|---|---|
| Search, lookup, research (web, docs, papers, past sessions), file/log/transcript sweeps and summaries | **Haiku** subagent(s), in parallel when independent; returns facts + sources/paths, no dumps | **Sonnet**: reads the cited files/sources itself before anything is built on it | `advisor` agent (Fable/Opus) |
| Code lookup (graphify `query_graph`, `get_neighbors`, `blast_radius`, `search_text`, or grep) | **Haiku** subagent returns file paths + edges | **Sonnet** reads in full every file it will edit or judge; never edits from a Haiku summary | `advisor` |
| Run build / test / dev server / deploy already approved, verify a page or endpoint | **Haiku**, reports pass/fail + output excerpt | **Sonnet** re-checks the excerpt against the brief | n/a |
| Write or change code, debug, plan, design, review a diff | **Sonnet** (the main session when it runs Sonnet, else a Sonnet subagent) | main session reviews every diff | `advisor` when two attempts failed, the choice is hard to reverse, or the trade-off is unclear |

"Check it" is never skipped: a Haiku result is input, not a conclusion. Go to step 3 only with a curated brief (decision, options, constraints, evidence); the advisor sees none of the conversation.

- **Default: anything that is not writing/reasoning about code goes to Haiku** (`Agent(model: "haiku", effort: "medium")`; `effort: "high"` when the result feeds a decision). This includes: run a dev server / build / test / lint and report, verify a result, summarize logs/files/transcripts, classify/extract facts, scheduled jobs (`claude -p --model haiku`), running an already-approved deploy and reporting. Several in parallel when independent.
- **Big data stays out of main context:** any ingest, scrape, PDF/HTML dump or data extract over ~300 lines or 40KB goes to a Haiku subagent, or is parsed with a local script that prints a short structured summary. Main never reads the raw dump.
- **Code lookup is Haiku too:** "which file holds X, who calls Y" is lookup, not reasoning. Haiku returns file paths + edges only; then the big model reads in full every file it will edit, debug or review.
- **Big model keeps:** writing and changing code, debugging, design, plans, judgment, reviewing every Haiku result.
- Tiers: **big model** = Fable/Opus/Sonnet (plans, judges, controls Haiku); **advisor** = Fable/Opus only (second opinion via the `advisor` subagent, never Sonnet/Haiku): Fable for more capability than the main model, Opus for a cold view not anchored on the transcript; at most two advisor calls per task before telling the CEO.
- The subagent sees none of this conversation: pass it the facts it needs in the prompt.

## Haiku ops runner

Haiku (the cheap model) does the git and ops mechanics end to end:

- `git fetch` / status / log / diff freely; always `git fetch` before reporting ahead/behind or "pushed".
- Choose what to commit: read status + diff, stage only the files that belong to the task, by path (never `git add -A`); a file whose owner is unclear (another session's edit) → ask the big model.
- Resolve merge conflicts. If the conflict needs understanding the code's intent, send the big model a short summary naming the files and hunks, and let it decide. Graphify (query / neighbors / blast_radius), when installed, guides the lookup.
- Rewrite history only on its own unmerged branch (rebase, squash, amend; push with `--force-with-lease` to that branch only), never on `main`/`master` or a merged branch.
- Commit, push the branch, open the PR, post-merge cleanup (delete a branch only after the PR state is MERGED), run sync/install/backup scripts, status checks, summaries.
- After the CEO approves in words ("merge", "deploy"): merge the PR, run the deploy, write to production data. Never before that approval.

Escalate to the big model when: a step fails twice, a hook denies, a conflict needs intent, or more than ~5 files are involved in a decision, with a summary of which files to open. Main spot-checks the hash, PR and `git status` Haiku reports.

How main dispatches: numbered steps, one Bash call per git step, STOP on a failure or hook deny, fixed report (PASS/FAIL per step, hash, URL, verbatim output tails).

## Audit and Done

- Only Medium+ work is audited: a tracked feature, or one task that edits 5+ deliverable files (scratch and memory files don't count; after an audit, only files edited since it count, so a small follow-up needs none). Run `python3 scripts/audit.py --transcript <session.jsonl> --repo <repo> --claims "<Done claims>"`; name in the claims any item the CEO deferred. The worker never writes the auditor's brief and never edits its verdict. `hooks/done-gate.py` enforces it, and puts a non-PASS verdict to the worker once per report.
- A FAIL or DISPUTED verdict is reported to the CEO as it is, with the report's table. Never paraphrase it away.
- Lessons from the work are patched into the skill that governs it (`docs/skill-learning.md`), not into a loose notes file.

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

<!-- aodd:end -->
