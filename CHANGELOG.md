# Changelog

All notable changes to Kouen are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and Kouen follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). Each released version
has a matching `vX.Y.Z` tag and a signed, notarized DMG on
[GitHub Releases](https://github.com/Vit129/kouen-terminal/releases).
## [4.18.0] - 2026-09-21

### Added
- Release version bump to v4.18.0.

## [4.17.3] - 2026-09-19

### Added
- Add context resolve MCP tool, fix process (release v4.17.3) ([`1f8b873`](https://github.com/Vit129/kouen-terminal/commit/1f8b873df611dda29aca7e4bb42432684256f9ec))

## [4.17.2] - 2026-09-18

### Added
- Implement Phase 0 AI-SDLC workflow engine and worktree discipline ([`6b043ee`](https://github.com/Vit129/kouen-terminal/commit/6b043ee84792f23a74c8dbd96fe583ed2904d48d))
- Auto markdown sync, GUI preview, and MCP feature tools ([`61161d1`](https://github.com/Vit129/kouen-terminal/commit/61161d1318710edd9d986074693f1961643f09bc))
- Add session history phase 1, centralize logic search, centralize logo and ai provider name, fast context and token guard phase 2 (release v4.17.2) ([`15900dd`](https://github.com/Vit129/kouen-terminal/commit/15900dd84ea48effc5dd8070f57002a629cb7936))

### Fixed
- Restore green test suite and update graphify index ([`ed9f1ac`](https://github.com/Vit129/kouen-terminal/commit/ed9f1acd6ac82c00046aabddc6deb623a9e1c570))

## [4.17.1] - 2026-09-18

### Fixed
- Automation tab coding just show cron job only (release v4.17.1) ([`3d42f36`](https://github.com/Vit129/kouen-terminal/commit/3d42f36a2e8f35885d014531a6ff02a82ab1412a))

## [4.17.0] - 2026-09-18

### Added
- Add jobs fleet view and multi-format result viewer replacing git panel (release v4.17.0) ([`786ee2a`](https://github.com/Vit129/kouen-terminal/commit/786ee2a93ecc74b7f113f8602307d12d91136208))

### Documentation
- Standardize ARCHITECTURE.md and CONTEXT.md per workspace rules ([`0a47025`](https://github.com/Vit129/kouen-terminal/commit/0a4702536af688b162da0dfa54fa5ae360d1bf5e))
- Split CLAUDE.md into rules/, consolidate to AGENTS.md ([`99614f0`](https://github.com/Vit129/kouen-terminal/commit/99614f0c21f3ba7ea52445c998258b06142ae9be))

### Fixed
- Reset markdown/code edit-mode per file, not sticky across tabs ([`747bf50`](https://github.com/Vit129/kouen-terminal/commit/747bf50762f5f7e02b5b881e2810e3e08c6adae1))
- Never leave markdown preview blank on a JS render failure ([`3aff6e9`](https://github.com/Vit129/kouen-terminal/commit/3aff6e96232435f0e3e6a06a6e12b32bfefd6188))
- Markdown preview render completely broken since v4.15.8 ([`eb575b4`](https://github.com/Vit129/kouen-terminal/commit/eb575b453e6ef18d22f51eed00a172fc241d01be))

## [1.3.0-vit] - 2026-06-06

### Added
- Complete inception phases for ACP (Agent Client Protocol) feature ([`bba93bf`](https://github.com/Vit129/kouen-terminal/commit/bba93bfce514eaed1f5a2133dc287fce240cc1f7))
- Implement ACP core transport and process (Phase 1) ([`1df08b0`](https://github.com/Vit129/kouen-terminal/commit/1df08b08ccf7ea45d531836e53819e84adb83fbf))
- Sidebar tab switcher + file tree outline view (Phase 1) ([`c790a64`](https://github.com/Vit129/kouen-terminal/commit/c790a6433cfad7db285c1673b8e5bc62ce7c94c1))
- Replace NSOutlineView file tree with SwiftUI List + onDrag ([`b2c0da4`](https://github.com/Vit129/kouen-terminal/commit/b2c0da48582170f6b4112e885a590f2bc6ab28b6))
- SwiftUI file tree with onDrag ([`56e18da`](https://github.com/Vit129/kouen-terminal/commit/56e18dab957cdfb501de6daad66e874ff1bf95ea))
- SwiftUI file tree - DisclosureGroup expand + lazy load + onDrag ([`b424989`](https://github.com/Vit129/kouen-terminal/commit/b4249891d4643fa5c983b1d63807a17087f8353b))
- Session group expand/collapse, right-aligned action buttons, and close group option ([`0e48c46`](https://github.com/Vit129/kouen-terminal/commit/0e48c464f6ae9dcccb3918ed10fa6498996a64ad))
- Hide Git tab in the sidebar, keeping Sessions and Files tabs ([`f841736`](https://github.com/Vit129/kouen-terminal/commit/f8417364abac622c94cc0b50d7a173425923d70a))
- Wire FSEvents live watcher into file tree view ([`c53b115`](https://github.com/Vit129/kouen-terminal/commit/c53b11570b87acb583cf3c2554d00c0c2b8b5435))
- Add full native support for antigravity/agy and update performance docs ([`f2aced8`](https://github.com/Vit129/kouen-terminal/commit/f2aced8199d7e904b118344e5c4f2cacf8fa5df4))

### Changed
- Panel & session performance fixes + file tree git status ([`c3db2d5`](https://github.com/Vit129/kouen-terminal/commit/c3db2d5fd6f05586cc4c2e4931a1ad8a0f5e672d))

### Documentation
- Add IDE sidebar feature README ([`1f04e7b`](https://github.com/Vit129/kouen-terminal/commit/1f04e7bfe259c04a0a15160830be9f23f65e425b))
- Add CHANGELOG.md for v1.0.0 ([`583fbe8`](https://github.com/Vit129/kouen-terminal/commit/583fbe866e82ac06e7636e1ad6acb222e3216adb))
- Add fork attribution to README ([`1cb5051`](https://github.com/Vit129/kouen-terminal/commit/1cb5051222c7135d9e335aacc97595612f8f8cd6))
- Remove non-working features and git clone from README ([`3c02d60`](https://github.com/Vit129/kouen-terminal/commit/3c02d60ce5ee7ca7b42be0012d747482f4dabdee))
- Add IDE Sidebar section covering Session, Files, and Git panels ([`4ad5a80`](https://github.com/Vit129/kouen-terminal/commit/4ad5a80c6d256833146899f3d02718c87e73cab8))
- Update README + CHANGELOG for v1.1.0 ([`2dab4d4`](https://github.com/Vit129/kouen-terminal/commit/2dab4d4388bee70f119e99c1d339c288127a9482))
- Add panel & session performance + file tree auto-update plan ([`02c69e3`](https://github.com/Vit129/kouen-terminal/commit/02c69e3e72ca49564093933bebafaa9ec328f2cf))
- Update panel-session-performance plan — mark P1/P3-P6/F1A-F1F done, note F1-G and P2 pending ([`4c9d780`](https://github.com/Vit129/kouen-terminal/commit/4c9d780386c5d70de74d315f2e5de71b72fd976b))

### Fixed
- Restore drag-drop to terminal + add image drag support ([`461bb79`](https://github.com/Vit129/kouen-terminal/commit/461bb79aaf6b8b56b5c5a9947fd2821c33c26316))
- Drag-drop to terminal (files, folders, images) ([`a6c6217`](https://github.com/Vit129/kouen-terminal/commit/a6c62176daefcb35948bc19bb35eeae5644670ed))
- Remove action selector that blocked drag initiation in file tree ([`7a68a07`](https://github.com/Vit129/kouen-terminal/commit/7a68a074fa5ca4d0341c3bc067cde118b08d1af0))
- Remove action selector that blocked drag initiation in file tree ([`f6789dd`](https://github.com/Vit129/kouen-terminal/commit/f6789dd5c487fa2fd8ba62dc78d9ea41bba78f6c))
- Single-click folder expands/collapses in file tree ([`fd5632b`](https://github.com/Vit129/kouen-terminal/commit/fd5632b384109329d0ef38e760f4b1dc05e5fac9))
- Merge drag-drop + folder click fixes from worktree ([`7c4c71a`](https://github.com/Vit129/kouen-terminal/commit/7c4c71a189c45b39d9b4c000db17f62ae7e4a13a))
- Defer UNUserNotificationCenter init to avoid macOS 26 launch crash ([`017bff7`](https://github.com/Vit129/kouen-terminal/commit/017bff7c160ea6acb9bcd76128117c3c3b8dafdb))
- Merge notification crash fix ([`18f3470`](https://github.com/Vit129/kouen-terminal/commit/18f3470318366737289b06cb0488481560d32a49))
- Disable UNUserNotificationCenter to avoid macOS 26 launch crash ([`fc4c117`](https://github.com/Vit129/kouen-terminal/commit/fc4c117090797eac1e53b86f04fab83e862048f9))
- Disable desktop notifications for macOS 26 compatibility ([`ddd9341`](https://github.com/Vit129/kouen-terminal/commit/ddd93413b3ee303506e48d8d4f39e0645d61dc59))
- Show empty state when no repo; surface git errors via alert ([`993cdcb`](https://github.com/Vit129/kouen-terminal/commit/993cdcb2a5fe79dc7b3a7b3378c58613c4b25c23))
- Disable NotificationPermission UNUserNotificationCenter calls on macOS 26 ([`f6f8be0`](https://github.com/Vit129/kouen-terminal/commit/f6f8be038c510dfbf117fcee9a4fd311b4967b09))
- Pre-load first-level children so List(children:) tree structure renders correctly ([`9fe4748`](https://github.com/Vit129/kouen-terminal/commit/9fe474891e7126ee507e77cb3dec9b82fa61b902))
- Notification crash + file tree expand ([`3ecec6e`](https://github.com/Vit129/kouen-terminal/commit/3ecec6e251cd5622183095f5389b6ffba2326601))
- Use DisclosureGroup so folder label click expands/collapses + lazy child loading ([`b2e152e`](https://github.com/Vit129/kouen-terminal/commit/b2e152eab2ef49f6467bccac29d2ff482a97407f))
- Folder expand/collapse in SwiftUI file tree ([`a3dd841`](https://github.com/Vit129/kouen-terminal/commit/a3dd841ac1524ebd664b1556bb7c3f09546afd36))
- Folder expand/collapse ([`56373ff`](https://github.com/Vit129/kouen-terminal/commit/56373ff0b661a538266b18fb9fb88801ebf2cf2c))
- Make top bar zoom instant ([`6f441eb`](https://github.com/Vit129/kouen-terminal/commit/6f441ebba4089ffa2fadecc6b865110e0d1b2be7))
- Make window zoom on double-click work across the entire top panel (tab bar and sidebar titlebar header) ([`2734062`](https://github.com/Vit129/kouen-terminal/commit/2734062137922608d0d813dfaf78e86f9ccb7aa6))

