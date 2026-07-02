# Feature Provenance — harness-terminal

Grep target: `grep -n "<keyword>" knowledge/architecture/feature-provenance.md`

Where each major feature/decision actually came from — tool researched, problem hit, or fork lineage.
Not a changelog (see CHANGELOG.md for that) — this is "why does this exist and what did we look at."

## Origin Story

- Tried cmux first (native macOS, libghostty, notification-first) — no git UI, no file editor, no IDE features.
- Tried Zed next (IDE-grade sidebar, git panel, file editor) — not terminal-first, not built for multi-agent orchestration.
- Found robzilla1738/harness-terminal — 100% native macOS (Swift/AppKit/Metal, no Electron), terminal-first.
- Forked it and merged the two worlds: terminal-native performance (from harness base) + IDE-grade workflow (from Zed) + multi-agent orchestration (own direction).
- Positioning: nobody else in the category (cmux, Supacode, Superset) combines all three — they stay terminal-only.

## IDE Track — File Tree / Editor / LSP (the "Zed half" made real)

This is the direct payoff of the Zed-inspired half of the origin story — built as its own multi-phase track, not one feature:

- File tree: started as `NSOutlineView` (`c790a64` Phase 1), replaced with SwiftUI `List` + `onDrag` (`b2c0da4`), then `DisclosureGroup` expand + lazy load (`b424989`). FSEvents live watcher wired in (`c53b115`). Git status decoration per file (`da39df1`), dynamic per-session branch display (`f50fcb8`/`4f663c7`), hidden-files toggle (`f46b6ca`).
- File preview: read-only preview MVP first (`a53f24f`, P4 Track 1), then syntax + Quick Look previews (`f22016c`), then Excel/CSV via QuickLook (`35d0a93`).
- File editor: split-panel editor with tabs/syntax/save/undo/redo/find-replace came after preview (`3bbedf1`, `f2cad57`), then vi-like modal editing + git diff gutter in the editor (`712999b`).
- LSP: `harnessErrors` MCP tool surfaces LSP diagnostics to agents (P4, v3.2.0) — this is the piece that ties the file-editor track back into agent workflows, not just human editing.
- Numbering note: this whole track is filed under "P4" across several plan docs (file view MVP, editor, LSP) — treat P4 as "the file/editor track," not a single PR.

## ACP (Agent Client Protocol) — tried, shelved, erased

- Built as its own protocol layer: AIDLC inception (`bba93bf`) → core transport/process Phase 1 (`1df08b0`) → Client with agent chat panel in sidebar (`7aff448`).
- Intent per `decisions.md`: ACP = LSP-style framing for agent→daemon notifications (the "daemon calls back" half, MCP = "agent calls out" half — same connectivity model as harness-mcp).
- Filed as **P5**, later fully reactivated as a planned "P29" — then abandoned. Ultimately `c4e1e15 "remove: ACP + ⌘I — erase as if never built"` deleted `HarnessAIChatView`/`SearchPanelView` entirely. Current state per `decisions.md`: "No built-in AI chat view — Harness connects AI via CLI agents (Claude Code, Codex) in terminal" instead.
- **Why it was actually erased (the ROI, not just the fact):** never found the payoff that justified the protocol work. Telling Harness to do something through a built-in ACP chat panel vs just typing directly into a `claude`/`kiro` CLI pane produced no meaningfully different outcome for the user — same agent, same capabilities, same result, just routed through an extra in-house layer. Building/maintaining a second, custom-framed channel next to the terminal that already talks to those agents natively wasn't worth it once that stopped being obviously true. Kept wanting it to matter — it didn't pay for itself.
- Why this matters for provenance: it's the one major track that was fully built, shipped, and then deliberately reverted — not a case of "never got to it," and not a case of "found a bug" either. Pure cost/benefit call after the fact.

## Command Palette / Power-User Terminal Features

- Not one feature — an accretion pulled from tmux, vim, and zoxide over many passes, described in the fork's own commits as "close last tmux gaps" and "terminal power-user features":
  - `55c7bff feat: terminal power-user features — vi mode, tmux parity, LSP, zoxide` — the umbrella commit.
  - vi mode: modal editing, jump-list/marks/search (`6cd143d`).
  - tmux parity: window-size/json CLI (`6cd143d`), word-separators in copy-mode `w`/`b`/`e`, `list-*` `-F` flag (`99d4cc2`).
  - zoxide: frecency-based directory jump wired into command palette (`72bbd67`), plus wrap-search option.
  - Layout presets ⌘⌥1-5 + workspace symbol index in palette (`1e998ae`).
  - Fuzzy file quick-open in palette (`7106b74`), Switch Project + worktree-to-tab integration (`40ecd09`).
  - Ctrl+R interactive command-history search overlay (`4e4c2d4`).
- This whole area is why the README lists "optional tmux-style controls" and "IDE-like navigation" as separate bullets — they were built as genuinely separate tracks that later got unified under the command palette as the common entry point.

## Pane System

