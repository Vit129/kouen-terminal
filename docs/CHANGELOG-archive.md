# Changelog Archive

Older releases. See [CHANGELOG.md](../CHANGELOG.md) for recent versions.

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

## [1.0.0] - [1.0.4] - 2026-06-01

Initial public releases of Harness: a native macOS terminal with its own GPU
rendering engine, daemon-owned sessions/tabs/splits, `harness-cli` automation, the
`attach-window` compositor, agent detection and notifications, 490 built-in themes,
and a signed/notarized DMG with Sparkle auto-update. See the
[GitHub Releases](https://github.com/robzilla1738/harness-terminal/releases) for the
per-patch detail.

[1.5.1]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.5.1
[1.5.0]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.5.0
[1.4.1]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.4.1
[1.4.0]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.4.0
[1.3.2]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.3.2
[1.3.1]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.3.1
[1.3.0]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.3.0
[1.2.0]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.2.0
[1.1.2]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.1.2
[1.1.1]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.1.1
[1.1.0]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.1.0
[1.0.6]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.0.6
[1.0.5]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.0.5
