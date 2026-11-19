# Changelog

All notable changes to Kouen are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and Kouen follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). Each released version
has a matching `vX.Y.Z` tag and a signed, notarized DMG on
[GitHub Releases](https://github.com/Vit129/kouen-terminal/releases).
## [4.24.0] - 2026-11-19

### Added
- Consolidate sidebar projects and add clone and create actions ([`6d1a715`](https://github.com/Vit129/kouen-terminal/commit/6d1a715dc94da46f21aea764786730b1e6777721))
- Consolidate session history in the sidebar ([`dc47c60`](https://github.com/Vit129/kouen-terminal/commit/dc47c60b6b04ed643a1afc68e06b8d3d9522a142))
- Add Review Changes and PR feedback with IPC 15 ([`fd16f5d`](https://github.com/Vit129/kouen-terminal/commit/fd16f5dcde1ba5a584d70d50a15304dcb7deb329))

### Documentation
- Archive older changelog entries ([`5b2bd1f`](https://github.com/Vit129/kouen-terminal/commit/5b2bd1f9907eb4ab162a8913dd50499bc3bd80fd))
- Point agent memory path to unified-memory-vault ([#154](https://github.com/Vit129/kouen-terminal/pull/154)) ([`e675adc`](https://github.com/Vit129/kouen-terminal/commit/e675adc4b4757ff1b5b61a4fe3ecf1593691668a))
- Update project behavior and shortcut references ([`82a78ad`](https://github.com/Vit129/kouen-terminal/commit/82a78adbb4dc3d843c20ca38afce01f2899f13db))

### Fixed
- Bound history storage and close subprocess pipes ([`4abcc79`](https://github.com/Vit129/kouen-terminal/commit/4abcc7911de675dda036b0919a7056814505ff6f))
- Stabilize browser pane navigation and lifecycle ([`7b86569`](https://github.com/Vit129/kouen-terminal/commit/7b865692203b9970c8cd908e1b1f1881a039a7f4))
- Clear synchronized terminal output after SIGINT ([`32f4484`](https://github.com/Vit129/kouen-terminal/commit/32f4484cefe1bca0af7ce9561627ed835d19afcd))
- Run ProcessRunner pipe readers on dedicated threads ([`6591580`](https://github.com/Vit129/kouen-terminal/commit/6591580de4aa04b55ced4e5bc60b7318176263c9))
- Reap PTY children on dedicated threads instead of the GCD pool ([`509bfd7`](https://github.com/Vit129/kouen-terminal/commit/509bfd7873baba8fc84ddfa802add0e709aab73d))


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

## [4.22.16] - 2026-11-15

### Changed
- Arm only for the focused pane, scan off main with carry-over ([`e3630f0`](https://github.com/Vit129/kouen-terminal/commit/e3630f0ff7e2e580131dd0fc503f367d60ba5596))
- Cap network-capture body reads, skip streams and unbounded bodies ([`b340767`](https://github.com/Vit129/kouen-terminal/commit/b340767270243ad059f166ceec1c06f4e81aaf0d))
- Feed coalesced output in capped slices ([`a3436cd`](https://github.com/Vit129/kouen-terminal/commit/a3436cd6a5411d6426b0a45d366c1f0e4a626b1a))
- Skip the 0.5s cwd probe for silent surfaces ([`c10339d`](https://github.com/Vit129/kouen-terminal/commit/c10339d89b5371c05a5baa1cb39839a26a337475))

### Documentation
- Retain verified Kouen query results ([`9521d67`](https://github.com/Vit129/kouen-terminal/commit/9521d67d1ad9b3e796f2b2a930485de45b737ef6))
- Retain wave 1 query result ([`34a8d4e`](https://github.com/Vit129/kouen-terminal/commit/34a8d4edc1f780723b74ffaa9ca9f4144f4af866))

### Fixed
- Preserve staged index when restoring checkpoint ([`8729b55`](https://github.com/Vit129/kouen-terminal/commit/8729b55f585d8522f25ed084098fa7c063a1d0eb))
- Match output triggers split across chunks ([`fc27787`](https://github.com/Vit129/kouen-terminal/commit/fc2778713937bc3f3841c8016393d2150eb439fc))
- Cap console log line length ([`05f5cee`](https://github.com/Vit129/kouen-terminal/commit/05f5ceeacaa189c2b353060578d2441945d775e2))
- Encode typed text as a JSON string literal ([`2f4f7ea`](https://github.com/Vit129/kouen-terminal/commit/2f4f7eae03e54a3d4df3949e8e94584b9bd740ac))
- Stop busy-spinning on a failed read after POLLERR ([`b485e3c`](https://github.com/Vit129/kouen-terminal/commit/b485e3c5f909790ed4525cd279d9ad85703c4a32))
- Preserve output triggers and reject stale secure input scans ([`8cc3b2a`](https://github.com/Vit129/kouen-terminal/commit/8cc3b2ab29d0bcda78a8c3ef5daa8975c5b41f9a))
- Avoid recursive locking during feature sweep ([`90e72de`](https://github.com/Vit129/kouen-terminal/commit/90e72de6d38becd87ba3b7a0d5623c7d8a3b1393))
- Require Bearer authentication and validate HTTP origins ([`5ed642c`](https://github.com/Vit129/kouen-terminal/commit/5ed642caa00ea0f9958e3533d05e1938cf34d885))
- Sanitize markdown and restrict local image access ([`498b90a`](https://github.com/Vit129/kouen-terminal/commit/498b90a077be425b9b63f90ae17ee54fb7118305))
- Drop async replies whose connection is gone ([`552ed79`](https://github.com/Vit129/kouen-terminal/commit/552ed796d76f7fcd4e4510dcafced7bda95ef060))
- Reject malformed or oversized Content-Length before auth ([`488cc7a`](https://github.com/Vit129/kouen-terminal/commit/488cc7ada6f591bb89c21cf2ec7dda61ad5f5f95))
- Clamp waitForLoad timeout before UInt64 conversion ([`d9a74e1`](https://github.com/Vit129/kouen-terminal/commit/d9a74e17e2021aba2673e4f1b3e5694f3f259a4b))
- Ignore stale onEnd after switchEndpoint ([`7173e56`](https://github.com/Vit129/kouen-terminal/commit/7173e5659a2e392d7d4d5419cf83275183d68316))
- Re-attach local browser panes by tab id, not index ([`d6ef9c6`](https://github.com/Vit129/kouen-terminal/commit/d6ef9c6cd4017091549b5cfddd859682ce234121))
- Run worktree git and archive script off the registry lock ([`ab8580d`](https://github.com/Vit129/kouen-terminal/commit/ab8580d14b0d8768a158c273eebb600eef638d27))
- Discard setup log creation result on Linux ([`57aa16e`](https://github.com/Vit129/kouen-terminal/commit/57aa16e5fd7d11bf5f6ce3fda951c90bd1e28b84))

## [4.22.15] - 2026-11-11

### Fixed
- Refresh Graphify before every commit and keep graph in the same commit ([`fb35c00`](https://github.com/Vit129/kouen-terminal/commit/fb35c00477e42624ab8bbd9748c61b5ce6d24ef5))

## [4.22.14] - 2026-11-07

### Fixed
- Read only the log tail so a huge job log no longer spikes app memory ([`d78b1d3`](https://github.com/Vit129/kouen-terminal/commit/d78b1d394925af0d06daa79f673b1fe1797154dc))
- Let make start release from a worktree when only graphify-out is dirty in main ([`69b2665`](https://github.com/Vit129/kouen-terminal/commit/69b266584d82fbd5de81c1c6d58dc27cd5d3620e))

## [4.22.13] - 2026-11-07

### Fixed
- Stop ProcessRunner.run from blocking forever on an open pipe ([`a530bcb`](https://github.com/Vit129/kouen-terminal/commit/a530bcb69c1e78e64f2db78a40b3ab573467e5f8))

## [4.22.12] - 2026-11-06

### Documentation
- Record that the fleet/tab-bar memory guards have landed ([`29e70e0`](https://github.com/Vit129/kouen-terminal/commit/29e70e0d012d61a5fcc601f1fe2e0c52cfd102bc))
- Record that the fleet/tab-bar memory guards have landed ([`39549c8`](https://github.com/Vit129/kouen-terminal/commit/39549c85e878b5ea644b184e885606fa811566fb))

### Fixed
- Stop fleet/tab-bar republishing on unchanged snapshots ([`8901aa8`](https://github.com/Vit129/kouen-terminal/commit/8901aa880b0a53ebca0f2f85b4838bed4493f5a3))
- Stop fleet/tab-bar republishing on unchanged snapshots ([`debca87`](https://github.com/Vit129/kouen-terminal/commit/debca874c4acfc3ea930a1c4399307f46be77fd9))
- Drain autoreleased JSON per transcript during history scans ([`acfab00`](https://github.com/Vit129/kouen-terminal/commit/acfab003895e646bb5c15d0b22c938c12df9cf6e))
- Release memory during history scans ([`b004679`](https://github.com/Vit129/kouen-terminal/commit/b004679a9db62ca88b43351323ca085f1b639cf5))

## [4.22.11] - 2026-11-03

### Fixed
- Session history about searching (release v4.22.11) ([`f015b6f`](https://github.com/Vit129/kouen-terminal/commit/f015b6f85a13678c5e61a1d5d6529ba8c47ea47a))

## [4.22.10] - 2026-11-02

### Fixed
- Stop black panes and make tab switching reliable (release v4.22.10) ([`6d014ba`](https://github.com/Vit129/kouen-terminal/commit/6d014ba7e5a7be15676ed159c54031061980b502))

## [4.22.9] - 2026-11-01

### Documentation
- State the real reason the build number must not roll back ([`e3caa30`](https://github.com/Vit129/kouen-terminal/commit/e3caa30ce55ef1a391783a227c069ce24ceeb2d9))

### Fixed
- Label generated release notes with the release tag ([`7ea98c3`](https://github.com/Vit129/kouen-terminal/commit/7ea98c34a581cd7bc3222b101a592ac43104c90b))
- Opt web views out of Extensible SSO so navigation cannot hang on AppSSO ([`780b5b8`](https://github.com/Vit129/kouen-terminal/commit/780b5b8eade7ee732b258cc7183cd966d7932248))

## [4.22.8] - 2026-10-31

### Fixed
- Generate GitHub release notes from HEAD, not the not-yet-created tag ([`4f48ebd`](https://github.com/Vit129/kouen-terminal/commit/4f48ebdc727f5d434c6cc9c83a0bfe8f1f9198ab))
- Keep CFBundleVersion above every build ever shipped ([`35c0fc2`](https://github.com/Vit129/kouen-terminal/commit/35c0fc205d267024bedab2cea14dfedea18b166b))

## [4.22.7] - 2026-10-30

### Fixed
- Refuse a version build that rolls backwards ([`3679c49`](https://github.com/Vit129/kouen-terminal/commit/3679c49ae2eb7d8604c924cd7777a55fdb0a37eb))
- Keep the live browser pane on cmd+B and fully dispose panes on close ([`a1a40e1`](https://github.com/Vit129/kouen-terminal/commit/a1a40e194325ba6c028281b287430ca8a63093fc))

## [4.22.6] - 2026-10-30

### Fixed
- Stop agent launches from opening the Companion in Chrome ([`84c809f`](https://github.com/Vit129/kouen-terminal/commit/84c809fd02a225ab244038232c2c74c705e865f7))
- Release browser panes when closed ([`81d1cfc`](https://github.com/Vit129/kouen-terminal/commit/81d1cfc798d793d9fb757de73fac0b8af5a5dd3a))

## [4.22.4] - 2026-10-29

### Fixed
- Ensure full-width webview layout, progress completion, and graceful install quit timeout ([`b03d6d3`](https://github.com/Vit129/kouen-terminal/commit/b03d6d3d0acce8bc607ecaf0ab6721a4afe44399))

## [4.22.3] - 2026-10-29

### Added
- Auto-expand revealed directories and add pasted images section ([`2473a54`](https://github.com/Vit129/kouen-terminal/commit/2473a54736b553bafecf66051ee07dfcd5f958d4))

### Documentation
- Record lesson on WKWebView transparent repaint and compositor waking ([`b0c0d6b`](https://github.com/Vit129/kouen-terminal/commit/b0c0d6b8589e32a63682d01cc7cf31933ec93a8d))

### Fixed
- Stop ScriptingTests crashing/flaking so the full suite is green ([`16860d7`](https://github.com/Vit129/kouen-terminal/commit/16860d70e55741e0d82659c152aeb9992cc5032e))
- Wake compositor on window attach and commit to prevent black screen ([`67f2b45`](https://github.com/Vit129/kouen-terminal/commit/67f2b459493c1214cebfbae829ec374415f21aa1))
- Resolve compositor kick drop, sidebar reveal race, and main-thread I/O ([`6febe9b`](https://github.com/Vit129/kouen-terminal/commit/6febe9b31765abdb3430e8f0a3a96a36c49cca05))

## [4.22.2] - 2026-10-26

### Fixed
- Resolve ProcessRunner regressions in timeouts, output draining, and async concurrency ([`993bfd9`](https://github.com/Vit129/kouen-terminal/commit/993bfd904a44a038f90af64a84009418fb82facd))

## [4.22.1] - 2026-10-25

### Changed
- Complete Dev-QA pattern (ProcessRunner, ratchet G3 to 0, Rule 2/3 guards, layered test tags) ([`ca7164d`](https://github.com/Vit129/kouen-terminal/commit/ca7164d78d0f1dea08820cd629ed607d3027ee52))

## [4.22.0] - 2026-10-25

### Changed
- Establish QA architecture guard and extract KouenGit package ([`f6b40e3`](https://github.com/Vit129/kouen-terminal/commit/f6b40e3a4fa50d9213372217d215fc400ba8c013))
- Extract KouenCompositor, eliminate onboarding fork, and purify design token logic ([`2c7640f`](https://github.com/Vit129/kouen-terminal/commit/2c7640f91ac5b1f2a4e58970be4e511d8f12c4a3))
- Decouple MainSplitViewController from GitPanelView and hoist pure parsers to KouenGit ([`f6400a0`](https://github.com/Vit129/kouen-terminal/commit/f6400a0311e6b87b62fed831f45d8a22d6da647e))
- Purify KouenIPC, extract MobileBridge web assets, and unify Layer 2 tokens ([`c95e9eb`](https://github.com/Vit129/kouen-terminal/commit/c95e9ebacb742b0baa9753aa5187303bf3e686fa))

### Documentation
- Update copyright notice with co-authors ([`91f453d`](https://github.com/Vit129/kouen-terminal/commit/91f453da74f44ee2dcb124c7b208401dde43989d))

### Fixed
- Resolve claude audit findings (swiftui font import, git background execution, worktree lock parsing) ([`aa779fb`](https://github.com/Vit129/kouen-terminal/commit/aa779fb3290760aac55b46fb2316c6da05b1a80b))

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

