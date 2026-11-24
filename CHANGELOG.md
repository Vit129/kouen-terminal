# Changelog

All notable changes to Kouen are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and Kouen follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). Each released version
has a matching `vX.Y.Z` tag and a signed, notarized DMG on
[GitHub Releases](https://github.com/Vit129/kouen-terminal/releases).
## [4.24.2] - 2026-11-22

### Changed
- Remove embedded AI-SDLC from Kouen ([`545c371`](https://github.com/Vit129/kouen-terminal/commit/545c37159e2cc30d5e68df3dbf443a62c7012745))

### Fixed
- Discover the shared memory vault in file search ([`89ca0f4`](https://github.com/Vit129/kouen-terminal/commit/89ca0f46ff1cde7ba2a3417e22161d02f4133619))

## [4.24.0] - 2026-11-19

### Added
- Consolidate sidebar projects and add clone and create actions ([`7c6582a`](https://github.com/Vit129/kouen-terminal/commit/7c6582ad865d773db55d91d16963425a4f2df346))
- Consolidate session history in the sidebar ([`c92eea4`](https://github.com/Vit129/kouen-terminal/commit/c92eea424d64ab968b27931d8a8273883b8b0c57))
- Add Review Changes and PR feedback with IPC 15 ([`86894bc`](https://github.com/Vit129/kouen-terminal/commit/86894bc5607404e497b52e380f4725dfc00194ac))

### Documentation
- Archive older changelog entries ([`5b2bd1f`](https://github.com/Vit129/kouen-terminal/commit/5b2bd1f9907eb4ab162a8913dd50499bc3bd80fd))
- Point agent memory path to unified-memory-vault ([#154](https://github.com/Vit129/kouen-terminal/pull/154)) ([`e675adc`](https://github.com/Vit129/kouen-terminal/commit/e675adc4b4757ff1b5b61a4fe3ecf1593691668a))
- Update project behavior and shortcut references ([`5543a3f`](https://github.com/Vit129/kouen-terminal/commit/5543a3f3c6b9548065087070e05615ffdb291217))

### Fixed
- Bound history storage and close subprocess pipes ([`50bfba3`](https://github.com/Vit129/kouen-terminal/commit/50bfba325b4f52c21d95a2d2040038aef187f666))
- Stabilize browser pane navigation and lifecycle ([`c509d36`](https://github.com/Vit129/kouen-terminal/commit/c509d366be568a08f8bac3c147168224624205fb))
- Clear synchronized terminal output after SIGINT ([`5c7c1ae`](https://github.com/Vit129/kouen-terminal/commit/5c7c1aef7c1e6f5354b4392b4c6e1d155ccff0bc))
- Run ProcessRunner pipe readers on dedicated threads ([`eb25258`](https://github.com/Vit129/kouen-terminal/commit/eb25258fdc2b820c6b66a03c7fa05ea0c6efc1af))
- Reap PTY children on dedicated threads instead of the GCD pool ([`1c69f3c`](https://github.com/Vit129/kouen-terminal/commit/1c69f3cd0489e852d732b6c45fdbf25b562c10fa))

## [4.23.2] - 2026-11-18

### Added
- Simplify project workspace navigation ([`9964ff2`](https://github.com/Vit129/kouen-terminal/commit/9964ff2c998c720be84439d67b5b7e3355e05d1a))
- Streamline workspace and history navigation ([`2f767e5`](https://github.com/Vit129/kouen-terminal/commit/2f767e528f70e00e77d9d6dbf82458e5374128ec))
- Streamline project and history navigation (release v4.23.2) ([`9b8d21e`](https://github.com/Vit129/kouen-terminal/commit/9b8d21e541ce1eb745f46d53bbf5679530ca0eea))

## [4.23.1] - 2026-11-17

### Added
- Improve session history and agent shortcuts (release v4.23.1) ([`c97d980`](https://github.com/Vit129/kouen-terminal/commit/c97d980e6f19d309e1caa3f102905ed85cf4d81c))

## [4.23.0] - 2026-11-17

### Added
- Let users hide the menu bar icon ([`45fb779`](https://github.com/Vit129/kouen-terminal/commit/45fb7790ae2253097e02a900793ccf5be2d58e8e))

### Changed
- Brief 2 hot-path fixes (fingerprint, cwd probe, debounced commits, task request sharing, git refresh gate, dock badge, spool cap) ([`078177e`](https://github.com/Vit129/kouen-terminal/commit/078177e9c5f3388c1d9a1e4a0c53c0bb573eaf3e))
- Tear down LSP on editor hide, reuse client, bounded shutdown, cached graph lookup ([`330fd2e`](https://github.com/Vit129/kouen-terminal/commit/330fd2e8c64f8cbe5ecb7d2229d369958c680e47))
- Release markdown webview/QuickLook when hidden, skip redundant symbol scan, cheaper dirty check, cached regexes ([`f956e0e`](https://github.com/Vit129/kouen-terminal/commit/f956e0edfa3244ed8dd4178e154a02cd632b5b87))
- Drop bad stdio frames and cap sizes, shell timeout and output cap, readFile cap, SSE parked wait and request deadline ([`18139ff`](https://github.com/Vit129/kouen-terminal/commit/18139ff5561cead7f42229d5bd332422efcc149f))
- Finish incremental history and resource lifecycle fixes ([`700a303`](https://github.com/Vit129/kouen-terminal/commit/700a3034ac7da45e77660d5c96cb74ca9f42543f))
- Improve performance and responsiveness (release v4.23.0) ([`c12b800`](https://github.com/Vit129/kouen-terminal/commit/c12b800bc538d9c5f90363a9e128bd58c1550fca))

### Fixed
- Stream JSONL parsing and bound history scan memory ([`c7dbda6`](https://github.com/Vit129/kouen-terminal/commit/c7dbda6aaa52321c1600d4bb229766c23bab70bb))
- Keep real exit code on truncated output; drain grace after exit ([`23bdec8`](https://github.com/Vit129/kouen-terminal/commit/23bdec8f13d135d990aaa886b593245bac984313))
- Allow runCommand up to 600s; keep 120s for quick helpers ([`764b95c`](https://github.com/Vit129/kouen-terminal/commit/764b95c167b3524fd4956eb302082021daf70803))
- Bound terminal image retention and release idle buffers ([`70cfbbc`](https://github.com/Vit129/kouen-terminal/commit/70cfbbcf86a4d051d44d4f444a4522894837312b))
- Bound SSH socket detection and notch state retention ([`f0fb764`](https://github.com/Vit129/kouen-terminal/commit/f0fb76428d3f88dfd06abb05c8b8a158cba92e9f))
- Release resources when panes close ([`e36acbf`](https://github.com/Vit129/kouen-terminal/commit/e36acbfbc69faf0e9b18b8f4cfc177f2d44c71ff))
- Isolate pairing loop wakeups across restarts ([`8a1a640`](https://github.com/Vit129/kouen-terminal/commit/8a1a6402f458f599d46fb0b012e0e020b0fdc09b))
- Linux build of history index and stale release-notes digest ([`0e471e6`](https://github.com/Vit129/kouen-terminal/commit/0e471e66550f803dee702b71c7288fb8720f0d06))
- Autoreleasepool shim for Linux history scanner ([`28f2c1e`](https://github.com/Vit129/kouen-terminal/commit/28f2c1ef2bce62af7d9f9b9dffc241e695bd2cd8))
- Keep agy turn helpers outside the SQLite3 guard ([`6611167`](https://github.com/Vit129/kouen-terminal/commit/66111672ff4109ed85f3bac140d4a190e5576ad8))
- Guard Apple-only MobileBridge files for Linux; widen ProcessRunner timeout margin ([`002e0c7`](https://github.com/Vit129/kouen-terminal/commit/002e0c755e809c8f6402c34dd0905e9c7bd71f09))
- Guard TranscriptFileWatcher tests for Linux ([`234b886`](https://github.com/Vit129/kouen-terminal/commit/234b886bafeaea9a612b24c3239e073d1c9f1d3d))
- Skip SQLite-FTS history tests on Linux ([`9d095bc`](https://github.com/Vit129/kouen-terminal/commit/9d095bc37e55eb2d991b2579c8b7d073c98d0b94))
- Disable automatic Graphify in start menu ([`274a772`](https://github.com/Vit129/kouen-terminal/commit/274a772168e001ba335b9e221452cae2fe215bb8))

## [1.3.0-vit] - 2026-06-06

### Added
- Complete inception phases for ACP (Agent Client Protocol) feature ([`14b7abc`](https://github.com/Vit129/kouen-terminal/commit/14b7abce388f819ff95b2fb168fc2fe35ee7c86e))
- Implement ACP core transport and process (Phase 1) ([`d05c266`](https://github.com/Vit129/kouen-terminal/commit/d05c2661bd0d4b0c4949235e9a8392ed1c340549))
- Sidebar tab switcher + file tree outline view (Phase 1) ([`f9e9bc4`](https://github.com/Vit129/kouen-terminal/commit/f9e9bc4dd74ac99eb6fb0972db162dc35ccba1c8))
- Replace NSOutlineView file tree with SwiftUI List + onDrag ([`0b45018`](https://github.com/Vit129/kouen-terminal/commit/0b45018db6206b2df860c8fd5a1ff2fab7305450))
- SwiftUI file tree with onDrag ([`b1b0f01`](https://github.com/Vit129/kouen-terminal/commit/b1b0f012bdeea1e32c54d704cd51719c1454b0ad))
- SwiftUI file tree - DisclosureGroup expand + lazy load + onDrag ([`3fd94ff`](https://github.com/Vit129/kouen-terminal/commit/3fd94ff43b6087cfad24f145ec67a91d56730423))
- Session group expand/collapse, right-aligned action buttons, and close group option ([`0da3eb7`](https://github.com/Vit129/kouen-terminal/commit/0da3eb7506c1322d5d5585867fc86c0d73072312))
- Hide Git tab in the sidebar, keeping Sessions and Files tabs ([`fc41a9f`](https://github.com/Vit129/kouen-terminal/commit/fc41a9f100543e00d38bee5f50db24f6de5f67c6))
- Wire FSEvents live watcher into file tree view ([`4f89128`](https://github.com/Vit129/kouen-terminal/commit/4f891287f0855587f183208f88af08c448cba19e))
- Add full native support for antigravity/agy and update performance docs ([`382deee`](https://github.com/Vit129/kouen-terminal/commit/382deee1a4bd2146c3ff2d033657cfe387c494d3))

### Changed
- Panel & session performance fixes + file tree git status ([`95b29ab`](https://github.com/Vit129/kouen-terminal/commit/95b29ab7ff27804ffb202f2d86576f02a3de5067))

### Documentation
- Add IDE sidebar feature README ([`8c9ed1a`](https://github.com/Vit129/kouen-terminal/commit/8c9ed1a774f96248143ba06f38a4214cabcf3069))
- Add CHANGELOG.md for v1.0.0 ([`157c7ac`](https://github.com/Vit129/kouen-terminal/commit/157c7ac528c843a20640faea795e738c5b14b5a6))
- Add fork attribution to README ([`cc852d7`](https://github.com/Vit129/kouen-terminal/commit/cc852d743dc74b01efd547099765959731ecf0a5))
- Remove non-working features and git clone from README ([`d7c9db3`](https://github.com/Vit129/kouen-terminal/commit/d7c9db3cd2b5bf4e8ebe4a247f7d414aac0d7ed3))
- Add IDE Sidebar section covering Session, Files, and Git panels ([`d927e5a`](https://github.com/Vit129/kouen-terminal/commit/d927e5a3284dc201a53ac4c9b76c16733bbe59d6))
- Update README + CHANGELOG for v1.1.0 ([`2177e0b`](https://github.com/Vit129/kouen-terminal/commit/2177e0ba270ebea407c8b71dc073d5277ae0e6a5))
- Add panel & session performance + file tree auto-update plan ([`6e431b8`](https://github.com/Vit129/kouen-terminal/commit/6e431b8880afe1502bdccd4e49130649d3c414e2))
- Update panel-session-performance plan — mark P1/P3-P6/F1A-F1F done, note F1-G and P2 pending ([`e7b1543`](https://github.com/Vit129/kouen-terminal/commit/e7b1543450ac0d05ef992772a98c2fac4c0f3047))

### Fixed
- Restore drag-drop to terminal + add image drag support ([`86d5b8e`](https://github.com/Vit129/kouen-terminal/commit/86d5b8ea70f953a91bdd75159a7f17e73b42ae8c))
- Drag-drop to terminal (files, folders, images) ([`4645fbf`](https://github.com/Vit129/kouen-terminal/commit/4645fbf4d796a4e6b62674a24d58aaa2678b26ac))
- Remove action selector that blocked drag initiation in file tree ([`d257207`](https://github.com/Vit129/kouen-terminal/commit/d2572073968f33b44f0168256a176abcbcddfe5d))
- Remove action selector that blocked drag initiation in file tree ([`c284241`](https://github.com/Vit129/kouen-terminal/commit/c284241f100ab28654a795ba5c2b45999563e223))
- Single-click folder expands/collapses in file tree ([`23264a2`](https://github.com/Vit129/kouen-terminal/commit/23264a2f8d71b97de68a2852c2bccf5b69e9d071))
- Merge drag-drop + folder click fixes from worktree ([`d7b8371`](https://github.com/Vit129/kouen-terminal/commit/d7b8371c02ea8574e88487d5bf04a5f24105e6e1))
- Defer UNUserNotificationCenter init to avoid macOS 26 launch crash ([`69c90c9`](https://github.com/Vit129/kouen-terminal/commit/69c90c9575429d8d023a4aef65540858634727c1))
- Merge notification crash fix ([`538ec68`](https://github.com/Vit129/kouen-terminal/commit/538ec68763ede23fbc8cf6b33b5db0357a3d88ce))
- Disable UNUserNotificationCenter to avoid macOS 26 launch crash ([`59af77b`](https://github.com/Vit129/kouen-terminal/commit/59af77b9d9558c328b4da8d5ba2e1a227bb01768))
- Disable desktop notifications for macOS 26 compatibility ([`7135acb`](https://github.com/Vit129/kouen-terminal/commit/7135acb47df6232f8047e60178bd209f2b6556be))
- Show empty state when no repo; surface git errors via alert ([`1f5659e`](https://github.com/Vit129/kouen-terminal/commit/1f5659e0b01f2fe367a088e7873dda2cd8ab469d))
- Disable NotificationPermission UNUserNotificationCenter calls on macOS 26 ([`08509c5`](https://github.com/Vit129/kouen-terminal/commit/08509c5e57c76df03ef4a2fa7fc6382a2a1f8e9d))
- Pre-load first-level children so List(children:) tree structure renders correctly ([`d0a592c`](https://github.com/Vit129/kouen-terminal/commit/d0a592c734023713002461d83f41da341b64443e))
- Notification crash + file tree expand ([`1df5b24`](https://github.com/Vit129/kouen-terminal/commit/1df5b24ffb06b66a9d8d8f82d94cb811e63c1690))
- Use DisclosureGroup so folder label click expands/collapses + lazy child loading ([`993b201`](https://github.com/Vit129/kouen-terminal/commit/993b201c92715e0ea332423d177c8b00528936f5))
- Folder expand/collapse in SwiftUI file tree ([`87d62d7`](https://github.com/Vit129/kouen-terminal/commit/87d62d7d28fb5e60d089c214144c9e8d6bf11352))
- Folder expand/collapse ([`b4e4547`](https://github.com/Vit129/kouen-terminal/commit/b4e4547ec71f5ea2cfbe8ea71a80f1a8bb8f1287))
- Make top bar zoom instant ([`0b01ceb`](https://github.com/Vit129/kouen-terminal/commit/0b01cebaf56c5ee179adfe7b7818127304fbc2a9))
- Make window zoom on double-click work across the entire top panel (tab bar and sidebar titlebar header) ([`441525a`](https://github.com/Vit129/kouen-terminal/commit/441525a108abf0d567202ac3827994d208a5162d))

