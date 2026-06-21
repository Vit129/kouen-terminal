# Memory — harness-terminal

## Decisions
- ACP shelved — re-enable when adapters ship with agent CLIs natively
- No built-in AI chat view — Harness connects AI via CLI agents (Claude Code, Codex) running in terminal + ACP (like MCP). Removed HarnessAIChatView and SearchPanelView sidebar tabs.
- AI connectivity model: (1) harness-mcp = MCP server that CLI agents call to interact with terminal sessions, (2) ACP = LSP-style framing for agent→daemon notifications (hook events, waiting state). Same pattern as Zed/SupaCode context providers.
- CWD tracking: daemon polls proc_pidinfo 500ms — no shell integration needed
- File preview: constraint-based sibling panel, never reparent terminal views
- ⌘1–9: `selectSession(workspaceID:sessionID:)` — not `selectWorkspace`
- vi mode: `ViEngine` `@MainActor final class` in `ViNormalMode.swift`
- Config centralization: JSON files in `~/Library/Application Support/Harness/` — fallback to hardcoded defaults
- Upstream merge not viable: codebase diverged too far (424 commits, 25% new code) — port by reading instead
- Keybinding single source of truth: `BannerShortcutRegistry` (`Keybinding` struct) — menu, banner, and onboarding all read from one place
- ⌘W = close pane → fall through to close tab if single pane (iTerm2/Warp pattern). ⌘⇧W = force close tab
- ⌘T = new session (not ⌘⇧N)
- IDE-like navigation: double-click folder in sidebar sends `cd <path>` to active terminal
- `:cd` command now sends actual `cd` to shell (not just switch tabs)
- `⌘P` palette zoxide entries cd active terminal instead of creating new session
- P24 Complete: all 4 phases shipped (ProjectConfig, agent badges, worktree auto-isolate/archive, GitHub PR/CI inline, browser multi-tab, :make/:recent scoped)
- Browser multi-tab: WKWebView tab bar always visible, target=_blank opens new tab, persistent cookies
- GitHub URLs in terminal open in browser pane (not external Safari)
- CI status shown in PR badge (✓/✗/○)
- Personal project config override: ~/.config/harness/projects/<name>.json
- Sidebar 2-line layout: Line 1 = branch (bold), Line 2 = short cwd (dimmed) — Supacode-style info density
- Top bar always shows branch (⎇) even when agent active — only hides cwd path
- Worktree auto-isolate is ALWAYS ON (not config-gated) — every branch switch → own worktree → correct git probe per tab
- ⌘⇧I toggles the Agent Notch panel for selecting the notifying agent; ⌘⇧U opens the notifications inbox; persistent peek stays until user action
- [2026-06-21] agent-memory/ UPPERCASE convention: top-level = UPPERCASE (MEMORY.md, PLAYBOOK.md, INDEX.md), subdirs (knowledge/, plans/) = lowercase kebab-case
- [2026-06-21] Shared memory protocol: single canonical `~/.claude/scripts/shared/memory-protocol.md` → symlinked into each project as `.ai/memory-protocol.md` → agent docs include via `@.ai/memory-protocol.md`
- [2026-06-21] `@` auto-include only works in Claude Code — Codex/Gemini/Kiro need explicit read instruction in their agent docs
- [2026-06-21] Webview Console redirection & Glassmorphism: WKWebView redirects logs to /tmp/harness-browser-[paneID].log & includes them in BrowserSnapshot for agent debugging. Refactored UI toolbar/tabbar with installChromeBackground(.tabBar) and SoftIconButton.

