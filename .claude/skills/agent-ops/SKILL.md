---
name: agent-ops
version: 0.2.1
description: >
  AODD "Agent Ops" learning loop. Reads the audit reports, git history and skill usage and
  proposes team changes (add/merge/retire a skill or agent, fix a rule that keeps causing
  rework). Proposals only: the CEO approves every change. Also the on-demand usage check before
  building, keeping, comparing or pruning a skill/workflow/rule.
  Trigger: "agent ops", "/agent-ops", "review the agent team", "is this worth it", "which skills are unused",
  "compare with X", "ปรับทีม", "คุ้มมั้ย", "ใช้จริงมั้ย", monthly.
---

# Agent Ops

| JD | |
|---|---|
| JTBD | The team gets better every month from real work, not from guesses |
| Out of scope | Applying changes. Deleting skills/agents/memory |
| KPI | Share of audited sessions that end FAIL/DISPUTED trending down month over month |
| Permissions | Read; write only the report file |
| Reports to | CEO |

## SOP

1. Gather (mechanical, a Haiku subagent is fine):
   - audit reports: `$AODD_REPORTS/audit-*.md` and `done/` for the period; count verdicts (`verdict:` frontmatter) and note which rows failed
   - skill and rule changes: `git -C <claude-home> log --since=<date> --stat -- skills rules agents hooks`
   - skill usage: count `Skill` tool calls per skill name in recent session transcripts under `<claude-home>/projects/` (`grep -o '"skill":"[^"]*"'`), plus how many `ai-sdlc-task-progress.md` files exist under the plans dir (`python3 hooks/_aodd_paths.py plans`)
   - skill-capture nudges that fired: `$AODD_STATE/skill-capture/` (one marker per session)
2. Find (your judgment): repeated FAIL/DISPUTED reasons, skills never used in 60 days, the same correction recurring without the governing skill being patched, rules that are always loaded but rarely used.
3. Propose at most 5 changes, each: **Why** (the problem, with numbers and where they came from) → change → expected effect → how we'll know next month.
4. Write `$AODD_REPORTS/agent-ops-<YYYY-MM>.md`; tell the CEO the path. Nothing is applied until approved.

Extension: if `$AODD_HOME/extensions/agent-ops.md` exists, also follow it (extra gather steps, extra report sections). Nothing else is pluggable.

On-demand usage check ("is this worth it", before adding or comparing a skill): decide from the counts above, not impressions. Before calling something a gap, grep `scripts/`, `hooks/` and `git log` for an existing or retired implementation. Verdict per item: used → keep; unused for months → archive or make opt-in; always loaded but rarely used → move behind a skill; must never be skipped → a hook, not prose.

Proposals from other agents (`agy-proposal-*.md` in `$AODD_REPORTS/`) are triaged the same way: run `python3 scripts/check_agy_proposal.py <file>` first (it auto-rejects one without the evidence fields), then accept or reject each with a reason. Decided files move to `$AODD_REPORTS/done/` with the decision noted.

## Pitfalls (verified)

- A learning/usage metric that reads ~0% for weeks usually counts the wrong thing: check it against real transcripts for every output type (skill patches, project skills, Bash reads) before rebuilding the system.
- Comparing us with an external tool: fetch its upstream README/source and cite it, and re-check that our own scripts still match the current setup; never compare from memory or a pasted post.
- Skill usage counts miss user-typed slash commands: `"skill":"<name>"` only catches Skill tool calls. Also count `<command-name>/<plugin>:<skill>` in the transcripts, or a skill the user runs by hand reads as unused.
- Retiring a skill or plugin: after removing its references, grep for its sub-command names too (`/<command>`, `<plugin>:<skill>`), not only the plugin name; a bare `/<command>` left in a guide keeps the dependency alive.

## Self-Update (after every use)

This skill is its own memory. When using it brought a correction, a gotcha,
or a wrong/missing step, and the fix was verified, patch this file in place: a measurement that misled, or a proposal shape that the CEO rejected, goes in the steps above.
Then bump `version` (patch). Procedure: `docs/skill-learning.md`.
