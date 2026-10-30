# Output Format & Workflow Fan-out

Sub-file of `rules/coding.md`.

## 6. Visual Output: .md vs HTML/Artifact

- **Test scene/structure docs, specs, scaffolding** → always `.md`/text. Never a checked-in `.html` file — markup overhead costs tokens on every future AI read with no readability gain (see § 2).
- **UI prototype/demo that a human needs to actually see** (layout, interaction, "does this look right?") → use the **Artifact tool**, not a workspace `.html` file. Rendering it beats describing it in chat text — chat descriptions are lossy and still cost tokens, plus the inevitable "not quite like that" rework loop.
- **Actual test scripts** (Playwright/Vitest/etc.) → stay as code (`.ts`/`.js`). They execute, they aren't viewed — HTML adds nothing.
- Treat demo/Artifact HTML as throwaway scratch. Once the human approves it, port the agreed UI into the real framework component — don't ship the demo file as production code.

## 7. Workflow Fan-out Pattern Check

Before authoring a multi-agent `Workflow` script for an audit/sweep/broad-coverage task (find bugs across a codebase, cross-project scan, "find anything worth flagging" — the search space isn't knowable upfront), apply this decision rule:

- Dimensions/targets known upfront (e.g. reviewing a diff for bugs/perf/security) → fixed-dimension pipeline (`DIMENSIONS` array), as usual.
- Dimensions/targets NOT knowable upfront → self-selecting flock pattern (3 rules: separation/alignment/cohesion), batch size 2-3 concurrent agents per round (not 5+ — measured 40% collision rate at batch-5).

Skip this check for a normal fixed-dimension Workflow where the dimensions are already obvious from the task.

