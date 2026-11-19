# Changelog Archive

Older releases. See [CHANGELOG.md](../CHANGELOG.md) for recent versions.

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
