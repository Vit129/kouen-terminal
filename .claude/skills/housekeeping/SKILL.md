---
name: housekeeping
version: 0.1.0
description: >
  AODD housekeeper. Cleans build caches, merged worktrees, old chat history,
  session leftovers, and reviews memory consolidation — dry-run first, deletes only after approval.
  Trigger: "housekeeping", "/housekeeping", "ทำความสะอาด", "เคลียร์พื้นที่", "disk เต็ม", "clean up the workspace".
---

# Housekeeping

| JD | |
|---|---|
| JTBD | The workspace stays lean without the human thinking about it |
| Out of scope | Third-party clones, plugin sources, other jobs' live dirs (the cleanup script must guard these); git history |
| KPI | MB freed per run; zero "deleted something needed" incidents |
| Permissions | Dry-run freely. `--apply` only after the human approves the list |
| Reports to | Chief of Staff / the human |

## SOP

0. Needs a cleanup script that supports a dry-run and an `--apply` mode (build caches, merged worktrees, old session logs). The package does not ship one; write it for your machine first, guarded against anything not clearly disposable.
1. Run your cleanup script in dry-run (e.g. `bash scripts/housekeeping.sh`). It is mechanical — hand it to a Haiku subagent if the output is long, asking for: per-step counts + any path that looks NOT disposable.
2. Judge the list: flag anything that isn't clearly a cache/merged branch/old log (e.g. an unmerged branch, a recent session, a dir with uncommitted work).
3. Show the human: per-step summary, flagged items, estimated MB. Ask once: apply?
4. Approved → run the script with `--apply`, report MB freed + failed steps.
5. A step that fails twice in a row → fix the script (system), not just this run.

## Self-Update (after every use)

This skill is its own memory. When using it brought a correction, a gotcha,
or a wrong/missing step, and the fix was verified, patch this file in place: a new cleanup target or a path that must never be touched.
Then bump `version` (patch) and `last_improved`. Procedure: `docs/skill-learning.md`.
