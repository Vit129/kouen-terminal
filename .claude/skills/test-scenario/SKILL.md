---
disable-model-invocation: true
name: test-scenario
description: >
  skill used when user asks "design test scenarios", "ออกแบบ test scenarios",
  "create test cases", "สร้าง test cases", "generate test data", "สร้าง test data",
  "export to CSV", "export CSV", "add test scenario", "เพิ่ม test scenario",
  "quick scenario", "สร้าง scenario เร็วๆ", needs full test scenario design cycle:
  analyze → design → data → export.
version: 2.1.0
---

# Test Scenario

Always read `references/ts-design.md` (design guidelines + process + 9-column CSV format, all in one file) before designing or exporting — these are the authoritative rules, not optional background reading.

## Requirements Source (before Step 1)

Where the requirements come from is project-specific — this skill doesn't hardcode a tracker:
- Already have them (a spec or requirements-gathering session) → use `$AODD_PLANS/<feature>/GLOSSARY.md` or the requirements doc directly
- Tracked in GitHub Issues/Jira/Linear/etc. → pull with a script you write for that tracker's API, or paste the issue text manually
- Neither → interview the requester (one question at a time) to extract them first

## Full Workflow (MANDATORY for new feature — execute ALL steps in order)

```
Step 1: Reuse Analysis & Invariants → references/ts-design.md §10
Step 2: Batch 1 — Success           → references/ts-design.md §12 (write .md + .csv directly) → summary → wait approval
Step 3: Batch 2 — Alternative       → references/ts-design.md §12 (write .md + .csv directly) → summary → wait approval
Step 4: Batch 3 — Edge              → references/ts-design.md §12 (write .md + .csv directly) → summary → wait approval
Step 5: Data Generation             → references/ts-data-gen.md  (write file) → wait approval
Step 6: CSV Self-Check & Finalize   → references/ts-design.md §15 (verify 9-column integrity)
Step 7: Done ✅
```

**Hard rules:** Reuse Analysis is mandatory before design. Each batch MUST pause for user approval. AI MUST NOT self-approve. As batches are approved, write directly to BOTH `.md` and `.csv` files. Data Gen and CSV export are never optional.

## Batch Skip Guard (fires immediately on any skip signal)

If user says "ข้าม", "skip", "ข้ามไป automation", or skips any batch:

```
⚠️ You are skipping [Batch X / Data Generation]
Steps that will be skipped as a result: [list]
Choose:
1. Skip everything including Export (no CSV for automation)
2. Skip, but keep the CSV from what already exists
3. Continue as normal (do not skip)
```

- NEVER silently skip CSV Export — always surface consequence to user
- Guard fires ONCE per skip event, not repeatedly

## When to Load Each Reference

| Trigger | Load |
|---------|------|
| Designing scenarios — design standards, process, and CSV schema (title format, priority levels, categories, paired design, test techniques, language policy, reuse analysis, batches, 9-column CSV direct-write, validation checklist) | `references/ts-design.md` |
| After design approved — generate test data | `references/ts-data-gen.md` |
| "add scenario", "quick scenario", "modify scenario" | `references/ts-maintenance.md` (Edit Mode) |
| "parse scenarios", "extract automatable cases", "read CSV", "extract test cases for automation" | `references/ts-maintenance.md` (Read Mode) |
| "export to Jira/ADO/Sheets/{tracker}" | `references/export-{tracker}.md` — only if this project has one, see Extending to a Specific Tracker below |

## Extending to a Specific Tracker (Jira, Azure DevOps, Google Sheets, etc.)

`ts-design.md`'s 9-column schema (§15) is the canonical, tracker-agnostic model — **never edit it to fit one tracker's fields.** If a project needs to push scenarios into a specific tool, add a sibling exporter file instead:

