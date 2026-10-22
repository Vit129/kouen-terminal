# Changelog Archive

Older releases. See [CHANGELOG.md](../CHANGELOG.md) for recent versions.

## [4.19.1] - 2026-09-24

### Added
- Multi-agent remote-control & centralized launch table (P50) (release v4.19.1) ([`3f8ad46`](https://github.com/Vit129/kouen-terminal/commit/3f8ad469bb5986bf312cf89eb94457dcb6a43c75))

## [4.18.6] - 2026-09-23

### Added
- Real Codex/Copilot session scanning, resume variants, list UX parity ([`410161d`](https://github.com/Vit129/kouen-terminal/commit/410161dc64db9c4151b6ef115c06e7daaee1e1bd))

### Documentation
- Record decision to depend on vendor remote-control apps for mobile ([`1b21933`](https://github.com/Vit129/kouen-terminal/commit/1b219335080ffd23ed287d5466ed1c2798b4d785))

### Fixed
- Content pane covers the header cluster during the Cmd+\ slide ([`1dbd578`](https://github.com/Vit129/kouen-terminal/commit/1dbd578193bb3e5064c0c7619827b622b1bc3c75))

## [4.18.4] - 2026-09-23

### Changed
- P49 architectural hardening and decoupling (release v4.18.4) ([`f13b912`](https://github.com/Vit129/kouen-terminal/commit/f13b912b9486aced151953d4723d573c0908b51c))

## [4.18.2] - 2026-09-22

### Added
- Add browser-style back/forward navigation for tab/session switches ([`a9f3cd9`](https://github.com/Vit129/kouen-terminal/commit/a9f3cd9da516ccbfedffb522e3dc869c5401c240))

### Changed
- Replace MRU back/forward with the existing session-cycle logic ([`c32f372`](https://github.com/Vit129/kouen-terminal/commit/c32f372c95fa2051797efe71442fde1f89c7de41))

### Fixed
- Stop primary tree from squatting on a feature branch after auto-isolate ([`33ab8db`](https://github.com/Vit129/kouen-terminal/commit/33ab8db1f4bd1303eb4938159973d6fc7c9ad7f2))
- Force bracketed-paste wrapping for unsafe multi-line pastes ([`2ad8bf4`](https://github.com/Vit129/kouen-terminal/commit/2ad8bf41b8f10b7f3344ec038a72bc0925f05520))

## [4.18.1] - 2026-09-22

### Added
- Refresh graphify index before any make-start action ([`3ab464c`](https://github.com/Vit129/kouen-terminal/commit/3ab464c94cb564b06cef5fe933a3ca5bc51adaa2))

### Fixed
- Point skill-trigger at real skill names, not a nonexistent doc ([`7a328c2`](https://github.com/Vit129/kouen-terminal/commit/7a328c2cc2f5c371ee5782b401cc76bcf8992111))
- Skip graphify refresh for the preview option ([`1191651`](https://github.com/Vit129/kouen-terminal/commit/119165143399b6f2b135a8303db0cc0161b86b23))
- Skill-keywords.json was missing entries AGENTS.md declares ([`ee95464`](https://github.com/Vit129/kouen-terminal/commit/ee95464f67afa9add2bee48acef863661a42a5cd))

## [4.18.0] - 2026-09-21

### Added
- Auto-show job result on run-now + scheduled runs ([`ee30c4e`](https://github.com/Vit129/kouen-terminal/commit/ee30c4e84dbee25b4d9702f4f248aa7c72acefb0))
- Harden multi-agent attention & write safety (P46 Pillar 6) ([`8e39a3f`](https://github.com/Vit129/kouen-terminal/commit/8e39a3f7b280ba2721f02d2fb341c7d06a63cd26))
- Complete P46 CLI-First Agent Harness (phases 1-4) ([`d333cef`](https://github.com/Vit129/kouen-terminal/commit/d333cef663c1d862fa1aa0fe83b12f37c84f3fb1))
- Plan-46-agent-dev-env-completely (release v4.18.0) ([`591f084`](https://github.com/Vit129/kouen-terminal/commit/591f084bab43058000b75b76803a1fa0683fd300))

### Documentation
- Add document for kouen agent dev env terminal ([`675f881`](https://github.com/Vit129/kouen-terminal/commit/675f881115b0271a49e7fd496becf5db1a6b54d8))

### Fixed
- Close P46 follow-up gaps — verification timeout, dirty-tree guard, feed-to-agent ([`c7e66fb`](https://github.com/Vit129/kouen-terminal/commit/c7e66fb8b9e6f921899225e2d5290eea5be8f0c9))
- Row click did nothing — .onTapGesture inside List is a no-op on macOS ([`6b84d6b`](https://github.com/Vit129/kouen-terminal/commit/6b84d6b790fffc48b4ee29ea0e3146a616809bdc))
- Make PR and no-PR release paths behave identically ([`4ef384e`](https://github.com/Vit129/kouen-terminal/commit/4ef384e2dec66324f987f01bb7c8c8502520f158))

## [4.17.3] - 2026-09-19

### Added
- Add context resolve MCP tool, fix process (release v4.17.3) ([`1737cee`](https://github.com/Vit129/kouen-terminal/commit/1737cee9e444c1106f95089471cb8049acf61860))

## [4.17.2] - 2026-09-18

### Added
- Implement Phase 0 AI-SDLC workflow engine and worktree discipline ([`619ac23`](https://github.com/Vit129/kouen-terminal/commit/619ac2371877ea0477904f700de4e6e943538bd5))
- Auto markdown sync, GUI preview, and MCP feature tools ([`fd336ee`](https://github.com/Vit129/kouen-terminal/commit/fd336ee574930f41ad9a53dc9426219cc613c53a))
- Add session history phase 1, centralize logic search, centralize logo and ai provider name, fast context and token guard phase 2 (release v4.17.2) ([`440cd48`](https://github.com/Vit129/kouen-terminal/commit/440cd48d9f56376040e7d08019c11e9f44f006d6))

### Fixed
- Restore green test suite and update graphify index ([`bb7d847`](https://github.com/Vit129/kouen-terminal/commit/bb7d84739f193c32e7d22a7829addb81bb8dc81b))

## [4.17.1] - 2026-09-18

### Fixed
- Automation tab coding just show cron job only (release v4.17.1) ([`69d65ac`](https://github.com/Vit129/kouen-terminal/commit/69d65ac6a36ddeb38377b128285879ab9b2e2d16))

## [4.17.0] - 2026-09-18

### Added
- Add jobs fleet view and multi-format result viewer replacing git panel (release v4.17.0) ([`4a36837`](https://github.com/Vit129/kouen-terminal/commit/4a36837d9f04cfef5616e46a1ccc9acc39ffc2dd))

### Documentation
- Standardize ARCHITECTURE.md and CONTEXT.md per workspace rules ([`5312520`](https://github.com/Vit129/kouen-terminal/commit/53125207a8304803e55c0b85a74561cb794390e9))
- Split CLAUDE.md into rules/, consolidate to AGENTS.md ([`c66452d`](https://github.com/Vit129/kouen-terminal/commit/c66452db3e00accdda3f37ea499b441063dc9468))

### Fixed
- Reset markdown/code edit-mode per file, not sticky across tabs ([`d96405c`](https://github.com/Vit129/kouen-terminal/commit/d96405c30dec47b2b40df0709f185a4382409641))
- Never leave markdown preview blank on a JS render failure ([`461bd1a`](https://github.com/Vit129/kouen-terminal/commit/461bd1a27909cf362c49001844b5bb6c5b4abed1))
- Markdown preview render completely broken since v4.15.8 ([`d280d07`](https://github.com/Vit129/kouen-terminal/commit/d280d0732fec535af98330bce09954d452fce707))

## [4.16.0] - 2026-09-15

### Added
- Agent Swarm Core — headless fleet orchestration (P44 follow-on) ([`d125680`](https://github.com/Vit129/kouen-terminal/commit/d1256802652e4bf68c557dccd02e5bd945db5926))
- Remote HTTP/SSE transport for kouen-mcp ([`b2a982b`](https://github.com/Vit129/kouen-terminal/commit/b2a982bbf0f97a80920414dbbc68c63c8e1a6922))
- Render non-markdown source files in preview, inline file-tree preview, more languages ([`346a17e`](https://github.com/Vit129/kouen-terminal/commit/346a17e0f545b7f08ca50db7c2745757569a76b5))

### Fixed
- Secure defaults for kouen-mcp's remote HTTP/SSE server ([`3b9b58c`](https://github.com/Vit129/kouen-terminal/commit/3b9b58c74ed5cedba5ee2be9ff54fc67b7bc2138))
- Sync fleet node status on real completion, turn on Fleet dashboard ([`c66f4c2`](https://github.com/Vit129/kouen-terminal/commit/c66f4c2b1a81161c806445a4168b70a390bc7051))

## [4.15.10] - 2026-09-14

### Fixed
- Clear stale git branch label when cwd leaves a git repo (release v4.15.9) ([`aabdaaa`](https://github.com/Vit129/kouen-terminal/commit/aabdaaac87538967abb7cef6548009127c3288a0))
- Hide gutter triangles and check non-git folders in file tree (release v4.15.10) ([`a4c7b06`](https://github.com/Vit129/kouen-terminal/commit/a4c7b06ac74c77f43fde5edee56feae7f8a27a25))

## [4.15.8] - 2026-09-09

### Fixed
- Editor file preview (release v4.15.8) ([`866ef65`](https://github.com/Vit129/kouen-terminal/commit/866ef650d43b9da5b5b5a99fcdd4a39f2c1f2739))

## [4.15.7] - 2026-09-09

### Fixed
- Display markdown and mermaid format and able to click fromterminal (release v4.15.7) ([`0130c7c`](https://github.com/Vit129/kouen-terminal/commit/0130c7c60822fa5023651410db3da956d72d1c11))

## [4.15.6] - 2026-09-08

### Added
- Comment kouen create branch (release v4.15.6) ([`5405cfb`](https://github.com/Vit129/kouen-terminal/commit/5405cfb125a205ba156532d9d4381d1b04c3f93a))

## [4.15.4] - 2026-09-06

### Fixed
- Keep transient notch peek notification independent of the persistent HUD toggle (release v4.15.4) ([`5796303`](https://github.com/Vit129/kouen-terminal/commit/57963032d6fc8b5aee3fe2d323e971453c848b87))

## [4.15.3] - 2026-09-06

### Fixed
- Stop trusting NSSplitView.setPosition, assign sidebar/content frames directly ([`d6519ad`](https://github.com/Vit129/kouen-terminal/commit/d6519ad95cbd3d73c1ce0368b322d9b5c68a3683))
- Turn off Agent Notch HUD by default, merge menu-bar sessions list, fix Close toggle (release v4.15.3) ([`40620fc`](https://github.com/Vit129/kouen-terminal/commit/40620fc077db157260b876169a0650220b57ffa0))

## [4.15.2] - 2026-09-06

### Fixed
- Keep collapsed sidebar hidden across screen/window resize (release v4.15.2) ([`e84ed2d`](https://github.com/Vit129/kouen-terminal/commit/e84ed2d8077ae78f44bf74ac1264a3de5b2bbff6))

## [4.15.1] - 2026-09-04

### Fixed
- Don't wipe scrollback on ESC[3J (erase saved lines) ([`28cd81e`](https://github.com/Vit129/kouen-terminal/commit/28cd81ef668d9af5c8a7a54ddb4803b30b3cface))
- Support drag-to-scroll on terminal and file view scrollbars ([`22240df`](https://github.com/Vit129/kouen-terminal/commit/22240dfa60382e4fe95e84c0300edf070800f464))
- Fire scrollbar update immediately on pane split + register hover tracking area reliably (release v4.15.1) ([`459a000`](https://github.com/Vit129/kouen-terminal/commit/459a000529e65b0185b7f1c291db21957c8ab0bc))

## [4.14.0] - 2026-08-31

### Added
- P44 autonomous orchestrator (MCP tools, inline task badges, orchestrator contract) + git diff gutter extraction (release v4.14.0) ([`32fa5b9`](https://github.com/Vit129/kouen-terminal/commit/32fa5b92997255484ea9b53fb213ec24c3aed0a0))

## [4.13.1] - 2026-08-24

### Fixed
- Wake WKWebView compositor when a cached browser pane is revealed on tab switch ([`6003830`](https://github.com/Vit129/kouen-terminal/commit/600383020312ae7a5023ba0e131f80829908f55f))
- Wake WKWebView compositor when BrowserPaneView's own tab switch reveals a webview ([`546aa68`](https://github.com/Vit129/kouen-terminal/commit/546aa68071f87ff7841c5569e213fab42b81b4ca))
- Wake WKWebView compositor when BrowserPaneView's own tab switch reveals a webview (release v4.13.1) ([`1574111`](https://github.com/Vit129/kouen-terminal/commit/157411129ba9156b1dd895620c8f66330a7b6440))

## [4.13.0] - 2026-08-23

### Added
- Notch auto-hides when idle; fix dead approval buttons and false waiting badge across all agent hooks ([`4517786`](https://github.com/Vit129/kouen-terminal/commit/4517786394bc800a2be62059043ce5e4e3641432))

## [4.12.3] - 2026-08-19

### Documentation
- Note agent-memory is gitignored + centrally backed up (claude-memory-private) ([`bbe0980`](https://github.com/Vit129/kouen-terminal/commit/bbe0980c731df3290ee9029d732c49a4ef099a4f))
- Agent-memory-private rename (was claude-memory-private) ([`930fc1c`](https://github.com/Vit129/kouen-terminal/commit/930fc1c1712e211b1ae039f76299dfa571aa6f4b))

### Fixed
- Allow secondary browser tabs to receive the compositor repaint kick ([`6046423`](https://github.com/Vit129/kouen-terminal/commit/6046423e17eb7132a4553f326aaaffd3255533a8))
- Stop stuck git child processes and fix new file/folder not appearing in an already-expanded file tree folder (release v4.12.2) ([`f5a2736`](https://github.com/Vit129/kouen-terminal/commit/f5a273616ee97ada381490192e40bf64d3aed48d))
- Use launchctl instead of pgrep for daemon liveness in graceful install (release v4.12.3) ([`096a9b5`](https://github.com/Vit129/kouen-terminal/commit/096a9b594395b3a30eac965ad1f8be219b14eb24))

## [4.12.1] - 2026-08-13

### Fixed
- Force WKWebView repaint after load, flush session state before daemon restart (release v4.12.1) ([`12e12d1`](https://github.com/Vit129/kouen-terminal/commit/12e12d12e1a130aebabd9e380615b2bc37b784d0))

## [4.12.0] - 2026-08-09

### Added
- Add --model/--effort passthrough and kouen-cli cc run/status/list/cancel (release v4.12.0) ([`3b1d72b`](https://github.com/Vit129/kouen-terminal/commit/3b1d72b107b90c9781cfcbe3bc0f62db11376df5))

## [4.11.0] - 2026-08-09

### Added
- Add Claude Code CLI subprocess harness (kouenCCRun/kouenCCStatus) ([`3544a5f`](https://github.com/Vit129/kouen-terminal/commit/3544a5f0371d107f3f69dcfff381790a2fc277b1))

### Documentation
- Resolve M2-M9 competitive gaps to Closed, add M2-M9 feature matrix ([`71ff18e`](https://github.com/Vit129/kouen-terminal/commit/71ff18e7796ef7712cb19f1eb7674bd982c403a0))

### Fixed
- Bump ipcProtocolVersion so M2/M5's new IPC cases force a daemon restart ([`26874b4`](https://github.com/Vit129/kouen-terminal/commit/26874b4f5336e71ad8fe2e1f33c65542be1c6336))

## [4.10.0] - 2026-08-06

### Added
- Select all URL text on click ([`378c2d7`](https://github.com/Vit129/kouen-terminal/commit/378c2d71a94c7a53ae98171bd4946f41574d1967))
- Add AgentRoutingRule model for agent:"auto" spawn-time CLI routing ([`20dc1cf`](https://github.com/Vit129/kouen-terminal/commit/20dc1cf68fc3e7901dc480dd19b65459d91c827c))
- Add AgentRoutingRuleStore persistence for routing rules ([`90c0e7d`](https://github.com/Vit129/kouen-terminal/commit/90c0e7d78b93b2b9a89710a961e67f36b3146ae6))
- Add AgentRoutingResolver, first-match rule resolution to AgentKind ([`55df6e9`](https://github.com/Vit129/kouen-terminal/commit/55df6e9f0d4f55b66ae1765a703141a496172af7))
- Add IPC-safe AgentRoutingRuleSummary type ([`ba9081c`](https://github.com/Vit129/kouen-terminal/commit/ba9081cf1b2742df515efd1214de81ff73c7e88e))
- Add defaultAgentKind fallback for unmatched auto-routing ([`b7ec376`](https://github.com/Vit129/kouen-terminal/commit/b7ec37671d09e60c3294483e0fdecba86207fa62))
- Gate routing-rule mutate tools behind MCP control policy ([`9a74c89`](https://github.com/Vit129/kouen-terminal/commit/9a74c89358890028c0dc3f4b54e4f9494b971c18))
- Register kouenRoutingRule* MCP tools ([`ef6cfaa`](https://github.com/Vit129/kouen-terminal/commit/ef6cfaac229639fa7acd0c232d582a3b15c207bd))
- Resolve agent:"auto" via routing rules in kouenSpawnAgent ([`9af8ce0`](https://github.com/Vit129/kouen-terminal/commit/9af8ce07579869f9e00e20213a28b0922715eb68))
- Add routing-rule and saved-layout IPC request/response cases ([`0fcf649`](https://github.com/Vit129/kouen-terminal/commit/0fcf6495f65a03f8219c58790b40b332abb60f53))
- Wire AgentRoutingRuleStore and SavedLayoutStore into the daemon ([`ab89e33`](https://github.com/Vit129/kouen-terminal/commit/ab89e33e89db80fe758046c0950d395257ffbd23))
- Add agent-routing-rules.json and saved-layouts.json paths ([`9003355`](https://github.com/Vit129/kouen-terminal/commit/9003355e58874e26901e5a214c00b479c599e02b))
- Add browser design mode — hover-highlight, click-select, style preview, Copy CSS ([`88ceec7`](https://github.com/Vit129/kouen-terminal/commit/88ceec72d377ff3a038cf46dbba24ddb20ea8a44))
- Add SavedLayout/PaneLayoutShape model, distinct from LayoutTemplate ([`de854b3`](https://github.com/Vit129/kouen-terminal/commit/de854b3131358b0d11673d3582669c3741d6ee6b))
- Add IPC-safe SavedLayout type ([`f35eb06`](https://github.com/Vit129/kouen-terminal/commit/f35eb060eba83a8d0dacf322f706dd4f0fb9c462))
- Apply saved layout shape via recursive client-side split ([`df654b5`](https://github.com/Vit129/kouen-terminal/commit/df654b511d63f602f10ec79cf3680457145bbb6e))
- Add RiskyCommandClassifier regex heuristic for risky-shell-command detection ([`53c5e8f`](https://github.com/Vit129/kouen-terminal/commit/53c5e8ffa62f0bc6b3ca7ed7d24962d11ce617d7))
- Saved-layout facade methods + risky-command advisory toast on command finish ([`48628e5`](https://github.com/Vit129/kouen-terminal/commit/48628e5ebcff258bf296a76860ed2bfdb7ea012b))
- Add Fork Conversation, Save/Apply Layout, Request Peer Review menu actions ([`c5f34d9`](https://github.com/Vit129/kouen-terminal/commit/c5f34d9f4eb5ee84f2cca73f533678cba962046c))
- Parse PR reviewDecision from gh CLI output ([`38a6d02`](https://github.com/Vit129/kouen-terminal/commit/38a6d020e1ef7ffa2c9993ac4329bf44c22a285c))
- Thread prReviewDecision through RepoGitMetadata ([`cbabb1e`](https://github.com/Vit129/kouen-terminal/commit/cbabb1e9d93b66739f4612406a2bc52794121301))
- Offer checks-waiver merge when PR is approved, never waive mergeable ([`a4b1ef2`](https://github.com/Vit129/kouen-terminal/commit/a4b1ef2ec3c2f0aa8fba718bd33d255e1cf3e745))
- Add slash-command discoverability picker; fix(composer): reassert typingAttributes before every keystroke, not just once, so typed text is never black ([`b990ae9`](https://github.com/Vit129/kouen-terminal/commit/b990ae965f809b6e45097d51d1d0774645a35974))

### Changed
- Drop Agents cross-repo review dashboard, redundant with Board+Worktrees ([`ebde550`](https://github.com/Vit129/kouen-terminal/commit/ebde550f34bd36084d32043fcdd4063c8cf7ebfd))
- Drop selectAgentsTab notification handling, Agents tab removed ([`5963963`](https://github.com/Vit129/kouen-terminal/commit/59639639c92a4b2a69fec4d38942b924b1131943))
- Drop Review Agent Work action, Agents tab removed ([`bfbba02`](https://github.com/Vit129/kouen-terminal/commit/bfbba02e79db137722e1c6cce036a8a7e55acffa))

### Documentation
- Migrate stale Claude Code auto-memory into portable agent-memory ([`aeea3e7`](https://github.com/Vit129/kouen-terminal/commit/aeea3e7a0a4739cf14b60da0f4349e5549d0e1aa))
- Update parseWorktreePorcelain comment after Agents tab removal ([`c28fca3`](https://github.com/Vit129/kouen-terminal/commit/c28fca3439810b653c924b7c78ab093622a81335))
- Record Agents tab removal decision (redundant with Board/Worktrees, 2026-08-06) ([`597da09`](https://github.com/Vit129/kouen-terminal/commit/597da09ebdcc73c401f9fe7a24107222e12a4292))
- Design doc — session-spawn CLI routing (scope-corrected from Warp's model router) ([`723ae60`](https://github.com/Vit129/kouen-terminal/commit/723ae6032e02cee01c93243642b960e16831487e))
- Task progress — closed, build/test/robot green, live-check owed ([`6d8d171`](https://github.com/Vit129/kouen-terminal/commit/6d8d1718eec2737694fe68b6c8f10970b2dc0d56))
- Design doc — visual-preview-only, no source-file round-trip (scope cut) ([`be96d23`](https://github.com/Vit129/kouen-terminal/commit/be96d23cf87b9ddf12247d211b592fe929c0ef67))
- Task progress — closed, build/test/robot green, live-check owed ([`4706020`](https://github.com/Vit129/kouen-terminal/commit/4706020589fcfbd31271fca3345d041c0a6fed0d))
- Task progress — closed, shape-only (no ratio/process restore) ([`3195e36`](https://github.com/Vit129/kouen-terminal/commit/3195e3609c6306627587b43d71a1c9f65abcbf57))
- Task progress — closed, advisory-only (fires after command finishes) ([`7a5cb99`](https://github.com/Vit129/kouen-terminal/commit/7a5cb99e3b7b37ed8580990d73d3d641e207e074))
- Design doc — reuses each CLI's own native fork flag, claude-code/codex only ([`6ce1035`](https://github.com/Vit129/kouen-terminal/commit/6ce1035d123c1d37f227dadf9c427862f602836b))
- Task progress — closed, build/test green, live-check owed ([`93f2b6f`](https://github.com/Vit129/kouen-terminal/commit/93f2b6faf7d7420e0e59dbdaf8455f8674afbe73))
- Task progress — closed, human-triggered ask-only (no auto-capture/paste-back) ([`dff7428`](https://github.com/Vit129/kouen-terminal/commit/dff7428ea8f5012f8823fcff743ceebe64ac4bfe))
- Task progress — closed, extends existing P39 G3 merge picker ([`6912b9d`](https://github.com/Vit129/kouen-terminal/commit/6912b9d47b74954cf24fd5f6dc735a06cad75eb5))
- Task progress — closed, @file mention cut (documented, not built) ([`6df1e8d`](https://github.com/Vit129/kouen-terminal/commit/6df1e8d3d762f285ebc7a1d9ba7076632b4034d6))
- Define M2-M9 vocabulary (Agent Routing Rule, Design Mode, Fork Conversation, Saved Layout, Risky Command Advisory, Request Peer Review, Merge Waiver, Slash Command Picker) ([`aa70e24`](https://github.com/Vit129/kouen-terminal/commit/aa70e2441c8cb9744f02ab3a736c64e269421893))
- Wayfinder map — M2-M9 competitive-gap features, all 8 tickets closed 2026-08-05 ([`7d90631`](https://github.com/Vit129/kouen-terminal/commit/7d90631ea8a04b073e810f4b509cfd546912a8f0))
- Record user approval to build all 8 M2-M9 gaps despite no per-feature usage signal ([`5885603`](https://github.com/Vit129/kouen-terminal/commit/588560329c21b84bb48c2239c74d3ba909ca2cea))
- Index M2-M9 plan files and wayfinder map ([`357525a`](https://github.com/Vit129/kouen-terminal/commit/357525a065136f8adaf445fd9181236268d3be92))
- Index m2-m9-competitive-build-decision and agents-tab-removed memory files ([`64465c2`](https://github.com/Vit129/kouen-terminal/commit/64465c2cdb8ada28a6dd3812ce3716a44fe9fa99))
- Flag broken [[review-new-features-against-lessons]] link for follow-up ([`df9ca7f`](https://github.com/Vit129/kouen-terminal/commit/df9ca7fd443c04833102600e887c39cc989f2dde))
- Flag broken [[feedback_review-new-features-against-lessons]] link for follow-up ([`b4d2e2e`](https://github.com/Vit129/kouen-terminal/commit/b4d2e2ea0203447482a45b5aedf7667cff6e3e6d))
- Record 2026-08-02 scheduled memory-maintenance run results ([`4eb5454`](https://github.com/Vit129/kouen-terminal/commit/4eb5454bbaed9cf7752f489700d7af24fab051bf))
- Open gate for kouen-browser-mcp-intermittent-unresponsive investigation ([`a4d757f`](https://github.com/Vit129/kouen-terminal/commit/a4d757f2f5d980679133057325e944eb952eec9d))
- Forbid nested git worktrees inside .kouen-worktrees/ ([`1e78819`](https://github.com/Vit129/kouen-terminal/commit/1e788199114509b1450c604f2f996d6661c6af7b))

### Fixed
- Guard stale file-tree scan from clobbering active session's root ([`795736f`](https://github.com/Vit129/kouen-terminal/commit/795736f013e65296b3682d8a1e3844267a9b4493))

## [4.9.3] - 2026-07-31

### Fixed
- Reload board columns on metadata-only snapshot pushes (release v4.9.3) ([`8715c54`](https://github.com/Vit129/kouen-terminal/commit/8715c54b7066cdf5e037a82e57615d903fecc8eb))

## [4.9.2] - 2026-07-29

### Fixed
- Clamp persisted sidebar width so Cmd+\ toggle can't get stuck at zero-delta (release v4.9.2) ([`c42b0c0`](https://github.com/Vit129/kouen-terminal/commit/c42b0c0552fc9a3633df90222ee4ba40ec2d43b0))

## [4.9.1] - 2026-07-27

### Added
- AppIntents/Shortcuts (Phase 7), sidebar-width persistence (Phase 5) ([`c583a5b`](https://github.com/Vit129/kouen-terminal/commit/c583a5b000c7aa476566dcf7a73062565ada6247))

### Documentation
- Fix stale Phase 5 note, record why Phases 4/6/10/11/12 are deliberately deferred ([`4f50fe2`](https://github.com/Vit129/kouen-terminal/commit/4f50fe20eae13c18aa4f3a646d0252f281518594))
- Close P8 and P37, archive completed plan docs ([`d8e3673`](https://github.com/Vit129/kouen-terminal/commit/d8e36737b1c689956dfc755b7cbb6debbd593599))

### Fixed
- Resync GeneratedReleaseNotes.swift; test(notch): fix stale peek-size assertions ([`82fc709`](https://github.com/Vit129/kouen-terminal/commit/82fc7094c528c550de1dfbb74477ac98e9a8789c))
- Prevent FSEventStream teardown race crash in FileTreeWatcher ([`4cd5d46`](https://github.com/Vit129/kouen-terminal/commit/4cd5d466b47abacde7f31dc23a5ccb058087c3e2))
- Resolve sidebar toggle window via NSApp.windows loop, not keyWindow chain ([`0a71a0b`](https://github.com/Vit129/kouen-terminal/commit/0a71a0b9425cf6b227877198d6da372dbef049dd))

## [4.9.0] - 2026-07-26

### Added
- Approve/deny, quick-reply, exact-pane jump, per-event sounds ([`1aaa5f3`](https://github.com/Vit129/kouen-terminal/commit/1aaa5f3e206fd1a96c0ab13cb4e599acf1654196))

### Fixed
- Restore Liquid Glass transparency pipeline and finish browser-pane chrome ([`ef055ad`](https://github.com/Vit129/kouen-terminal/commit/ef055ad6a94f67b5e641e1aadabb6e32b8ada5d8))
- Enable arrow-key line editing in release-pipeline prompts ([`16b1a41`](https://github.com/Vit129/kouen-terminal/commit/16b1a415e8eb0b4e9b442bc55d5e42b5fd4a35cf))
- Guard MobileBridgeServer reference for platforms without Network ([`aa89f1b`](https://github.com/Vit129/kouen-terminal/commit/aa89f1bb844cc55345a93979e01fe68cc5dd2b4a))

## [4.8.0] - 2026-07-25

### Added
- Adopt macOS 27 plan additions and window quick wins ([`d9c510c`](https://github.com/Vit129/kouen-terminal/commit/d9c510cad7a55fa0906c2bf23730e6f832b0d03e))
- Add actionable notification category with Focus Pane, Rerun Command, and Copy Output ([`70a0c94`](https://github.com/Vit129/kouen-terminal/commit/70a0c9474a10a226a49596a0c808c3d36299da4a))
- Make session row title semi-bold only when selected ([`713072b`](https://github.com/Vit129/kouen-terminal/commit/713072bec16ca2e72543cccbba92a07342b8b00c))
- Add ActivityAssertionManager to prevent App Nap during builds/agent runs ([`cbc4d5e`](https://github.com/Vit129/kouen-terminal/commit/cbc4d5efa8ed7d16b07b08c9300c0453fba31cf8))
- Adopt NSViewCornerConfiguration and .containerConcentric on overlays ([`b3e077a`](https://github.com/Vit129/kouen-terminal/commit/b3e077a4ca296c2e419d05eab59596c3e755a6a6))
- Support macOS27 beta 4 first version ([`a4a6480`](https://github.com/Vit129/kouen-terminal/commit/a4a64806327501342e61a372fa2437d3fe08e49d))

### Documentation
- Add Scheduled Memory Maintenance Job term to LANGUAGE.md ([`604056a`](https://github.com/Vit129/kouen-terminal/commit/604056a119a5fe4b596737fa87aa496fae45c5f2))
- Rename LANGUAGE.md to GLOSSARY.md ([`6680d0d`](https://github.com/Vit129/kouen-terminal/commit/6680d0d48c4ac1e7c13e03f5905cb3fe943070b5))
- Record Xcode 27 beta compatibility findings for Phase 1 ([`559b46f`](https://github.com/Vit129/kouen-terminal/commit/559b46f41aa4e49e2083b085fd838036f9d6d844))

### Fixed
- Guard UNUserNotificationCenter calls when bundle identifier is nil ([`79c1e2a`](https://github.com/Vit129/kouen-terminal/commit/79c1e2a5e4d008a30df925366ed63dfc0433aed7))
- Safely handle UNUserNotificationCenter in xctest runner environment ([`cc76905`](https://github.com/Vit129/kouen-terminal/commit/cc7690547f8656b6623fb0ff80c98c941c152930))
- Guard updateTrackingAreas against window==nil in TabOverviewController/ContentAreaViewController ([`4f023e2`](https://github.com/Vit129/kouen-terminal/commit/4f023e299892784e48ca3599a2b50e6ba3ffb1be))
- Replace unsafe MainActor.assumeIsolated with Task { @MainActor in } ([`9d11f68`](https://github.com/Vit129/kouen-terminal/commit/9d11f6866599c3f2fc42506ea72579b25e48c448))

## [4.7.4] - 2026-07-23

### Fixed
- Stop daemon-side pane changes from being silently discarded while a browser pane is open (release v4.7.4) ([`c3cef05`](https://github.com/Vit129/kouen-terminal/commit/c3cef05dce46471c3503406e1520166d3c188b01))

## [4.7.3] - 2026-07-23

### Fixed
- Raise daemon-routed git request timeout from 2s to 30s (fetch/pull/push were silently timing out on ordinary network latency) (release v4.7.3) ([`080808d`](https://github.com/Vit129/kouen-terminal/commit/080808d0e8cd154b1b85235993b1daeb3b62c6d4))

## [4.7.2] - 2026-07-23

### Added
- MAW-style merge validate gate + agent handoff surfacing (human review + agent-to-agent spawn seed) (release v4.7.2) ([`8e70a64`](https://github.com/Vit129/kouen-terminal/commit/8e70a645b15759a253c001f03a57dfafc4f3a2e2))

## [4.7.1] - 2026-07-22

### Added
- Ghq-style wake command, signal-file agent routing, graphify LSP hover (release v4.7.0) ([`f87dec3`](https://github.com/Vit129/kouen-terminal/commit/f87dec32fa9b0585f008029b55971abd0c09eb94))

### Fixed
- Replace Harness placeholder logo with Kouen brand mark ([`aba004e`](https://github.com/Vit129/kouen-terminal/commit/aba004e4d6091b2ae92e2a3d23aac237c0aafa87))
- Closed notch pill no longer forced to a 100pt floor on non-notch Macs ([`a8e3cc7`](https://github.com/Vit129/kouen-terminal/commit/a8e3cc7e526482e488d8a856f572a47521dbdbfd))
- Stop swallowing gh release create/edit errors in full-cycle.sh ([`01322f5`](https://github.com/Vit129/kouen-terminal/commit/01322f5f0d37e2e986a8c82ea6bd92a17fa0901d))
- Guard release notes against GitHub's 125000-char body limit ([`ae57497`](https://github.com/Vit129/kouen-terminal/commit/ae57497f862488d9a3ed0cdb7af62a4c4e0e9e72))
- Browser pane always opens in the requesting session's own tab, not whichever tab is focused (release v4.7.1) ([`312d940`](https://github.com/Vit129/kouen-terminal/commit/312d940e1539610cb92d5df319afcaa873cf095e))

## [4.6.1] - 2026-07-18

### Added
- Group Task Dashboard by project, auto-delete tasks on done ([`90c9d82`](https://github.com/Vit129/kouen-terminal/commit/90c9d82500758e3253090c1cc31caa8796fbe1c5))

### Fixed
- Emit task createdAt/updatedAt in UTC+7 instead of UTC ([`2341efd`](https://github.com/Vit129/kouen-terminal/commit/2341efd32aadfc529276404f91c48c7970240ed3))
- Route markdown through syntax view, restore file preview copy/find (release v4.6.1) ([`d725578`](https://github.com/Vit129/kouen-terminal/commit/d7255785f2ac840f5a6722809bee0eff4bc5ae7d))

## [4.6.0] - 2026-07-17

### Added
- Dedupe open-tab repo roots into kouenProjectsList MCP tool (release v4.6.0) ([`e0e5fd0`](https://github.com/Vit129/kouen-terminal/commit/e0e5fd03ee6e34b1a8a63f02b617e08e2d54c033))

## [4.5.5] - 2026-07-16

### Fixed
- Forward arrow keys through doCommandBy when input routes via marked-text/IME (release v4.5.5) ([`14d012e`](https://github.com/Vit129/kouen-terminal/commit/14d012e95e6eaf20c95334a84e9c4a096e3485ee))

## [4.5.4] - 2026-07-16

### Fixed
- Restore path-insert as default terminal drop (⌥-drag opts into file preview) (release v4.5.4) ([`26b7d4f`](https://github.com/Vit129/kouen-terminal/commit/26b7d4f20537ae357d077b28e5bc8e3cf62fc0ef))

## [4.5.3] - 2026-07-16

### Added
- Group Recipes & History picker by originating pane ([`4bf668f`](https://github.com/Vit129/kouen-terminal/commit/4bf668f0ad76e6e2905243ef0ea88ba0b0a973a4))
- Add Codex MCP config support (config.toml, not JSON) ([`e2880c5`](https://github.com/Vit129/kouen-terminal/commit/e2880c5b107660902e01587201584d717b2fa0f4))
- Add Antigravity (agy) Stop hook support ([`7797811`](https://github.com/Vit129/kouen-terminal/commit/77978114c2c73fa0a2b752ac8aff6dca7f9c2117))
- Check for newer git-clone version at launch, confirm before pull ([#53](https://github.com/Vit129/kouen-terminal/pull/53)) ([`7168498`](https://github.com/Vit129/kouen-terminal/commit/716849804b32609cd8872b39fd743c85e1d2712c))
- Drag-and-drop file support (terminal open-preview, sidebar copy-in) (release v4.5.3) ([`1a2606c`](https://github.com/Vit129/kouen-terminal/commit/1a2606c193055be31a1a52095cce366e3c576c67))

### Fixed
- Scope kouenBrowserOpen pane reuse to the target tab ([`17ca4fe`](https://github.com/Vit129/kouen-terminal/commit/17ca4fe97dcb56faac7a73c34b2190de615ba865))
- Show checkmark when agent hooks are installed ([`d28e15d`](https://github.com/Vit129/kouen-terminal/commit/d28e15de36ea82d100e31a1b6de98f5d4e87b948))

## [4.5.1] - 2026-07-15

### Fixed
- Actually call WorktreeAutoIsolateService.shared.start() ([`8b72ae3`](https://github.com/Vit129/kouen-terminal/commit/8b72ae3d29ead59df5130466c16e30b0527c77ce))

## [4.5.0] - 2026-07-15

### Added
- Subagent visibility badge on tab/sidebar (P38 Phase B) ([`958c383`](https://github.com/Vit129/kouen-terminal/commit/958c3839719716433959f82368ffbc37e14e645d))
- Merge command-history into the Recipes picker (P38 Phase C) ([`3ccfb9a`](https://github.com/Vit129/kouen-terminal/commit/3ccfb9a0abf7d456d075a6ae2c4a6961d72103c8))
- Kitty Graphics protocol conformance slice (P38 Phase D) ([`3327cb9`](https://github.com/Vit129/kouen-terminal/commit/3327cb92cd65bc1b51a8700c2bf72737ee7e2d83))

### Documentation
- Update P38 status across all phases in plans index ([`afc3b4f`](https://github.com/Vit129/kouen-terminal/commit/afc3b4fdac9bb7b59b4a650a38bb48b2d7c2ea23))

### Fixed
- Dispatch paneCreated/paneRemoved lifecycle hooks (P38 Phase E) ([`214d621`](https://github.com/Vit129/kouen-terminal/commit/214d621f9ea0436c1558a393f939759e75d97cd7))
- Auto-isolate background tabs, not just the focused one ([`f8b9ec4`](https://github.com/Vit129/kouen-terminal/commit/f8b9ec4f52ca373ddc2850c93a429bc40332a33f))

## [4.4.4] - 2026-07-14

### Fixed
- Switch panel view + tag worktreePath on click-to-worktree navigation (release v4.4.4) ([`e99d916`](https://github.com/Vit129/kouen-terminal/commit/e99d91628398014a98ca2e4e941646f8f62fc790))

## [4.4.3] - 2026-07-14

### Added
- Mobile terminal keyboard toolbar (Esc/Tab/Ctrl-C/Ctrl-D/arrows) ([`075f081`](https://github.com/Vit129/kouen-terminal/commit/075f081c56e42bc45100d1fea65a946658130aa4))
- Mobile terminal @ file-path autocomplete (P37 Phase G1) ([`d1dafe5`](https://github.com/Vit129/kouen-terminal/commit/d1dafe5476f388eadd9da65057005160b8cb6d1d))
- Mobile terminal shell tab-completion suggestion strip (P37 Phase G2) ([`92e6d99`](https://github.com/Vit129/kouen-terminal/commit/92e6d999dba202af9277d3803cdd0237f7085c6e))
- Mobile terminal AI command suggestion via claude CLI (P37 Phase G3) ([`ab34833`](https://github.com/Vit129/kouen-terminal/commit/ab348337b80732766bd776137a44688ba8dce0d5))
- Capture creating session's cwd on Kouen Task create ([`0e536f9`](https://github.com/Vit129/kouen-terminal/commit/0e536f9ee631ce7504c9717fbd82d15c5d528ac3))
- Add cross-repo Agents review dashboard + merge flow, fix worktree card navigation (release v4.4.3) ([`71bebac`](https://github.com/Vit129/kouen-terminal/commit/71bebac368e613f08a2870f92d81927e0bfb03d0))

### Documentation
- Record F2 keyboard toolbar shipped + F3 already-true in Phase F ([`e0f9401`](https://github.com/Vit129/kouen-terminal/commit/e0f94013bb2e932af4a451f501b3c5b2ed6dee02))
- Design + task breakdown for P37 Phase G (autocomplete) ([`471b406`](https://github.com/Vit129/kouen-terminal/commit/471b406d87c912b4e3955f92ecd8ab97bc25dd35))
- Defer P37 F5 (share-sheet upload) pending web-based mobile bridge completion ([`953c320`](https://github.com/Vit129/kouen-terminal/commit/953c3201e1443a8cb3c5b14e1d96641157f858b2))
- Caveman-compress CLAUDE.md to cut input tokens ([`32fb624`](https://github.com/Vit129/kouen-terminal/commit/32fb6242f166438e6846300d33c959d2ff85bc23))
- Record today's P39/P40 verification pass, refresh graphify ([`4f98d53`](https://github.com/Vit129/kouen-terminal/commit/4f98d53b2780a56d7ae1ffce6a007cfb91363951))

### Fixed
- G3 newline auto-execute, pipe deadlock risk, stale AI suggestion state ([`a5edcd5`](https://github.com/Vit129/kouen-terminal/commit/a5edcd534e7a9ca58347088f1a0405838f9667ca))
- Cmd+\ sidebar toggle raced window's launch-time resize-to-real-size, causing stuck squeeze/black panel ([`050c5a6`](https://github.com/Vit129/kouen-terminal/commit/050c5a6702caa66c8c86dfa6927d2c02da710ab1))
- Browser open reuses existing pane as new tab instead of splitting a second pane ([`ce7ef5a`](https://github.com/Vit129/kouen-terminal/commit/ce7ef5a75e34daec09b1dde6f88cb53ab871c155))
- Mobile bridge terminal double-wrap on real phone width, upload picker no-op, add copy-path ([`61db127`](https://github.com/Vit129/kouen-terminal/commit/61db1278cbb0de74926cdde45f067fdde51dc250))
- Mobile bridge reconnect trusts a stale readyState and never retries an active drop (P37 F4) ([`04aa4c1`](https://github.com/Vit129/kouen-terminal/commit/04aa4c12bb4beadbe259520634a241646faf2384))

## [4.4.2] - 2026-07-13

### Added
- Mobile-triggered Mac window focus + protect native window from phone resize votes ([`912d9c3`](https://github.com/Vit129/kouen-terminal/commit/912d9c3f608b9f23bd95b43b3f396e54864ca802))
- Mobile bridge readFile/listDirectory for read-only file preview (P37 Phase D1, server-side) ([`b19b9c5`](https://github.com/Vit129/kouen-terminal/commit/b19b9c52ba9b488c00e8e8ceb7b1909e9d81ffe8))
- Mobile bridge file preview UI — files sheet + text/image preview view (P37 Phase D1, client-side) ([`afdd16a`](https://github.com/Vit129/kouen-terminal/commit/afdd16ac40bca4cbed823564a22131ed32d01a23))
- Mobile bridge file/image attach (upload) — server + client (P37 Phase D2) ([`4598906`](https://github.com/Vit129/kouen-terminal/commit/45989063982e96ddbdc7c4ece650b35777cfb6a7))
- Mobile bridge browser mirror — navigate/snapshot/interact/screenshot (P37 Phase D3) ([`caf3330`](https://github.com/Vit129/kouen-terminal/commit/caf3330b6782e43386e7dca0176561ecfb86c79d))
- Mobile bridge unified preview tab-strip + tablet layout (P37 Phase E) ([`3f39ad0`](https://github.com/Vit129/kouen-terminal/commit/3f39ad0679045cb3eb919a59357394e589266ced))

### Documentation
- Record second Opus review pass + fixes in Phase E task doc ([`1787d47`](https://github.com/Vit129/kouen-terminal/commit/1787d47236a4d48fe618df223c4fa00e6649ad27))

### Fixed
- Browser interact used a different element list than snapshot, could click the wrong element ([`35e520d`](https://github.com/Vit129/kouen-terminal/commit/35e520d40d433bcb34728996ac302a0c70e0f0f6))
- Phase E's #term-empty leaked onto phone, browser back/forward/reload raced the page load ([`1e2470d`](https://github.com/Vit129/kouen-terminal/commit/1e2470dada5cb696be41f4a84633fc6088f09f1a))
- Resync sidebar-side layout when Settings toggles Sidebar-on-right, preventing stuck black panel on next Cmd+\ (release v4.4.2) ([`a3c0912`](https://github.com/Vit129/kouen-terminal/commit/a3c091238e4a6002d825c4b3b68d3cca8172eedb))

## [4.4.1] - 2026-07-12

### Added
- Reveal cat/view'd files in the sidebar file tree (OSC 7736) ([`62907cb`](https://github.com/Vit129/kouen-terminal/commit/62907cba3be34262f7e4ffcbedd170f866c43547))

### Fixed
- Copy-mode yank leaked kouen-cat line numbers past the SGR 73/74 exclude marker ([`3081f32`](https://github.com/Vit129/kouen-terminal/commit/3081f327500808f8fad3dbf080dd81b0f9c864a3))
- Mobile-created sessions register as real tabs so they show and stay selectable; enable iOS predictive text in mobile terminal (release v4.4.1) ([`662b25b`](https://github.com/Vit129/kouen-terminal/commit/662b25bd2ae02062fcd9bb0f6ed8896fe83c9a83))

## [4.4.0] - 2026-07-11

### Added
- P39 competitive-gap closes — SSH agent forwarding, sidebar port badge, git hunk staging, in-app PR merge, fleet visibility badge ([`3de6c1b`](https://github.com/Vit129/kouen-terminal/commit/3de6c1b4f9d72e5b07217a16b279df1a6e07c294))
- Add Tasks/Worktree/Hosts MCP tools and Automations scheduler (release v5.0.0) ([`93a50da`](https://github.com/Vit129/kouen-terminal/commit/93a50da38140fb540a737389f39c30e256d6ae11))

### Fixed
- Reload MCP tool policy on every check, not once at construction ([`ac866cb`](https://github.com/Vit129/kouen-terminal/commit/ac866cbeca5f743149661147411b103b2f01c78c))
- Move Cmd+F find bar below pane's browser/split/close icon row ([`825db24`](https://github.com/Vit129/kouen-terminal/commit/825db24f817f9196b0fc6eaa382c9ca84f2a6bc1))
- Mobile pairing rejected every real device because the token rotated out before connect ([`ee35d81`](https://github.com/Vit129/kouen-terminal/commit/ee35d81c2a2bf8b813102a800582f5585ddb3cd4))
- Browser pane sends a real Safari UA so Google/Apple OAuth doesn't reject it ([`33a58d8`](https://github.com/Vit129/kouen-terminal/commit/33a58d885116b388e37f9bce25aa0894d4a2113f))
- Correct release to v4.4.0 (was mistakenly major-bumped) and scope kouenBrowserOpen to the calling agent's own session ([`06598f7`](https://github.com/Vit129/kouen-terminal/commit/06598f7409059ede306e7b93a26d760af7ac9d1c))

## [4.3.1] - 2026-07-10

### Fixed
- Stop worktree branch cache clobbering, silent terminal file-link failures, and uncapped git panel history (release v4.3.1) ([`9c0304d`](https://github.com/Vit129/kouen-terminal/commit/9c0304df829b04773d5a24a2548a0a6d5a405a25))

## [4.3.0] - 2026-07-10

### Added
- Mobile bridge Settings toggle no longer restarts daemon + P37 Phase C real terminal client (release v4.3.0) ([`02c64fe`](https://github.com/Vit129/kouen-terminal/commit/02c64feafd47ad0f32d0fdf6375ded04aa5371c7))

## [4.2.0] - 2026-07-09

### Added
- P37 mobile-bridge hardening + S1 daemon-restart fix (release v4.2.0) ([`d2b4992`](https://github.com/Vit129/kouen-terminal/commit/d2b4992ec436b4a50306bd1274bbb8f81d3ac998))

## [4.1.0] - 2026-07-08

### Added
- Add QuickTerminalController, a visor-style ⌥Space terminal panel ([`5299db6`](https://github.com/Vit129/kouen-terminal/commit/5299db6ae8ffb30ed6594c7c8d9d7d2b9f6f2f19))
- Darken app icon green + add dark-mode Dock icon via runtime swap ([`66e182f`](https://github.com/Vit129/kouen-terminal/commit/66e182f956a673f7a1cefbcabc37a4e321e9de49))
- P25 mobile pairing bridge — pairing MVP + production wiring (build 195) ([`b6b54f0`](https://github.com/Vit129/kouen-terminal/commit/b6b54f08c9fae7925a67a37d3e48a1a823d12407))

### Documentation
- Add fork maintainer's copyright to LICENSE ([`bd413ab`](https://github.com/Vit129/kouen-terminal/commit/bd413ab15bf86937648e1e73b533a0494a5128ee))
- Update agent memory notes ([`a7ba739`](https://github.com/Vit129/kouen-terminal/commit/a7ba7393458eccc6d8a707c04ad509d16bac138c))

### Fixed
- Bump CI's pinned Xcode from 16 to 26.5 to match the dev toolchain ([`4d2f9bc`](https://github.com/Vit129/kouen-terminal/commit/4d2f9bcdbc021463632644d242201ea16216af13))
- Guard UserNotifications import for Linux headless daemon build ([`589e9d0`](https://github.com/Vit129/kouen-terminal/commit/589e9d058c3a844a0218f4edec177087e3ac39fb))
- Use the existing kouenStderr/new kouenStdout idiom in CLI install-tools/agent ([`ec7260d`](https://github.com/Vit129/kouen-terminal/commit/ec7260dcd72b6754b3e8e1a6770ef147cb402c57))
- Pad dark Dock icon to match light icon's OS-auto-shrunk size ([`2cd359b`](https://github.com/Vit129/kouen-terminal/commit/2cd359b66dbe77b0a32bde68879165bac5d0cc99))
- OAuth login and nested-iframe scroll in embedded browser pane ([`83a345b`](https://github.com/Vit129/kouen-terminal/commit/83a345bca9e8eb5748df61f7763b5cff5a6fd447))
- Prune legacy harness-cli hook entries on agent reinstall ([`5674ba5`](https://github.com/Vit129/kouen-terminal/commit/5674ba50c3cd96611393b25ffea3e02d3592f306))
- Stop QuickLook preview flicker loop from self-triggered attrib events ([`6142a1b`](https://github.com/Vit129/kouen-terminal/commit/6142a1b370d31236e71cce3785e27a4b53af5aee))
- Clean up git panel error toast for push/fetch/pull failures ([`3695e83`](https://github.com/Vit129/kouen-terminal/commit/3695e8340581cd100f70ce2a5cf2e9f57f4df15d))

## [4.0.0] - 2026-07-06

### Added
- Rename product from Harness to Kouen ([#43](https://github.com/Vit129/kouen-terminal/pull/43)) ([`2bc7925`](https://github.com/Vit129/kouen-terminal/commit/2bc7925119cf1b50fdf7361fe7dfde6682ae31e3))
- KOUEN_HOME env var, sentinel migration, v4.0.0 bump ([#45](https://github.com/Vit129/kouen-terminal/pull/45)) ([`19e8093`](https://github.com/Vit129/kouen-terminal/commit/19e809387e29e77692346cc0c8a62847930d7d1a))
- Migrate the App Support data root from Harness to Kouen ([#48](https://github.com/Vit129/kouen-terminal/pull/48)) ([`741dcdd`](https://github.com/Vit129/kouen-terminal/commit/741dcddd123b7df937fe3b80e212489a34540608))
- Rename all internal Swift modules, directories, and identifiers to Kouen ([#49](https://github.com/Vit129/kouen-terminal/pull/49)) ([`d2eec67`](https://github.com/Vit129/kouen-terminal/commit/d2eec6723d7b21ba8682650bbb76974e43327188))

### Documentation
- Add "What's different from upstream" section to README ([`5aaa78e`](https://github.com/Vit129/kouen-terminal/commit/5aaa78e377245791e85f766af9302638c97164da))
- Trim "What's different from upstream" to link existing sections ([`4a55d8f`](https://github.com/Vit129/kouen-terminal/commit/4a55d8fc5a3570e230df7d2b55a5f36188cc5c2e))
- State explicitly that this fork isn't affiliated with upstream ([#40](https://github.com/Vit129/kouen-terminal/pull/40)) ([`6174f26`](https://github.com/Vit129/kouen-terminal/commit/6174f2682a6e5dfae3f8471d237d15cac710ba42))
- Trim README's upstream mention to one, fix stale repo links ([#47](https://github.com/Vit129/kouen-terminal/pull/47)) ([`ca71cbf`](https://github.com/Vit129/kouen-terminal/commit/ca71cbfb828e47f077e53edcd838060711dededb))
- Capture P35 plan — Google/OAuth login fails in embedded browser ([#42](https://github.com/Vit129/kouen-terminal/pull/42)) ([`20f5e2d`](https://github.com/Vit129/kouen-terminal/commit/20f5e2d661805842229d3b834d74cda68ed935cf))

### Fixed
- Rebrand bundle identifier off upstream, disable Sparkle appcast ([#41](https://github.com/Vit129/kouen-terminal/pull/41)) ([`37867d5`](https://github.com/Vit129/kouen-terminal/commit/37867d59459c0a457422bcc4f5e233c0fdcfc4b2))
- Rename the release/packaging pipeline and revert App Support path drift ([#46](https://github.com/Vit129/kouen-terminal/pull/46)) ([`982a05d`](https://github.com/Vit129/kouen-terminal/commit/982a05d2366c56913fb2a43e9f3d859524e6e9dc))
- Rename the tracked Xcode project and entitlements file ([#50](https://github.com/Vit129/kouen-terminal/pull/50)) ([`b3538b3`](https://github.com/Vit129/kouen-terminal/commit/b3538b3c8ea2841a22596c7f0bae9dc0435ccdb4))
- Rename remaining tooling configs missed by every previous pass ([#51](https://github.com/Vit129/kouen-terminal/pull/51)) ([`e550fda`](https://github.com/Vit129/kouen-terminal/commit/e550fda3e0b4aa67ccaa4f98a5bd2e6831efe2b8))

## [3.14.0] - 2026-07-04

### Added
- Open every http/https link in the in-app Browser Pane ([`6513fc2`](https://github.com/Vit129/kouen-terminal/commit/6513fc2f24caf83bd29ee75071adbf9c3744937c))
- Route web links to the in-app browser pane, fix popup crash (release v3.14.0) ([`5b12a5a`](https://github.com/Vit129/kouen-terminal/commit/5b12a5a3a6b11e001a549ab1c9288a8d4042da18))

### Fixed
- Respect sound toggle in foreground and route banner clicks to their pane ([`0460a6c`](https://github.com/Vit129/kouen-terminal/commit/0460a6c54dc2c6c7fef6172650d0549eb90ec212))
- Prevent crash when a browser popup reuses the opener's WKWebViewConfiguration ([`626b9b1`](https://github.com/Vit129/kouen-terminal/commit/626b9b14680dffeb65f232ad57105f0865ba7325))

## [3.13.3] - 2026-07-04

### Added
- Render local .html files in the embedded browser pane on double-click (release v3.13.3) ([`74c7913`](https://github.com/Vit129/kouen-terminal/commit/74c79138e2cd408d5ec11aeb376cf2dc74d85512))

### Fixed
- Auto-tag commit message when Info.plist is staged ([`ca80fb1`](https://github.com/Vit129/kouen-terminal/commit/ca80fb1e25d7e6d3b4ff560f89a44b2007cc9227))

## [3.13.2] - 2026-07-03

### Added
- Wire auto-rebuild hook + gitignore wiki/log bloat ([`6cffd78`](https://github.com/Vit129/kouen-terminal/commit/6cffd781d2afbaafecebb06bb8792686961136cd))

### Fixed
- Notification Step 1, S1 daemon-reuse install, H5 bootout quoting bug ([`003e313`](https://github.com/Vit129/kouen-terminal/commit/003e313249b9beeb709cac2ed1851a6b5dc69d8f))
- Notification Step 1, S1 daemon-reuse install, H5 bootout quoting bug (v3.13.2) ([`9668ed8`](https://github.com/Vit129/kouen-terminal/commit/9668ed8c22514d1c75e69d9e3e2a6ec2c603ea02))

## [3.13.1] - 2026-07-02

### Added
- Support non-interactive option with patch version bump ([`9af3946`](https://github.com/Vit129/kouen-terminal/commit/9af3946500bdc6c58854eb3ca5744123ef70ff9a))

### Documentation
- Drop hardcoded release version from README ([`e2ca7ba`](https://github.com/Vit129/kouen-terminal/commit/e2ca7baec359b89bfeb8ad7c22c656cce99ccc16))

### Fixed
- Preserve selection on reload, fix clicking agent tool-call paths ([`d3f5d40`](https://github.com/Vit129/kouen-terminal/commit/d3f5d40521ad9172e953c67e7023f74b51f4874d))

## [3.13.0] - 2026-07-02

### Added
- Visible divider between panes + 3-way corner drag ([`f80731b`](https://github.com/Vit129/kouen-terminal/commit/f80731b10b9479a93513bbd8bc2b8bd1d6d6a4e3))
- Visible divider between panes + 3-way corner drag ([`64e09f2`](https://github.com/Vit129/kouen-terminal/commit/64e09f2d7619532a3f611ccb74d057965548a6e1))
- SSH socket auto-detect for remote host manager (P23/PBI-SSH-008) ([`9c5d31f`](https://github.com/Vit129/kouen-terminal/commit/9c5d31f973afeb9858a40b900ce5997a039e7ee7))
- Explicit New Agent Task command palette flow (P32 Phase 1) ([`3fa72c7`](https://github.com/Vit129/kouen-terminal/commit/3fa72c7c44bf1072b95653ee4e92f3bfbbb67b51))
- Task metadata + sidebar UI for agent task tabs (P32 Phase 2) ([`4e85c9c`](https://github.com/Vit129/kouen-terminal/commit/4e85c9ce9d9fa5c33a8bdb3aaeeb20001c173d22))
- Wire archiveScript teardown hook + close out P32 (Phase 3+4) ([`79305fc`](https://github.com/Vit129/kouen-terminal/commit/79305fc6e395d61949ff082d0141bf06cee36e57))
- Surface agent notification text in sidebar (P33 Phase 2) ([`73040c6`](https://github.com/Vit129/kouen-terminal/commit/73040c64adbbaef87ff2283a8ff024678907c6ee))
- Color git-change file previews like the diff instead of raw unified text ([`93d6d5c`](https://github.com/Vit129/kouen-terminal/commit/93d6d5c6e3bf4e0be95b77cd69558fb704d42ff4))
- Scope file preview tabs per terminal Tab ([`f48f33c`](https://github.com/Vit129/kouen-terminal/commit/f48f33c5deee28ebd3ab1c853f98fe9519f826c0))
- Expand editor LSP + syntax highlighting to 21 languages ([`59b682d`](https://github.com/Vit129/kouen-terminal/commit/59b682de5fc3d5196f9b348d7e2f489175b59907))
- Capture exact command text on OSC 133 command boundary (P34 F1 slice 1) ([`f904a2e`](https://github.com/Vit129/kouen-terminal/commit/f904a2e99afd4158fe9a18e497c9742ca176e6f0))
- Block copy actions + MCP block access (P34 F2/F3) ([`cee04bf`](https://github.com/Vit129/kouen-terminal/commit/cee04bf783866a6eeb6e5bbdfc18b39bfe3f868c))
- Add setPaneLabel MCP tool for per-pane purpose labels ([`90ee6fc`](https://github.com/Vit129/kouen-terminal/commit/90ee6fc7f30b77bb1298f43d678f7ae1dc885246))
- Let spawnSession/splitPane set a pane label atomically ([`e35d529`](https://github.com/Vit129/kouen-terminal/commit/e35d529eae84f033e49dd967a2d948a25479b33f))
- Link worktree cards to running agents, add diff-vs-main ([`22cb2fb`](https://github.com/Vit129/kouen-terminal/commit/22cb2fb7c7f40725820d264135f2052993c0af95))

### Changed
- Replace ⌘-click block action bar with right-click context menu ([`f0b7492`](https://github.com/Vit129/kouen-terminal/commit/f0b7492c4ebcb736bcb3289ea939eb0d87a95ac7))

### Documentation
- V3.12.0 accuracy pass — remove stale inline AI chat claims, verify MCP/browser round-trip fixed, fix P33 status, add feature-provenance + P34 plan ([`d836bd4`](https://github.com/Vit129/kouen-terminal/commit/d836bd47125aa1e4c285968ea4069dd63865125c))
- Fix CONTEXT.md commit-status note for P34 F2/F3 ([`de45354`](https://github.com/Vit129/kouen-terminal/commit/de4535411957cfc365cba2ca06d3cdb1d14eff6c))
- Log two backlog decisions from P34 follow-up discussion ([`ff2f98c`](https://github.com/Vit129/kouen-terminal/commit/ff2f98cea54e67ff443ca55484588a7682b689af))
- Archive P32 setPaneLabel + P34 right-click backlog items as shipped ([`a1cdd8e`](https://github.com/Vit129/kouen-terminal/commit/a1cdd8e508cd6d49d677e56b26c44fd86ed83af5))
- Archive atomic pane-label-on-create follow-up as shipped ([`a2c17f3`](https://github.com/Vit129/kouen-terminal/commit/a2c17f3f450cc1c04dddc07482857054ec40180f))

### Fixed
- Repair swift test build broken by ACP removal ([`b7f0fbc`](https://github.com/Vit129/kouen-terminal/commit/b7f0fbc466cbd440636413a742f0f8361dbe912d))
- Surface addAgentTask errors via NSAlert instead of silent no-op (P32 Phase 2) ([`ee0a270`](https://github.com/Vit129/kouen-terminal/commit/ee0a2706cf15c0098207df20256f74b114822e7a))
- Pin sidebar width against proportional resize; smaller default + always-open ([`2a7a307`](https://github.com/Vit129/kouen-terminal/commit/2a7a307a07f970b083b300a7c4c5a19f341acda5))
- Unify running/status classification + replace dot with agent icon ([`66b87c2`](https://github.com/Vit129/kouen-terminal/commit/66b87c2f3d3713a3df1ff0c7f3f3263ccb31f652))
- Unify Board status classification/color + fix Board tab layout ([`e18051b`](https://github.com/Vit129/kouen-terminal/commit/e18051bb24824e0c591dc6e07456ed453f4e4814))
- Show PR checks status dot, remove dead PR poller (P33 Phase 1) ([`01609a2`](https://github.com/Vit129/kouen-terminal/commit/01609a2fa765a06295cc5a9316e4cadf13cf5a47))
- NSSplitView first-reveal blank panel + wire diff popover (P33 Phase 3) ([`7571084`](https://github.com/Vit129/kouen-terminal/commit/7571084c62e10064b28f6cc34a64a089351c6294))
- Address 4 findings from Opus code review ([`908a8c7`](https://github.com/Vit129/kouen-terminal/commit/908a8c77d22d47b7f67337b525b08ed824371b43))
- Stop blanket .git/ FSEvent filter from swallowing external commit/push ([`3390db2`](https://github.com/Vit129/kouen-terminal/commit/3390db2896cd64dc4ed4474c1e87c62abb197aef))

## [3.12.0] - 2026-06-30

### Added
- Board + Spaces tabs + openDiffReview MCP tool ([`6bfb154`](https://github.com/Vit129/kouen-terminal/commit/6bfb1547bacc7513f777ef7b732c175813802e91))
- Show Needs Attention text inline in session rows ([`7d8f528`](https://github.com/Vit129/kouen-terminal/commit/7d8f5283ded3d5f17fea82791f039a2adc579310))
- Board toggle, inline agent status, openDiffReview; bump version 3.12.0 ([`c5a6f6d`](https://github.com/Vit129/kouen-terminal/commit/c5a6f6d0a716804e68d9ed4df1e7a3d0930d0a71))

### Changed
- Merge Board into Sessions tab with list/board toggle ([`5fd71e3`](https://github.com/Vit129/kouen-terminal/commit/5fd71e38e219540a1d75f9c85aeb8308c41e1968))
- Inline board status in session rows, drop Spaces tab ([`3448635`](https://github.com/Vit129/kouen-terminal/commit/344863536f2aaf9d202135c04617f640677c3e8c))

### Documentation
- Record CASE-057 — CC 2.1.195 rejects whole settings.json on one invalid value ([`1798ce5`](https://github.com/Vit129/kouen-terminal/commit/1798ce5131f10708acb94e0ecacf7bac9b739e86))
- Record live perf profile — CPU = SwiftUI .repeatForever ViewGraph storm, memory clean ([`1f9870f`](https://github.com/Vit129/kouen-terminal/commit/1f9870f81a6b0c232a907b56cb1333a71f13b72e))
- Mark .repeatForever CPU fix done (aa17c55) in knowledge ([`36910a1`](https://github.com/Vit129/kouen-terminal/commit/36910a1f6c4778222e85c70a3f8c2e650a1653eb))

### Fixed
- Status line hidden on plain mode after SwiftUI settings migration ([`53370b1`](https://github.com/Vit129/kouen-terminal/commit/53370b16d73099eccdd3cb1f8c3a40d2f29fc9e1))
- Contain Metal layer islands so status bar stays on top ([`68a9a3b`](https://github.com/Vit129/kouen-terminal/commit/68a9a3b87ceecf0905f7943e5e57ab34029ac0e4))
- Eliminate CPU spikes from FSEvent storm during agent writes ([`d827f61`](https://github.com/Vit129/kouen-terminal/commit/d827f619394b40aeefe72467e1a905aaef586607))
- Move working/notch pulse off SwiftUI .repeatForever to CALayer (CPU) ([`aa17c55`](https://github.com/Vit129/kouen-terminal/commit/aa17c55e19d769149d0bac4aa3326f9d3524f1eb))
- Add openGitPanel stub to SurfaceRegistry exhaustive switch ([`3e148c8`](https://github.com/Vit129/kouen-terminal/commit/3e148c868f58b306b986731e04420d58659815cc))
- Kill in-flight CADisplayLink before reading frame width ([`6348ea1`](https://github.com/Vit129/kouen-terminal/commit/6348ea13c2eda8390f8a848ca23a76e18f984051))

## [3.11.7] - 2026-06-29

### Changed
- Skip Phase-1 revision pings in all UI snapshot observers ([`6202c72`](https://github.com/Vit129/kouen-terminal/commit/6202c7207eabb1abd7a94013ac37a6fe31d5f611))
- Coalesce burst pings in SessionCoordinator; cap FrecencyDirectoryStore at 500 ([`78f6073`](https://github.com/Vit129/kouen-terminal/commit/78f6073947de6892c02b72d3027230e37c2700f9))

## [3.11.6] - 2026-06-29

### Added
- Inline image paste & drag-drop via Kitty graphics; perf: remove SurfaceShellTracker full-process-table walk ([`fbda8e5`](https://github.com/Vit129/kouen-terminal/commit/fbda8e5b151cc87937e6040696374dd9906c9a34))
- Image paste & drag-drop inserts file path instead of Kitty bytes ([`9dd326c`](https://github.com/Vit129/kouen-terminal/commit/9dd326c0808b6f50466df967459e3fadafe144d7))

### Documentation
- Update README — agent workspace positioning, browser MCP, multi-agent statusline ([`d3ca9d9`](https://github.com/Vit129/kouen-terminal/commit/d3ca9d9c9307b52b684da5f035aeeaa31ad0a283))
- Update README to v3.11.5 + keyboard shortcuts; CHANGELOG otty features ([`d814220`](https://github.com/Vit129/kouen-terminal/commit/d814220ecf31f39b920648da353a75431510b117))
- Remove [Unreleased] section; mark otty-features closed in CHANGELOG ([`00b0864`](https://github.com/Vit129/kouen-terminal/commit/00b0864dcd787fb85eddcc0b9cbde5851d8e3a04))
- Remove otty-features comment from CHANGELOG ([`e3844fd`](https://github.com/Vit129/kouen-terminal/commit/e3844fdf7c2831a3c8f32787eb63e67313ec33e9))
- Record tab-switch black-screen root cause analysis in knowledge base ([`4d4e8d5`](https://github.com/Vit129/kouen-terminal/commit/4d4e8d5774f8b6282033cacf0c953af576896bb3))

### Fixed
- Daemon stop command with built-in 2-second timeout ([`109e06e`](https://github.com/Vit129/kouen-terminal/commit/109e06e8b32ac5765afe7b261dec0d3d91fa2354))
- Black screen on tab switch — wake Metal renderer after isHidden restore ([`aab2599`](https://github.com/Vit129/kouen-terminal/commit/aab2599fdc83dd6254f25b05982c12fb52ab4258))
- Tab-switch black screen — keep hosts in cached container ([`46373d1`](https://github.com/Vit129/kouen-terminal/commit/46373d14812b086976f7252467ce33f37f4689f5))
- Restore Metal rendering after display switch ([`0df4a0e`](https://github.com/Vit129/kouen-terminal/commit/0df4a0ee66a9ebc1a74716583942068e0da77d58))
- Tab-switch black screen — keep hosts in cached container ([`eb9ff64`](https://github.com/Vit129/kouen-terminal/commit/eb9ff6408c474db797c77f618ea684c863748fc9))
- Synchronous repaint on tab-switch fast-path reveal ([`a595724`](https://github.com/Vit129/kouen-terminal/commit/a595724fc8dc265e40b00762937da135c78b1039))
- Evict cached container on force rebuild to prevent black-on-revisit ([`5dbe867`](https://github.com/Vit129/kouen-terminal/commit/5dbe867da023c4ee5b7aa925a7d481c83a4a526c))
- Validate cached hosts before fast-path reveal; plug cache-overwrite leak ([`5aca818`](https://github.com/Vit129/kouen-terminal/commit/5aca818e5dbd87758eff582822c34e7d43553215))
- Performance and black screen when switch tab ([`518d094`](https://github.com/Vit129/kouen-terminal/commit/518d09443accbde7cc372aa4f9a108901b9d6ff9))

## [3.11.4] - 2026-06-28

### Added
- Add Option 3 — Fix version to re-sync all 4 version files ([`a53a29f`](https://github.com/Vit129/kouen-terminal/commit/a53a29fb554f5a800ae9c4f43bbeab92bbf32aa5))
- Add graceful install — preserve session layout across updates ([`04e7fce`](https://github.com/Vit129/kouen-terminal/commit/04e7fce3673103840b9ace99f610206b64615c5a))

### Fixed
- Critical bugs in action buttons and status line visibility ([`b412452`](https://github.com/Vit129/kouen-terminal/commit/b41245234e234c5b8465b247264db29e0528f9b4))
- BlockActionBar buttons unresponsive + skip redundant scroll redraws ([`ab9fa6c`](https://github.com/Vit129/kouen-terminal/commit/ab9fa6c6bb0ccb39c60b8db7fd6b003cb2312906))
- Shell injection in directory picker + floating panel guards ([`bacf239`](https://github.com/Vit129/kouen-terminal/commit/bacf239468e6f8b75500d9faa783607d9eeb7022))
- Remove duplicate shellQuoted extension + Self in stored property initializer ([`fdd28ab`](https://github.com/Vit129/kouen-terminal/commit/fdd28ab989b8a4969a1466d194d948b338f9a25e))
- Store and remove NotificationCenter observers in FloatingPaneController ([`64ad4fc`](https://github.com/Vit129/kouen-terminal/commit/64ad4fc8e450dc2e9a5a35afa39e6e1b231ebf24))
- Vi mode breaks Esc + 3 audit bugs from otty-features wave ([`4928811`](https://github.com/Vit129/kouen-terminal/commit/492881171835a6282a6823b2d44335d91b52d250))
- Group header '...' button silent since June 22 SwiftUI migration ([`75c1cc1`](https://github.com/Vit129/kouen-terminal/commit/75c1cc1684ddfc90ea20c697c0d0442a8698b520))
- ShowStatusLine orphaned gate hides status line permanently ([`b357ee2`](https://github.com/Vit129/kouen-terminal/commit/b357ee2108dd7577e1dbd21582416ee07a49860a))
- 4 bugs from wave-2 SwiftUI migration + Open With + harness view ([`59018ea`](https://github.com/Vit129/kouen-terminal/commit/59018eabb9fd3a1a4869dcc33ff4df340b1711a5))
- CommandPalette cd silently fails for paths with spaces ([`5d96970`](https://github.com/Vit129/kouen-terminal/commit/5d9697087963c390089cfa216241579b188f0d3b))
- 5 SwiftUI migration bugs + perf improvements ([`a4c7493`](https://github.com/Vit129/kouen-terminal/commit/a4c74930ab6d177dcb35c9ef9f64a9041a0ebf2c))
- Add timeout to harness-cli daemon stop to prevent hang ([`bf755ac`](https://github.com/Vit129/kouen-terminal/commit/bf755ac71dcf591fb4172da6594033a62e84b122))

## [3.11.2] - 2026-06-28

### Changed
- Debounce status line refresh + skip redundant NSAttributedString rebuilds ([`85852fd`](https://github.com/Vit129/kouen-terminal/commit/85852fde4ba299e8e67db7ba779a1e569aa63184))
- Hoist process-table build out of per-surface agent scan loop ([`9d21184`](https://github.com/Vit129/kouen-terminal/commit/9d21184d4ec4617f67ea76e87b13af254f82bfc4))

### Fixed
- Remove NotificationCenter observer leaks on window/pane teardown ([`ebddab3`](https://github.com/Vit129/kouen-terminal/commit/ebddab36794d9b8efbc7996c0d9b46546cb94977))
- Browser routing, GUI-disconnect hang, stale runSurface Ctrl-C, per-chunk alloc ([`954135d`](https://github.com/Vit129/kouen-terminal/commit/954135d5018680a6d844f7fea14e63e0303b5349))
- Shell-quote model/effort in spawnCommand + browser routing + invariant tests ([`d2bbd37`](https://github.com/Vit129/kouen-terminal/commit/d2bbd3777d2a11563d4fad49791f19857c3dbe0e))
- 5 Opus round-2 findings — snapshot reconnect, timer leak, progress, network capture, reconnect probe ([`404a314`](https://github.com/Vit129/kouen-terminal/commit/404a314e9970e66e5d317ca6fa5779879e35e2b8))
- PromptQueue surface-key leak + AppIdleThrottle double-install guard ([`d3b1763`](https://github.com/Vit129/kouen-terminal/commit/d3b176315dbfeadde8eee2cfccb8a14f279a103e))
- Status line Settings toggle bound to wrong field for non-full modes ([`996941d`](https://github.com/Vit129/kouen-terminal/commit/996941d9548858edb99972847a1b2e99956511fc))

## [3.11.0] - 2026-06-28

### Added
- Implement Phase 11 - Recipes command picker ([`a33dc49`](https://github.com/Vit129/kouen-terminal/commit/a33dc49e218c55143d6e2cbb60f9b38d63e68c38))
- Phase 10 — Quick Terminal ⌥Space (NSPanel + dedicated workspace) ([`b71ab9e`](https://github.com/Vit129/kouen-terminal/commit/b71ab9eaa35299be31a6d84b06fba66812b33ba5))
- Phase 2 — Vi modal editing (Esc/hjkl/wb/x/i/a/A) with ⌘⌃V toggle ([`0263389`](https://github.com/Vit129/kouen-terminal/commit/0263389494d42d1d0198b2c4bdf18e6a1a86385a))
- Phase 12 — block output: prompt gutter on by default, ⌘-click selects OSC 133 block ([`ff848cd`](https://github.com/Vit129/kouen-terminal/commit/ff848cd4328ba0af019376f1730a8fd3f2dbf677))
- Phase 14 — Floating Terminal ⌘⌥F (NSPanel, persisted frame) + Phase 15 — Tab Overview ⌘⇧\ (thumbnail grid, click to switch) ([`11d30a5`](https://github.com/Vit129/kouen-terminal/commit/11d30a5bc33d35f6207cc6004890b3b3c343ed92))
- ⌘↩ opens new tab in dir picker + zoxide as data source ([`dc95a1d`](https://github.com/Vit129/kouen-terminal/commit/dc95a1d2167cbb07ef293b8e8d091a5e064674d0))
- Block output tint + AI explain action bar (Phase 12b) ([`7bb63c7`](https://github.com/Vit129/kouen-terminal/commit/7bb63c7bbbb2b7059f4b79e7b67d31df733f0bab))
- Block border, collapse/expand, re-run button (Phase 12c) ([`7d66db9`](https://github.com/Vit129/kouen-terminal/commit/7d66db98d7f231fd1599e109bf55bbda0dff6a1e))
- OSC 26 agent protocol + Fork Tab + approval bar ([`b4ca5f5`](https://github.com/Vit129/kouen-terminal/commit/b4ca5f523a3818eeca2e37a54d022f1da2a4ccdf))

### Changed
- Defer tab thumbnail renders + add OSC 26 hook payloads ([`f04a7c9`](https://github.com/Vit129/kouen-terminal/commit/f04a7c994d9860fd01ca784485bb46be0d837b9b))

### Documentation
- Mark medium phases 10, 11, 18, 19 complete in PLAN + CONTEXT ([`173f976`](https://github.com/Vit129/kouen-terminal/commit/173f976b1e57991faf0a504aa8069aff79133148))
- Mark Phase 2 + 12 done in PLAN + CONTEXT ([`38a879b`](https://github.com/Vit129/kouen-terminal/commit/38a879b55223aa4e0d452bc40dcffb36f47caeec))
- Mark Phase 14 + 15 done — otty-features complete ([`b6fcea7`](https://github.com/Vit129/kouen-terminal/commit/b6fcea7d6601aca1971eb4ea3e67e2f059b2df50))
- Add agent-terminal AIDLC planning + update otty-features PLAN ([`85ba62f`](https://github.com/Vit129/kouen-terminal/commit/85ba62f9605e3798f02186c8a84499f885598809))

### Fixed
- Deinit in extension SyntaxTextView — move to class body ([`404cac3`](https://github.com/Vit129/kouen-terminal/commit/404cac33f30c73804e292a8d402217409e7dd828))
- Full-cycle uses make install (prod+install) before tag/release ([`401e368`](https://github.com/Vit129/kouen-terminal/commit/401e368b6becf37ab4cd69c574f134382ff8403d))
- Approval bar freeze + ProMotion render-rate cap ([`92f8802`](https://github.com/Vit129/kouen-terminal/commit/92f8802a63ad0d8579740c433061cf457d4d45f2))

## [3.10.1] - 2026-06-27

### Added
- Full-cycle --no-bump flag + start.mjs asks version bump before full run ([`87cfbc2`](https://github.com/Vit129/kouen-terminal/commit/87cfbc2c039b788df4adb518d4b6ce00eba162e4))
- Send selection to AI chat via right-click context menu ([`f0698e9`](https://github.com/Vit129/kouen-terminal/commit/f0698e9f177cecbd2c403adebda130fedad0d36d))
- Wire ⌘F scrollback search — find bar was implemented but unbound ([`c76df49`](https://github.com/Vit129/kouen-terminal/commit/c76df495caa6e0dffaa90ce7f045c13835a96521))
- Click-to-move shell cursor on single click (Phase 5) ([`bdde688`](https://github.com/Vit129/kouen-terminal/commit/bdde688e3d1b950e0e70acd87c34f26d874cd324))
- Auto secure input on password prompts (Phase 6) ([`eedd9d0`](https://github.com/Vit129/kouen-terminal/commit/eedd9d0a231f1fe2b532b9b4885b974c5637ba6e))
- Ctrl+C copies selection when text is selected (Phase 7) ([`40cca9c`](https://github.com/Vit129/kouen-terminal/commit/40cca9c8bc74d81620181b35af3837cbfad15334))
- Show git branch in tab immediately on cd (Phase 17) ([`49767b5`](https://github.com/Vit129/kouen-terminal/commit/49767b585e9707e3b5c7d17c1fe5ec3f0f713958))
- Composer panel for multi-line PTY commands ⌘⇧E (Phase 8) ([`ada7744`](https://github.com/Vit129/kouen-terminal/commit/ada7744c298b8db36c692b9fe88a5e8afa8c8534))
- Prompt queue — sequential command runner (Phase 9) ([`f0e0e86`](https://github.com/Vit129/kouen-terminal/commit/f0e0e864a3a8a14d0671abc2b8b0bb307de42182))

### Changed
- Prevent redundant UI rebuilds and memory leaks in GitPanelView ([`972fa07`](https://github.com/Vit129/kouen-terminal/commit/972fa0781d6c5182327d84bc404d5231f9ea4b0c))

### Documentation
- Release workflow + version sync rule in CLAUDE.md ([`f30ff27`](https://github.com/Vit129/kouen-terminal/commit/f30ff271a004b2301fbd42c58597ad0fc9a01702))
- Expand otty-features PLAN — 6 new features from CMUX/Zellij/iTerm2 research ([`5ba8e39`](https://github.com/Vit129/kouen-terminal/commit/5ba8e39f629179c87afe0fdf4461280f6d2d3b46))
- Update CHANGELOG, PLAN, CONTEXT for otty-features phases 1/3-9/17/20 ([`ac992a6`](https://github.com/Vit129/kouen-terminal/commit/ac992a6c9dcc6ba7267554f9b4a06ef63ac8e1f8))

### Fixed
- Full-cycle step 4 — build+sign only, no open (was dropping session) ([`ba66a41`](https://github.com/Vit129/kouen-terminal/commit/ba66a41cb3d725f0258a798539486d04538c01b7))
- Trim inactive session scrollback on macOS memory pressure ([`7e236b5`](https://github.com/Vit129/kouen-terminal/commit/7e236b5d530c0da8499a6bee7bb0a483c6947f08))
- AI chat streaming reads no output for batch-write agents (⌘I) ([`91a02ab`](https://github.com/Vit129/kouen-terminal/commit/91a02ab11e694c2b599563392d09b6c8459613f2))
- Remove NSEvent monitors and NotificationCenter observers on deinit ([`8b88808`](https://github.com/Vit129/kouen-terminal/commit/8b888084158ac9db8d04b3b895d0308aaa65a529))

## [3.10.0] - 2026-06-27

### Added
- SwiftUI settings foundation — SettingsModel + Terminal page ([`7427c6c`](https://github.com/Vit129/kouen-terminal/commit/7427c6c6ec8cdcdd2aa2929bb8a7ee3570b69af6))
- SwiftUI Settings — Appearance page (S2) ([`20d9c46`](https://github.com/Vit129/kouen-terminal/commit/20d9c465874573ca5657b605e61c76d9ed28e0dc))
- SwiftUI Settings S3–S5 — Colors, Keys, Agents pages ([`981a5ef`](https://github.com/Vit129/kouen-terminal/commit/981a5efb449a80d7ca1b96ff6c2fb50f97c1ca3d))
- SwiftUI Settings S6–S9 — Advanced, Remote, root wiring, AppKit deleted ([`6f42487`](https://github.com/Vit129/kouen-terminal/commit/6f424876f965c842b0dd8835d0f9451337701e1c))
- Migrate WorkspacePillButton to SwiftUI ([`49005b6`](https://github.com/Vit129/kouen-terminal/commit/49005b6c6a45ffc612cd45383ff63974d985d390))
- Migrate sidebar section label + footer to SwiftUI ([`eec6861`](https://github.com/Vit129/kouen-terminal/commit/eec6861aa669ecd3c797af6491e0362b2a2db31c))
- Migrate sidebar tab bar from NSSegmentedControl to SwiftUI Picker ([`763e5e9`](https://github.com/Vit129/kouen-terminal/commit/763e5e94d91be87c797c401223637791537b9006))
- Open With Harness for source files + file preview routing ([`8d6e4da`](https://github.com/Vit129/kouen-terminal/commit/8d6e4da8d5ab4d77bc922fa41ecd0e23a3882753))
- Open With file → terminal at git root + tree reveals file ([`9234774`](https://github.com/Vit129/kouen-terminal/commit/9234774e60babf18d6ee36067a61f3fcee64408b))
- File tree roots at git root, expands to CWD on cd ([`d424dcd`](https://github.com/Vit129/kouen-terminal/commit/d424dcd0dbe2faa16762b6fd283688d3ab588186))
- AppKit → SwiftUI wave 2 — 4 UI components migrated ([`4bbd469`](https://github.com/Vit129/kouen-terminal/commit/4bbd46910cc73ec7fc7d16bfc478059b575e3a54))

### Changed
- Migrate Toast+About to SwiftUI, delete dead NotificationBellButton + DragReorder stub ([`3d0bd54`](https://github.com/Vit129/kouen-terminal/commit/3d0bd54bf037fabbd7159cbafd9b7aa7edf131f0))

### Documentation
- Update knowledge — CASE-042/043 + cwd-worktree-bleed companion fix + memory decisions ([`9f546bc`](https://github.com/Vit129/kouen-terminal/commit/9f546bc3fe6aab399b5b85342a7209bae28d5387))
- Update CONTEXT — SwiftUI Settings S6–S9 complete ([`bab69a2`](https://github.com/Vit129/kouen-terminal/commit/bab69a2a4059f965f54f22953d9cd762fd78eee8))
- Update CONTEXT, knowledge, plans, graphify after sidebar SwiftUI wave 2 ([`96bed89`](https://github.com/Vit129/kouen-terminal/commit/96bed898f2f7cb01bc68c7b92ffb9022d194fa0c))
- Update CONTEXT — SwiftUI wave 2 complete (4 components, −424 lines) ([`fca6fbf`](https://github.com/Vit129/kouen-terminal/commit/fca6fbf369a332b5192d0f87b6be05fd396b3eb9))

### Fixed
- Flush NSHostingView layout after sidebar animation completes ([`1b158b0`](https://github.com/Vit129/kouen-terminal/commit/1b158b01a057f98d194dc9f362f471d3294de2f5))
- Sidebar animation frames drop on macOS 26 — Task {@MainActor} → assumeIsolated ([`5b61af7`](https://github.com/Vit129/kouen-terminal/commit/5b61af7175357ea9e56ae90446c9b4dfe5ff5870))
- Sync Metal terminal frames with CA during sidebar animation ([`2826876`](https://github.com/Vit129/kouen-terminal/commit/28268767eeeec5df3aaab741a7213bc43f0dbfd7))
- Point Bug 1 robot guard to BrowserIntegrationController where removeValue lives ([`3528463`](https://github.com/Vit129/kouen-terminal/commit/3528463f4780fb8fe402bcaf5cc8548cf23efef5))
- Remove presentsWithTransaction from animated sidebar — was blocking main thread every vsync ([`bc64b4a`](https://github.com/Vit129/kouen-terminal/commit/bc64b4a20e9aa532e249b31e7940e6611ce07e52))
- Panel to response slow and move pane to left/right corner ([`90917a5`](https://github.com/Vit129/kouen-terminal/commit/90917a53e71c73decd3a23909cb2adb3272b5016))

## [3.9.5] - 2026-06-26

### Added
- Vimium-style hint mode (Cmd+Shift+U) for keyboard link opening ([`0495089`](https://github.com/Vit129/kouen-terminal/commit/0495089f996b905940af9f48a605a47048dfc456))
- Harness view opens sidebar file viewer via OSC 7735 ([`bbbadc7`](https://github.com/Vit129/kouen-terminal/commit/bbbadc7eef34897e9cca03637a5dc1b87de46bbc))
- Harness cat shows line numbers that are excluded from copy ([`4e45d98`](https://github.com/Vit129/kouen-terminal/commit/4e45d98003dee43b46257ece68421fd6c59b7fed))
- Add Commit & Push to Sync menu ([`f965b9f`](https://github.com/Vit129/kouen-terminal/commit/f965b9f343c35e7365558a87f8071c516c9bdbbd))

### Documentation
- Update agent-memory with RL-056/057/058 and CASE-039/040/041 ([`eff8fc3`](https://github.com/Vit129/kouen-terminal/commit/eff8fc32ff383ddbf808431e21dab00d92e55322))
- Strip global-duplicate sections from CLAUDE.md ([`c7e6254`](https://github.com/Vit129/kouen-terminal/commit/c7e6254518c639cc74c6426a73c3ee86996018e9))
- Record memory-leak audit findings + onRetire fix pattern ([`d969198`](https://github.com/Vit129/kouen-terminal/commit/d9691988a1386c6a78538a359582c06bc2ccecc9))
- Add memory-leak-audit case study + update graphify for v3.9.4 ([`6306ea2`](https://github.com/Vit129/kouen-terminal/commit/6306ea20e6b6e2cdb3b89dbdb29934a3dc6057cf))
- Bump version to v3.9.4 + note Commit & Push shortcut in README ([`9326095`](https://github.com/Vit129/kouen-terminal/commit/93260951723bdd04e473f2723de7de488102285f))
- Note long-session memory stability in README ([`ff24a14`](https://github.com/Vit129/kouen-terminal/commit/ff24a1426cd7450bd0e3c37955e3da039eb5c151))

### Fixed
- Fix button hit-testing, sidebar toggle, and browser log freeze ([`d95f142`](https://github.com/Vit129/kouen-terminal/commit/d95f142b21506b3e00d1ad73aa11ea0acd09298b))
- Remove adjustSubviews() calls that caused terminal blink regression ([`62e41d7`](https://github.com/Vit129/kouen-terminal/commit/62e41d7fc3b26f073fe16efb1e2c36c3978627f1))
- Browser cannot show in cmd+b and browser button ([`9c0809c`](https://github.com/Vit129/kouen-terminal/commit/9c0809c97e9bf37673657d52c3f88b7646f8f7a3))
- Browser pane reuse guidance and skill routing paths ([`a928e89`](https://github.com/Vit129/kouen-terminal/commit/a928e894d459e8ac64176c186e0b2f87d640a2f9))
- Replace graphify CLI trigger with graph-report skill ([`9d26a3d`](https://github.com/Vit129/kouen-terminal/commit/9d26a3db0391beb9545ac3a71bc08171b20b322a))
- Cmd+W closes browser pane (intercept before WKWebView consumes it) ([`2d469a4`](https://github.com/Vit129/kouen-terminal/commit/2d469a40cfaddf61602aa84439831528fac9bd4d))
- Disarm prefix key on mouse click to prevent swallowing Cmd+\ ([`e487ce3`](https://github.com/Vit129/kouen-terminal/commit/e487ce3749d094a100980d2088bfdb7f236af643))
- Prevent git panel double-refresh blink after commit/push ([`a40f05f`](https://github.com/Vit129/kouen-terminal/commit/a40f05f3a426480ad01b63d695a2aabcafb4d647))
- Prevent git push from hanging in daemon ([`d1150bd`](https://github.com/Vit129/kouen-terminal/commit/d1150bd2de47f175d7e94b3d6a761df78d839e9f))
- Release unclaimed TerminalHostViews after PaneContainerView build ([`03b9da1`](https://github.com/Vit129/kouen-terminal/commit/03b9da15ec5a4489400a67938687801db7c9f7d0))
- Stop per-pane AI controllers and browser network log from leaking ([`89f653e`](https://github.com/Vit129/kouen-terminal/commit/89f653e37969120c7e100e0808ff0f14a7ee0864))
- Memory leak audit — pane lifecycle + AI controller cleanup ([`4ce9532`](https://github.com/Vit129/kouen-terminal/commit/4ce953287edc2acd0f23d57562a047079ef34260))
- Don't fail make install when open has no window server ([`36c78c8`](https://github.com/Vit129/kouen-terminal/commit/36c78c8b29cfe54236029c8272cb357e2c15c173))
- Pin session worktree to shell cwd, not deepest foreground descendant ([`84d83a7`](https://github.com/Vit129/kouen-terminal/commit/84d83a79ef7840722844549f920d25515382b693))

## [3.9.2] - 2026-06-22

### Documentation
- CHANGELOG for v3.10.0 — terminal flash fix ([`4e00523`](https://github.com/Vit129/kouen-terminal/commit/4e005236100dc60af92cb95cadd9357e16a593c1))

### Fixed
- Prevent hover flickering between shortcut and close button ([`45df90e`](https://github.com/Vit129/kouen-terminal/commit/45df90e7766ce9c8e42e7d94e9e69dc560079fb1))
- Terminal flicker on ⌘\ — remove layoutSubtreeIfNeeded, use split.layout() ([`7473da5`](https://github.com/Vit129/kouen-terminal/commit/7473da58c76bba102ce70f10fbd9c6fb7ed48de8))
- File preview open/close flicker — replace layoutSubtreeIfNeeded with layout() ([`385a2e9`](https://github.com/Vit129/kouen-terminal/commit/385a2e96fab395e7cb5bd3d8720c88a169816d99))
- Eliminate tab switch flash — cache PaneContainerView per tab, hide/show instead of rebuild ([`ec3a862`](https://github.com/Vit129/kouen-terminal/commit/ec3a862a6f56d5007dbba3e9925f78036bd713b7))
- Eliminate terminal flash on sidebar, tab switch, split, and file preview ([`5b4785a`](https://github.com/Vit129/kouen-terminal/commit/5b4785ae8675a8b8585509165d9fac2e96ea384c))

## [3.9.1] - 2026-06-22

### Added
- Sessions tab shows only idle worktrees (active ones already have sessions) ([`d5a992f`](https://github.com/Vit129/kouen-terminal/commit/d5a992f2fd046207733a991b1fe00cd5fc0c18b1))
- Worktrees collapsed by default in Sessions sidebar ([`9ac7e2d`](https://github.com/Vit129/kouen-terminal/commit/9ac7e2dabd21683ef4db9c03911cc65a6674a07b))
- Enable Worktrees tab in Git panel (was hidden, code already existed) ([`2d7b0a5`](https://github.com/Vit129/kouen-terminal/commit/2d7b0a580257778325e1c51469459c4d71fa52de))
- Git worktree panel — fix click conflict, add merged status indicator ([`9e64f98`](https://github.com/Vit129/kouen-terminal/commit/9e64f9833ec6dcd207ab8abde951a8e999c3cbbb))

### Changed
- Remove worktrees from Sessions sidebar — now lives in Git tab only ([`ed6e73f`](https://github.com/Vit129/kouen-terminal/commit/ed6e73f7c512cbd50d2c39b18ab7564ed4a97258))

### Documentation
- Archive completed plans (P28, sidebar SwiftUI, core split) ([`ccf4224`](https://github.com/Vit129/kouen-terminal/commit/ccf4224b160f9462b20651a5d4dd32af83c1836f))
- Update plans INDEX — archive P26/P27, add SwiftUI migration as active ([`9a13993`](https://github.com/Vit129/kouen-terminal/commit/9a13993bb1c2320dca570df46ccddca2b64c9398))
- Add RL-052/053 lessons + sidebar SwiftUI knowledge (MainActor freeze, @Observable loop) ([`454d538`](https://github.com/Vit129/kouen-terminal/commit/454d53854c7f5e2fad422d79d8c04991087df04c))

### Fixed
- Sidebar hang on z/cd — add re-entrancy guard to rebuildRows ([`7fb5dec`](https://github.com/Vit129/kouen-terminal/commit/7fb5dec3f78f24212e7c9748048ccd0f61d0eec3))
- Sidebar freeze on z/cd — move Process.waitUntilExit off main thread ([`ba61619`](https://github.com/Vit129/kouen-terminal/commit/ba61619fb0bcc3e6cac9430c646f5f557022628d))
- Sidebar infinite re-render loop — @ObservationIgnored on gitMetadataCache ([`5f4db25`](https://github.com/Vit129/kouen-terminal/commit/5f4db254e49baa9a8bd0211becb3d202344aed70))
- Worktree remove button — double-click for cd, single-click for ✕ button ([`004e503`](https://github.com/Vit129/kouen-terminal/commit/004e5036dc18be5f7398d654c25fdddb1d7ebc72))
- Worktree remove — confirmation alert, --force flag, proper error capture ([`32b4ad2`](https://github.com/Vit129/kouen-terminal/commit/32b4ad201aabca4deaf5040373b5337e1955c1d4))
- Worktree single-click cd + skip click on ✕ button area ([`c12c8d7`](https://github.com/Vit129/kouen-terminal/commit/c12c8d75f84b270f70ce154ea6d013464b0fd359))
- Worktree remove button — use SoftIconButton (same pattern as working browser tab close) ([`1cecc2e`](https://github.com/Vit129/kouen-terminal/commit/1cecc2e21d732f0c3d55fd26113766fbcb23dbfc))
- Worktree card — use mouseUp pattern (same as BrowserTabButton) for reliable click handling ([`950b7a1`](https://github.com/Vit129/kouen-terminal/commit/950b7a19cffbad2cd61e70acec183a464bd6f00d))
- Worktree panel flicker — cache output, skip rebuild if unchanged ([`7524147`](https://github.com/Vit129/kouen-terminal/commit/752414707229d290fddf018181e6596b9342c14c))
- V3.9.1 — sidebar freeze fix, git worktree panel, click handling ([`e741852`](https://github.com/Vit129/kouen-terminal/commit/e7418525d27214eac52ffedb5d90e28368bab528))

## [3.9.0] - 2026-06-22

### Added
- Wire git-cliff into full-cycle.sh for auto CHANGELOG + release notes ([`02403c7`](https://github.com/Vit129/kouen-terminal/commit/02403c718af9bc8fb1ee214187a87bea5675e028))
- Replace NSTableView with SwiftUI List (Option B) ([`d79cff3`](https://github.com/Vit129/kouen-terminal/commit/d79cff387c6fae7323b172646c56a5674891a66a))

### Changed
- Extract HarnessCommands + HarnessSettings from HarnessCore ([`113f91e`](https://github.com/Vit129/kouen-terminal/commit/113f91e9e328d4ad0573923573e9adaa0b36c96a))

### Documentation
- Update agent-memory with RL-051 (table row crash) + harness-mcp completion ([`03eb3cd`](https://github.com/Vit129/kouen-terminal/commit/03eb3cd387f8456c246a5280c415c8def9113384))
- Add sidebar race fix plan + update CONTEXT.md ([`1786603`](https://github.com/Vit129/kouen-terminal/commit/1786603a549d7d49e848e992eb1b0f32cbcb9ad7))
- Add sidebar SwiftUI List migration plan (Option B) ([`78ca923`](https://github.com/Vit129/kouen-terminal/commit/78ca9232b956fbc6d78c9c7cfb1cb8a3f675ca25))
- Update agent-memory indexes, regenerate graphify summary (post-migration) ([`fbd324c`](https://github.com/Vit129/kouen-terminal/commit/fbd324c1c0cf1327a6b6cd3e1fb18c92a5ef0661))
- Add SwiftUI migration plan (Phase 1/2/3 component map) ([`9cfc9bc`](https://github.com/Vit129/kouen-terminal/commit/9cfc9bc75609cfeed11c3a80f9d55022dc626984))

### Fixed
- Sidebar crash on z/cd/⌘\ — reloadData before accessing table rows ([`d9b583d`](https://github.com/Vit129/kouen-terminal/commit/d9b583deac514433f414e2080ae61787bc26a870))

## [3.8.0] - 2026-06-22

### Added
- CLI infrastructure — permissions, skill-trigger hook, graphify hint ([`a37ec9a`](https://github.com/Vit129/kouen-terminal/commit/a37ec9ae5834bb7a432c61c321067e4d4493f0e7))
- CLI infrastructure ([`2dc01fd`](https://github.com/Vit129/kouen-terminal/commit/2dc01fd03e2bdc96bbbeb3573bdce15a24d81d02))
- Finalize Git tab with auto-staging by default ([`06d7c15`](https://github.com/Vit129/kouen-terminal/commit/06d7c15e5f805fda4b61a5dc163aca2620c86202))
- Route Git commands via IPC to HarnessDaemon ([`36c1227`](https://github.com/Vit129/kouen-terminal/commit/36c1227d400d2b304c0c9ff1f97243ff4d4b8b5a))
- Fix crashes + worktree isolation + harness-mcp browser tools complete ([`5180dc2`](https://github.com/Vit129/kouen-terminal/commit/5180dc2aba9fb6aaf09eca85c672c0ae80bb5589))
- Add IPC protocol versioning to identifyClient handshake ([`6169aa7`](https://github.com/Vit129/kouen-terminal/commit/6169aa795455eb5666d5f0800556b45f2f6f2b3c))

### Changed
- Decompose ContentAreaViewController into three focused coordinators ([`d76f740`](https://github.com/Vit129/kouen-terminal/commit/d76f74012c08984daaa10ae68e40a6fe981acf50))
- Centralize zombie-hold pattern into ZombieHoldRegistry ([`d7d0097`](https://github.com/Vit129/kouen-terminal/commit/d7d0097e7c935dcfaee0d1190dd5689434edfaa8))
- Replace stringly-typed snapshotChanged userInfo with SnapshotChangedPayload ([`b443a8a`](https://github.com/Vit129/kouen-terminal/commit/b443a8a1c08a62769ab8bc3b87b21acfb1c1f93c))
- Harness-terminal ([`ddad262`](https://github.com/Vit129/kouen-terminal/commit/ddad26294fddb1b8bd932f1e5bb3e6e25ab03ef1))

### Documentation
- CONTEXT.md — P28 complete (all 3 phases + RL-048) + CLI infrastructure ([`bdc177b`](https://github.com/Vit129/kouen-terminal/commit/bdc177b1f0fbfd7a64c1acc5d747ca3e89dfbe1a))
- CONTEXT.md P28 completion ([`a3dd120`](https://github.com/Vit129/kouen-terminal/commit/a3dd1201ffdcd8a39b5060b93779ba453f9ea70b))

### Fixed
- Full-cycle push only new tag, not all tags — prevents rejection of existing tags ([`c9737f4`](https://github.com/Vit129/kouen-terminal/commit/c9737f4a62373922e8c9a8d43f65268fdf2222ef))
- Full-cycle tag push fix ([`62da73b`](https://github.com/Vit129/kouen-terminal/commit/62da73b0596735b821c5498864ce2cfab6abef5f))
- Warn + prompt when CHANGELOG entry missing before gh release ([`eca71cf`](https://github.com/Vit129/kouen-terminal/commit/eca71cfd1d687a99fca1a728514870c951a24e64))
- Full-cycle CHANGELOG guard ([`0876d01`](https://github.com/Vit129/kouen-terminal/commit/0876d019ce777e88b81a13393c4bb3126385a663))
- Replace bash-only ${confirm,,} with tr for zsh compatibility ([`9b25583`](https://github.com/Vit129/kouen-terminal/commit/9b2558304df255a4dcde49362e273a5960f9a09f))

## [3.7.0] - 2026-06-21

### Added
- P28 AI browser control — snapshot/network/storage + round-trip fix ([`eae5957`](https://github.com/Vit129/kouen-terminal/commit/eae5957caa232ab4d6b8a8dbb846627f41adbf70))

## [3.6.2] - 2026-06-21

### Added
- Pane drag-and-drop — model, IPC, coordinator, UI ([`b0f542b`](https://github.com/Vit129/kouen-terminal/commit/b0f542bcdd50bea2ebe38909cc6946646784fda5))
- Add MCP status and Add/Remove MCP button to agent list ([`a13eeef`](https://github.com/Vit129/kouen-terminal/commit/a13eeef3aa17c068b4313be87299c26511d27e7c))
- Bundle harness-mcp in Harness.app and add harness-cli mcp command ([`50969b6`](https://github.com/Vit129/kouen-terminal/commit/50969b6b7b17e0bc95e215ab683240fb94bccf83))
- Add ⌘I inline terminal AI chat (P26 Path B) ([`ece7cc8`](https://github.com/Vit129/kouen-terminal/commit/ece7cc8158989676bbb28b103c9aa7ba412ede52))
- AI chat agent selector (⌘I pill click) + bump 3.6.1 build 162 ([`71ec856`](https://github.com/Vit129/kouen-terminal/commit/71ec856232c6c827bea55449762ca91685cb8c2c))

### Documentation
- Update split shortcuts to ⌘D/⌘⇧D across all references ([`a427a02`](https://github.com/Vit129/kouen-terminal/commit/a427a029a6c6dd5181c833c614508582b8a43511))
- P27 plan — pane drag-and-drop reorder ([`d7245f5`](https://github.com/Vit129/kouen-terminal/commit/d7245f5ddae4e92f6caec6d5a1a0c9e52e17a523))
- Correct P8 nonisolated rule, update MCP tool count, add P26 terminal chat design ([`e665ddf`](https://github.com/Vit129/kouen-terminal/commit/e665ddfa572d5a133a9554a2ba904d0f28cdbd8e))
- Simplify terminal chat to use CLI print mode directly ([`175b3b8`](https://github.com/Vit129/kouen-terminal/commit/175b3b8d1e80e696282ee99dfd0a6ad6d1e81216))
- Add MCP setup guide to AGENT-HANDBOOK + update P26 plan ([`499c96c`](https://github.com/Vit129/kouen-terminal/commit/499c96c23fb77249a71306fb15376c17c847370f))
- Update mcp-server.md — 27 tools, 6 categories, agent config wiring ([`3275de7`](https://github.com/Vit129/kouen-terminal/commit/3275de7e1472c9cc791f02eabd3ed46396dcf763))
- Fix last lowercase agent-memory ref in AGENTS.md ([`4990fcc`](https://github.com/Vit129/kouen-terminal/commit/4990fcc0dc4001b8b132673b428c04f369ea9b30))
- Update knowledge, CONTEXT, MEMORY, graphify for browser redesign session ([`9a1dc99`](https://github.com/Vit129/kouen-terminal/commit/9a1dc9978e6e27535faba0f699b95a9fe3490ea2))
- Update competitive position to v3.6.1 — gaps closed, new USPs ([`bb80aaf`](https://github.com/Vit129/kouen-terminal/commit/bb80aaf60963d367c076be01d4cd0b5850d27270))
- Honest assessment — MCP and AI chat are partial, not fully functional yet ([`2e780f2`](https://github.com/Vit129/kouen-terminal/commit/2e780f276c2a8e8c600d15b58cfaaffb108f30c0))

### Fixed
- Terminal blinks on ⌘D split / ⌘W close / tab switch (CASE-025)\n\nThe pane rebuild path (reloadIfNeeded) didn't wrap the structural\nchange with presentsWithTransaction like the file editor split does.\nMetal presents an empty frame between remove-old-container and\nnew-container-first-layout. Fix: set presentsWithTransaction=true\nbefore rebuild, release in CATransaction completion block after\nthe first layout pass. ([`ee51260`](https://github.com/Vit129/kouen-terminal/commit/ee5126077cb98c1522917b868667eeaf4bddce4c))
- Browser tab close button unclickable (CASE-038)\n\nNSClickGestureRecognizer on BrowserTabButton intercepts the close\nNSButton's mouse events even with delaysPrimaryMouseButtonEvents=false.\nFix: override hitTest to return closeBtn directly when the click is\nwithin its frame, bypassing the gesture recognizer entirely. ([`846ce7d`](https://github.com/Vit129/kouen-terminal/commit/846ce7dd8a31f3acd8e8da74df5325da55288aa2))
- Window not showing on launch + remove built-in AI chat/search panels ([`f3e45c7`](https://github.com/Vit129/kouen-terminal/commit/f3e45c72aa0c1a89b0de33b570be21a363fce745))
- Extend zombie-hold durations and plug event monitor leak ([`d135321`](https://github.com/Vit129/kouen-terminal/commit/d1353212cbb3b8ea0fbd6decebaf13e4bdbf358f))
- Crash on ⌘⇧Arrow split + hang on fetchRepoName ([`dac90a7`](https://github.com/Vit129/kouen-terminal/commit/dac90a703bec1cd09a71f94bcc8c58edc74658c2))
- Wire notch notifications and split placement ([`cbb296a`](https://github.com/Vit129/kouen-terminal/commit/cbb296aa11583dd9808091ab13fecc959d82bfaf))
- Wire missing command prompt verbs (z, view, edit, agent, shell tools) ([`d713a5e`](https://github.com/Vit129/kouen-terminal/commit/d713a5eb099310ff9906a9009b0d4419b87e0302))
- Replace button with mouseDown drag grip for pane reorder ([`515a21b`](https://github.com/Vit129/kouen-terminal/commit/515a21bebf1f26e0ea31f5555fcc151cb90d3d84))
- Smoother drop zone + disable center swap for 2-pane layout ([`16a0d6c`](https://github.com/Vit129/kouen-terminal/commit/16a0d6ccba36e995e6b5b7bf6db51b0f73877ea3))
- Tab bar shows wrong branch when agent uses worktree ([`6883e8a`](https://github.com/Vit129/kouen-terminal/commit/6883e8a657bd6646f13d68ed8399264627ab04df))
- Split pane inherits worktree path instead of repo root ([`94a231f`](https://github.com/Vit129/kouen-terminal/commit/94a231f8392b5668561fb106ded6b1cf087b2ff1))
- Browser pane opens at root level (right of all terminals) ([`afe5c81`](https://github.com/Vit129/kouen-terminal/commit/afe5c817459b307997c21e4bacf6d972c3b5ba88))
- Widen pane/sidebar dividers from 1px to 2px (centralized) ([`410fe01`](https://github.com/Vit129/kouen-terminal/commit/410fe01c8b7285f74f85d541f3fe9e8d270b864f))
- Browser pane auto-retries when localhost server disconnects ([`bc6e7c7`](https://github.com/Vit129/kouen-terminal/commit/bc6e7c7cbf1765edf65a81082d6cd95e5299e946))
- Browser auto-close after 30s unreachable (10 retries × 3s) ([`15694e0`](https://github.com/Vit129/kouen-terminal/commit/15694e0d7dde90be16271e33978c6dafbf471641))
- Update release notes to 3.6.1 ([`618affd`](https://github.com/Vit129/kouen-terminal/commit/618affd9eea857061f1a6c70140687c1476b9053))
- Install missing NSEvent monitor + retire-hold in detachHosts ([`95b9dd6`](https://github.com/Vit129/kouen-terminal/commit/95b9dd681fe588afbbc71fff902785f486c577fd))
- Universal retire-hold via removeFromSuperview override — covers all free paths ([`4223f2d`](https://github.com/Vit129/kouen-terminal/commit/4223f2d9ffd4fb9573b47cb242bd8a36a36c4cdc))
- Remove workaround section from kiro plan ([`2b79d0f`](https://github.com/Vit129/kouen-terminal/commit/2b79d0f6aca4ebbe7b43f584ba3e046b71afe77d))
- Browser toolbar URL field not expanding + translucent blur (CMUX-style) ([`ecc64cb`](https://github.com/Vit129/kouen-terminal/commit/ecc64cb061fa4e8d934514a69251688bb60396ab))
- Browser tab bar translucent blur + always visible + close last tab closes pane ([`16f26a9`](https://github.com/Vit129/kouen-terminal/commit/16f26a9de59a94658cfc0180346da04373d50c40))
- Browser tab close button hit target 14px→20px ([`57ca130`](https://github.com/Vit129/kouen-terminal/commit/57ca130d726ce002e158fbc5c8bd1f1bfd5f5f0c))
- Close last browser tab calls closeBrowserPane directly + debug logs ([`6f05a1d`](https://github.com/Vit129/kouen-terminal/commit/6f05a1d21f931f22a2ff2004ceae4ad335eca83a))
- Browser tab close — add mouseUp override, keep gesture as backup ([`2a6c7f5`](https://github.com/Vit129/kouen-terminal/commit/2a6c7f524585e2836eb5b75d15ae59506b4db517))
- Browser tab close — replace NSScrollView with plain NSView (scroll view eats mouse events) ([`6f0a731`](https://github.com/Vit129/kouen-terminal/commit/6f0a731f4288743990592cff792fbf4c6d607005))
- Browser tab close button — use SoftIconButton (same as working close pane button) ([`ea77ece`](https://github.com/Vit129/kouen-terminal/commit/ea77ecef2a2a879a97da0b08768f474c868172ad))
- Tab close — handle in mouseUp directly (button action never fires with isTransparent) ([`4311fd8`](https://github.com/Vit129/kouen-terminal/commit/4311fd88f7d629d0225bf43a303add8109f61549))
- REMOVE gesture recognizer from BrowserTabButton — it consumed all clicks before mouseUp ([`12b077d`](https://github.com/Vit129/kouen-terminal/commit/12b077d364b34cc343dcc6fafe276fd538118fc0))
- Nonisolated on keyDown/keyUp/displayTick, retire-hold on TabBar+FlippedView ([`850675a`](https://github.com/Vit129/kouen-terminal/commit/850675a6558e0535be225c6af64d24e0d4984b62))

## [3.5.1] - 2026-06-20

### Added
- Implement 6 competitive-gap features vs Warp/iTerm2 ([`3396ea8`](https://github.com/Vit129/kouen-terminal/commit/3396ea8e21460de68110d8df13868dc4edf688b1))
- Modernize browser pane + add harnessSpawnAgent MCP tool ([`3e4467a`](https://github.com/Vit129/kouen-terminal/commit/3e4467ad8ad130531219b31e553a3e46ece8fc4b))
- Metal shader overlay effects (scanlines, grain, vignette, crt) ([`6469cd4`](https://github.com/Vit129/kouen-terminal/commit/6469cd42054ad1f19ed4f2fe018200204e35f0e7))
- Wire shaderEffect from HarnessSettings and add inline AI completion (⌥Space) ([`b46fa04`](https://github.com/Vit129/kouen-terminal/commit/b46fa04af4f20189fb5a909104231271307302fc))
- AI chat, block terminal, plugins, settings export, browser modernization, MCP agent spawn, Metal shaders, inline AI completion ([`4a61bec`](https://github.com/Vit129/kouen-terminal/commit/4a61beceea78e5f80c2c1448b0beb4016a511a84))
- P23 SSH remote host manager UI — Settings Remote page + window title strip ([`11ce93d`](https://github.com/Vit129/kouen-terminal/commit/11ce93d2d2f3b148556354ddf9fedc8e397e9c4a))

### Documentation
- Update P4/ACP/MCP index, archive, and competitive position ([`9a38819`](https://github.com/Vit129/kouen-terminal/commit/9a3881945676d63a881da407787e27d9af9cc0d0))

### Fixed
- RL-040 zombie crashes + tab branch probe + sidebar height + notification icon ([`1116700`](https://github.com/Vit129/kouen-terminal/commit/11167001f13ce0fc4e77a2618e2166c34b7778f5))
- CWD tracking — skip shell-only poll when subprocess holds foreground ([`4ee334b`](https://github.com/Vit129/kouen-terminal/commit/4ee334b8fc326d59e2e78faf59af64b754a2b731))
- Resolve 6 RL-040 zombie crashes on macOS 26 / Swift 6.3.2\n\nAll crashes share the same root cause: @objc thunk executor check\n(swift_task_isCurrentExecutorWithFlagsImpl) dereferences freed self.\n`nonisolated` does NOT suppress this on Swift 6.3.2.\n\nFixes:\n- HarnessTerminalSurfaceView: stopDisplayLink() in viewWillMove(toWindow:nil)\n- TerminalTabBarView: static retiredBars[] retire-hold (500ms)\n- HarnessWindow: static retiredWindows[] on close() + early contentView guard\n- PrefixKeymap: nonisolated(unsafe) capture bypasses executor check\n\nAlso fixes pre-existing Sendable compile errors in ClaudeDirectClient,\nInlineAICompletionController, and HarnessAIChatView. ([`afe64c4`](https://github.com/Vit129/kouen-terminal/commit/afe64c4048b381ee077c5468bf2e30e4bfb4d985))
- Resolve 14 bugs in Remote settings, WindowTitleStripView, RemoteHostsService\n\n- hitTest() now passes through to child NSButtons (remoteBadge clickable)\n- saveRemoteHostClicked: duplicate-name guard + reconnect on rename of active host\n- connectRemoteHostClicked: no longer overwrites saved config for existing hosts\n- sshArgValue(after:) supports glued arg form (-p2222)\n- Connect button enabled for new unsaved hosts when form is filled\n- Settings VC observes activeHostDidChange (replaces stale 0.5s timer)\n- Remove ambiguous 'identity' keyword from Advanced page search\n- Guard constraint activation in buildRemotePage (no accumulation)\n- disconnect() only posts notification when state actually changed\n- Replace magic index 6 with SettingsWindowController.pageRemote constant\n- uniqueRemoteName() reads live store instead of stale in-memory list\n- Remove redundant refreshRemoteBadge() from applyChrome()\n- Remove dead initial build of pages 5/6 in layoutShell() ([`2f41921`](https://github.com/Vit129/kouen-terminal/commit/2f4192168f6d4bd8b780e8be40a2dadf4e2b823e))
- RL-040 crash in ContentAreaViewController.installCopySelectionToast()\n\nSame pattern: @Sendable closure's _checkExpectedExecutor crashes on\nzombie event chain. Use nonisolated(unsafe) capture to bypass the\nexecutor check (safe: NSEvent monitors always fire on main thread). ([`477831e`](https://github.com/Vit129/kouen-terminal/commit/477831eb2f80a949def04f7d10ac57453c9c7e42))
- Notification attributed to Script Editor instead of Harness\n\nOn macOS 26 where UNUserNotificationCenter is disabled (crash),\n`tell application id \"com.robert.harness\"` via osascript doesn't\nattribute the notification to our app (shows under Script Editor\nin System Settings). Switch to `tell application \"Harness\"` (by\nname) which macOS resolves correctly. ([`899dbd8`](https://github.com/Vit129/kouen-terminal/commit/899dbd8bbba87cff78c978a236be4a0654f337d7))

## [3.5.0] - 2026-06-20

### Added
- Sidebar 2-line layout (branch + cwd) + top bar always shows branch ([`860458e`](https://github.com/Vit129/kouen-terminal/commit/860458e653021241f81d29b19762c173f47567a6))
- ⌘I opens Agent Notch panel — select notifying agent directly ([`a827c25`](https://github.com/Vit129/kouen-terminal/commit/a827c2593b9a43c2d93dc6728260dabdb6711006))
- Persistent notch peek — stays until user clicks, no auto-dismiss ([`66f6646`](https://github.com/Vit129/kouen-terminal/commit/66f66467c6eaae3a30ea452de80d81566cdf99e3))
- Harness-cli install-tools — one command to install all shell tools ([`1036df8`](https://github.com/Vit129/kouen-terminal/commit/1036df8e9eded025bfdb7b0f074e340555414da1))
- File click action setting + tab pill branch-first + worktree grouping fix ([`fcf9c3e`](https://github.com/Vit129/kouen-terminal/commit/fcf9c3e699816dcc91bfec5a97c40682ef4cb18b))

### Documentation
- Add sidebar 2-line + top bar branch to knowledge/ui/tab-bar.md ([`0b071c6`](https://github.com/Vit129/kouen-terminal/commit/0b071c684287b854f19d86fd6ebcb5897a1d125d))
- Add P25 iOS/iPadOS support plan ([`33c98e9`](https://github.com/Vit129/kouen-terminal/commit/33c98e964abd1f4cab2c37aa9ef486eae9ca71ea))
- Add competitive position, git branch isolation to knowledge ([`1a7d335`](https://github.com/Vit129/kouen-terminal/commit/1a7d335e4c76bc79b1c6c3a72803844d83c62ad2))

### Fixed
- Enable macOS toast notifications via osascript fallback ([`8470736`](https://github.com/Vit129/kouen-terminal/commit/8470736e26ac09c289fddc8d74fadc40ea441330))
- Always auto-isolate into worktree on branch switch ([`d2c5c23`](https://github.com/Vit129/kouen-terminal/commit/d2c5c23e10e96aaff9d1ddeff59ef306a076cf90))

## [3.4.0] - 2026-06-19

### Added
- F4 git worktree sidebar + F6 session row density ([`c55e92c`](https://github.com/Vit129/kouen-terminal/commit/c55e92c007cec04faabea767b13691b87cb004b2))
- Harness.json + agent auto-start + ⌘R/⌘. run scripts ([`6a71479`](https://github.com/Vit129/kouen-terminal/commit/6a714799f62bcbfbb8bad2b30f698ea22606128a))
- Worktree-per-session model — group by repo, CLI --worktree ([`adcdb20`](https://github.com/Vit129/kouen-terminal/commit/adcdb202c3497451b5e2f22a47b6f464c4249657))
- Worktree-per-session isolation model ([`cd2b5e8`](https://github.com/Vit129/kouen-terminal/commit/cd2b5e83cdf83aac57b18655239da75352c318a9))
- P24 Phase 3 — GitHub PR/CI integration + browser multi-tab ([`09dd0bf`](https://github.com/Vit129/kouen-terminal/commit/09dd0bf50701993a2324bcfc992111c6e77aefb5))
- Enable LSP integration in FileViewerViewController preview ([`7930a78`](https://github.com/Vit129/kouen-terminal/commit/7930a78285524d5c6b68347d638e31e8a4012017))
- P24 Phase 2+4 complete — worktree auto-isolate/archive + polish ([`38d123a`](https://github.com/Vit129/kouen-terminal/commit/38d123aca96f6127728deb0bedc881c3801f0ff7))

### Documentation
- Update agent-memory, knowledge index, graphify for P24 completion ([`062472b`](https://github.com/Vit129/kouen-terminal/commit/062472bb77e42b84eb0e84d9891849e6a238925f))

### Fixed
- Prevent self-kill in make start + remove close confirmations ([`2f09750`](https://github.com/Vit129/kouen-terminal/commit/2f0975058565d9f1dc91f993f182959afd73d91f))
- Improve text contrast visibility with transparent windows ([`3ec0705`](https://github.com/Vit129/kouen-terminal/commit/3ec07051399a110e7094da3eb587ee4af7688e88))
- RL-040 zombie surface view use-after-free on macOS 26.5\n\n- Add `guard window != nil` to mouseMoved (matches keyDown/keyUp)\n- Hold detached hosts 500ms during pane tree rebuild so in-flight\n  AppKit events (tracking area mouseMoved, queued keyDown) drain\n  before ARC frees unreused hosts\n\nAddresses EXC_BAD_ACCESS in swift_task_isCurrentExecutorWithFlagsImpl\nat @objc thunk boundary when AppKit dispatches events to freed\nHarnessTerminalSurfaceView instances. ([`8ecac6b`](https://github.com/Vit129/kouen-terminal/commit/8ecac6bd660eb45004597dad0641d469cb4ff026))
- Restore active pane focus on tab switch back ([`09bf4f3`](https://github.com/Vit129/kouen-terminal/commit/09bf4f3fb3c8569e0de87bb889325f7da0634cb9))
- Sidebar agent icon uses branding color instead of status color ([`1dc0bb1`](https://github.com/Vit129/kouen-terminal/commit/1dc0bb15e33053318f130e215640d59af3e9c4e5))
- Sidebar agent icon uses centralized settings color (same as tab pill) ([`5476f83`](https://github.com/Vit129/kouen-terminal/commit/5476f83a8c6f4d9305fd8cb88e108500d7e7ecb0))
- Git branch probe now updates all tabs sharing same cwd ([`ea804a9`](https://github.com/Vit129/kouen-terminal/commit/ea804a9aa27119e9952eebcb93bf434371a218ad))
- Invalidate NSTextInputContext on view removal (RL-040) ([`08f7103`](https://github.com/Vit129/kouen-terminal/commit/08f710313899303225507a07bd4bfac068121cdb))
- Prevent zombie view crashes on macOS 26 / Swift 6.3 ([`f1193e6`](https://github.com/Vit129/kouen-terminal/commit/f1193e611d5cdf40629090b1caa668c2b7b0f3ca))
- Suppress selectPane feedback during session switch ([`42ce563`](https://github.com/Vit129/kouen-terminal/commit/42ce563ffd16d8c1b98aac4d8b019b377bb8907c))
- Retain removed FileTreeNodes across render cycle ([`a92072d`](https://github.com/Vit129/kouen-terminal/commit/a92072d35b967c8de9cc4447f60eab9de4eea92d))
- Detect relative file paths not starting with / ~ or . ([`1397d52`](https://github.com/Vit129/kouen-terminal/commit/1397d52906a02985b54132e8084932ca80bcfe4f))

## [3.3.0] - 2026-06-18

### Added
- Output triggers + notch peek when active ([`3f872c2`](https://github.com/Vit129/kouen-terminal/commit/3f872c2610e3bae04483aed096c562f32d7fabf4))
- Graphify auto-load via GRAPH_SUMMARY.md ([`2247709`](https://github.com/Vit129/kouen-terminal/commit/2247709a9c89239a2c6eabf6ac5d34622c858f8a))
- Liquid Glass adaptive transparency (macOS 26+) ([`06bdd6b`](https://github.com/Vit129/kouen-terminal/commit/06bdd6b9d6d9f66c5b73f5f2ecb284dc6a6bd467))
- Add loading state + success/error toast to Fetch/Pull/Push ([`4d021fb`](https://github.com/Vit129/kouen-terminal/commit/4d021fb9e8458cdff8364665b5338495034259ab))
- Sync button shows ahead/behind count (Push ↑2, Pull ↓1) ([`f206d75`](https://github.com/Vit129/kouen-terminal/commit/f206d7556d5f8fdf6aac088b53e7dd54a700938b))
- Keybinding single source of truth, IDE-like navigation, cheat sheet ([`9ea5078`](https://github.com/Vit129/kouen-terminal/commit/9ea5078194fea531f12ee643a40fb0760902b979))
- Full-cycle now auto-tags + creates GitHub release ([`a02fa1d`](https://github.com/Vit129/kouen-terminal/commit/a02fa1ddf03e81d4f4a0d6813dfa4ec4c996b0dc))

### Changed
- Scrollback streaming compaction + renderer micro-batch optimizations ([`b1ea417`](https://github.com/Vit129/kouen-terminal/commit/b1ea417867402fcb58f54c8ec4d9420ce534ac84))
- SalvageRowKeys memo + off-main output coalesce; feat: file tree reveal ([`11569fb`](https://github.com/Vit129/kouen-terminal/commit/11569fbc786cf2d724b49f9d4be7edbd271f02c1))
- Remove GRAPH_SUMMARY auto-load, use graphify-mcp instead ([`36f6d84`](https://github.com/Vit129/kouen-terminal/commit/36f6d849a9abcd9c906b19f98ab7483586bb6fc3))
- Unify make start as single entry point, remove s1-s4 aliases ([`c98953b`](https://github.com/Vit129/kouen-terminal/commit/c98953bf1e93799c6c10edd31e4c89d9f497abd8))
- Skip BoardViewController rebuild when columns unchanged (fixes NSTextField leak) ([`2f5e973`](https://github.com/Vit129/kouen-terminal/commit/2f5e9732b4692615caa52905d0888a54ad8bc4a5))
- Unify pane/session shortcuts to ⌘/⌘⇧ only\n\n- ⌘[/⌘] now cycles panes (was session navigation)\n- ⌘⇧[/⌘⇧] now navigates sessions (was ⌘[/⌘])\n- ⌘W closes pane (was ⌘⌥W), ⌘⇧W closes tab (was ⌘W)\n- ⌘⇧Arrow for directional pane focus (was ⌘⌥Arrow)\n- Fix: ⌘⌥Arrow no longer intercepted by readline handler\n- Matches iTerm2/Ghostty/Warp convention: ⌘=pane, ⌘⇧=tab/session ([`73a3131`](https://github.com/Vit129/kouen-terminal/commit/73a31318fa09f67135d07ef4ae9fc3664d01067b))
- Extract BannerShortcutRegistry as single source of truth\n\nWelcome banner shortcuts now read from BannerShortcutRegistry\ninstead of hardcoded arrays. The registry has a showInBanner flag\nfor each shortcut, so future changes only need one edit. ([`49915f8`](https://github.com/Vit129/kouen-terminal/commit/49915f831080f037024ae8c5c91632d721f77a72))

### Documentation
- Update memory, playbook, graphify for session work ([`c50a494`](https://github.com/Vit129/kouen-terminal/commit/c50a494af6bf280d7c2648a92d799db682ac9cdf))
- Update README + agent-memory; refresh graphify graph ([`057e95c`](https://github.com/Vit129/kouen-terminal/commit/057e95c4c42a66da43884cb0dd60e85be933a3e8))
- Shelve p20/p21 — terminal-first agent flow sufficient for now ([`23c7163`](https://github.com/Vit129/kouen-terminal/commit/23c71639ec3ae602514eebb2b5d96f149dea10df))
- Close P16 (board) + P22 (perf) — both done ([`11a5089`](https://github.com/Vit129/kouen-terminal/commit/11a50892e4ea66769a6012c5ff79f456610b081b))
- Add zombie-crash-macos26 knowledge doc (CASE-034→040 consolidated) ([`9bd91af`](https://github.com/Vit129/kouen-terminal/commit/9bd91af15839b47fcec9330480ee71a8eeed0b5b))
- Add NSTextField leak knowledge doc (P20 perf) ([`ed9e504`](https://github.com/Vit129/kouen-terminal/commit/ed9e504c3b1a7817bd8d83a2b866b23c2671a75f))
- Add P23 SSH Remote Host Manager plan ([#23](https://github.com/Vit129/kouen-terminal/pull/23)) ([`b209c08`](https://github.com/Vit129/kouen-terminal/commit/b209c08111356f1f57d205a76ea50a00795cf361))
- Add updateTrackingAreas guard to zombie crash knowledge ([`40baf33`](https://github.com/Vit129/kouen-terminal/commit/40baf33168a951210c3bc0b709fff66c00ce4139))
- Add tableView race guard to knowledge ([`5f558bc`](https://github.com/Vit129/kouen-terminal/commit/5f558bcd2e38c090bc8fbf151558de72c9b474e9))
- Update zombie-crash knowledge with final timeline + script fix + 500ms ([`670052b`](https://github.com/Vit129/kouen-terminal/commit/670052bbe5400befdfa60b876b6f8905fc211313))
- Add Phase 0 (concurrency safety) to P8 macOS 27 plan — lessons from crash saga ([`4be18a0`](https://github.com/Vit129/kouen-terminal/commit/4be18a0029d37a94e5280e233b66ca93171f4314))
- Update knowledge, changelog, graphify for crash fix session ([`6a7eebb`](https://github.com/Vit129/kouen-terminal/commit/6a7eebb7367e9967011738cc8db1ecca19f82fb1))

### Fixed
- Zombie surface view crashes (CASE-037) + centralize configs ([`85d8a7e`](https://github.com/Vit129/kouen-terminal/commit/85d8a7e01f2f814b02f63e13ea92539a07528bad))
- Zombie crash (CASE-037), perf: renderer micro-batch + scrollback ([`85eafd7`](https://github.com/Vit129/kouen-terminal/commit/85eafd7500156c8b0104484c39c598875ee267f3))
- Zombie mouseMoved crash — remove NSTrackingArea on detach ([`f277421`](https://github.com/Vit129/kouen-terminal/commit/f277421415dca77dfa43ab506bf09edbdefb96c2))
- Terminal content area unreadable at low opacity on bright backgrounds ([`c8cc672`](https://github.com/Vit129/kouen-terminal/commit/c8cc67279702b9e874cb244fedb8a090681eda4e))
- Full-cycle builds before bumping version + rollback on failure ([`ac2af12`](https://github.com/Vit129/kouen-terminal/commit/ac2af12990815c17833064e948eccc1d22c9d0ea))
- Remove discardCursorRects from deinit (Swift 6 actor warning) + regenerate release notes ([`15788bb`](https://github.com/Vit129/kouen-terminal/commit/15788bb8cbaac4e2736fbad00fe4c7274d3ddf0c))
- Restore discardCursorRects in deinit to prevent zombie crash ([`32a4a75`](https://github.com/Vit129/kouen-terminal/commit/32a4a75959567fb8e4cb29599c04e5c3f7e2f4db))
- Eliminate macOS 26.5 zombie crashes — remove nonisolated layout, extend retire() to 100ms, fix Optional.map executor check ([`7b5b71e`](https://github.com/Vit129/kouen-terminal/commit/7b5b71e6a409e7299206185a8819989aa8d3e96c))
- Guard updateTrackingAreas against re-adding when view has no window ([`5d08b62`](https://github.com/Vit129/kouen-terminal/commit/5d08b62db9263d52c023f130fd43fbd0c82db51b))
- Image preview blink — reuse QLPreviewView instead of recreating ([`a33f42d`](https://github.com/Vit129/kouen-terminal/commit/a33f42d1f8a24faf90860d22ee85f30c59b4803e))
- Guard ALL updateTrackingAreas against windowless re-add (18 sites) ([`36a7b8e`](https://github.com/Vit129/kouen-terminal/commit/36a7b8e3530a2db80a7c94be4ca160f4590aa982))
- ⌘\ toggle sidebar works on first launch before initial layout ([`c69b3da`](https://github.com/Vit129/kouen-terminal/commit/c69b3dad72bf5f26f5d063e83b250c4f409daa7e))
- Guard sidebar tableView delegate against stale row index ([`b8ad429`](https://github.com/Vit129/kouen-terminal/commit/b8ad42999cc63c038955dac1159adc9f76a9ac3e))
- Resign first responder before pane rebuild to prevent zombie keyDown ([`618a1c3`](https://github.com/Vit129/kouen-terminal/commit/618a1c3ef8586afdc82892b0c6f64a7f6e728f68))
- Increase retire/retiredContainer delay to 500ms ([`c6e1655`](https://github.com/Vit129/kouen-terminal/commit/c6e1655b2eab99b2ed4375debf90210ecd563f31))
- Kill app BEFORE build in prod/install scripts ([`1b3518e`](https://github.com/Vit129/kouen-terminal/commit/1b3518e1e1a56e27d3ef1769b07529f079ba878f))
- NSEvent local monitor swallows events targeting windowless responders ([`a1a64ed`](https://github.com/Vit129/kouen-terminal/commit/a1a64edd2b321b3590a58d03ad84c8ff9b80218e))
- BrowserPaneView crash on dealloc — move unregister to viewWillMove ([`46f1b90`](https://github.com/Vit129/kouen-terminal/commit/46f1b90b0f8c80c4288ea2a5274de284338f598a))
- ⌘\ sidebar + BrowserPaneView cleanup ([`0e32e94`](https://github.com/Vit129/kouen-terminal/commit/0e32e94338a3e624a53ebe8f0a10b25b0bab7b96))
- Remove mouseUp/mouseDragged forwarding that caused infinite recursion ([`929d034`](https://github.com/Vit129/kouen-terminal/commit/929d03456ec3919f9b50b804e409b5a678ded962))
- Browser pane reload on tab switch, stale CWD on new tab, blank WKWebView ([`7c633a4`](https://github.com/Vit129/kouen-terminal/commit/7c633a45a8b9ccd2464637611d95e26778fa2f57))
- Restore 3.3.0 version after botched non-TTY full-cycle run ([`ed47c1c`](https://github.com/Vit129/kouen-terminal/commit/ed47c1c73543e567d137812de501ea2f48e4ea8f))

## [3.2.1] - 2026-06-16

### Added
- Agent-memory v2 — CONTEXT.md + MEMORY.md, UPPERCASE files ([`79ed7ec`](https://github.com/Vit129/kouen-terminal/commit/79ed7ecef0b8956d0166d71c031130087a910aa8))

## [3.2.0] - 2026-06-16

### Changed
- Cache agent icon in sidebar row, skip duplicate fileTreeView.updateRoot, fix file-preview flash (presentsWithTransaction on open/close) ([`eeca480`](https://github.com/Vit129/kouen-terminal/commit/eeca48014c4fa5edfac88995887a546a59505095))
- Skip sidebar rebuildSidebarRows+configure when sessions unchanged on metadata refresh ([`39b86a5`](https://github.com/Vit129/kouen-terminal/commit/39b86a556385104412a54245c844b8e0b032f5a5))
- Adaptive SurfaceShellTracker interval (0.5s→2s when idle); skip tabBar.refreshMetadata when tabs unchanged ([`ab020bc`](https://github.com/Vit129/kouen-terminal/commit/ab020bcbc2ca9a81db968878fdc97c6aae28db71))
- IsStableEqual for Tab/SessionGroup — ignore volatile fields (currentCommand, lastMCPControlAt) in sidebar/tabbar skip checks ([`4735048`](https://github.com/Vit129/kouen-terminal/commit/47350489c341771a4330beed9ffdfe6373759e20))

### Documentation
- Update playbook (CASE-032/033), knowledge tab-bar effectiveAgentKind, memory v3.1.5 ([`2c26e18`](https://github.com/Vit129/kouen-terminal/commit/2c26e1899be9052e3b49f68f16ea4045412381c4))
- Archive CHANGELOG v1-v2 + Task_Ledger tasks 1-50 to reduce context size ([`8d8bc3b`](https://github.com/Vit129/kouen-terminal/commit/8d8bc3b25ba58cfaf02d5c4d9771f50972c6c72d))

### Fixed
- TerminalTabBarView layout() nonisolated crash (CASE-034); perf: skip browser-pane merge + surfaceIndex rebuild when no structure change ([`cb30019`](https://github.com/Vit129/kouen-terminal/commit/cb300190acff88dfc75422ee025d65a2ef779615))
- Nonisolated + MainActor.assumeIsolated on all override func layout()/viewDidMoveToWindow() in HarnessApp — prevent Swift 6 executor crash ([`6b651a3`](https://github.com/Vit129/kouen-terminal/commit/6b651a3d0281ca53a25ffe0f6f064ccbde6cad1d))

## [3.1.3] - 2026-06-16

### Added
- Show native shortcuts on every new surface; add shortcut section to welcome banner ([`c941091`](https://github.com/Vit129/kouen-terminal/commit/c94109196ff3d1557d70146ed331b612b774a1b4))

### Fixed
- Add deinit to HarnessTerminalSurfaceView; fix CASE-030 sidebar + CASE-031 CADisplayLink ([`a95cb99`](https://github.com/Vit129/kouen-terminal/commit/a95cb99522ce6964c454be6cf7cdcd40983e8265))

## [3.1.2] - 2026-06-16

### Added
- Centralize logic — PathTokenParser (shared path:line:col parser) + AgentBridge (send context to agent pane) ([`244b1a1`](https://github.com/Vit129/kouen-terminal/commit/244b1a1d2496067c3c607fc8b236440a6f455f20))
- :agent ex command + harness agent send CLI ([`4896265`](https://github.com/Vit129/kouen-terminal/commit/489626563bcade68c0b0ee0fb90124e4f1bbce7c))
- :agent target by kind (--claude/--codex/--kiro) + prompt when multiple agents ([`a0a681e`](https://github.com/Vit129/kouen-terminal/commit/a0a681e312a8cb059295971983a564162a040c13))
- :agent auto-spawn + file autocomplete ([`aede5e4`](https://github.com/Vit129/kouen-terminal/commit/aede5e47e0692a03abc62e0d8c9496e1f656c95f))
- Add workbench commands (:view, :agent, :cd) + Robot suite ([`50f718c`](https://github.com/Vit129/kouen-terminal/commit/50f718cbe709b422f822241292a5d4978b6e245d))
- AgentCatalog centralized config (claude/codex/kiro/gemini models+effort) ([`063ffb6`](https://github.com/Vit129/kouen-terminal/commit/063ffb66f396ea78b21da64c46bf000dccac3f15))

### Changed
- Eliminate unconditional 5-s sync + snapshot fanout overhead ([`be38bab`](https://github.com/Vit129/kouen-terminal/commit/be38bab8c05c9be830fa909c93ee221e039cae41))

### Documentation
- P21 plan — ACP re-enable + agent/model/effort selection (terminal-first) ([`41f60a2`](https://github.com/Vit129/kouen-terminal/commit/41f60a223b63415a43c4d45be3d21bacbc0e3976))
- Update P20/P21 status — AgentBridge/AgentCatalog/agent commands done, ACP re-enable deferred ([`4600aef`](https://github.com/Vit129/kouen-terminal/commit/4600aef0e6bc03a5918bcc81d236d25b31fa9ba6))
- Merge harness chat branding into P21 PBI-ACP-005 ([`501ddfb`](https://github.com/Vit129/kouen-terminal/commit/501ddfbb87ba856652bf3554edcf578d0bc35989))
- Integrate Hermes concepts — multi-provider + brain + orchestration + backends ([`2ddefeb`](https://github.com/Vit129/kouen-terminal/commit/2ddefebc0da260ecbe7be728d66462527ab35a3f))
- Update agent-memory, knowledge, graphify for long-session perf work ([`64f5a5c`](https://github.com/Vit129/kouen-terminal/commit/64f5a5c228a5b0dc7ed484da481757b82f13091f))

### Fixed
- Dot after title, branch always visible, cancel drag on reload ([`6af3d93`](https://github.com/Vit129/kouen-terminal/commit/6af3d93935cdb51389d486da1c6fddc85f7c5022))
- Dot after title, branch always visible, cancel drag on reload ([`4bfafc7`](https://github.com/Vit129/kouen-terminal/commit/4bfafc7bb997311766d8652f228f4219844cad99))

## [3.1.0] - 2026-06-15

### Added
- Add status indicator to session card rows (dot + label on right) ([`9078709`](https://github.com/Vit129/kouen-terminal/commit/9078709c64db26dfea359040f13c39e7a208540a))
- Central board status dot on top bar session pills + sidebar cards ([`389957b`](https://github.com/Vit129/kouen-terminal/commit/389957b90288c617eedb649d053058d1163f262b))
- Bell badge + dropdown include board error/needs-attention sessions ([`9d42145`](https://github.com/Vit129/kouen-terminal/commit/9d4214516374299e6de74e68854dc1ad97698c8c))
- Change notification shortcut ⌘⇧U → ⌘⇧I (Inbox) ([`fe8eaa7`](https://github.com/Vit129/kouen-terminal/commit/fe8eaa793fd510472f89a7d16cbce1e8a165474a))
- ⌘F opens grep/find-in-files palette (Cmd+Shift+F parity) ([`546447c`](https://github.com/Vit129/kouen-terminal/commit/546447cbe42d27ee16f95b8932c5e7ad09702372))
- Add ⌘P as alias for Command Palette (alongside ⌘K) ([`94d7e48`](https://github.com/Vit129/kouen-terminal/commit/94d7e48ed0f715c00f7138408886812b81d066b0))
- Replace ⌘K with ⌘P for Command Palette (VS Code/Cursor/Zed parity) ([`1e60982`](https://github.com/Vit129/kouen-terminal/commit/1e60982aa7ee71c01af21b9f7d1d6ca6b9f68b1a))

### Changed
- Centralize board status logic ([`2ab7f63`](https://github.com/Vit129/kouen-terminal/commit/2ab7f63bc2a4937472aa518f8268d2d5d75deb03))

### Documentation
- Add IDE-like Terminal Workbench section to USAGE, COMMANDS, KEYBINDINGS ([`8a8b7be`](https://github.com/Vit129/kouen-terminal/commit/8a8b7be11d01d29b88eee2f8191ed8983baeef4c))
- Update README doc index with workbench command references ([`1c746f1`](https://github.com/Vit129/kouen-terminal/commit/1c746f12ca70a46d586030ad24c2f9536454778c))
- Update P11/P15/P16 plan status to reflect actual implementation state ([`32655e2`](https://github.com/Vit129/kouen-terminal/commit/32655e2219e02235fafdd8f671351eb851b39721))
- Update KEYBINDINGS.md and fix remaining ⌘K/⌘⇧T/⌘⇧⌥W references in docs ([`a8a5023`](https://github.com/Vit129/kouen-terminal/commit/a8a5023b10a3f0ff96e6b253f999b2e0a6096da0))
- Consolidate docs — add Modes+Migration summary to USAGE.md, move MANUAL_TEST_PLAN to agent-memory, update README index ([`95a90b5`](https://github.com/Vit129/kouen-terminal/commit/95a90b5da92d585c367bcd4dd21e0e21b0cec9ed))

### Fixed
- Sidebar group header chevron size and click area ([`49cff21`](https://github.com/Vit129/kouen-terminal/commit/49cff212865fa2387770d29e20f5abeceadb49f0))
- Remove broken ⌘⇧T Reopen Closed Tab; ⌘F opens Command Palette (fuzzy find) instead of browser find bar ([`3e80b7e`](https://github.com/Vit129/kouen-terminal/commit/3e80b7e353cceb14684792fa924d9a6b395c8950))
- Close Pane ⌘⇧⌥W → ⌘⌥W (iTerm2 parity, easier to press) ([`238068d`](https://github.com/Vit129/kouen-terminal/commit/238068d6f5fe8c34122480daa79eb3f9ada1cabf))
- Tab bar × button now shows confirmation dialog (same as ⌘W) ([`cc5826a`](https://github.com/Vit129/kouen-terminal/commit/cc5826a26dae5f3252dc11f6c8dd87ce270b0dc6))

## [3.0.0] - 2026-06-15

### Added
- Simplify version-bump flow into install/prod/full-cycle ([`78aa2de`](https://github.com/Vit129/kouen-terminal/commit/78aa2de5773c84dff11b346b008171bbc43d61b9))
- Add keyboard navigation to notification dropdown ([`bfcba37`](https://github.com/Vit129/kouen-terminal/commit/bfcba37798d6a13676cd03848d919bf51827e20c))
- Implement spotlight search safety & fix git status update/blinking issues ([`3a04116`](https://github.com/Vit129/kouen-terminal/commit/3a04116681c97ff7939ce30fb8d0012ce08dfb02))
- Add interactive arrow-key start menu & auto-prepend release notes to changelog ([`bfdead7`](https://github.com/Vit129/kouen-terminal/commit/bfdead709fc19b3f16dcb8cadbe72dc3f943eb2e))
- Show next semantic versions in start menu choices ([`b97c4ea`](https://github.com/Vit129/kouen-terminal/commit/b97c4ea3e01c04ef51fe0a722f96f0632bee8b53))
- Restore split-down (top/bottom) parity (P13) ([#10](https://github.com/Vit129/kouen-terminal/pull/10)) ([`7ab5fa2`](https://github.com/Vit129/kouen-terminal/commit/7ab5fa2ed02ba478596cfb03844bd34a4f35254b))
- Agent orchestration via MCP (P12 PBI-ORCH-001..005) ([#11](https://github.com/Vit129/kouen-terminal/pull/11)) ([`6abe384`](https://github.com/Vit129/kouen-terminal/commit/6abe384edf940f2c984eb6b6b35e40cf23436593))
- Add terminal-first LSP and file view commands ([`d49895a`](https://github.com/Vit129/kouen-terminal/commit/d49895afdf60a00dc4c944a905dfcf70ad08a6ab))
- Complete vi lsp navigation ([`c1613dd`](https://github.com/Vit129/kouen-terminal/commit/c1613dd9c8390dfca92211b93c9d778f82da13e8))
- Add JavaScriptCore config runtime (P11 PBI-SCRIPT-001..003) ([`a5fddb3`](https://github.com/Vit129/kouen-terminal/commit/a5fddb3ed071315426742d850572ec8494884dfa))
- P16 Agent/Session Board (PBI-BOARD-001/002/003/005) ([`a9786b8`](https://github.com/Vit129/kouen-terminal/commit/a9786b8d961316ed00debf0b0f48493782eb7828))
- Add harness.events bridge (P15 step 3) ([`01c8bfe`](https://github.com/Vit129/kouen-terminal/commit/01c8bfef08267db76455576e18f93ad6ebfac484))
- Merge harness.events bridge (step 3) — unblocks P11/P12/P16 ([`9b84f59`](https://github.com/Vit129/kouen-terminal/commit/9b84f59bff47842b0cc2f7ade2777521ea18fd7c))
- PBI-ORCH-005 — MCP-controlled indicator on tab bar ([`e8471aa`](https://github.com/Vit129/kouen-terminal/commit/e8471aaa705fd44909d123dbf747d411e8288066))
- Complete PBI-SCRIPT-004/005 + harness.events bridge + test fixes ([`d7709ff`](https://github.com/Vit129/kouen-terminal/commit/d7709ffbacc6771ac3613a7cecb7bd1b3321c5ba))
- PBI-BOARD-004 live updates + PBI-BOARD-006 dismiss ([`2c93aa2`](https://github.com/Vit129/kouen-terminal/commit/2c93aa23f2f4ef45cb5220996e2cac2d46fe11d7))
- Scripting 004/005 implementation from worktree ([`d903e85`](https://github.com/Vit129/kouen-terminal/commit/d903e8544750ebcb6747e301d84faf6d1e3c62e5))
- PBI-BROWSER-001..005 — embedded browser pane + MCP tools ([`7b7a5d1`](https://github.com/Vit129/kouen-terminal/commit/7b7a5d12abf8d5fc3d424e72cf96375a78085b76))
- WB-001 WorkbenchCommand facade + parser ([`b06311a`](https://github.com/Vit129/kouen-terminal/commit/b06311a0e9594181958e61fb717e56c2dcff14fe))
- WB-002/003/004/006 ex commands + task detector ([`7f31b15`](https://github.com/Vit129/kouen-terminal/commit/7f31b151dd96382bf8780dc47cc616f94c575ae1))
- WB-007 harness.profiles.use('ide-migrant-terminal') ([`0c7e558`](https://github.com/Vit129/kouen-terminal/commit/0c7e5586114ed5b643e696fa3307aa08bd5fc3fa))
- Terminal Workbench — all PBI-WB-001..007 done ([`dd9fb69`](https://github.com/Vit129/kouen-terminal/commit/dd9fb6975d41eb950e66d206c0f48381c2557536))
- Add workbench CLI commands for IDE migrants ([`eba61bf`](https://github.com/Vit129/kouen-terminal/commit/eba61bfb4d85f770859bc80486a00acd484ed2b6))
- Session expand shows tab list with Board status + full CWD ([`8f86461`](https://github.com/Vit129/kouen-terminal/commit/8f864616515c2ce472a88745c1df362398b018b8))
- Add Cmd+B shortcut for Browser Pane + open localhost links in-app ([`d3c6f7d`](https://github.com/Vit129/kouen-terminal/commit/d3c6f7d5739e377c928e8128965cc9c2b4ad7c8c))
- Open LAN dev-server links (private IPv4/IPv6) in Browser Pane ([`fb5896d`](https://github.com/Vit129/kouen-terminal/commit/fb5896d1f106b5b58bf40bfe90f3b7cbb89da178))

### Changed
- Restructure dev-loop make targets and start.sh menu ([`0522be4`](https://github.com/Vit129/kouen-terminal/commit/0522be4f2d99e2fa51b69443ce1ab7f4c4056844))
- Consolidate menu shortcuts, add git panel toggle, fix preview socket path ([`ca1fb4a`](https://github.com/Vit129/kouen-terminal/commit/ca1fb4aa610f1e7610779c5b3579d7f2cab046b9))
- Remove dead Tab-switch shortcuts, repoint ⌘[/⌘] to session navigation ([`6a8e276`](https://github.com/Vit129/kouen-terminal/commit/6a8e276979bc5e654dfa839cdab0b3731fd8aabf))
- Worktree-aware full-cycle, commit-push-merge helper ([`9283e8c`](https://github.com/Vit129/kouen-terminal/commit/9283e8c5a35102577db7a821ea53f7d9dc9dd1cf))
- Decompose SessionCoordinator → ThemeService + ActivePaneService ([`f78c71f`](https://github.com/Vit129/kouen-terminal/commit/f78c71fbda1aedfd38d1974706b35a1c9f5de9a2))
- Complete PBI-REFACTOR-001 — SessionCoordinator 2050→397 LOC ✅ ([`5e693a9`](https://github.com/Vit129/kouen-terminal/commit/5e693a94268e6fdec2d58ee698867924ab50eb4a))
- Organize UI/ into feature subfolders, shelve ACP behind HARNESS_ACP flag ([`8250be1`](https://github.com/Vit129/kouen-terminal/commit/8250be17654a0a362299559851f7f3b656514b6f))
- Decompose ViNormalMode.swift into 5 focused files (PBI-REFACTOR-003) ([`fd7a41f`](https://github.com/Vit129/kouen-terminal/commit/fd7a41f313827fa5b95f958f5e8761b90fbdc4fd))

### Documentation
- Update memory to v2.5.2 + add HOW_TO_USE.md ([`989d74f`](https://github.com/Vit129/kouen-terminal/commit/989d74fe015cb587748bde1cf9edbf19fa1f5b9a))
- Update agent-memory and graphify after CASE-028 keybinding cleanup ([`8b4a9a6`](https://github.com/Vit129/kouen-terminal/commit/8b4a9a6780f9d14e3706202cb49871d0cab8b817))
- Add v2.5.3 entry for CASE-028 keybinding cleanup ([`0defdd4`](https://github.com/Vit129/kouen-terminal/commit/0defdd497e391091da99a3b8cdadc19f266c5872))
- Remove empty Unreleased heading so 2.5.3 is the top entry ([`14a85d4`](https://github.com/Vit129/kouen-terminal/commit/14a85d4806d0108396e64291ac24da2174cf2b60))
- Add P11-P13 strategic backlog plans from terminal comparison ([`9d8758b`](https://github.com/Vit129/kouen-terminal/commit/9d8758b4ca750df74b522c56ed43e0361c92c1e0))
- Add P15 integration roadmap and P16 agent/session board plans ([`3da9720`](https://github.com/Vit129/kouen-terminal/commit/3da972068fae5a82a6b23b9840deb66203bf52b6))
- Document P16 Agent/Session Board, update README and graph ([`b874f6b`](https://github.com/Vit129/kouen-terminal/commit/b874f6b9424912f5a5d7f53f967c679c1c1cc8d9))
- Refresh plan statuses after PR #10/#13-#19 merges ([`6770bc6`](https://github.com/Vit129/kouen-terminal/commit/6770bc6bcdcee0fcb2f1e4f83d46bc3d2cdab23d))
- Refine terminal-first roadmap ([`7283313`](https://github.com/Vit129/kouen-terminal/commit/72833136fa4e2d06f0b665c5bede62e74b4b5d45))
- Mark P17 PBI-002/003/005 done in structural-refactor plan ([`3464312`](https://github.com/Vit129/kouen-terminal/commit/34643122427cc8ad1ce40df388ca50b85990be2e))
- Mark P17 DONE, defer PBI-004 (HarnessCore split) ([`b2e0944`](https://github.com/Vit129/kouen-terminal/commit/b2e0944d59ac0a726289eca2e09dd00aa3c6dd0c))
- Update graphify, agent-memory, knowledge base ([`7aedf38`](https://github.com/Vit129/kouen-terminal/commit/7aedf3882a0e31f47a9cacf66e27d7cb78a0bd75))
- Add terminal workbench migration plan ([`e577115`](https://github.com/Vit129/kouen-terminal/commit/e577115c2a4c7c0890c7692ea087d1a33ae60722))
- Mark P12 DONE, add task 67 to memory ([`85f4744`](https://github.com/Vit129/kouen-terminal/commit/85f4744f74afcf7d163f3c71e22db4c9ef36f07d))
- Mark P11 PBI-SCRIPT-004/005 done in memory ([`d926962`](https://github.com/Vit129/kouen-terminal/commit/d92696259e88afe939be45f89c7e4e1a9ff51c90))
- Mark step 4 (P11 PBI-SCRIPT-004/005) done in integration roadmap ([`c647023`](https://github.com/Vit129/kouen-terminal/commit/c6470234dd508a17fe19884a902e22cddfae1b33))
- Update browser pane plan with cmux research + agent control design ([`7376d82`](https://github.com/Vit129/kouen-terminal/commit/7376d8228f7047ec80184e1036edca5a50cf4e5c))
- Finalize plan + agent prompt for PBI-BROWSER-001/002 ([`4aca3b2`](https://github.com/Vit129/kouen-terminal/commit/4aca3b2a0ade029cc207eb062636ae8e3d16604b))
- Add single agent prompt for all PBI-BROWSER-001..005 ([`4c6c9c8`](https://github.com/Vit129/kouen-terminal/commit/4c6c9c8d4d50f329e1efcf0ba81e27f7c7adf884))
- Davin/Windsurf kanban+CMUX proposal for sessions panel/top bar ([`fc09419`](https://github.com/Vit129/kouen-terminal/commit/fc094198da6f7bb6b33490570195d6a2c5af619a))

### Fixed
- Kill stale Harness/daemon before relaunching via run.sh ([`8194c89`](https://github.com/Vit129/kouen-terminal/commit/8194c89962785ba2097b036d4aeb62f48cfda782))
- Scope kill_stale to prod release home, guard prepare-release against Unreleased, add version banner + clean-state ([`5f8b0ef`](https://github.com/Vit129/kouen-terminal/commit/5f8b0ef0bf722d1df8ce202f1947b1f23268a425))
- Swift build -c release builds all products, not just the last --product flag ([`d3f725c`](https://github.com/Vit129/kouen-terminal/commit/d3f725cae2362875c34aaa49e1fdffb586fb827f))
- Keep text selection stable across scroll ([`c4d103c`](https://github.com/Vit129/kouen-terminal/commit/c4d103c6ef228b4b0db8b19d1c900371a600b15c))
- Fix diff deadlock, add notification rings, preview build badge ([`ab2e9fe`](https://github.com/Vit129/kouen-terminal/commit/ab2e9fee88d1907960890167c750469aee7fc5cc))
- Make ⌘\ a pure sidebar toggle, decoupled from file-editor split ([`91f7829`](https://github.com/Vit129/kouen-terminal/commit/91f7829bd32df05120e9c5924cb2b8123b27c62d))
- Close button bug, idle throttle, session short ID, P4 tests, P17/P18 plans ([`74482fd`](https://github.com/Vit129/kouen-terminal/commit/74482fd4b7475dfa34ec5e4cdacc29ca1a980b80))
- Guard NSApp nil in updateDockBadge, fix flaky board count assertion ([`8741d11`](https://github.com/Vit129/kouen-terminal/commit/8741d119a08d1e18caf1c4e699d547048e938c55))
- Wire WorkbenchMRU.add + :copy-path callbacks in FileEditorView ([`135f270`](https://github.com/Vit129/kouen-terminal/commit/135f2704da65eb991a736cc9b7d919d6a614ec06))
- Browser pane persists across daemon syncs ([`4f7b42e`](https://github.com/Vit129/kouen-terminal/commit/4f7b42e74dd30a5235163fad829db1d7321446bd))
- Stop browser pane blink loop ([`ca2e3f1`](https://github.com/Vit129/kouen-terminal/commit/ca2e3f190cfadba60e1ca90240293e663e85a07a))
- Add close (×) button to browser toolbar + closeBrowserPane ([`fcbf138`](https://github.com/Vit129/kouen-terminal/commit/fcbf13804fa3c754b7ca65d1bd465e5ac51331c4))
- Wire closePaneButton → closeBrowserPane correctly ([`ec04ee7`](https://github.com/Vit129/kouen-terminal/commit/ec04ee722ff3e42b43dab030f2fe5984f29fec3a))
- Expand arrow stays visible using insertRows/removeRows ([`f68da70`](https://github.com/Vit129/kouen-terminal/commit/f68da70461a007a123dade7fb2693eb590618a37))
- Browser close button + prompt file for Agy ([`8dfdeb8`](https://github.com/Vit129/kouen-terminal/commit/8dfdeb80f9df0c8e2dd8720f1134daecfc109b9c))
- Browser toolbar close/refresh fix, branch-aware tabs ([`697b84b`](https://github.com/Vit129/kouen-terminal/commit/697b84bfbf16f910b0c122bf01f7f2e75f51eeca))
- Hide collapsed error banner to stop it intercepting toolbar clicks; add hit-test/action tests for close+refresh buttons ([`6e4d07c`](https://github.com/Vit129/kouen-terminal/commit/6e4d07c9366de300e00ad6de669f350a4087c081))
- Keep group-header expand arrow visible after collapse/re-expand ([`fa80ec8`](https://github.com/Vit129/kouen-terminal/commit/fa80ec826dab3e3b0a3928589427ce0032da6c22))
- Stop applyLocalSnapshot from re-injecting closed browser panes ([`4545f9c`](https://github.com/Vit129/kouen-terminal/commit/4545f9c04bac2c74d9d85acc044b9c3ce385ad98))
- Apply initial sidebar visibility after first layout pass ([`2c02b03`](https://github.com/Vit129/kouen-terminal/commit/2c02b03f6bf0d22d44ec859138e1d251ada91e3b))

## [2.5.2] - 2026-06-12

### Fixed
- Enforce 15% minimum tint on translucent window background ([`54d1fef`](https://github.com/Vit129/kouen-terminal/commit/54d1fefaca256dce648df476382e98f918243fc7))
- Make pasted image handoff readable ([`1dcc502`](https://github.com/Vit129/kouen-terminal/commit/1dcc502a7426c361e580b94496fcc0e5d1397e63))
- Select sessions with number shortcuts ([`0704670`](https://github.com/Vit129/kouen-terminal/commit/07046701af83208fb0bf263f5eb184e7e353c2f9))

## [2.5.1] - 2026-06-12

### Added
- Close last tmux gaps — word-separators in copy-mode w/b/e, CLI list-* -F ([`eed04ee`](https://github.com/Vit129/kouen-terminal/commit/eed04eebcf754005180966c93d7780f044dab6a4))
- Per-theme-mode background opacity for auto light/dark ([`137d6ea`](https://github.com/Vit129/kouen-terminal/commit/137d6eaadba487acb0bd42a0385514390deca137))
- Per-theme-mode background opacity for auto light/dark ([`6234652`](https://github.com/Vit129/kouen-terminal/commit/6234652b7b3b707d7077c811fcbd53828689ddf1))

### Documentation
- Rewrite README — cleaner structure, no agent-memory/graphify internals ([`32812c2`](https://github.com/Vit129/kouen-terminal/commit/32812c2bb31f5a8857efd3f577c3021e25d45f6d))
- Trim README to 66 lines (A+B style) ([`e3aa6e1`](https://github.com/Vit129/kouen-terminal/commit/e3aa6e11e760906636a09c7457797bf23018c07c))
- Add fork attribution to README ([`90f66fd`](https://github.com/Vit129/kouen-terminal/commit/90f66fd74d8715b7db82f00ea66f0da6b9338b00))
- Update CHANGELOG, memory, and knowledge for session fixes and opacity improvements ([`bc4b907`](https://github.com/Vit129/kouen-terminal/commit/bc4b9074bcccba99ace8bf9684b8a79d6df486a7))
- Add Apple Liquid Glass / legibility context to knowledge base ([`d047630`](https://github.com/Vit129/kouen-terminal/commit/d04763021d42bf456dc8f52b45127463b55c86c2))

### Fixed
- Use theme-tinted window background when translucent ([`99475ec`](https://github.com/Vit129/kouen-terminal/commit/99475ec56743775693c1b8faf72059cafc05a493))

## [2.5.0] - 2026-06-12

### Added
- Support wrap-search option and zoxide frecency in command palette ([`6250ef8`](https://github.com/Vit129/kouen-terminal/commit/6250ef8960c58032d19f534f8d1590add910fb6a))
- Terminal power-user features — vi mode, tmux parity, LSP, zoxide ([`8c0f373`](https://github.com/Vit129/kouen-terminal/commit/8c0f3739468f47566d191a9659701caea40ab66e))
- Keyboard file tree, vi jump-list/marks/search, tmux window-size/json ([`3bb9601`](https://github.com/Vit129/kouen-terminal/commit/3bb960112a962ac6bafb69bf8219a8e6883d9420))

### Changed
- Remove Toggle IDE Mode preset shortcut and menu items ([`536d371`](https://github.com/Vit129/kouen-terminal/commit/536d3713ab6a564301f97d231ae0a86f8f4ec36f))

### Documentation
- Clarify design philosophy to Terminal First, IDE Convenient and resolve features duplication ([`faffb4b`](https://github.com/Vit129/kouen-terminal/commit/faffb4bf5c2040eee6761b47be9b1303867dbcba))
- V2.5.0 — update CHANGELOG, README, memory, TMUX_PARITY, graphify ([`393bc96`](https://github.com/Vit129/kouen-terminal/commit/393bc9622cb1ac5de09ff5c1a337cbeee8789a20))

### Fixed
- Reset Focus Mode state on manual panel toggles to prevent out-of-sync layouts ([`9f1eb3e`](https://github.com/Vit129/kouen-terminal/commit/9f1eb3e60e98a7c42a6c4db8e8a0a0535d4d6a29))

## [2.4.0] - 2026-06-12

### Added
- Lazy scrollback reflow, task board sidebar, focus mode (⌘P) ([`ccc2b6e`](https://github.com/Vit129/kouen-terminal/commit/ccc2b6e93df30f7baf735592c8f39182891a8099))
- Add Switch Project section and worktree-to-tab integration ([`5149832`](https://github.com/Vit129/kouen-terminal/commit/5149832b64dc9583f01e9fc0be18e370e3634055))
- Add fuzzy file quick-open to command palette ([`2626aa0`](https://github.com/Vit129/kouen-terminal/commit/2626aa04ed60ee78a02e3d83be8e2e1e0ae87f0a))
- Add Ctrl+R interactive command-history search overlay ([`2b8f01c`](https://github.com/Vit129/kouen-terminal/commit/2b8f01c13c593084f5f71c3375624dfe937bab1e))
- Layout presets (⌘⌥1-5) and workspace symbol index in command palette ([`9333529`](https://github.com/Vit129/kouen-terminal/commit/93335294fa995b95aafbf963f64506ae9a6839f4))

### Changed
- Remove task board panel and clean up related code ([`19843bd`](https://github.com/Vit129/kouen-terminal/commit/19843bd25786d247a5504df6f3ed628bd8fe5de8))
- Enumerate files off main thread for fuzzy file quick-open ([`ddbe586`](https://github.com/Vit129/kouen-terminal/commit/ddbe586fdf5cffc101e5000f9fd852dc5af5d6c5))

### Documentation
- Add scrollback lazy reflow prompt for P10 agent execution ([`b7ee562`](https://github.com/Vit129/kouen-terminal/commit/b7ee562ea54ea0a9da64777e1fe15d7f2956cae7))
- Update memory, playbook, P10 plan; refresh graphify for v2.3.0 post-release ([`10206de`](https://github.com/Vit129/kouen-terminal/commit/10206de6eaaf69cbb9993d930ca920265dc35b5b))
- Add fzf-searchable Linux + Vi cheat sheet ([`351a321`](https://github.com/Vit129/kouen-terminal/commit/351a32151e80b44ca54cd20b7a11c694f472baf3))
- Update README, KEYBINDINGS, AGENT-HANDBOOK, HARNESS_TMUX_CAPABILITIES ([`89cca08`](https://github.com/Vit129/kouen-terminal/commit/89cca08bdc5a1deb58cb5c435ec5be34e3a169fd))

### Fixed
- Always stop+start display link in viewDidMoveToWindow (CASE-026) ([`a60bbd3`](https://github.com/Vit129/kouen-terminal/commit/a60bbd3243c1611c90d4c178f2101c5d71cb24c5))
- CASE-026 black terminal on new session (display link race) ([`41c180f`](https://github.com/Vit129/kouen-terminal/commit/41c180f1a6d688a3521a649655a9549aa5e83095))
- Close-pane button closes the clicked pane, not the active one ([`9ba147a`](https://github.com/Vit129/kouen-terminal/commit/9ba147a1f543d789ee25ae4772d23d7f87a97b07))
- Force child layout after applying split divider positions ([`057bae4`](https://github.com/Vit129/kouen-terminal/commit/057bae4475e446d687a2004b260a9229903470b7))
- Skip redundant schedule if revision already pending ([`75e1d0f`](https://github.com/Vit129/kouen-terminal/commit/75e1d0fbf87df5d9327d6e78cebb44d50410105c))

## [2.3.0] - 2026-06-11

### Added
- Diff syntax coloring, changes click-to-preview, history context menu ([`d5fcbc9`](https://github.com/Vit129/kouen-terminal/commit/d5fcbc9105e310c49126bc671261dc64b4e97fce))

### Changed
- Extract pure logic from HarnessTerminalSurfaceView ([`62cc31c`](https://github.com/Vit129/kouen-terminal/commit/62cc31cd849a74a0b546e4be10696e50f53692af))
- Extract HarnessCLI handlers and SurfaceRegistry helpers ([`e17ddc1`](https://github.com/Vit129/kouen-terminal/commit/e17ddc1346b605fe8bf881713f8559d75959c5c4))

### Documentation
- Record P9 extraction task and refresh graphify graph ([`ea81af4`](https://github.com/Vit129/kouen-terminal/commit/ea81af4c3f9ca6978d3af2764716353c19e0100b))
- Update for git panel fixes + P10 prompts, refresh graphify ([`cab5b47`](https://github.com/Vit129/kouen-terminal/commit/cab5b478297fb761cfe6140999d537b551d2a914))

## [2.2.4] - 2026-06-11

### Added
- Add Scripts/install-app.sh with macOS cache clearing ([`5543c82`](https://github.com/Vit129/kouen-terminal/commit/5543c8272060b53150d6ec4349ba3eb1deef5791))
- Redesign AgentInboxPanelView rows to match notch HUD format ([`0af34e2`](https://github.com/Vit129/kouen-terminal/commit/0af34e2d2094d1d2e5116d801cad2b1c47a77ffd))
- Add toggles to show hidden files and folders ([`7b34c3e`](https://github.com/Vit129/kouen-terminal/commit/7b34c3e2e16dd41bf7ef2aad1b8ba8d326b4db46))
- Expand start.sh menu with commit/push and release-prep options ([`7b66e64`](https://github.com/Vit129/kouen-terminal/commit/7b66e64fab757217d3b2d55815d979adfd01ecb4))
- Collapse sidebar by default on fresh installs ([`4edac61`](https://github.com/Vit129/kouen-terminal/commit/4edac613142847152c3841375d4c435b3afa25e3))
- Add Always collapse sidebar on launch option ([`3c4fac4`](https://github.com/Vit129/kouen-terminal/commit/3c4fac47a7738e6d18ff0a22df6524b394e18864))
- Add Excel and CSV support via QuickLook ([`e076989`](https://github.com/Vit129/kouen-terminal/commit/e076989ed22385135fa9bc70364d13e7cad2c919))

### Changed
- Move app-only Notch and FileExplorer domains out of HarnessCore ([`1b043aa`](https://github.com/Vit129/kouen-terminal/commit/1b043aa4aab28f8e38fed8937e0235d3fcf952ce))
- Split HarnessSidebarPanelViewController into focused files ([`1003330`](https://github.com/Vit129/kouen-terminal/commit/100333057b3aeaaea77e02a4044e71966b80b675))
- Split HarnessTerminalSurfaceView into focused extension files ([`adaba9b`](https://github.com/Vit129/kouen-terminal/commit/adaba9b3fa6b3842a4d694c6d39ac17b05a98dac))
- Split SettingsViewController into per-page extension files ([`a57fcae`](https://github.com/Vit129/kouen-terminal/commit/a57fcae84ef0e5b1968c88343f420db68ed8ddc6))

### Documentation
- Add CASE-016..021, FSEvents pattern, RL-007..010, git-panel knowledge update ([`7baa854`](https://github.com/Vit129/kouen-terminal/commit/7baa854b2048049925074804431c0c30ef3f85e7))
- Record CASE-023/024 and refresh graphify graph ([`3b633e8`](https://github.com/Vit129/kouen-terminal/commit/3b633e8458146d940a479dde41cef8f8dbfc0c55))
- Record build/run command preferences ([`abd6f66`](https://github.com/Vit129/kouen-terminal/commit/abd6f6625bcf5a68339d4f9b316f4d517588c236))

### Fixed
- Install-app.sh must build release to match package-app.sh release ([`1a328d1`](https://github.com/Vit129/kouen-terminal/commit/1a328d15e0f64c31d3c83298e945c2f8066c96b7))
- Refresh UI after create/delete/rename operations ([`1538270`](https://github.com/Vit129/kouen-terminal/commit/153827043d9efc631bae544d64531a4d822d3a5a))
- Resolve file tree watcher, folder expand state, file preview selection, and selection highlight visibility ([`9ae608e`](https://github.com/Vit129/kouen-terminal/commit/9ae608eebcf12492f586267dacffd3d3c6882226))
- Replace DispatchSource watcher with recursive FSEvents stream ([`f9c5bee`](https://github.com/Vit129/kouen-terminal/commit/f9c5beee393e4a16b50d4b8f837e271707f1ff2a))
- Update branch chip on HEAD change and add FSEvents watcher for working-tree changes ([`4ed9803`](https://github.com/Vit129/kouen-terminal/commit/4ed98033fbb03c9d05b7817c6836f579b648ee73))
- Declare HarnessTerminalEngine dep, sync CLAUDE.md targets, ignore dated graphify dirs ([`7fed132`](https://github.com/Vit129/kouen-terminal/commit/7fed132f891f64c26fd32d82d405e66f6166869a))
- Serialize refresh() to prevent stale staged-state UI ([`e4ccd5a`](https://github.com/Vit129/kouen-terminal/commit/e4ccd5a7eab3ac41a2e8251082be44da70a03474))
- Make File Preview opacity match Terminal exactly ([`d44d48b`](https://github.com/Vit129/kouen-terminal/commit/d44d48b27769e162b7d054dcd8f4a813621c3e68))
- Reset transient modes at shell prompt ([`e124c63`](https://github.com/Vit129/kouen-terminal/commit/e124c6395bdebabb6e7003711468064ee3c4e574))
- Live-reload preview when the underlying file changes ([`42263bf`](https://github.com/Vit129/kouen-terminal/commit/42263bfc9bb74aff096100375760f01f23696b30))
- Sync sidebarVisible when forcing collapse on launch ([`ddbacbc`](https://github.com/Vit129/kouen-terminal/commit/ddbacbcddef1f7bf5f598b8255bfa4a54dece68b))
- Don't clear synchronizedOutput on shell-prompt reset ([`e16259c`](https://github.com/Vit129/kouen-terminal/commit/e16259c84f5bd42429c9c399c0e3a41386d416e5))

## [2.2.3] - 2026-06-09

### Added
- P7 sidebar button style + terminal tab bar background fixes ([`928723f`](https://github.com/Vit129/kouen-terminal/commit/928723f6eec0dd60f363215e29b44aacb951fbcb))

### Documentation
- Add changelog entry for P7 header button style fix ([`91b89b7`](https://github.com/Vit129/kouen-terminal/commit/91b89b7f6df6906e65cbc35b62aa6679a3b44cae))
- Consolidate P7 + tab bar fixes into 2.2.2 changelog ([`18fbd7a`](https://github.com/Vit129/kouen-terminal/commit/18fbd7a63800a08fde81cdb84b4d1eb0ae9d3ed9))

### Fixed
- Use SoftIconButton for group header + and ... buttons ([`25b1525`](https://github.com/Vit129/kouen-terminal/commit/25b1525e142543a68140f693664786474807ff1d))
- Terminal tab bar uses clear background with bottom border ([`249c9f4`](https://github.com/Vit129/kouen-terminal/commit/249c9f4e1592cbeee717d659d61bf1c3e01b2d75))
- Terminal tab bar background uses terminalBackground instead of clear ([`254bdd9`](https://github.com/Vit129/kouen-terminal/commit/254bdd91a7aba4f36949005ef9b2375c42e20613))
- Activate tab bar height constraint ([`46ae757`](https://github.com/Vit129/kouen-terminal/commit/46ae7571d93ebc779fe96650b5d639c227d460e4))
- File editor opacity parity with terminal (P6) ([`f066e4c`](https://github.com/Vit129/kouen-terminal/commit/f066e4cc5d45305ed31325e2e7f3deaa812c3ab7))

## [2.2.2] - 2026-06-08

### Documentation
- Backfill CHANGELOG for v1.9.0, v2.0.0, v2.1.0 ([`db01e89`](https://github.com/Vit129/kouen-terminal/commit/db01e898acbd5ebd11ba2b01ec043690155f8abe))
- Add P6 plan — editor opacity parity with terminal ([`bc63129`](https://github.com/Vit129/kouen-terminal/commit/bc631299e39692d91fff33dadedfdc827009825c))

### Fixed
- File preview text rendering + draggable editor divider (v2.2.2) ([`c697106`](https://github.com/Vit129/kouen-terminal/commit/c697106effc22f2aaa8f959a3b03efff3282d6f1))
- Editor panel background matches terminal vibrancy ([`e5e2f93`](https://github.com/Vit129/kouen-terminal/commit/e5e2f935435f61205bc2d866939b0a4ced847757))
- Editor panel tab bar no longer overlaps terminal tab bar ([`b2b894d`](https://github.com/Vit129/kouen-terminal/commit/b2b894d8062f1d3a1e8da712805855f5d2dd41eb))

## [2.2.1] - 2026-06-08

### Added
- Fast CWD tracking via lightweight daemon probe (500ms) ([`4ad7c69`](https://github.com/Vit129/kouen-terminal/commit/4ad7c69a70c78cb641f000a75259be304c0ead66))
- Add Search panel in sidebar — file name fuzzy search + content grep ([`361ad4c`](https://github.com/Vit129/kouen-terminal/commit/361ad4c53b26cc0a8a0f3cd50a22c5d134abacf9))

### Documentation
- Update agent-memory with CWD tracking, file preview, crash fixes ([`dcb23d8`](https://github.com/Vit129/kouen-terminal/commit/dcb23d81dd9c40bbf735e9e5a2f18ca2a8ab520e))

### Fixed
- Restore real-time git refresh — DispatchSource watcher on .git dir ([`67c5901`](https://github.com/Vit129/kouen-terminal/commit/67c59018d1146b1623e8e54792d4c47b39db86bd))
- Crash in GitPanelView.startWatching — @MainActor isolation from utility queue ([`3d9b31c`](https://github.com/Vit129/kouen-terminal/commit/3d9b31c51d0c0c8dacdb88415f66740fb541a567))
- GitPanelView watcher crash — bounce to main before accessing self ([`e67bcec`](https://github.com/Vit129/kouen-terminal/commit/e67bcec3f84fec8f0a87fbc3cac9806481a041f7))
- MacOS 26 Swift 6 crash, git diff coloring, file tree perf, preview isolation ([`d218c66`](https://github.com/Vit129/kouen-terminal/commit/d218c66c9e290c8e61a725724e9cca3c558ee772))
- File preview split ratio 40/60 with layout retry fallback ([`da62a18`](https://github.com/Vit129/kouen-terminal/commit/da62a182092b5cda58120951d042a80fbc010e50))
- File preview no longer causes black screen + brighter text ([`444870c`](https://github.com/Vit129/kouen-terminal/commit/444870c3a7d7e52d5f713c882c97fe8143cdb50f))
- Git panel row alignment + redesigned changes list, restore file preview rendering ([`db38262`](https://github.com/Vit129/kouen-terminal/commit/db38262ee2c918a554d929423c88a93b7610003d))
- Sidebar session card now mirrors tab bar (icon + live folder title) ([`deb6396`](https://github.com/Vit129/kouen-terminal/commit/deb63966241e5b60032bf1347c5246c2eba3a01d))

## [1.8.0] - 2026-06-07

### Added
- Add Worktrees tab with add/remove support ([`cc42852`](https://github.com/Vit129/kouen-terminal/commit/cc4285223e26796a4e2fb1c0be4dbf9dbf6d59e4))
- Session ID in sidebar, tab reorder fix, session grouping, hide Agent tab ([`efe06aa`](https://github.com/Vit129/kouen-terminal/commit/efe06aab17fb70a90ae93c0d4da6960889de4375))

### Documentation
- Add agent-memory/knowledge, update memory + user-profile + graphify ([`e78a2b4`](https://github.com/Vit129/kouen-terminal/commit/e78a2b4b5fcc010349cf9bd027925120b580ebaa))

### Fixed
- Resolve correct ACP binary/args per agent kind in Settings ([`f530c88`](https://github.com/Vit129/kouen-terminal/commit/f530c880a2c9a0f56a01556baa38b49a1705287e))
- Resolve GitPanelView merge — use Worktrees version, add clearRoot stub ([`43060e6`](https://github.com/Vit129/kouen-terminal/commit/43060e62c7b70d18e892782a31b3e9a7b1af602b))
- Suppress DECRPM (mode 2026) and Kitty ?u replies to prevent shell echo race ([`7068396`](https://github.com/Vit129/kouen-terminal/commit/706839677ab8b0a1ac6cfa7f343a32f07f6ff53f))
- Stop replying to DECRQM 2026/2027 and Kitty keyboard queries to avoid echo race ([`430b629`](https://github.com/Vit129/kouen-terminal/commit/430b629d53eb86c71349a0aaaacd243fab0e306a))
- Auto-refresh changes view and show commit details on click ([`b3a9145`](https://github.com/Vit129/kouen-terminal/commit/b3a91453348d8370fe4584713d970c28f41f6f99))

## [1.5.1] - 2026-06-06

### Added
- Implement non-blocking async IPC (P2-async) and isolate Prod/Debug/Preview sessions ([`81be588`](https://github.com/Vit129/kouen-terminal/commit/81be58850143b20adff2ae14859ae9bea6b682bb))

### Documentation
- Rewrite README — CMUX + Zed architecture, full feature overview ([`ddd6a30`](https://github.com/Vit129/kouen-terminal/commit/ddd6a3026627f3ffcd1832378c6da72e46c2ad0b))

### Fixed
- Force file tree + git panel refresh on session switch ([`1e0c0eb`](https://github.com/Vit129/kouen-terminal/commit/1e0c0eb31c03198d6090d7460d16596af2cffe5d))
- Crash in GitPanelView.startWatching — @MainActor isolation from utility queue ([`6cafe01`](https://github.com/Vit129/kouen-terminal/commit/6cafe01387bf558ac244e2414788f27248b26ef3))

## [2.2.0] - 2026-06-07

### Documentation
- Update README (graphify, agent-memory, multi-agent sections) + git real-time refresh ([`e320acc`](https://github.com/Vit129/kouen-terminal/commit/e320acc377fd23cd1e1bb3af49f4f2ec1fad949c))

## [2.1.0] - 2026-06-07

### Added
- Decorate file tree git statuses ([`333ae2f`](https://github.com/Vit129/kouen-terminal/commit/333ae2fe5af569eb7b74be4bf3f9b14019d9896c))
- Add clickable commit history panel ([`1909259`](https://github.com/Vit129/kouen-terminal/commit/19092596562e44bda1d2f878284cfcba455814c5))
- Add LSP client package and preview resources ([`d1ccdda`](https://github.com/Vit129/kouen-terminal/commit/d1ccddaa90eb13e9a24df1e3e3c0873898551adb))
- Add syntax and quick look file previews ([`57f9f22`](https://github.com/Vit129/kouen-terminal/commit/57f9f220882b4d682c41561fa277aa5cb4db024b))
- ⌘-click file paths in terminal, branch switcher in Files tab, vi-like edit mode ([`b668123`](https://github.com/Vit129/kouen-terminal/commit/b668123402835f256e8c68e288152186dbe5b489))
- Add harness-mcp (MCP server for AI agents) ([`64a6e8e`](https://github.com/Vit129/kouen-terminal/commit/64a6e8e9d3732025167dd1bafeef1823b5f21edf))
- Add `make install` — build + deploy to /Applications ([`b85508a`](https://github.com/Vit129/kouen-terminal/commit/b85508a744819ed5045a36080d7062cfc117eec3))
- Implement ACP Client — agent chat panel in sidebar ([`392efad`](https://github.com/Vit129/kouen-terminal/commit/392efad6635459465b72cf9ee23d6b4832df980f))

### Documentation
- Update README with v2.0.0 file editor features ([`0bfe02b`](https://github.com/Vit129/kouen-terminal/commit/0bfe02b2312771b1c7a59f262daf880acb1ae335))

### Fixed
- Tab reordering, git branch display prefix, and metadata refresh order check ([`c676011`](https://github.com/Vit129/kouen-terminal/commit/c676011e960c1ba1baed852c528e7d30a96551eb))
- Refine preview isolation and session insertion ([`3299962`](https://github.com/Vit129/kouen-terminal/commit/32999620d40238fbcf5bc3ecbd0de0790f15114d))
- Flip gutter coordinate system, default LSP auto-start off ([`ebff4af`](https://github.com/Vit129/kouen-terminal/commit/ebff4afca16deaadf7a9399af7c8b4e98e38a457))
- Session card title updates dynamically when cwd changes ([`7c26907`](https://github.com/Vit129/kouen-terminal/commit/7c26907d92f98e1d3d54e6885435273f22e542ca))

## [2.0.0] - 2026-06-07

### Added
- Split panel file editor with tabs, syntax, and file ops ([`f5dc30d`](https://github.com/Vit129/kouen-terminal/commit/f5dc30d93c04eb40cbbcaf89bf920165a6c6e617))
- Editable file editor with save, undo/redo, find/replace ([`d6a4502`](https://github.com/Vit129/kouen-terminal/commit/d6a4502fedb6848a8ba40a546f127e396e775d71))
- Vi-like mode (i=insert, Esc=normal) + git diff gutter ([`e18bd2e`](https://github.com/Vit129/kouen-terminal/commit/e18bd2e0b6e8a6e63ed58a89e7b04835aa3c1f89))

### Documentation
- Consolidate completed plans into single archive ([`abca9e3`](https://github.com/Vit129/kouen-terminal/commit/abca9e3c91365b2243de6c2cd42d649e77dce50d))
- Add Terminal First, IDE Convenience philosophy to README ([`78763d2`](https://github.com/Vit129/kouen-terminal/commit/78763d228a5fef64c5ecab92ec9c107a5dc0bc7a))

### Fixed
- Terminal-first split ratio 30/70 (editor is compact panel) ([`202b4c4`](https://github.com/Vit129/kouen-terminal/commit/202b4c441370a423542855f6845a6fbecad69f4d))

## [1.6.0] - 2026-06-07

### Added
- Dynamic branch display per session (A+B) ([`99d161f`](https://github.com/Vit129/kouen-terminal/commit/99d161fcf0dafa0dee7cb261dc9a237091b02c9a))
- Merge dynamic branch display (A+B) ([`f8cce7b`](https://github.com/Vit129/kouen-terminal/commit/f8cce7b02b1b65c8b9cf338e7d9222b3076b9dd6))
- Add read-only file preview to sidebar (P4 Track 1 MVP) ([`64469ab`](https://github.com/Vit129/kouen-terminal/commit/64469abf8966036ce82771f1b257296377812fed))
- Implement right sidebar layout and document current layout issues ([`0301451`](https://github.com/Vit129/kouen-terminal/commit/03014510ae8f8823d9196bd47c792202932e2e61))
- Right-click toggle button shows Move Sidebar Left/Right menu ([`31afcab`](https://github.com/Vit129/kouen-terminal/commit/31afcab2749ad40843fd91e80290c510fef4b01e))

### Documentation
- Add CLAUDE.md developer guide ([`383937d`](https://github.com/Vit129/kouen-terminal/commit/383937df54e6736dff44653ba5912af376275df5))
- Merge CLAUDE.md developer guide ([`f6dc243`](https://github.com/Vit129/kouen-terminal/commit/f6dc24327747b3897863534a3626277b27d3ad50))
- Update playbook (CASE-006 recursion) and P3 plan with progress + cmuxlayer reference ([`a3191f3`](https://github.com/Vit129/kouen-terminal/commit/a3191f33b3f9b6827a07e86816ba3214c73a6072))
- Add AGENTS.md for AI coding agents (Codex/Gemini) ([`5ebd9ec`](https://github.com/Vit129/kouen-terminal/commit/5ebd9ecd661facf57e2d27965fa021325681456d))
- Merge AGENTS.md for AI coding agents ([`57832cd`](https://github.com/Vit129/kouen-terminal/commit/57832cd1a59517edb366d9c7b5d29d3d7f75e51d))
- Update all docs for sidebar toggle fix and split down removal ([`69067cc`](https://github.com/Vit129/kouen-terminal/commit/69067cc03c19fa5834a882e33def2b875f46d569))

### Fixed
- N-ary flatten + recursion guard for equal pane sizing ([`2d701aa`](https://github.com/Vit129/kouen-terminal/commit/2d701aa5e01b35901d233e0ae713b8ddeceb46bb))
- Real-time sidebar position toggle without restart ([`972bb9b`](https://github.com/Vit129/kouen-terminal/commit/972bb9b27e1ff91c56f20cf283c27b8f4c0929be))
- Remove Split Down from all context menus, add Move Sidebar option ([`fcc3c5e`](https://github.com/Vit129/kouen-terminal/commit/fcc3c5e4b230117c7e64c5d2efada0be9c78e95f))

## [1.0.0] - 2026-05-31

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
