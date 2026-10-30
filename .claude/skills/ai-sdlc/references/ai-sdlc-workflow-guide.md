# AI-SDLC Workflow & Execution Guide

Operational guide for executing the 5-phase Shift-Left software lifecycle using `ai-sdlc` as the spine, optionally powered by the companion plugin `9arm-skills` (see the README) and your project's QA automation. Without them, do each step directly.

---

## 5-Phase Lifecycle Overview

| Phase | Purpose | Tool / Slash Command | Primary Artifact |
|---|---|---|---|
| **Phase 0: Scope & Discovery** | Map unknowns, spikes, multi-session work | decision map doc, Haiku research, throwaway spike | Decision tickets, exploratory spike |
| **Phase 1: Interview** | Uncover assumptions, clarify scope | Phase 1 grill → short markdown spec | Feature Spec (`docs/specs/` or prompt output) |
| **Phase 2: Architect** | Domain language, interface/seam design & ticket slicing | Phase 2 design + vertical slices | `CONTEXT.md`, `$AODD_PLANS/[FEATURE]/[FEATURE]-architecture.md`, `$AODD_PLANS/[FEATURE]/ai-sdlc-task-progress.md` |
| **Phase 3: QA-Design** | Shift-Left test scenarios & skeletons | scenario tool + your test framework (Playwright, Robot Framework, ...) | `[TS-XXXX]` test files in **RED (failing)** state |
| **Phase 4: Dev** | Implement tickets until tests pass | Phase 4 unit loop (red → green → refactor) | Application code driving tests to **GREEN** |
| **Phase 5: QA-Verify** | Verify suite & run parallel pre-merge audit | Full test suite run + `/code-review`, `handoff.md` when stopping mid-feature | Code Review Report (Standards + Spec) |

---

## Step-by-Step Execution Guide

### Step 0: Scope & Discovery (Pre-SDLC)
1. If the task is too broad or spans multiple sessions:
   - Write a decision map (open decisions, what blocks what) and pick the next unblocked ticket.
2. If exploring unfamiliar libraries or codebase areas:
   - Have a Haiku subagent gather primary-source evidence before proposing architecture.
3. If technical viability is unproven:
   - Build a throwaway spike to validate feasibility before writing formal specs.

### Step 1: Clarify & Spec (Phase 1)
1. When receiving a new feature request:
   - Grill it per `phases/phase1-interview.md`: weakest assumptions first, one question at a time, recommended answer first.
   - Extending existing code or a complex framework: read the code, and have a Haiku subagent fetch the official docs, before asking.
2. Once aligned, write scope as an explicit, verifiable markdown spec.

### Step 2: Architect & Slice Tickets (Phase 2)
1. Standardize ubiquitous domain terms in `CONTEXT.md` (`references/dev-qa-handoff.md` § Domain Language).
2. Determine module depth, public seams, and adapters (deep modules: small interface, real logic behind it).
3. Create/record the architecture plan directly in `$AODD_PLANS/[FEATURE]/[FEATURE]-architecture.md` (co-located with `ai-sdlc-task-progress.md`).
4. Determine QA testability requirements (`data-testid`, DB fixtures, mock boundaries) per `references/dev-qa-handoff.md`.
5. Break the spec into vertical slices directly and initialize `$AODD_PLANS/[FEATURE]/ai-sdlc-task-progress.md`.

### Step 3: Design Test Skeletons in RED (Phase 3)
1. Generate `[TS-XXXX]` scenarios (your scenario tool, or by hand).
2. Stub automated test skeletons at confirmed seams:
   - Use the framework the project already has; greenfield defaults: Playwright for web/API, Robot Framework for mobile.
3. Execute tests once: confirm they **FAIL (RED)** strictly for the expected reasons.

### Step 4: Implement to GREEN (Phase 4)
1. Pick the stack-specific coding skill if you have one (frontend, backend, platform-specific).
2. Implement ticket-by-ticket with the Phase 4 unit loop (red → green → refactor, one vertical slice at a time, at the agreed seams).
3. Refactor with tests green to deepen modules and simplify seams.
4. For difficult design/typing decisions, consult the `advisor` agent.
5. Stop when all Phase 3 tests pass (**GREEN**).

### Step 5: Verify & Pre-Merge Gate (Phase 5)
1. Run the entire test suite to confirm zero regressions.
2. Invoke `/code-review` to launch parallel sub-agents:
   - **Standards Sub-agent**: Validates against the project's coding standards and baseline code smells.
   - **Spec Sub-agent**: Verifies complete coverage against the Phase 1 spec.
3. Optionally run `/scrutinize` for an outsider-perspective sanity check.
4. If handing off to another agent or session, write a structured summary (format: `references/ai-sdlc-progress-spec.md` § Resume protocol) to `$AODD_PLANS/[FEATURE]/handoff.md`; `ai-sdlc-task-progress.md` is a checkbox list, don't drop the narrative into that.

---

## Bugs, Incidents & Git Operations

- **Bug Investigation:** Route through `9arm-skills:debug-mantra` (Reproduce → Trace → Falsify → Cross-reference) and `/diagnosing-bugs` or `/triage`.
- **Post-Mortem:** Conduct root cause analysis and document prevention via `/post-mortem`.
- **Merge Conflicts:** Safely resolve git conflicts without loss of intent via `/resolving-merge-conflicts`.
- **Stakeholder Communication:** Translate technical changes into leadership updates via `/management-talk`.

---

## Collapse Rules (When to Skip Phases)

- The path follows what changes (logic → TDD only, UX/UI → design + visual check, requirement → all 5 phases), not the size; see § Pick the path in `rules/ai-sdlc-workflow.md`.
