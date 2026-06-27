# Combined Agent Terminal — Decisions
**Date:** 2026-06-27
**Source:** Warp + CMUX + Otty gap analysis

---

## Context

Harness already covers CMUX's core pane API (`spawnSession`, `splitPane`, `sendPaneText`, `readPaneOutput`, `harnessSpawnAgent`, etc. via harness-mcp). The remaining gaps come from Otty and Warp.

### Confirmed gaps

| # | Feature | Source | Decision |
|---|---|---|---|
| 22 | OSC 26 Terminal Agent Protocol | Otty | **Build** — standard protocol lets ANY agent report status without custom hooks per agent |
| 23 | Pane-state visual indicators | CMUX | **Build** — use existing `AgentSnapshot.activity` + new gutter badge per pane |
| 24 | Fork & Branch sessions | Otty | **Build** — clone current tab → new tab; reuse `LayoutDescriptor` snapshot infrastructure |
| 25 | Agent approval feed | CMUX | **Build** — inline approve/deny UI when agent requests permission via OSC/IPC |
| 26 | Multi-step Agent Mode | Warp | **Defer** — large, overlaps with existing Claude Code UX; wait for demand |

---

## Decision 1 — OSC 26 scope

**OSC 26** (Otty's proposal): `\x1b]26;key=value;key=value\x07`

Keys we support:
- `identity=<agent-name>` — which agent is running (claude, codex, etc.)
- `status=<idle|working|waiting_input|error>` — current agent state
- `progress=<0-100>` — optional progress %

**Why OSC not IPC:** agents already have PTY access. OSC sequences work without any extra socket/pipe setup — agent just `print()`s the escape sequence.

**Who sends it:** agent hooks (`~/.harness/hooks/`) emit OSC 26 on notification events. Claude Code hook updated to emit on start/finish/waiting.

---

## Decision 2 — Pane indicator placement

Options:
- A) Tab bar badge (tab level, not pane level)
- B) Pane gutter dot (per-pane, always visible)
- C) Title bar suffix (like `· working…`)

**Decision: B + C** — gutter dot for at-a-glance status, title suffix when agent is active. Uses existing `SurfaceShellTracker` CWD update path for propagation.

---

## Decision 3 — Fork & Branch mechanics

**Fork creates:** a new tab with the same CWD + a copy of the visible scrollback (not full history — too large). Shell starts fresh in same dir.

**Branch (stretch):** also restore shell history (`~/.zsh_history` cursor position). Defer unless trivially implementable.

**Trigger:** `⌘⇧K` (K = fork) — not taken. Menu: Session → Fork Tab.

---

## Decision 4 — Approval feed trigger

**How agent requests permission:** two paths:
1. OSC: `\x1b]26;status=waiting_input;prompt=<text>\x07`
2. Existing: Claude Code already emits permission prompts in PTY stream — detect by pattern

**UI:** `AgentApprovalBar` — slim bar above Composer area, shows agent + prompt text + Allow / Deny buttons. Fires back `\n` (Allow) or `\x03` (Ctrl-C / Deny) to the pane.

---

## Decision 5 — Multi-step Agent Mode (deferred)

Defer Phase 26. Reason: Warp's Agent Mode works because Warp controls the AI model directly. Harness delegates to CLI agents (claude, codex) — multi-step would require wrapping their output parsing. High effort, uncertain UX. Revisit when OSC 26 is live and agents can report step boundaries.
