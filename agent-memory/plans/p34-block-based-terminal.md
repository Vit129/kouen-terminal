# P34 — Block-Based Terminal (Command Grouping)

Status: **Planning**
Priority: **P2** — competitive gap vs Warp, not a blocker; power-user terminal stack (vi, fd,
fzf, zoxide, ripgrep) already ships, this is the remaining "Block-based terminal" row from
`competitive-position.md`'s gap table.
Owner surface: `HarnessTerminalEngine` (VT parser/scrollback), `TerminalHostView`,
`GridCompositor`, new `TerminalBlockStore`/`TerminalBlock` model
Created: 2026-07-02
Depends on: shell-integration OSC hooks (already shipped — `PR-35 feat: shell-integration
auto-inject at spawn`) for command-start/command-end boundary detection.

---

## Why

Not a code-analysis feature — do not confuse with LSP. LSP (`harnessErrors` MCP tool, P4)
diagnoses **source files**. Blocks group **command + its own output** in the terminal
scrollback itself, as a distinct structural unit instead of one continuous stream.

Warp's model (reference, not to copy pixel-for-pixel): each shell command + its output becomes
one visually and programmatically distinct Block — select/copy/share/bookmark independently,
without bleeding into the command before or after it in scrollback.

Why this fits Harness specifically, on top of "closes a gap vs Warp":
- Agent output is exactly the case blocks solve. A long `npm test` or `swift build` run
  produces output that's currently one continuous scrollback blob — pulling just "the last
  command's output" to hand to another agent pane, or to a Harness MCP caller, means either
  manual selection (error-prone, can bleed into the previous command) or dumping the whole
  scrollback and letting the agent guess where one command ends and the next begins.
- MCP payoff: a `harnessGetLastBlock`/`harnessGetBlock(id:)`-shaped MCP tool becomes possible
  once blocks are real objects instead of raw scrollback ranges — agents get exact command
  output on request, not "read N lines of scrollback and hope."
- Reuses infrastructure already built for file preview / hidden files (see F3) rather than
  inventing a new interaction model from scratch.

## Non-goals (this plan)

- Command palette / YAML workflows (Warp's separate feature, not requested)
- Cloud sharing / permalink for blocks (Warp Teams feature — no cloud sync in Harness by design,
  see `competitive-position.md` gaps table)
- Rewriting the VT parser or scrollback storage model — blocks are a layer on top of existing
  scrollback (command-start/end markers), not a new terminal engine
- Alias expansion / command inspector (Warp's input-editor features, different surface)

---

## Feature Specs

### F1 — Block boundary detection — P0

- Shell integration already injects OSC sequences at spawn (PR-35) — extend to emit
  command-start (`OSC 133;A` / prompt-start convention, or reuse existing marker if
  shell-integration already tags this) and command-end (exit code + duration) markers.
- `TerminalBlock` model: `id`, `command: String`, `startOffset`/`endOffset` (scrollback byte or
  line range — reuse the same range concept `ScrollbackFileTests`/`ScrollbackPersistenceTests`
  already exercise), `exitCode: Int32?`, `startedAt`/`finishedAt`.
- `TerminalBlockStore` per pane, appended as boundaries are detected — do not retroactively
  rescan existing scrollback; blocks start applying from when the pane's shell integration is
  live, same boundary as the existing OSC 133 command-block selection (`⌘-click output block`
  in the terminal-editing shortcut table) already uses.

### F2 — Block-aware selection and actions — P0

- Extend the existing `⌘-click output block` shortcut (already selects an OSC 133 command
  block, per `docs/KEYBINDINGS.md`) to route through `TerminalBlockStore` instead of
  re-deriving the range ad hoc — single source of truth for "what counts as a block," same
  rule P33 F2 applied ("reuse the data already flowing" instead of parallel implementations).
- Actions on a selected block: Copy (command + output), Copy Output Only, Copy Command Only,
  bookmark (local only — no cloud share, see non-goals).
- Visual grouping: subtle background tint or left-edge marker per block on hover, distinguishing
  it from plain scrollback — should not require a mode switch or slow down normal typing.

### F3 — MCP block access — P1

- `harnessGetLastBlock(surfaceID:)` and `harnessGetBlock(surfaceID:, blockID:)` MCP tools,
  following the same policy-gating pattern as the existing 27 `harness-mcp` tools
  (`architecture/mcp-server.md`).
- Payoff: an agent asking "did the last build pass" gets the exact block (command, output,
  exit code) instead of a scrollback dump it has to parse itself.
- Depends on F1 shipping first — no block store, nothing for MCP to read.

### F4 — File preview / hidden-files parity note (not new work, cross-reference)

- File preview already supports both single-click (quick preview) and double-click (open in
  editor tab) per the existing sidebar file-tree interaction; hidden files/folders toggle
  already exists (`f46b6ca feat(file-tree): add toggles to show hidden files and folders`).
- Called out here only because blocks should follow the same "fast default action, escape
  hatch for the heavy view" interaction pattern already established by file preview and by the
  git-panel quick-look popover (see `feature-provenance.md` Git Panel section) — single-click
  a block = quick inline actions, not a forced modal or new tab.

---

## Open Questions (resolve before F1 implementation)

- Does shell-integration's existing OSC injection (PR-35) already emit `133;A`/`133;C`/`133;D`
  boundaries, or does it need extending? Check `docs/shell-integration/*.{zsh,bash,fish}`
  before assuming a gap.
- Retroactive scrollback (pane opened before this ships) — blocks simply don't exist for that
  history, or best-effort backfill by scanning for prompt markers? Leaning toward "don't exist"
  to avoid an expensive rescan; confirm this is acceptable before F1.
