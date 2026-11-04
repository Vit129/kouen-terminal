# The `redesign` Trigger — Same Content, Different Structural Fingerprint

[source:github.com/Nutlope/hallmark] — adapted from [hallmark `references/verbs/redesign.md`](https://github.com/Nutlope/hallmark/blob/main/skills/hallmark/references/verbs/redesign.md). Scope-detection (single-page vs multi-page), the non-destructive implementation rule, and the inverted-diversification rule for multi-page are ported mechanisms; the design-system-lock step reuses ui-designer's own existing `DESIGN.md`/`design-system/<project>/MASTER.md` conventions instead of introducing Hallmark's separate `design.md` format.

The user is unhappy with the current visual/structural shape of a page — it reads as templated, generic, or "AI-shaped" — but wants the same content, copy intent, and information architecture. `redesign` keeps what works and forces a genuinely different structural fingerprint, not a re-skin.

## Non-destructive implementation rule

`redesign` changes the visual and interaction layer. It does not delete production files by default.

- Never delete existing route files, component directories, or page trees unless the user explicitly asks for deletion or approves a file-level plan that lists the deletions.
- Default to in-place edits of the named files, or additive new components/tokens wired through the existing route.
- If the redesign would require removing multiple components or replacing a route tree, stop and ask for confirmation first.
- Treat PDFs, READMEs, briefs, and docs as reference material for understanding the product, not verbatim page copy — summarize/adapt unless the user explicitly asks for their exact wording.
- Before editing, state the files you expect to modify/create/delete. Any deletion needs explicit confirmation.

## Step 0 — Detect scope first

Decide **single-page** or **multi-page** before anything else — the rule set inverts between them.

**Multi-page signals** (any one fires):
- The target is a directory or a glob.
- The user names more than one file in the brief.
- The user says "the whole site" / "every page" / "the app" / "all the pages".
- The project has multiple route files and the user pointed at the project root.

If any fires → multi-page. Otherwise → single-page.

---

## Multi-page flow — lock a system first, then redesign each page

A multi-page app needs a *design system*, not N unrelated re-skins. ui-designer's diversification rule (`references/diversification-memory.md`) is **wrong here** — across pages of the same product, consistency is the goal, not variety. Redesigning every page with a different pattern/style/accent ships a slop split-personality app even if each individual page passes the Anti-Patterns checklist.

1. **Read the project, then pause.** Walk the target directory, list every page-level file with a one-line description. Note existing design assets (a tokens file, a Tailwind config with brand values, a `design-system/<project>/MASTER.md`, a `DESIGN.md`). Check `.ui-designer/log.json` — if entries show a different pattern/style per page, that confirms the user's complaint.
2. **Produce or reuse the locked system.** Don't invent a new file format — ui-designer already has one:
   - If `DESIGN.md`/`design.md` exists at the project root (per `rules/product-design.md` and Phase 0), that **is** the locked system. Read it, don't regenerate.
   - Otherwise, run `python3 $CLAUDE_HOME/skills/uxui-designer/scripts/search.py "<product type + industry>" --design-system -p "<Project Name>" --persist` to generate and persist `design-system/<project>/MASTER.md` at the project root. State the picks aloud before running with `--persist` — pattern, style, colors, typography — and get the user's go-ahead, same as any Design Mode Step 3-9 pass.
3. **Redesign each page reading from the locked system.** For each target page: read the locked system first (it overrides per-page BM25 search results); pick component/archetype variation only within what the system allows; apply the locked tokens/typography/motion stance as-is — do not swap theme "for variety"; stamp each page's CSS `/* ui-designer · pattern: <name> · style: <name> · design-system: MASTER.md */` (or `design-system: DESIGN.md`) so future audits can verify allegiance.
4. **Diversification rule — INVERTED for multi-page.** Consecutive pages MUST share style, accent, and typography; they may differ on pattern/layout within what the locked system allows. `references/diversification-memory.md`'s "must differ from the last entry" check is suspended for pages stamped `design-system: MASTER.md`/`DESIGN.md` — the system overrides rotation here. `references/audit-verb.md` flags drift from the locked system as a critical finding, not the absence of variety.
5. **Amend, don't override.** If a page genuinely needs something the locked system doesn't allow, amend the system file first (add a documented per-page allowance), don't override locally. The file evolves; per-page overrides don't.

---

## Single-page flow

**What to preserve:**
- Copy intent, factual claims, product names, primary message. Preserve exact wording only when it already lives in the target UI or the user explicitly asks for verbatim copy.
- Information architecture (which sections exist, roughly what order).
- The brand (colors/fonts the user has named, if any).
- The primary action.
- Existing route/component ownership boundaries, unless the user approved a full rebuild.

**What to replace:**
- **The structural fingerprint.** Run the diversification check in `references/diversification-memory.md` against `.ui-designer/log.json` — the new pattern + style pick must differ from the page's own current shape (and ideally from the log's last entry) on at least one axis: pattern, style, or accent hue band.
- Component voice — different button/card/divider treatment.
- Visual rhythm — vary section padding/alignment deliberately instead of uniform spacing.

**What not to replace without confirmation:**
- Route trees, production component directories, or file structure.
- Working app logic — data fetching, auth, forms, analytics, integration code.
- Existing copy pasted from PDFs/docs/markdown unless the user requested verbatim copy.

**Project-level check.** Before treating this as a true single-page redesign, check for a locked `DESIGN.md`/`design-system/<project>/MASTER.md`. If one exists, the project is being designed as a system and the single-page rules don't apply — follow the Multi-page flow's step 3-5 instead (read the system, apply it, inverted diversification). If the user genuinely wants to break from the locked system on this one page, update the system file first, then redesign.

**Output:**

Return the redesigned code plus a short note:
- The pattern + style you picked, and which axis (pattern / style / accent) it differs on from before.
- Why this combination fits the brief better than the original.
- One thing you removed and why.
- The `.ui-designer/log.json` entry appended (per `references/diversification-memory.md`).
