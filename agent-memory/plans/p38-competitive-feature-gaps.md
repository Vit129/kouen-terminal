# P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed)

> Source: competitive analysis session 2026-07-11 comparing Kouen against cmux, Supacode,
> Superset (all three: Ghostty-based "run N agents in parallel" command-center terminals),
> WezTerm, and Zed's Agent Panel / Terminal Threads. Full comparison table not persisted
> elsewhere — this plan is the durable artifact of that analysis. Ranked by leverage: how much
> of the gap is already closed by existing infra (worktree isolation, block capture, MCP tools)
> vs net-new build.

## Where Kouen already leads (don't rebuild these)
- Daemon-owned sessions surviving restart + remote/headless daemon over SSH (Linux) — no
  competitor in this set does this.
- `kouen-mcp` browser control (open/snapshot/interact/screenshot/network/cookies/storage) —
  deeper than Superset's 2026 in-app-browser addition, which has no MCP tool surface this rich.
- Built-in editor + LSP across 21 languages — none of cmux/Supacode/Superset have this; Zed has
  it but Zed isn't terminal/multiplexer-first.
- Per-tab git worktree auto-isolation already exists (`WorktreeAutoIsolateService` +
  `WorktreeManager`, keyed off branch change) — the *substrate* cmux/Supacode/Superset build
  their whole pitch on. We have the substrate; we're missing the UI on top (Phase A).
- Command-boundary block capture already exists (P34: `TerminalBlock`, `BlockSummary`,
  `kouenGetLastBlock`/`kouenGetBlock`) — this is most of what Zed's "Terminal Threads" needs;
  we're missing the thread-level UX wrapper (Phase C).

## Current architecture relevant to these gaps
```
WorktreeAutoIsolateService (Apps/Kouen/.../Services)
 └─ observes KouenActiveTabGitBranchDidChange → WorktreeManager.create/list
     → tab.worktreePath set, one worktree per non-default branch per workspace

AgentDetector → AgentKind (KouenIPC/AgentSnapshot.swift: codex/claudeCode/cursor/grok/pi/
hermes/openClaw/openCode/aider/gemini/goose/antigravity/kiro/generic)
 └─ process-tree inspection + CLI hook hints → per-pane agent identity, statusline

TerminalEmulator → TerminalBlock (engine-side, line-range only)
 └─ BlockSummary (KouenIPC, pre-joined text) → kouenGetLastBlock / kouenGetBlock MCP tools
```

## Phases

### Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}
Superset and Supacode's core pitch is: agent runs in isolated worktree → single dashboard
shows every agent's diff → review/merge/handoff without leaving the app. We have the worktree
isolation; we have no aggregate view.
- **A1 inventory**: enumerate all tabs in a workspace with `worktreePath != nil`, resolve each
  to `git diff` against its base branch (reuse whatever git-diff plumbing the existing sidebar
  Git panel already calls — do not re-implement diff parsing).
- **A2 UI**: new sidebar section or command-palette action ("Review Agent Work") listing one
  row per isolated tab: branch name, agent kind (from `AgentKind`, if a pane in that worktree
  has one), files changed count, last commit time. Click → existing diff popover/viewer.
- **A3 handoff action**: per-row action to merge the worktree branch into the tab's original
  branch (shell out to `git merge`/`git rebase`, surface conflicts inline — do not auto-resolve).
- Explicitly out of scope for v1: cross-agent conflict prediction, auto-merge, N-way diff UI.

### Phase B — Subagent/teammate visibility as panes (vs cmux)
cmux auto-splits a new pane whenever a running agent spawns a subagent/teammate, so nested
agent work is never a hidden background process.
- **B1 investigate detection surface**: does `AgentDetector`'s process-tree walk already see
  child agent processes (e.g. Claude Code's Task tool spawning a nested `claude` process)? If
  yes, this is a wiring problem, not a detection problem — confirm before scoping further.
- **B2 auto-split on detection**: when a new agent-kind process is detected as a child of an
  existing agent-kind process in the same pane's process tree, prompt (or auto, behind a
  setting) split the pane and attach a view onto the child's own output stream — needs a way to
  address a subprocess's I/O independently of the parent PTY, which may not exist yet (RealPty
  is one PTY per pane, not per-process). Flag as the likely hard part; may require design
  discussion before implementation.

### Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}
Zed's Terminal Threads treats each agent CLI session as a searchable thread with turn-level
structure. We already capture command blocks (P34); missing piece is presenting them as a
navigable thread rather than raw scrollback.

**Built as a standalone `TerminalThreadOverlay` (⇧⌘L) first, gated green, then deleted during live
testing** — double-click/filter never worked, and the user asked to merge it with Recipes instead
of debugging it separately. Current implementation: merged into `RecipePickerController` (⌘⇧R
only, single flat list of recipes + history). Still missing: a unit test for the merge logic, and
a live check that selecting a history item actually jumps to its output.
- **C1** reuse `TerminalBlock`/`BlockSummary` to render a per-pane "thread view" (block list,
  jump-to-block) as an alternate view mode on the existing pane, not a new surface.
- **C2** cmd-F search should search block boundaries/commands first, fall back to raw scrollback
  search (existing ⌘F) for content within a block.
- Verify this doesn't regress the F1-F4 P34 deliverables (see completed-archive.md P34 entry)
  before touching `TerminalBlock`.

### Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm
Already scoped and explicitly deferred once in P30 ("Otty Feature Parity") alongside WASM
plugins. Re-raising because agent CLIs increasingly emit inline images/charts (some MCP tool
output, some agent screenshots-in-terminal workflows) that Kouen's engine currently cannot
render inline.
- **D1** confirm still deferred / not partially built since P30 (`grep` engine source for any
  Kitty/Sixel escape handling before assuming zero).
- **D2** if truly greenfield: scope as its own plan, don't fold into P38 — this is an engine-level
  escape-sequence + Metal-texture-upload change, orthogonal to the agent-workflow gaps above.

### Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority
- **E1** audit which WezTerm-style lifecycle hooks (window-resized, new-tab, pane-focus-changed)
  the JavaScriptCore layer already exposes vs not, before deciding this is worth doing. Don't
  build blind — likely small delta, possibly already covered.

## Verification gates (every phase)
- `swift build` + `swift test` green, `Tests/robot/run.sh` 10/10
- Phase A/B: live check with a real multi-worktree workspace (not just unit tests) — spawn 2+
  tabs on different branches, confirm dashboard reflects real `git diff` output
- Phase C: confirm scrollback search and P34 block MCP tools still pass their existing tests
- Phase D/B: design-review checkpoint before implementation (both flagged as architecturally
  uncertain above) — don't start coding until the hard part (subprocess I/O addressing for B,
  escape-sequence handling for D) has an actual design
