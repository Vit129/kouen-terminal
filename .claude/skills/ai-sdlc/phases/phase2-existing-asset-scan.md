# Phase 2 — Existing Asset Scan (Dev + QA)

> Load before designing any new module, component, service, query or test helper (never collapses, see the parent baseline rules). Parent: `rules/ai-sdlc-workflow.md`.


Applies to Dev code and QA automation alike, in whatever language or test framework the
project already uses:

1. Check both the module-scoped and top-level/cross-module shared locations first,
   following whatever convention the project already has — naming varies (`shared/`,
   `util/`, `common/`, `base/`, a per-package root file like `paths.py`/`config.py`, or a
   dedicated package in a multi-package repo). Look for what's actually reused, not for a
   specific folder name to match.
2. If `graphify-out/` exists, query it (`mcp__graphify__query_graph`) for a similar symbol/concept; otherwise `grep -r` other feature/module folders by
   keyword (translate non-English intent to English terms first).
3. Classify: does exactly what's needed → **reuse** (use as-is); close but missing a
   method/parameter → **extend** (keep the existing signature backward-compatible — see
   Reuse Modification Retest, `skills/ai-sdlc/phases/phase2-reuse-retest.md`); nothing matches → **create**.
4. **Nth-Occurrence check and verdicts:** whenever this scan ran (any new function/component/query/helper), read `skills/ai-sdlc/phases/phase2-reuse-table.md` now: its Nth-Occurrence rule applies to every such task, and when Phase 2 touches more than one file you also write the verdicts into its table (Gate 1's review artifact).
5. **Smart-Copy Rule:** never copy a whole file — copy only the function/method needed
   plus its direct dependencies.
6. **Known-bug check:** for a `reuse`/`extend` candidate, check the project's notes and the Pitfalls sections of loaded skills for gotchas already recorded against that component before building on it.