1. Create `references/export-{tracker}.md` (e.g. `export-jira.md`, `export-ado.md`) in *this* skill's `references/` — never modify `ts-design.md`, `ts-data-gen.md`, or `ts-maintenance.md` to add tracker-specific fields.
2. In that file, map the 9 canonical fields (TS-ID, Title, Description, Pre-conditions, Test Steps, Expected Result, Actual Result, Priority, Automation Status) to the tracker's real fields/format — e.g. Jira's Summary/Issue Type/custom fields, or ADO's Area Path/Iteration Path/`System.AssignedTo` (fields this skill deliberately leaves out — they come back here, scoped to this file only, if a project actually needs ADO).
3. Add one row to the "When to Load Each Reference" table above pointing at it (already added).
4. Google Sheets is usually the exception — a 9-column CSV pastes into Sheets directly with no field translation needed, so only add `export-sheets.md` if the project needs live writes via the Sheets API instead of a one-time paste.

This keeps the core skill portable: a project with no tracker never loads any `export-*.md` file, and adding one tracker's mapping never risks breaking another's.

## Shortcut Commands

| Command | Skips | Use when |
|---------|-------|----------|
| `/ts new` | Nothing | New feature scenario design |
| `/ts quick` | Steps 1, 5, 6 | Adding/modifying 1-2 scenarios in existing file |
| `/ts read` | Steps 1-6 | Parsing existing scenarios for automation |

## Gotchas

- **Skipping reuse analysis** — designing from scratch without checking existing patterns → duplicate scenarios
- **Bulk batch dump** — writing all 3 batches at once without pausing → user can't course-correct early
- **Using HTML in scenarios** — writing `<div>`, `<ol>`, or `<ul>` instead of clean plain markdown
- **Skipping test data** — finishing scenarios without concrete test data → QA/automation has no sample data
- **CSV out of sync** — writing markdown without updating the matching 9-column CSV file

## Anti-Rationalization

| Excuse | Counter |
|---|---|
| "New feature, nothing to reuse" | Auth flows, CRUD, error handling repeat across features. Skip reuse analysis → duplicate scenarios and inconsistent naming. |
| "I'll write all 3 batches at once to save time" | User can't course-correct until you're already done. Batch approval exists to catch this early. |
| "Scenarios are self-explanatory, skip data gen" | Automation and QA can't execute tests without concrete data. A scenario without data is an ambiguous spec. |
| "Markdown is enough, skip CSV" | Downstream automation planning (`rules/ai-sdlc-workflow.md` Phase 3, Read Mode in `ts-maintenance.md`) relies on structured 9-column CSV for clean parsing. |

## Red Flags

- 🚩 All 3 batches in one output, no approval pause between them
- 🚩 No reuse analysis or acceptance criteria invariants documented
- 🚩 HTML tags (`<div>`, `<ul>`, `<ol>`, `<br>`) used in scenario steps/conditions
- 🚩 CSV file missing or not matching the 9-column schema
- 🚩 Test data section empty or filled with vague placeholders

## Verification

Before declaring test scenario design complete:
- [ ] Reuse analysis ran first
- [ ] All 3 batches delivered with user approval between each
- [ ] Every scenario has Title, Pre-conditions, Steps (with test data), Expected Result, Priority, Automation Status
- [ ] No HTML tags in markdown or CSV steps/conditions
- [ ] Test data generated (Valid + Boundary + Edge)
- [ ] Matching 9-column CSV written directly and verified against `references/ts-design.md` §15 checklist

## Human-in-the-Loop Points

| Step | Approval | When |
|------|----------|------|
| Each scenario batch (Success/Alternative/Edge) | Approve/refine per batch | After each of the 3 batches — must pause |
| Priority assignment | Confirm ranking | Before finalizing metadata |
| Batch skip | Skip all / export partial / continue | Whenever a batch/step is skipped |

## Self-Update (after every use)

This skill is its own memory. When using it brought a correction, a gotcha,
or a wrong/missing step, and the fix was verified, patch this file in place: an approved scenario pattern, or what made a draft get rejected.
Then bump `version` (patch) and `last_improved`. Procedure: `docs/skill-learning.md`.
