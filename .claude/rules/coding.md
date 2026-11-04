---
# Single place to register a language: add its extension here + one row in coding/programming-language.md
paths:
  - "**/*.{swift,py,js,jsx,mjs,cjs,ts,tsx,go,rs,sh,c,h,m,java,kt,kts,cpp,cc,cxx,hpp,hh,cs,gd}"
---
# Coding Principles

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.
- **Scope = every place the change must reach:** read the task and the code it touches, then list the callers, tests, fixtures, config and exports the change affects, and what it could break for users (data it would destroy or expose, callers that stop working). That is scope; extra features are not.
- **Architecture-First (Medium+ tasks, Dev & QA):** before writing code or tests that add or split files, state a short separation plan (where logic, UI/integration, and tests/fixtures go) — see § Anti-Monolith & Separation Pattern.
- **Plan co-location:** when planning a project or feature, put the architecture document in `$AODD_PLANS/<feature>/<feature>-architecture.md` (or `<feature>-architecture/`), in the same folder as `ai-sdlc-task-progress.md`. Do not scatter planning documents.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.
- A vague request ("build me X") gets the smallest version that does the core job; name what you left out in one line.
- No wrapper or type conversion nobody asked for: keep values in the form the platform already gives you.
- The shortest working diff wins, once you know everything it must touch. A one-liner that needs decoding is not short.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

