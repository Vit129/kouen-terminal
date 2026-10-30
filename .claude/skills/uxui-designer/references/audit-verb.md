# The `audit` Trigger — Read-Only Quality Check

[source:github.com/Nutlope/hallmark] — adapted from [hallmark `references/verbs/audit.md`](https://github.com/Nutlope/hallmark/blob/main/skills/hallmark/references/verbs/audit.md). Mechanism ported as-is (score against anti-pattern list, stamp-vs-page check, no edits); prose translated from Hallmark's macrostructure/theme vocabulary to ui-designer's Anti-Patterns (Hard Bans) section and pattern/style vocabulary.

This closes a real gap: `audit` was listed as an Implement Mode trigger keyword in SKILL.md's Two Modes table, but nothing routed it anywhere distinct — it fell through to the normal build/polish flow, which edits code. `audit` must never edit code. If you find yourself about to write or modify a file during an audit, stop — that's a different mode.

## What `audit` does

Read the target file(s) the user pointed at (or, if unspecified, the files most recently touched / the whole UI directory — ask if genuinely ambiguous). Score them against the Anti-Patterns (Hard Bans) section of `SKILL.md` and the diversification stamp (if present). Return a ranked punch list. **Make no edits.**

For each finding, return:

- **Tell** — the specific anti-pattern from SKILL.md's Anti-Patterns (Hard Bans) section (Typography / Color / Layout / Motion / Visual) that's violated.
- **Where** — file path and line range.
- **Severity** — `critical` (ships as slop / fails WCAG / breaks structurally), `major` (reads as AI-generated but functions), `minor` (small taste issue).
- **Fix** — one concrete, one-line correction (not a rewrite — a pointer to what would fix it).

Group findings by severity, most severe first. End with a count line: `N critical · M major · K minor`.

## Structural fingerprint check

Beyond the per-rule anti-patterns, `audit` also checks the page's overall shape against the generic AI template: a centered hero, three equal feature cards with icon + heading + text, a CTA band, then a footer — with no asymmetry, no varied spacing, no surprise. If the page matches that shape, flag it as a **critical structural finding** even if every individual color/font/spacing choice technically passes the other checks. This is the same judgment call the Anti-Patterns → Layout section already makes about "identical card grids" and "center everything" — `audit` is where it gets applied systematically instead of only caught incidentally during a build.

## Stamp-vs-page check

If the audited file's CSS carries a `/* ui-designer · pattern: <name> · style: <name> · accent: <band> */` stamp (see `references/diversification-memory.md`), verify the page actually matches what the stamp claims. If the stamp says `pattern: Bento Grid` but the page renders as a single centered column with no grid, flag it as a **critical: stamp lies** finding — the stamp must reflect what shipped, or be removed. This catches drift where a prior ui-designer run stamped one thing and a later manual edit (by a human or a different tool) pulled the page back toward the generic template without updating the record.

## `design-system/<project>/MASTER.md` / `DESIGN.md` audit

If the project has a locked system — `design-system/<project>/MASTER.md` (written by `scripts/design_system.py --persist`) or a `DESIGN.md`/`design.md` at the project root (see `rules/product-design.md` and Phase 0) — read it before grading, then check the audited page against it:

- **System drift.** The page's tokens/fonts/pattern don't match the locked system → `critical: design-system drift`. A per-page pattern/style pick is slop on a system-managed project even if that page would be fine standing alone — see `references/redesign-verb.md` § Diversification rule — inverted for multi-page for why consistency, not variety, is the goal once a system exists.
- **No stamp on a system-managed project** → `major: missing system reference`. Every page on a project with a locked `MASTER.md`/`DESIGN.md` should be traceable to it.

Inversely, on a project **without** a locked system, apply the normal diversification rule from `references/diversification-memory.md`: flag a page that repeats the previous `.ui-designer/log.json` entry on all axes as `minor: variety drift`.

## Output shape

```text
AUDIT: [target]
─────────────────────────────────────────────
CRITICAL
- [Tell] — [file:lines] — [Fix]
...

MAJOR
- [Tell] — [file:lines] — [Fix]
...

MINOR
- [Tell] — [file:lines] — [Fix]
...
─────────────────────────────────────────────
N critical · M major · K minor
```

## When to hand off

`audit` is diagnosis only. If the user wants the findings fixed, that's a separate, explicit step — hand off to Implement Mode's `/polish` or `/harden` (or a fresh build) after the user confirms which findings to act on. Don't chain straight from audit into edits in the same turn.
