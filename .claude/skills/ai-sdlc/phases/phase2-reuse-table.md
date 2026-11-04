# Phase 2 — Reuse-Table Artifact & Nth-Occurrence Centralization Rule

> Load whenever Phase 2 touches more than one file or adds a function/component/query/helper (even when every verdict is create-new), and when a pattern now occurs a third time. Parent: `rules/ai-sdlc-workflow.md`.


**MANDATORY, always — this does not collapse for small tasks and is not the model's call
to skip.** See baseline rule 3 in `rules/ai-sdlc-workflow.md`: a trivial one-line edit with nothing to
scan is exempt because there's genuinely nothing to check, not because this rule is
optional. The instant a task adds any new function/component/query/helper, run the scan
and the Nth-Occurrence check below before writing that code — on a "small" task exactly as much
as a large one.

**The table itself is required when Phase 2 touches more than one file:** produce a markdown table as part of
the feature's `[FEATURE]-architecture.md`, columns exactly:

```markdown
| Concern | File | Symbol/Function | Verdict | Rationale |
|---|---|---|---|---|
```

`Verdict` is one of four values:

- **Reuse-as-is** — an existing symbol already does exactly what's needed, called
  unmodified. Cite `file:line`.
- **Extend** — one existing symbol/file is close, gets a backward-compatible parameter/
  behavior added in place (feeds the Reuse Modification Retest, `skills/ai-sdlc/phases/phase2-reuse-retest.md`). Still ONE file being
  touched, not a new one.
- **Create-centralized** — see the Nth-Occurrence Rule immediately below. A **new** shared
  file/symbol is created, but *because* the scan found the same logic already duplicated
  independently ≥2 times, and the existing duplicates get refactored to call the new
  centralized one instead of the task adding a 3rd/4th independent copy.
- **Create-new** — genuinely nothing to reuse/extend/centralize; a new file/symbol with no
  precedent. This is the only verdict that adds code without also removing or redirecting
  any existing duplication.

**The Nth-Occurrence Rule** (what turns a `create` into a `create-centralized`): during
step 2 of the Existing Asset Scan (graphify query / grep for a similar symbol), if the
*same* non-trivial logic pattern — not merely a similar-sounding name — turns up already
implemented **independently in 2 or more places** that don't already share a common
call site, the correct move for this task (which would otherwise be the 3rd copy) is:

1. Extract the shared logic into one new file/symbol in the project's existing shared
   location (per step 1 of the Existing Asset Scan — reuse the shared-folder convention
   already established, don't invent a new one).
2. Refactor the existing N duplicates to call the new centralized symbol, deleting their
   private copies. This is itself an `extend` on each of those N files — run the Reuse
   Modification Retest (`skills/ai-sdlc/phases/phase2-reuse-retest.md`) on each before considering the centralization done, since each
   duplicate has its own existing callers/tests that must stay green.
3. The task's own new caller reuses the centralized symbol — it contributes **zero** new
   duplicate logic.

**A 3rd independent copy of the same logic is itself the signal to centralize — don't
wait for a 4th.** Two independent copies can still be coincidence; three is a pattern
the codebase is asking to have named once.

**Applies identically across Backend, Frontend, DB, and QA** — this is not a Dev-only or
QA-only rule: a validation rule, form hook, seed helper, or login helper reimplemented
per-file instead of centralized in the project's existing shared location is the same
pattern in every domain.

**This table is Gate 1's actual review artifact, not a nice-to-have** — the user approving
Phase 2's design is approving this table specifically, not just the prose.