- Split-right shipped first, split-down broke — researched WezTerm/Zellij/iTerm2 pane-tree models to fix it. Landed as P13 "restore split-down (top/bottom) parity" (`e0a35f7`).
- Pane reorder/move-freely was NOT one feature — iterative: button-based reorder → `mouseDown` drag grip (P27, `ce09618d`) → visible divider + 3-way corner drag (`b556b4f`) → move-to-corner fix (`0f71782`). Several passes before "move pane anywhere" felt solid.
- **P27 formal name is "Pane Drag-and-Drop"** (v3.5.0, per plans/INDEX.md) — full flow is drag grip → drop zone overlay → `swapPanes`/`joinPane`. The mouseDown-grip commit above is the input mechanism; P27 is the complete interaction including the drop-zone UI and the swap/join semantics.
- `otty-features` plan (`3163e1c`) is the paper trail — 6 features pulled from CMUX/Zellij/iTerm2 comparison research in one pass. This became **P30 "Otty Feature Parity"** (v3.11.x): Recipes (saved command picker, ⌘⇧R), Floating Panes (⌘⌥F, NSPanel), Tab Thumbnails (⌘⇧\ overview grid), Frecency directory picker (⌘⇧J), Session Resurrection audit. Kitty Graphics + WASM plugins were scoped into P30 but deferred, not shipped.

## Embedded Browser

- Built in-app WKWebView browser pane so agents don't need a separate Playwright process.
- Behavior rule added alongside it: clicking `localhost` or any URL in the terminal always opens full-screen on the right (not a new window, not external Safari) — deliberate UX decision, not a WKWebView default.
- GitHub URLs specifically route into the browser pane (not external Safari) — same rule, carved out because GitHub links are common in agent output (PR links, CI status).
- Multi-tab browser (WKWebView tab bar, `target=_blank` → new tab, persistent cookies) came after the single-tab version shipped and felt limiting.

## Git Panel

- Real-time git panel (`ui/git-panel.md`) shipped first — worktree-aware, `DispatchSource` live refresh.
- [Uncommitted, in progress] Commit click behavior split in two: default single-click now opens a fast anchored quick-look popover (`previewCommitDetail`, file-nav bar + colored diff, no tab) instead of the old full-tab `showCommitDetail`. Full tab view demoted to a context-menu item ("Open Full Diff in Tab") for the copy/search/keep-open case. Same pattern as the browser's "always open where it's fast, escape hatch for the heavy view" rule above.

## Harness MCP

- Built in the same work cycle as the embedded browser (P28) — MCP exists specifically so agents can drive the browser (open/navigate/snapshot/click/screenshot/network/cookies/storage/evaluate) without shelling out to chrome-devtools-mcp.
- 14 browser tools, ~70-75% token savings over chrome-devtools-mcp (per `decisions.md`).
- ACP (agent→daemon notification framing) added alongside MCP, same "connectivity model" pass — pattern borrowed from how Zed and Supacode structure their context providers (not copied code, just the pattern: MCP = agent calls out, ACP = daemon calls back).

## Notifications

- Entire notification system (rings, sidebar badges, unread jump, OSC 9/99/777 pickup) ported from cmux's model wholesale — cmux's notification design is the direct reference, not just "inspired by."

## Status Dashboard (running/idle/attention states)

- Dashboard-style agent status classification (running/idle/needs-attention) came from Devin (Windsurf's agent CLI), not cmux — different source than the notification UI even though both surface "agent needs you."
- Recent fix unified the running/status classification and replaced a plain dot indicator with an agent icon (`eb0c89b`) — cleanup pass after the Devin-derived states were integrated, to make sure one status model drives both the dot/icon and the notification ring instead of two parallel systems drifting apart.

## Performance Crisis — SwiftUI Migration (Sat–Wed, ~4-5 days)

- Root cause: AppKit → SwiftUI migration (started ~Jun 22) introduced a `.repeatForever` ViewGraph storm — CPU pegged, memory stayed flat (confirmed via live perf profile, `b188a4b`).
- Fix was not one commit — multiple waves: wave-2 SwiftUI migration bugs (`411ee6d`, `ce16dbb`), sidebar section label + footer migration (`a072edf`), status line hidden after settings migration (`71e3c05`), burst-ping coalescing in SessionCoordinator (`ffb059a`), skip Phase-1 revision pings in UI snapshot observers (`5cbbe82`).
- Some AppKit views deliberately NOT migrated to SwiftUI — marked intentional exceptions (`09c371d`) rather than forced through, once it was clear not everything benefits from the migration.
- As of this writing: considered the most stable point yet post-migration.

## Remaining Work

- P32 (task-based agent worktrees) — done, closed the "reactive not workflow" worktree gap vs Superset/cmux/Supacode.
- P33 (Visibility Gaps) — in progress, created 2026-07-02 from a competitor re-read of cmux/Supacode/WezTerm/Superset/AgentsRoom. Key finding: two of the three "gaps" were never missing code, just unwired code:
  - PR status: `PRStatusPoller.swift` polls `gh` every 30s but is dead/duplicate — the real, already-wired mechanism is `SidebarListModel.fetchGitMetadata`. Same "already built, never connected" shape as `archiveScript` before P32 Phase 3.
  - Cross-pane notifications: `AgentNotification`/`OSCNotificationParser` correctly parses OSC 9/99/777 + bell, but only flips one tab's status dot — cmux's bar (ring + sidebar text visible across splits/tabs) needs the fan-out wired, not new parsing.
  - Diff viewer: not a gap at all — `GitPanelView.showCommitDetail`/`.showChangedFileDiff` already work; the cmux/Supacode difference is UX polish (dedicated panel vs open-as-tab), scoped down to P2/optional.
- Known non-goals, deliberately out of scope (not forgotten, decided against): multi-agent "teams" orchestration UI (cmux's Claude Code Teams — different product surface), team sharing/cloud sync/SOC2 (Superset's enterprise angle — not relevant to local single-user open source), iOS/iPadOS companion (P25, status: Planning, remote-first design already decided — cmux ships theirs on TestFlight, harness hasn't started building yet).
