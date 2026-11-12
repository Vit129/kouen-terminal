# Phase 1 — Interview

> Load when you start Phase 1. Parent: `rules/ai-sdlc-workflow.md`.


Route by situation:
- Vague or underspecified idea, or a high-stakes / hard-to-reverse decision → **grill it**:
  list the 3-5 weakest assumptions or open forks in the plan, then ask them one at a time
  (`AskUserQuestion`, recommended answer first, with the why). Follow each answer to the next
  dependent question; stop when every branch has a decision. Write the result as a short
  markdown spec (goal, scope in/out, decisions, open assumptions).
- Has codebase → read the code the plan touches first, so questions the code can answer are
  never asked; note where the plan's language drifts from what the code already calls things,
  and record any real ADR-worthy decision inline.
- Framework/library specific, API version matters → a Haiku subagent fetches the primary
  docs and returns facts + sources; read the cited parts before relying on them.

**Phase 1 also picks the path** (§ Pick the path in `rules/ai-sdlc-workflow.md`): name the kind of change (logic, UX/UI, requirement, or several). When the kind is unclear, that is the first question to settle; anything else still unclear is settled here too, before design.

The scope check comes first, silently: if scope is already unambiguous from the request + visible context (typo fix, single clear bug, direct question, explain/summarize/search/diagnose), state the 1-line scope read and skip straight to the fitting phase/action — don't invoke any of the above.

**On the Requirement path, Phase 1 is not skippable and hands off to plan mode.**
The scope-check skip is for collapsed tasks only. On the Requirement path, close Phase 1 by stating
the resolved scope (spec summary + any assumptions still open) in the response, then —
enter plan mode (`EnterPlanMode` in Claude Code; elsewhere a plan file in `$AODD_PLANS/[FEATURE]/` that the user approves)
*before* writing any Phase 2 design, so Phase 2 drafts inside plan mode and Gate 1 is the explicit user approval
(mechanics: `skills/ai-sdlc/references/dev-qa-handoff.md`). Keep all interview/planning context in the plan;
do not edit repo living docs (`PRODUCT.md`, `ARCHITECTURE.md`, etc.) or product code until Gate 1 is approved.
Never go interview → architect file directly without passing through plan mode.

**Update `ai-sdlc-task-progress.md` now** — initialize it if this is the first phase touching
this feature, record the spec/decisions this phase produced (§ Incremental Update Rule,
`skills/ai-sdlc/references/ai-sdlc-progress-spec.md`).
