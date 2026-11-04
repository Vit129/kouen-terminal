---
name: ai-sdlc
description: Full Dev/QA feature workflow (interview → architect → QA design RED → dev GREEN → QA verify, with 3 approval gates). Use when the user runs /ai-sdlc, says "ทำฟีเจอร์ใหม่", "new feature", "วางแผนฟีเจอร์", "เริ่มโปรเจกต์", "full workflow", or starts a multi-file feature/refactor that needs QA coverage and tracked progress.
version: 1.0.1
---

# ai-sdlc

Read `rules/ai-sdlc-workflow.md` (installed under your Claude home, `~/.claude/rules/`) now and follow it phase by phase for this feature: load each phase file from its Phase map (`skills/ai-sdlc/phases/`) only when you reach that phase. Pull the
`references/*.md` files next to this SKILL.md only when the phase you are in points to them.

- Argument = feature slug. Create `$AODD_PLANS/<slug>/ai-sdlc-task-progress.md` yourself
  (`AODD_PLANS` defaults to `~/.aodd/plans`; `python3 hooks/_aodd_paths.py plans` prints the resolved dir).
- The 3 approval gates are real stops even in auto mode — the user opted in by invoking this.
- `hooks/done-gate.py` blocks stopping while that progress file still has `- [ ]` boxes,
  so keep checkboxes current as you go, not at the end.
- Runs as `chief-of-staff` full: Phase 1 output is the brief (`$AODD_PLANS/<slug>/brief.md`),
  each phase dispatches to its team, and the run ends with the `auditor` + the CEO report shape
  (Result / Evidence / Needs your decision / Cost). `hooks/done-gate.py` blocks Done until the auditor ran.
- Skill-by-situation routing: `references/skill-routing.md`.

## Read before each phase (memory dir from the `agent-memory` skill; open only matching sections)

| Before | Read first |
|---|---|
| Any phase / "continue" | this feature's progress file → resume at its first `- [ ]` (session start lists unfinished ones) |
| 1 Interview | `INDEX.md` → `knowledge/` notes for this domain; earlier plans of the same feature |
| 2 Architect | `PRODUCT.md` / `ARCHITECTURE.md`, `knowledge/` decision records, the governing skills' pitfalls |
| 3 QA design | `knowledge/` notes on known bugs in this area (each one gets a regression test) |
| 4 Dev / 5 Verify | the governing skills' pitfalls, `knowledge/` notes on known bugs |

## Self-Update (after every use)

This skill is its own memory. When using it brought a correction, a gotcha,
or a wrong/missing step, and the fix was verified, patch this file in place: a phase rule or pitfall goes in the phase's section or the matching `references/` file.
Then bump `version` (patch). Procedure: `docs/skill-learning.md`.
