# Context — harness-terminal

## Now
- **Task:** Release 3.6.0 + agent-memory infrastructure normalization
- **Branch:** main
- **Latest release:** v3.6.0 (build 161)
- **Status:** complete

## What Was Done This Session (2026-06-21)
1. ✅ Released 3.6.0 (build 161) — P26 inline AI chat, P27 pane drag-and-drop, browser auto-retry
2. ✅ Normalized agent-memory filenames to UPPERCASE across all 4 projects
3. ✅ Updated all docs (CLAUDE.md, AGENTS.md, GEMINI.md) to reference UPPERCASE filenames
4. ✅ Designed + implemented shared memory-protocol architecture:
   - Canonical: `~/.claude/scripts/shared/memory-protocol.md`
   - Delivery: symlink via `.ai/memory-protocol.md` per project
   - Install: `~/.claude/scripts/install-memory-protocol.sh`
5. ✅ Updated graphify, built, committed, pushed all repos

## Open Questions
- [open] `@.ai/memory-protocol.md` auto-include works for Claude Code only. Codex/Gemini/Kiro need explicit "read .ai/memory-protocol.md" instruction instead of `@` directive.
- [open] 3 remaining crashes on 2026-06-17: zombie-view (same mechanism as RL-040). Not yet root-caused.
- [open] Per-session-tab focus not restored on cmd+1/2/3. Partial fix not verified.

## Key Files
- `~/.claude/scripts/shared/memory-protocol.md` — shared protocol (single source of truth)
- `~/.claude/scripts/install-memory-protocol.sh` — installer
- `agent-memory/knowledge/ui/browser-pane.md` — updated with auto-retry section

## Session Notes
- Build: `make preview` (uses `.harness-preview/` dir)
- `swift build` passes clean on 3.6.0
- Never reparent Metal terminal surfaces — causes black screen (RL-004)
