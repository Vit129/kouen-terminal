# Changelog

All notable changes to Harness are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and Harness follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). Each released version
has a matching `vX.Y.Z` tag and a signed, notarized DMG on
[GitHub Releases](https://github.com/Vit129/harness-terminal/releases).
## [Unreleased]

### Added
- Memory pressure monitor — trims inactive pane scrollback to 1 000 lines on warning, 0 on critical (frees ~96 MB per idle session)
- Hint mode ⌘⇧U — Vimium-style keyboard URL picker overlay; home-row-biased labels, 3 s auto-dismiss
- Send selection → AI chat — right-click selected text → "Ask AI…" prefills ⌘I panel
- Scrollback search ⌘F — wires existing `TerminalFindBar`; rebinds Find in Files to ⌘⇧F
- Click-to-move cursor — single click on same row as cursor sends left/right arrow sequences
- Auto Secure Input — `SecureInputMonitor` detects password prompts via PTY output patterns and toggles macOS Secure Input API
- Context-aware Ctrl+C — copies selection to clipboard when text is selected; falls through to PTY interrupt otherwise
- Composer ⌘⇧E — floating multi-line command editor panel; ⌘↩ sends to active PTY
- Prompt Queue ⌘⇧↩ — queues clipboard contents as sequential commands; each runs after previous shell prompt appears; floating status bar shows queue count
- Git branch in tab bar — instant update on `cd` by reading `.git/HEAD` directly (no subprocess)

### Fixed
- AI chat streaming returned no output — pipe double-read anti-pattern (`while isRunning || availableData`) replaced with `while true { let chunk = availableData; if chunk.isEmpty { break } }`

## [3.10.0] - 2026-06-27

### Added
- Full-cycle --no-bump flag + start.mjs asks version bump before full run ([`10346cb`](https://github.com/Vit129/harness-terminal/commit/10346cb36c4f607e32a17cea05611a3c83a0a432))
- SwiftUI settings foundation — SettingsModel + Terminal page ([`4435619`](https://github.com/Vit129/harness-terminal/commit/443561969f40a6a153afa21beb37eef2fa7179f7))
- SwiftUI Settings — Appearance page (S2) ([`dd1ca45`](https://github.com/Vit129/harness-terminal/commit/dd1ca45b688e7694b664b1bee1bab18be14fe45b))
- SwiftUI Settings S3–S5 — Colors, Keys, Agents pages ([`c572ed4`](https://github.com/Vit129/harness-terminal/commit/c572ed4cf723d5ce22fe57ec5fef5e773e2704cb))
- SwiftUI Settings S6–S9 — Advanced, Remote, root wiring, AppKit deleted ([`94c9491`](https://github.com/Vit129/harness-terminal/commit/94c94913c260e4fbca555f575e0f215d4ce1c5c4))
- Migrate WorkspacePillButton to SwiftUI ([`204dcf2`](https://github.com/Vit129/harness-terminal/commit/204dcf2d2ddd5e7c0299320117a1594540322c6d))
- Migrate sidebar section label + footer to SwiftUI ([`a072edf`](https://github.com/Vit129/harness-terminal/commit/a072edf56bdd051951a6ae9e4a1a0e26c6e988b6))
- Migrate sidebar tab bar from NSSegmentedControl to SwiftUI Picker ([`a6d59a9`](https://github.com/Vit129/harness-terminal/commit/a6d59a9ce4549c1a080584bb981a268af569ac46))
- Open With Harness for source files + file preview routing ([`36fde38`](https://github.com/Vit129/harness-terminal/commit/36fde383ef6d6f6ab5ec19bff05800fbfa81e1b0))
- Open With file → terminal at git root + tree reveals file ([`cabcb86`](https://github.com/Vit129/harness-terminal/commit/cabcb86707bdc001cc590c11986e9a2f206176b5))
- File tree roots at git root, expands to CWD on cd ([`d3a700f`](https://github.com/Vit129/harness-terminal/commit/d3a700f3d4d9c1fd55e005079cd5aea2de2de130))
- AppKit → SwiftUI wave 2 — 4 UI components migrated ([`760705a`](https://github.com/Vit129/harness-terminal/commit/760705a092f877d78eacb5419e3e777ae4f3bfee))

### Changed
- Migrate Toast+About to SwiftUI, delete dead NotificationBellButton + DragReorder stub ([`94f4d54`](https://github.com/Vit129/harness-terminal/commit/94f4d541b44ac728aeb58ade876edfbec84dd3b9))

### Documentation
- Update knowledge — CASE-042/043 + cwd-worktree-bleed companion fix + memory decisions ([`c67a980`](https://github.com/Vit129/harness-terminal/commit/c67a980f668cb32497eecd1db8103242d3c53d10))
- Update CONTEXT — SwiftUI Settings S6–S9 complete ([`654fe82`](https://github.com/Vit129/harness-terminal/commit/654fe820b0d8676f657d20487c8c2acdcfc8c74f))
- Update CONTEXT, knowledge, plans, graphify after sidebar SwiftUI wave 2 ([`95290db`](https://github.com/Vit129/harness-terminal/commit/95290dbc140413bcb42db54896d81dfae6dd836e))
- Update CONTEXT — SwiftUI wave 2 complete (4 components, −424 lines) ([`139ab6a`](https://github.com/Vit129/harness-terminal/commit/139ab6a04662f976d791c78a550172d902d57547))

### Fixed
- Flush NSHostingView layout after sidebar animation completes ([`bef888a`](https://github.com/Vit129/harness-terminal/commit/bef888a9b06d0ef1a5cfd549c1a571a7a56b70da))
- Sidebar animation frames drop on macOS 26 — Task {@MainActor} → assumeIsolated ([`d5833b0`](https://github.com/Vit129/harness-terminal/commit/d5833b0deed13b73942eec00e52f2fcc4e1b8541))
- Sync Metal terminal frames with CA during sidebar animation ([`28d0233`](https://github.com/Vit129/harness-terminal/commit/28d02337fb1a55d0605cc352a021d9b337d6771b))
- Point Bug 1 robot guard to BrowserIntegrationController where removeValue lives ([`ad792c9`](https://github.com/Vit129/harness-terminal/commit/ad792c9ca0753023088bd8f9b1e278c27a77e83d))
- Remove presentsWithTransaction from animated sidebar — was blocking main thread every vsync ([`b9f94cd`](https://github.com/Vit129/harness-terminal/commit/b9f94cd7a49e0d767443a858c59d5e8f4332ec9e))
- Panel to response slow and move pane to left/right corner ([`0f71782`](https://github.com/Vit129/harness-terminal/commit/0f7178285d13542c1f639f84cf3d0932cf25105c))

## [3.9.5] - 2026-06-26

### Added
- Vimium-style hint mode (Cmd+Shift+U) for keyboard link opening ([`cba7cdc`](https://github.com/Vit129/harness-terminal/commit/cba7cdce553b4fec0dbef6bb72dd5a0553ab6333))
- Harness view opens sidebar file viewer via OSC 7735 ([`8913672`](https://github.com/Vit129/harness-terminal/commit/8913672e8acb9d8fa558cea8cdf1c0ab8edae36c))
- Harness cat shows line numbers that are excluded from copy ([`22f4dd5`](https://github.com/Vit129/harness-terminal/commit/22f4dd5c88e59ed897689c0869e57f51781cedc9))
- Add Commit & Push to Sync menu ([`e902d2e`](https://github.com/Vit129/harness-terminal/commit/e902d2e54d0434cfbc57d3b6056a60bf8e98144e))

### Documentation
- Update agent-memory with RL-056/057/058 and CASE-039/040/041 ([`4b9eb22`](https://github.com/Vit129/harness-terminal/commit/4b9eb2249a281bc05774e9ed819abdb317824216))
- Strip global-duplicate sections from CLAUDE.md ([`7bb5578`](https://github.com/Vit129/harness-terminal/commit/7bb55781617016e728b7cee146bc60932a121174))
- Record memory-leak audit findings + onRetire fix pattern ([`8af2790`](https://github.com/Vit129/harness-terminal/commit/8af27904ddc03dd7c803067db2729a11b81ecc25))
- Add memory-leak-audit case study + update graphify for v3.9.4 ([`120acf3`](https://github.com/Vit129/harness-terminal/commit/120acf3b20caf34ac8af9c2100a350aeba7b0eaa))
- Bump version to v3.9.4 + note Commit & Push shortcut in README ([`5720d01`](https://github.com/Vit129/harness-terminal/commit/5720d0149b940a41aa00ce75371104866d8a0d54))
- Note long-session memory stability in README ([`53aefa9`](https://github.com/Vit129/harness-terminal/commit/53aefa9b4667cbc28519c5349cc11c5ec3185229))

### Fixed
- Fix button hit-testing, sidebar toggle, and browser log freeze ([`aeadae9`](https://github.com/Vit129/harness-terminal/commit/aeadae9d3f45c2e883ad202739d4599240112d25))
- Remove adjustSubviews() calls that caused terminal blink regression ([`b55cc62`](https://github.com/Vit129/harness-terminal/commit/b55cc6299c4241e70201d58efc782c4f051f60a2))
- Browser cannot show in cmd+b and browser button ([`e530205`](https://github.com/Vit129/harness-terminal/commit/e53020518bf1356cf2c1ac1ee84779c10d0735b8))
- Browser pane reuse guidance and skill routing paths ([`9bd07a4`](https://github.com/Vit129/harness-terminal/commit/9bd07a4afedd1f3380a384456d847b5ceb330b3c))
- Replace graphify CLI trigger with graph-report skill ([`528c166`](https://github.com/Vit129/harness-terminal/commit/528c1661a85d0dcf6bb08c35ed2b20b9d070229a))
- Cmd+W closes browser pane (intercept before WKWebView consumes it) ([`02e49cd`](https://github.com/Vit129/harness-terminal/commit/02e49cd553cf2172ea6e88ef0e29205ecb544d15))
- Disarm prefix key on mouse click to prevent swallowing Cmd+\ ([`fd7a5f0`](https://github.com/Vit129/harness-terminal/commit/fd7a5f075e7abf1dc1b2d69bd5638ba9ba72873d))
- Prevent git panel double-refresh blink after commit/push ([`c9dc884`](https://github.com/Vit129/harness-terminal/commit/c9dc884c487a3b89f2188566ca1afc4a20507ef4))
- Prevent git push from hanging in daemon ([`1ddc27d`](https://github.com/Vit129/harness-terminal/commit/1ddc27d31485e753a3182097e8f654329f755be4))
- Release unclaimed TerminalHostViews after PaneContainerView build ([`0430ed8`](https://github.com/Vit129/harness-terminal/commit/0430ed879698facf0720935029e6a18f3197b206))
- Stop per-pane AI controllers and browser network log from leaking ([`e642997`](https://github.com/Vit129/harness-terminal/commit/e64299781218c800fa52b220ad1e766d83e911d2))
- Memory leak audit — pane lifecycle + AI controller cleanup ([`38fa427`](https://github.com/Vit129/harness-terminal/commit/38fa4273c85187230dca073db3eff93b44597987))
- Don't fail make install when open has no window server ([`9d7de27`](https://github.com/Vit129/harness-terminal/commit/9d7de27a34b693d2a776695676af195800c81d7f))
- Pin session worktree to shell cwd, not deepest foreground descendant ([`8ad328d`](https://github.com/Vit129/harness-terminal/commit/8ad328d98c431cea72275fae931f82cbd0e6652e))

## [3.9.2] - 2026-06-22

### Documentation
- CHANGELOG for v3.10.0 — terminal flash fix ([`0fc4fd9`](https://github.com/Vit129/harness-terminal/commit/0fc4fd9585a0d5383969a87b84ca6ec613d20c3e))

### Fixed
- Prevent hover flickering between shortcut and close button ([`f140efb`](https://github.com/Vit129/harness-terminal/commit/f140efb94dfe414dbe33a85bb1ef8c70e939c587))
- Terminal flicker on ⌘\ — remove layoutSubtreeIfNeeded, use split.layout() ([`bf96fd1`](https://github.com/Vit129/harness-terminal/commit/bf96fd111f1ca418958c4921dc7f82a7043f14a6))
- File preview open/close flicker — replace layoutSubtreeIfNeeded with layout() ([`ce0603f`](https://github.com/Vit129/harness-terminal/commit/ce0603f7cf390e494f8b203aac357bc9e441123a))
- Eliminate tab switch flash — cache PaneContainerView per tab, hide/show instead of rebuild ([`de39a37`](https://github.com/Vit129/harness-terminal/commit/de39a37c8d5718ed2bce51b94969108291e3f762))
- Eliminate terminal flash on sidebar, tab switch, split, and file preview ([`6dc94fe`](https://github.com/Vit129/harness-terminal/commit/6dc94fe325ad45bd22a593e9cc02e4b8ac0a3ab7))

## [3.9.1] - 2026-06-22

### Added
- Sessions tab shows only idle worktrees (active ones already have sessions) ([`f5b78aa`](https://github.com/Vit129/harness-terminal/commit/f5b78aab2ad9f9a1bf7154cc5fb1885fa4361c4c))
- Worktrees collapsed by default in Sessions sidebar ([`b990f64`](https://github.com/Vit129/harness-terminal/commit/b990f6412b41b7c03d9e75cd65c5c7842714e17a))
- Enable Worktrees tab in Git panel (was hidden, code already existed) ([`8e55be6`](https://github.com/Vit129/harness-terminal/commit/8e55be6c80ea0f1656ef752b3a558289aec6f9aa))
- Git worktree panel — fix click conflict, add merged status indicator ([`78badf8`](https://github.com/Vit129/harness-terminal/commit/78badf89c37e3b23ff3e12e142d8c3035ed274c9))

### Changed
- Remove worktrees from Sessions sidebar — now lives in Git tab only ([`ffec772`](https://github.com/Vit129/harness-terminal/commit/ffec7720fa5f50f896356d8f33d6463d5aa733f3))

### Documentation
- Archive completed plans (P28, sidebar SwiftUI, core split) ([`3718eb0`](https://github.com/Vit129/harness-terminal/commit/3718eb004249024cc36a68fe78c51a97549f5e5f))
- Update plans INDEX — archive P26/P27, add SwiftUI migration as active ([`c009000`](https://github.com/Vit129/harness-terminal/commit/c00900075578e17e1c63a816604e0bb9da92d052))
- Add RL-052/053 lessons + sidebar SwiftUI knowledge (MainActor freeze, @Observable loop) ([`3e43b89`](https://github.com/Vit129/harness-terminal/commit/3e43b893de559b60ae3ffe067775da4e88c867df))

### Fixed
- Sidebar hang on z/cd — add re-entrancy guard to rebuildRows ([`36319f9`](https://github.com/Vit129/harness-terminal/commit/36319f99ce8f506b162d3f7bf5da947ee7eb90ba))
- Sidebar freeze on z/cd — move Process.waitUntilExit off main thread ([`0d2196a`](https://github.com/Vit129/harness-terminal/commit/0d2196a07d7e9689b40712ed3d7415f1d206b15a))
- Sidebar infinite re-render loop — @ObservationIgnored on gitMetadataCache ([`5587b02`](https://github.com/Vit129/harness-terminal/commit/5587b02acfad03eb10deb5e0068ef058c6eb6e99))
- Worktree remove button — double-click for cd, single-click for ✕ button ([`92456d5`](https://github.com/Vit129/harness-terminal/commit/92456d50b7232027994f2695678f5f741d816641))
- Worktree remove — confirmation alert, --force flag, proper error capture ([`fc60a68`](https://github.com/Vit129/harness-terminal/commit/fc60a68d75a97ca67faeca1f38d7ce283ada4bfb))
- Worktree single-click cd + skip click on ✕ button area ([`fcd9032`](https://github.com/Vit129/harness-terminal/commit/fcd90328f8dd4fae90af5b626b2f7a35b14dbec5))
- Worktree remove button — use SoftIconButton (same pattern as working browser tab close) ([`eb5e565`](https://github.com/Vit129/harness-terminal/commit/eb5e5657d8ce49529380be8ceaa70e6bb9d00284))
- Worktree card — use mouseUp pattern (same as BrowserTabButton) for reliable click handling ([`1e7d389`](https://github.com/Vit129/harness-terminal/commit/1e7d3893c0c2464caf0402ef51b6f5b0670ceeb6))
- Worktree panel flicker — cache output, skip rebuild if unchanged ([`333d352`](https://github.com/Vit129/harness-terminal/commit/333d3520c76307f5c8f4fb6cc19115f4146cc363))
- V3.9.1 — sidebar freeze fix, git worktree panel, click handling ([`74ae012`](https://github.com/Vit129/harness-terminal/commit/74ae01214ecb9be26b20a60ace4d4b7d775415f2))

## [3.9.0] - 2026-06-22

### Added
- Wire git-cliff into full-cycle.sh for auto CHANGELOG + release notes ([`a95f257`](https://github.com/Vit129/harness-terminal/commit/a95f2570747460fc08c2b09bd98cda54e854655e))
- Replace NSTableView with SwiftUI List (Option B) ([`72cf712`](https://github.com/Vit129/harness-terminal/commit/72cf71253865fbb3cbbab4d96dad809de12cbce1))

### Changed
- Extract HarnessCommands + HarnessSettings from HarnessCore ([`fdcbd58`](https://github.com/Vit129/harness-terminal/commit/fdcbd58bd20c4a465dce030e5ee90a70c3e0a26f))

### Documentation
- Update agent-memory with RL-051 (table row crash) + harness-mcp completion ([`1cc11b0`](https://github.com/Vit129/harness-terminal/commit/1cc11b04491239ec968d6f1d74264bb26d7ee596))
- Add sidebar race fix plan + update CONTEXT.md ([`9147e79`](https://github.com/Vit129/harness-terminal/commit/9147e7912727c8ac2f837cda150cf589b36f7644))
- Add sidebar SwiftUI List migration plan (Option B) ([`23965f4`](https://github.com/Vit129/harness-terminal/commit/23965f49c1157d3c11664edaca0555317c0fbc33))
- Update agent-memory indexes, regenerate graphify summary (post-migration) ([`dd26bde`](https://github.com/Vit129/harness-terminal/commit/dd26bde979e1b58b4c39f662692e5387356a32e2))
- Add SwiftUI migration plan (Phase 1/2/3 component map) ([`39a32e0`](https://github.com/Vit129/harness-terminal/commit/39a32e040931cd14a1159b38d901de587838c520))

### Fixed
- Sidebar crash on z/cd/⌘\ — reloadData before accessing table rows ([`e611e78`](https://github.com/Vit129/harness-terminal/commit/e611e7886bbf7e0dfaa672fb3673bf4d813a8508))

## [1.3.0-vit] - 2026-06-06

### Added
- Complete inception phases for ACP (Agent Client Protocol) feature ([`bba93bf`](https://github.com/Vit129/harness-terminal/commit/bba93bfce514eaed1f5a2133dc287fce240cc1f7))
- Implement ACP core transport and process (Phase 1) ([`1df08b0`](https://github.com/Vit129/harness-terminal/commit/1df08b08ccf7ea45d531836e53819e84adb83fbf))
- Sidebar tab switcher + file tree outline view (Phase 1) ([`c790a64`](https://github.com/Vit129/harness-terminal/commit/c790a6433cfad7db285c1673b8e5bc62ce7c94c1))
- Replace NSOutlineView file tree with SwiftUI List + onDrag ([`b2c0da4`](https://github.com/Vit129/harness-terminal/commit/b2c0da48582170f6b4112e885a590f2bc6ab28b6))
- SwiftUI file tree with onDrag ([`56e18da`](https://github.com/Vit129/harness-terminal/commit/56e18dab957cdfb501de6daad66e874ff1bf95ea))
- SwiftUI file tree - DisclosureGroup expand + lazy load + onDrag ([`b424989`](https://github.com/Vit129/harness-terminal/commit/b4249891d4643fa5c983b1d63807a17087f8353b))
- Session group expand/collapse, right-aligned action buttons, and close group option ([`0e48c46`](https://github.com/Vit129/harness-terminal/commit/0e48c464f6ae9dcccb3918ed10fa6498996a64ad))
- Hide Git tab in the sidebar, keeping Sessions and Files tabs ([`f841736`](https://github.com/Vit129/harness-terminal/commit/f8417364abac622c94cc0b50d7a173425923d70a))
- Wire FSEvents live watcher into file tree view ([`c53b115`](https://github.com/Vit129/harness-terminal/commit/c53b11570b87acb583cf3c2554d00c0c2b8b5435))
- Add full native support for antigravity/agy and update performance docs ([`f2aced8`](https://github.com/Vit129/harness-terminal/commit/f2aced8199d7e904b118344e5c4f2cacf8fa5df4))

### Changed
- Panel & session performance fixes + file tree git status ([`c3db2d5`](https://github.com/Vit129/harness-terminal/commit/c3db2d5fd6f05586cc4c2e4931a1ad8a0f5e672d))

### Documentation
- Add IDE sidebar feature README ([`1f04e7b`](https://github.com/Vit129/harness-terminal/commit/1f04e7bfe259c04a0a15160830be9f23f65e425b))
- Add CHANGELOG.md for v1.0.0 ([`583fbe8`](https://github.com/Vit129/harness-terminal/commit/583fbe866e82ac06e7636e1ad6acb222e3216adb))
- Add fork attribution to README ([`1cb5051`](https://github.com/Vit129/harness-terminal/commit/1cb5051222c7135d9e335aacc97595612f8f8cd6))
- Remove non-working features and git clone from README ([`3c02d60`](https://github.com/Vit129/harness-terminal/commit/3c02d60ce5ee7ca7b42be0012d747482f4dabdee))
- Add IDE Sidebar section covering Session, Files, and Git panels ([`4ad5a80`](https://github.com/Vit129/harness-terminal/commit/4ad5a80c6d256833146899f3d02718c87e73cab8))
- Update README + CHANGELOG for v1.1.0 ([`2dab4d4`](https://github.com/Vit129/harness-terminal/commit/2dab4d4388bee70f119e99c1d339c288127a9482))
- Add panel & session performance + file tree auto-update plan ([`02c69e3`](https://github.com/Vit129/harness-terminal/commit/02c69e3e72ca49564093933bebafaa9ec328f2cf))
- Update panel-session-performance plan — mark P1/P3-P6/F1A-F1F done, note F1-G and P2 pending ([`4c9d780`](https://github.com/Vit129/harness-terminal/commit/4c9d780386c5d70de74d315f2e5de71b72fd976b))

### Fixed
- Restore drag-drop to terminal + add image drag support ([`461bb79`](https://github.com/Vit129/harness-terminal/commit/461bb79aaf6b8b56b5c5a9947fd2821c33c26316))
- Drag-drop to terminal (files, folders, images) ([`a6c6217`](https://github.com/Vit129/harness-terminal/commit/a6c62176daefcb35948bc19bb35eeae5644670ed))
- Remove action selector that blocked drag initiation in file tree ([`7a68a07`](https://github.com/Vit129/harness-terminal/commit/7a68a074fa5ca4d0341c3bc067cde118b08d1af0))
- Remove action selector that blocked drag initiation in file tree ([`f6789dd`](https://github.com/Vit129/harness-terminal/commit/f6789dd5c487fa2fd8ba62dc78d9ea41bba78f6c))
- Single-click folder expands/collapses in file tree ([`fd5632b`](https://github.com/Vit129/harness-terminal/commit/fd5632b384109329d0ef38e760f4b1dc05e5fac9))
- Merge drag-drop + folder click fixes from worktree ([`7c4c71a`](https://github.com/Vit129/harness-terminal/commit/7c4c71a189c45b39d9b4c000db17f62ae7e4a13a))
- Defer UNUserNotificationCenter init to avoid macOS 26 launch crash ([`017bff7`](https://github.com/Vit129/harness-terminal/commit/017bff7c160ea6acb9bcd76128117c3c3b8dafdb))
- Merge notification crash fix ([`18f3470`](https://github.com/Vit129/harness-terminal/commit/18f3470318366737289b06cb0488481560d32a49))
- Disable UNUserNotificationCenter to avoid macOS 26 launch crash ([`fc4c117`](https://github.com/Vit129/harness-terminal/commit/fc4c117090797eac1e53b86f04fab83e862048f9))
- Disable desktop notifications for macOS 26 compatibility ([`ddd9341`](https://github.com/Vit129/harness-terminal/commit/ddd93413b3ee303506e48d8d4f39e0645d61dc59))
- Show empty state when no repo; surface git errors via alert ([`993cdcb`](https://github.com/Vit129/harness-terminal/commit/993cdcb2a5fe79dc7b3a7b3378c58613c4b25c23))
- Disable NotificationPermission UNUserNotificationCenter calls on macOS 26 ([`f6f8be0`](https://github.com/Vit129/harness-terminal/commit/f6f8be038c510dfbf117fcee9a4fd311b4967b09))
- Pre-load first-level children so List(children:) tree structure renders correctly ([`9fe4748`](https://github.com/Vit129/harness-terminal/commit/9fe474891e7126ee507e77cb3dec9b82fa61b902))
- Notification crash + file tree expand ([`3ecec6e`](https://github.com/Vit129/harness-terminal/commit/3ecec6e251cd5622183095f5389b6ffba2326601))
- Use DisclosureGroup so folder label click expands/collapses + lazy child loading ([`b2e152e`](https://github.com/Vit129/harness-terminal/commit/b2e152eab2ef49f6467bccac29d2ff482a97407f))
- Folder expand/collapse in SwiftUI file tree ([`a3dd841`](https://github.com/Vit129/harness-terminal/commit/a3dd841ac1524ebd664b1556bb7c3f09546afd36))
- Folder expand/collapse ([`56373ff`](https://github.com/Vit129/harness-terminal/commit/56373ff0b661a538266b18fb9fb88801ebf2cf2c))
- Make top bar zoom instant ([`6f441eb`](https://github.com/Vit129/harness-terminal/commit/6f441ebba4089ffa2fadecc6b865110e0d1b2be7))
- Make window zoom on double-click work across the entire top panel (tab bar and sidebar titlebar header) ([`2734062`](https://github.com/Vit129/harness-terminal/commit/2734062137922608d0d813dfaf78e86f9ccb7aa6))