**Before writing code, stop at the first rung that holds** (after you understand the problem, not instead of it):
1. Does this need to be built at all?
2. Does it already exist in this codebase? Reuse the helper or pattern that is there.
3. Does the standard library do it?
4. Does a native platform feature cover it? (The project's own component beats a native widget, rung 2.)
5. Does an already-installed dependency solve it? Never add a dependency for a few lines.
6. Can it be one line?
7. Only then: write the minimum code that works.

- **Lazy about the solution, never about the change:** finish every part the task needs, including the callers, tests and fixtures your change breaks.
- **Code you move or merge keeps its error handling and validation.**
- **Bug fix = root cause:** grep every caller of the function you touch and fix the shared function once, not one guard per caller.
- When two stdlib approaches are the same size, pick the edge-case-correct one: less code, not the flimsier algorithm.
- **Mark a deliberate shortcut** that has a known ceiling (global lock, O(n²) scan, naive heuristic) with a comment `shortcut: <the limit>, <when to upgrade>` (older code may say `ponytail:`). List them with `git grep -nE '(#|//|/[*]) ?(shortcut|ponytail):'`; a marker with no upgrade trigger is debt that rots, flag it `no-trigger`.
- **Never lazy about:** understanding the problem, input validation at trust boundaries, error handling that prevents data loss, security, accessibility, calibration real hardware needs, anything explicitly requested. Non-trivial logic leaves ONE runnable check behind (a small assert-based self-check or one test file); trivial one-liners need none.

- Never write or open report-style HTML files with large embedded data (for example graphify's `graph.html`, or a test/coverage report) in the workspace: they burn tokens and context. For graphify use `query`/`path`/`explain`; write other documents and reports as Markdown or plain text.

## 3. Graph Before & After Edit

If `graphify-out/graph.json` exists at or above the project root, **find and change code through graphify** (optional tool, installed separately; MCP `mcp__graphify__*` or the CLI, same functions):

| To do | Use |
|---|---|
| find a symbol / concept / file | `query "<q>"`, `explain "<symbol>" --snippet` (get_snippet) |
| find exact text, error message, config key | `graphify grep "<text>"` (search_text) — hits show their enclosing symbol |
| who is affected by a change | `affected "<symbol>"`, `affected --git-diff` (blast_radius) |
| where a Python parameter flows | `flow "<fn>" --param p --to "<sink regex>"` (trace_flow) |
| rename / replace / insert / delete a symbol | `edit rename\|replace\|insert-after\|delete "<symbol>" ...` — dry run first, `--apply` to write |

Raw `grep`/`find` are for the cases the graph cannot answer: confirming a caller list is exhaustive before changing a signature (the graph can miss dynamic or attribute calls), files graphify does not index, or editing a specific known line — say so when you use them. Skip all of this for trivial changes (typos, config values, docs).

**After modifying code:** run `graphify update .` (AST-only, no API cost) before declaring work done.

## 4. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

**Chesterton's Fence:** before deleting or simplifying code that looks redundant, understand
why it exists — check `git blame`/`git log -p` on it and its callers. Red flags that mean stop
and reconsider, not push through: modifying an existing test to make it pass (behavior changed,
not the test), removing error handling because it looked unnecessary. A refactor that breaks an
existing test means the refactor is wrong, not the test.

**Refactoring moves, when a real smell is present** (don't apply these speculatively — see §2):
nesting 3+ levels deep → guard clauses/early returns; a function past ~50 lines doing multiple
things → extract one focused helper; a boolean-flag parameter (`fn(true, false)`) → an options
object or two distinct functions. Split a function or file by job (it does several unrelated
things, so it is hard to read or test), never only to hit a line count, and never into helpers
that exist just to make a function shorter; the 300–400 line target in §6 is a signal to look,
not a reason to split.

**Boundary check** — most bugs hide where two things disagree about a contract: verify
casing/shape consistency at serialization boundaries (camelCase vs snake_case, date formats),
every `async` call that should be awaited actually is, and no `catch` block swallows an error
silently (log or re-throw, never `catch (e) {}` / `except: pass` with nothing in it). A bug fix
without a regression test that fails without the fix and passes with it isn't done.

## 5. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 6. Project Structure

Sub-files of this rule:
- `rules/coding/project-blueprint.md` (loaded on demand): Directory roles, size trees, dependency direction.
- `skills/ai-sdlc/references/dev-qa-pattern.md` (loaded on demand): The unified Dev + QA Pattern (BE vs FE, 5-layer Core-UI-Translator architecture, layer/kind tags, and QA automated architecture guard tests). A pattern, not a copy-paste template.

For projects you own, follow them. A repo with its own enforced layout keeps that layout.

### Logic vs UI split (every repo)

The folder names follow the project (blueprint §1 aliases, or the repo's own layout); the split itself is not optional.

| Layer | Holds | Never |
|---|---|---|
| **logic** (`logic/<feature>-logic.*`, or the repo's equivalent) | pure functions: data in → data out (filter, sort, compute, validate, format a value) | DOM/widgets, fetch/DB/file/clock, global state, localStorage |
| **view / UI** | build markup or widgets, bind events, read app state, call integrations, pass plain data into logic | business rules, thresholds, calculations |

- **Placement test:** could this function run in a unit test with no browser, no network and no app state? Yes → logic. No → view/integration.
- **When editing a view:** a new calculation or rule goes into the logic file and the view calls it. Never grow logic inside a render function. An existing view that mixes them is split only when the task touches that view, one view per branch/PR, with `ARCHITECTURE.md` updated in the same PR.
- **Proof:** every logic file has a test next to it (or in `tests/`) that imports it without a DOM. A refactor that moves logic must show the rendered output did not change: compare before/after on the same data.
- Example shape (static JS app): `logic/detail-logic.js` holds the pure functions, `views/detail-view.js` renders and calls them.

### Anti-Monolith & Separation Pattern (Target 300–400 lines)

Files must remain modular, maintainable, and testable for both **Dev and QA**.
- **Target size (300–400 lines):** a soft target; a file may exceed it when it is cohesive and the reason is clear.
- **Non-negotiable separation:** no monolithic "God file" (500–1000 lines) that holds every role in one place.
- **Dev Decomposition Strategy:**
  - **Pure logic / calculations:** Extract to `<feature>-logic.*` (or `utils/`, `helpers/`) without DOM or network dependencies.
  - **Sub-views / UI widgets:** Extract child components into dedicated files (`components/<child>.*`).
  - **Network / Storage:** Extract API calls or persistence to `services/` or `api/`.
  - **Modifying existing monoliths:** When editing an existing 500+ line legacy file, do not add more code directly into it. Extract the new feature or edited section into modular role files, keeping diffs clean.
- **QA Architecture & Separation Strategy (Playwright, Robot Framework, XCTest, etc.):**
  - **Locators & Page Actions:** Encapsulate in Page Objects / Keywords (`pages/`, `keywords/`) — never inline raw locators or long action chains inside test specs.
  - **Test Data & Fixtures:** Separate test fixtures, mock payloads, and schemas into `fixtures/` or `data/`.
  - **Test Scenarios / Specs:** Test files (`tests/`, `specs/`) focus purely on test orchestration and assertions. Target ~300–400 lines (can exceed if cohesive test cases in the same flow, but Page Object / Fixture separation pattern must hold).

## 7. Coding flow (after reading this file)

Each step names what to read or call next. **[hook]** means the step is enforced mechanically, not just written down.

| Step | Do | Read / call |
|---|---|---|
| 1. Orient | Project root `ARCHITECTURE.md`, `CONTEXT.md`; find code via graphify if the project has `graphify-out/`; past decisions in the project's memory (`knowledge/`, `plans/`) | `rules/product-design.md` |
| 2. Size it | AODD triage in `rules/aodd.md`. Small: just do it. Medium: Architecture-First (§1, § Anti-Monolith), `chief-of-staff` light. Large: suggest `/ai-sdlc` in one line, `chief-of-staff` full | `skills/chief-of-staff` |
| 3. Branch | New branch from `main` before the first edit (rule only; the hook blocks switching away from uncommitted work, not editing on `main`) | your project's git conventions |
| 4. Place code | Logic vs UI vs Tests split (§6) & Anti-Monolith pattern (target 300–400 lines); structure work → blueprint | `rules/coding/project-blueprint.md`, `project-blueprint` skill |
| 5. Domain skill | Web/mobile UI → `frontend-dev` (+ `uxui-designer` if no design tokens); API/DB → `backend-dev`; SwiftUI → `macos-swiftui`; bug → trace the failing path and falsify your hypothesis before fixing; auth/input/secrets → `security`; UI layout bug → `rules/gui-fixes.md` | the skill |
| 6. Verify | Tests + the language's type/syntax checker; UI change → look at it in a browser/screenshot | `rules/coding/programming-language.md` |
| 7. Review | Medium+: review the diff against the brief (an independent reviewer if available); tracked feature or 5+ files: `scripts/audit.py` (independent, cross-family) **[done-gate hook reads its verdict; only PASS allows Done]** | `rules/coding/review-report.md` |
| 8. Close | Tick progress boxes **[done-gate hook]**, skill patch **[skill-capture-nudge hook, at 20+ tool calls with a learning signal]**, graph refresh if used | `docs/skill-learning.md` |

- **Read before write:** understand existing code before modifying it.
- **New feature branch before coding** unless instructed otherwise. Never commit work-in-progress directly on `main`/`master`.
- **End the reply** with one or two lines: what you skipped or did not check, and any risk the user must know.

## Citation Format

`[source:path/or/command] — brief note`

## Error Handling & Logging

- Never swallow an exception silently (`catch (e) {}`, `except: pass`) — log it or re-throw it.
- Don't leak internal errors to users — no raw stack traces or database error text in a response;
  translate to a message the caller can act on.
- Remove temporary debug output (`console.log`, `print`) before finishing — use the project's
  existing structured logging if one exists, don't add a new logging library for one line.

## Code Comments

- Comments explain **WHY**, never WHAT.
- No commented-out code in commits.

## Commit Style

```
<type>: <why this change matters>
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`
Subject answers "why" — the diff shows "what".

## On-demand sub-files (`rules/coding/`, excluded from auto-load)

- Producing a code review → `coding/review-report.md` (Code Review Report Format)
- Choosing `.md` vs HTML/Artifact output, or using the Workflow tool → `coding/output-and-workflow.md`
- Cutting a release / changelog → `coding/release.md`
- Folder structure → `coding/project-blueprint.md`
- Per-language checks (type/syntax checker per extension) → `coding/programming-language.md`