## Lessons
- RL-004: Never reparent Metal terminal surfaces — 1-2s black screen (CASE-003)
- RL-010: `NSView.displayLink` does NOT strongly retain target — always `deinit { displayLink?.invalidate() }`
- RL-021: Pure transparent window fails on bright bg — use `window.backgroundColor = themeColor.withAlphaComponent(opacity)`
- RL-030: Every `snapshotChanged` consumer must check `metadataOnly` flag before rebuilding
- RL-031: Double-subscription — parent routes to child AND child has own observer = fires twice
- RL-032: NSAlert first button auto-gets `keyEquivalent = "\r"` — Enter ALWAYS fires it regardless of Tab focus. Clear it for destructive dialogs.
- RL-033: Borderless NSPanel `canBecomeKey` defaults to `false` — must subclass and override to accept keyboard input.
- RL-034: Zombie surface view — must discardCursorRects + resign first responder in viewWillMove(toWindow:nil), prune paths, AND deinit. AppKit cursor rect system holds unsafe references. Swift 6 nonisolated deinit workaround: call via `perform(NSSelectorFromString("discardCursorRects"))` — NSObject.perform is not @MainActor and bypasses actor isolation check.
- RL-040: `@MainActor @objc` thunks on macOS 26.5 / Swift 6.3 call `swift_getObjectType(self)` to verify executor isolation BEFORE the method body runs. If `self` is a zombie (use-after-free), the isa read crashes in the thunk — no Swift guard can intercept it. Root fix: (1) mark high-frequency AppKit callbacks (`layout()`, `resetCursorRects()`, `viewDidMoveToWindow()`, `viewDidMoveToSuperview()`, `viewWillMove(toWindow:)`, `displayTick()`) as `nonisolated override` + wrap body in `MainActor.assumeIsolated {}` — this eliminates the thunk's isa read entirely, (2) zombie-hold via `TerminalPaneRegistry.retire()` with 1.5s delay keeps freed views alive past AppKit's async layout drain, (3) remove `invalidateCursorRects(for:)` in resign paths — it re-queues callbacks on AppKit's internal display link after `discardCursorRects()` cleared them, (4) NSEvent local monitor in AppDelegate swallows events targeting windowless views, (5) `guard window != nil` at top of layout/resetCursorRects as defense for the case where self IS valid but detached. The `nonisolated + assumeIsolated` pattern IS correct — `nonisolated` prevents the thunk crash and `assumeIsolated` is safe because AppKit always calls these methods on the main thread.
- RL-041: `keyUp` arrives in a LATER event loop iteration than `keyDown`. A 1-tick async deferred dealloc is insufficient — must hold zombie-prone views for ~500ms to cover the full key press/release cycle and rapid rebuilds.
- RL-035: `local` keyword only works inside bash functions — shell scripts with inline logic must omit it.
- RL-036: NotificationCenter `queue: .main` closures are `@Sendable` — wrap body in `MainActor.assumeIsolated` for Swift 6.
- RL-037: Original upstream had wrong assumption: `CADisplayLink` retains target on macOS (it doesn't — only iOS does).
- RL-038: `NSPanel` never takes `mainWindow` status — use `NSApp.mainWindow` (not `keyWindow`) to anchor floating panels; on 2nd+ open `keyWindow` points at the panel itself and the anchor drifts each time.
- RL-039: Menu `@objc` actions fail before first user click (`keyWindow=nil` on launch). Always chain: `keyWindow ?? mainWindow ?? windows.first(where: { $0.contentViewController is MainSplitViewController })`.
- RL-042: `KeyModifiers` name exists in HarnessTerminalEngine (InputEncoder) — adding same name in HarnessCore causes ambiguity. Used `MenuModifiers` to avoid collision.
- RL-043: NSClickGestureRecognizer on parent view intercepts child NSButton clicks — check click location in handler or use mouseUp override instead
- RL-044: Documenting a verb in COMMANDS.md/BannerShortcutRegistry without adding it to `CommandParser.buildCommand` + `knownVerbs` = silent `unknownCommand` error. Always wire both layers.
- RL-045: Override `removeFromSuperview()` on zombie-prone views to add retire-hold — catches ALL free paths (our code, AppKit, SwiftUI) at a single chokepoint instead of chasing call sites. Definitive fix for macOS 26.5 + Swift 6.3.2 thunk crashes.
- [2026-06-21] Webview Console redirection & Glassmorphism: WKWebView redirects logs to /tmp/harness-browser-[paneID].log & includes them in BrowserSnapshot for agent debugging. Refactored UI toolbar/tabbar with installChromeBackground(.tabBar) and SoftIconButton.
- RL-046: The `nonisolated + MainActor.assumeIsolated` pattern must cover ALL `@objc` callbacks on zombie-prone views — not just `layout()`/`resetCursorRects()`. Also needed on: `viewDidMoveToWindow()`, `viewDidMoveToSuperview()`, `viewWillMove(toWindow:)`, `displayTick()`. Any `@objc` entry point AppKit can call asynchronously after removal needs this treatment.
- RL-047: Split pane CWD must prefer `tab.worktreePath` over live process CWD (`currentWorkingDirectory()`). When agents run, `deepestReadableDescendant()` returns the agent's CWD (repo root/main) not the session's intended worktree. Priority: `worktreePath → sourceCwd → tab.cwd`.

## Conventions
- Build: `make preview`
- Test: `swift build` + all test targets
- Services: unowned back-reference to coordinator, lazy init

## Docs
- Keybinding single source of truth: `BannerShortcutRegistry` (`Keybinding` struct) — menu, banner, onboarding, and `docs/KEYBINDINGS.md` all derive from one place
- ⌘T = new session, ⌘W = close pane (or tab if single pane, iTerm2/Warp pattern), ⌘⇧W = force close tab
- IDE-like navigation: double-click folder → cd, `⌘P` fuzzy jump via zoxide, `⌘;` → `:cd <path>` sends to shell, ⌘-click file path → editor
- `⌘P` palette zoxide entries cd active terminal (not create new session)
- Welcome page (CompleteStepView) and terminal banner read shortcuts from `BannerShortcutRegistry`

## Tech Debt
- PBI-REFACTOR-004: `#if HARNESS_ACP` deferred
