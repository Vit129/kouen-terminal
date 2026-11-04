# PRODUCT.md / ARCHITECTURE.md / DESIGN.md Convention

## Contents

- [What each file is](#what-each-file-is)
- [Same file everywhere, scale the content not the format](#same-file-everywhere-scale-the-content-not-the-format)
- [How skills use these files](#how-skills-use-these-files)
- [Authoring](#authoring)
- [FigJam to Markdown Converter](#figjam-to-markdown-converter)
- [User Flow Generator — Mermaid from Requirements](#user-flow-generator--mermaid-from-requirements)

PRODUCT.md and DESIGN.md are optional per-project docs — genuinely not needed where there's
no product vision or UX to speak of (a backend-only CLI tool has neither). ARCHITECTURE.md
is different: **every project gets one**, small or large — only its *content* scales with
project size, from a one-bullet stack note to a full living doc (see § Same file
everywhere below). When present at project root, these are the canonical source for
their domain — read them before designing, don't re-derive from scratch or guess. Named
so each one signals its own role at a glance:

| File | Role | Answers |
|---|---|---|
| **PRODUCT.md** | PO | "what are we building, for whom, why" |
| **ARCHITECTURE.md** | Architect + Dev + QA | "how is it built, what do things get called" |
| **DESIGN.md** | UX/UI | "what should it look/feel like" |

Three files, one per role — not more, plus the domain glossary file (`CONTEXT.md` at project root, or `CONTEXT-MAP.md` pointing to per-context `CONTEXT.md` files in a multi-context repo). Don't invent a different `GLOSSARY.md`/`ADR-*.md` pile outside that convention.

## What each file is

- **PRODUCT.md** — Product Context: vision, target users, core problems, core features, out of scope, success metrics.
- **ARCHITECTURE.md** — System Architecture: constraints, stack decision (with reasoning — pattern: dated entries, "why not the alternative" reasoning, not just a bare tech list), data model, hosting. Living doc, appended to as real decisions/bugs get found — not rewritten from scratch each time. Does **not** hold the domain-term dictionary — that's `CONTEXT.md` (below).
- **DESIGN.md** — Design Language: design direction, colors, typography, layout, components, avoid-list.

### Domain glossary: CONTEXT.md

The project's domain-term dictionary lives in `CONTEXT.md` (project root, or per-context under `src/{context}/CONTEXT.md` for multi-context repos pointed at by a root `CONTEXT-MAP.md`) — keep terms sharp: challenge vague words, cross-reference related terms, list words to avoid under `_Avoid_`. This rule only draws the boundary: ARCHITECTURE.md holds constraints/stack/data-model/hosting, `CONTEXT.md` holds the term dictionary — don't let either drift into the other's job.

> **Not the same file as** `$AODD_PLANS/<feature>/GLOSSARY.md` — that's a separate, per-feature requirements-capture output (written during requirements gathering, read by the ai-sdlc workflow and `test-scenario` as their Requirements Source), allowed to hold specs/findings that `CONTEXT.md`'s glossary-only rule would otherwise forbid. Don't apply `CONTEXT.md`'s "glossary only" discipline to the per-feature file, and don't write feature-specific requirement notes into `CONTEXT.md`.

### ADRs stay separate files, deliberately

Architecture Decision Records (`docs/adr/NNNN-title.md`) are NOT folded into ARCHITECTURE.md — they're individual, dated, immutable records of one hard-to-reverse decision each, which is a different shape than a living "current state of the architecture" doc. Record one only when all three are true: hard to reverse, surprising without context, and a real trade-off existed. This bar is already selective by design — most projects will have zero or very few ADRs, so this isn't the "too many markdown files" problem the PRODUCT/ARCHITECTURE/DESIGN consolidation targets.

### Feature & project planning: `$AODD_PLANS/<feature>/<feature>-architecture.md`

When planning a new project or feature, create its architecture document and technical plan directly in `$AODD_PLANS/<feature>/<feature>-architecture.md` (or `<feature>-architecture/`), next to `ai-sdlc-task-progress.md` and the feature's other artifacts, so the whole context lives in one place. `ARCHITECTURE.md` at the project root stays the living overview of the whole system, updated with the main decisions.


## Same file everywhere, scale the content not the format

Every project gets an `ARCHITECTURE.md` — small or large, script or full app. What scales
with project size is how much goes in it, not whether the file exists: this is the same
"no template, scale depth to the task" rule `rules/ai-sdlc-workflow.md` Phase 2 already
applies to design in general, applied here instead of carved out as a separate exception.

- **Trivial project** (single-file script, one-off CLI tool, config-only repo): `ARCHITECTURE.md`
  can be one bullet ("stdlib `argparse`, no framework needed") — still a real
  file at project root, not a note buried in chat history that's gone once the session ends.
- **Real project** (works with AI agents often, multiple pages/features, consistent
  branding needed, multiple contributors, or long-lived): the same file grows into the
  living doc described above (dated entries, "why not the alternative" reasoning, data
  model, hosting).

The failure mode this replaces: a project starting "too small to bother," the decision
never written down anywhere durable, then growing past the point where anyone remembers
*why* a choice was made. One committed bullet on day one costs nothing; reconstructing
the reasoning after the fact, or re-deriving it from git blame, does.

**Making the actual decision** (not just recording it) — for a real stack/interface
choice with genuine trade-offs (not "which of two nearly-identical libraries"), design deep modules with a small interface and a clear seam before writing
it into `ARCHITECTURE.md`. For a trivial one-line note, nothing more is needed.

## How skills use these files

- `rules/ai-sdlc-workflow.md`'s Architect phase — reads `PRODUCT.md` if present, checks new feature scope against it before designing; writes/updates ARCHITECTURE.md, and updates `CONTEXT.md` as design resolves bounded contexts and terms.
- `uxui-designer` — Phase 0 reads `DESIGN.md` if present as the existing design system (skip regenerating tokens); Context Gathering reads `PRODUCT.md` for target audience/use cases instead of asking when already documented.
- Any skill starting new-feature or UI work on a project root containing these files should read them first, the same way `graphify-out/GRAPH_SUMMARY.md` is read for code impact when graphify is used.

### Reading Priority for Agents & Devs

When exploring, developing, or testing in any repo containing these standard files:
1. **Understand the concept or feature:** read `CONTEXT.md` (domain glossary / ubiquitous language) to learn the system's vocabulary and concept model without reading code, and use its standard terms (avoid the words listed under `_Avoid_`).
2. **Write code, design architecture, or write automated tests:** read `ARCHITECTURE.md` (Architect + Dev + QA) for constraints, stack decisions with reasoning, data model/persistence, subsystems, and QA verification invariants / regression suites, before writing code or tests.
3. **Check scope and design:** read `PRODUCT.md` for PO vision/scope and `DESIGN.md` for the UX/UI design system and tokens.

## Authoring

Write from real repo facts (README, package.json/deps, existing color/font/component code, docs) — don't invent vision or tokens not evidenced in the repo. If a section would be pure invention, say so plainly and keep it thin rather than padding.

For the writing itself (not the facts): use a predictable structure, wording that reliably triggers the right read, and context pointers rather than inlined material, the same way you would write a skill or CLAUDE.md.

---

## FigJam to Markdown Converter

Convert plain text pasted from FigJam boards into structured requirements markdown.

### Input
`#figjam [PREFIX] {Pasted_Text_from_FigJam}`

**How to copy from FigJam:**
1. Select all elements on the FigJam board (Cmd+A)
2. Copy (Cmd+C) — gets plain text of sticky notes, text boxes, tables
3. Paste in chat with the prefix (if any)

### Process
1. Parse text structure: Headers (`:`, `::`, short lines), Lists (`-`, `•`, numbers), Tables (aligned columns/tabs), Flows (numbered sequences).
2. Infer sections: "Goal" → Goal, "Requirement" → Requirement, "Persona/User/Role" → Persona, Numbered flows → Steps.
3. Structure as markdown with appropriate headers.

### Output
- Location: Ask user where to save if not obvious from project structure.
- Naming: With PREFIX: `{Prefix}-Requirement.md` | No PREFIX: `{InferredName}-Requirement.md` (Example: `#figjam Login {paste...}` → `Login-Requirement.md`).
- Must end with:
  ```markdown
  ## 📌 Source
  > Converted from FigJam board (copy-paste method)
  > Date: {YYYY-MM-DD HH:mm}
  ```

---

## User Flow Generator — Mermaid from Requirements

Generate clean Mermaid flowcharts from user requirements.

### Command
`gen user flow {name}` + paste requirement text → direct analysis

### Rules & Formatting
- **Mermaid Nodes:** `([start])` Start/End | `[action]` Process | `{decision?}` Decision | `[/input/]` Input
- **Status Emoji:** ✅ Success | ❌ Error | ⚠️ Warning | 🔄 Retry
- **Design rules:** Happy path first (error branches split separately), Decisions phrased as questions `{has access?}`, Short labels (no `<br/>`), 5-20 nodes per diagram (use subgraph if > 20), No dead ends (every path reaches End).

### Output Template
```markdown
📊 User Flow: {Feature} {Title}

```mermaid
flowchart LR
    Start([Start]) --> [Main step]
    [Main step] --> {Condition?}
    {Condition?} -->|Yes| [Success]
    {Condition?} -->|No| [❌ Error]
    [Success] --> End([End])
    [❌ Error] --> End
```

💡 Export: FigJam Plugin "Mermaid to FigJam"
```
