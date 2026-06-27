# harness-terminal — Claude Instructions

## Session Start

- Continuation → read `agent-memory/CONTEXT.md` → invoke `macos-swiftui` skill
- Code navigation → `graphify-out/GRAPH_SUMMARY.md`
- Bug/pattern → `grep -rn "<keyword>" agent-memory/knowledge/cases/ agent-memory/MEMORY.md`

## Skills

AppKit/SwiftUI/macOS → `macos-swiftui` | debugging → `debug-mantra` | review → `review-personas`

## Build / Test / Run

| Command | What it does |
|---------|-------------|
| `make preview` | Isolated preview build (own bundle id, socket, state) — use for dev |
| `make prod` | Release build → signs → opens `Harness.app` at repo root |
| `make run` | Re-open existing `Harness.app` without rebuilding |
| `make install` | Release build → copy → `/Applications/Harness.app` |
| `swift build --product Harness` | GUI app only |
| `swift test` | Full test suite |
| `swift test --filter <name>` | Filtered test |
| `Tests/robot/run.sh` | **Run BEFORE every build** — regression invariants |
| `EXPORT_THEMES=1 swift test --filter ThemeCatalogEmbedTests` | Regenerate `BundledThemesData.swift` after theme edits |

**Release entry point: always `make start`** — never bump version manually.

| Flow | Command |
|------|---------|
| Dev iteration | `make start` → `Preview build` |
| Release (with bump) | `make start` → `Full cycle` → patch / minor / major |
| Release (no bump) | `make start` → `Full cycle` → skip |

Full cycle does: verify → bump → commit+push → prod → CHANGELOG → tag → GitHub release → install.

**Version sync rule** — these 4 files must always match. `prepare-release.sh` updates all 4 atomically; never edit one alone:
- `Apps/Harness/Sources/HarnessApp/Resources/Info.plist` (`CFBundleShortVersionString` + `CFBundleVersion`)
- `Packages/HarnessCore/Sources/HarnessCore/HarnessVersion.swift` (`short` + `build`)
- `Packages/HarnessCore/Sources/HarnessCore/ReleaseNotes/GeneratedReleaseNotes.swift` (via `make release-notes`)
- `CHANGELOG.md` (via `git-cliff --tag vX.Y.Z`)

**Git hooks**: `.githooks/commit-msg` blocks Info.plist in non-version commits. Activate after clone: `git config core.hooksPath .githooks`

## Non-obvious Constraints

- **Swift 6 strict concurrency**: `HarnessCore` + `HarnessTerminalEngine` use `-warnings-as-errors` — concurrency/deprecation warnings = build failures.
- **`@unchecked Sendable`**: `DaemonClient`, `DaemonServer`, `SurfaceRegistry`, `RealPty`, `DaemonLauncher`, `SurfaceIO`, `InputGate`, `SSHTunnelManager` — preserve lock/queue ownership.
- **Terminal output replay**: `TerminalHostView` uses `DispatchQueue.main.async` + `MainActor.assumeIsolated` to preserve FIFO byte order. `Task { @MainActor in }` can reorder bursty output.
- **IPC framing**: control = 4-byte big-endian length-prefixed JSON. PTY hot path = binary magic `0xF5` (output) / `0xF6` (input). New binary frame type needs version gate — old readers drop connection on unknown magic.
- **ACP shelved**: Agent sidebar + Chat toggle commented out. Code intact for re-enablement.
- **`IPCCodec.maxPayloadLength`**: 16 MiB.
- **Daemon socket**: owner-only `0600`, rejects peers with different uid.
- **`CharacterWidthTable.swift`**: generated + committed. Regenerate via `Scripts/generate-width-table.swift` if `CharacterWidth.swift` changes.
- **`themes.json`**: excluded from SwiftPM build. Regenerate `BundledThemesData.swift` with theme export test.
- **Release packaging order**: `dmg`/`sign`/`finalize` operate on existing `Harness.app` — wrong order rebuilds away the signature.

## Graphify

```bash
graphify query "..."        # first nav layer
graphify path "A" "B"       # dependency path
graphify explain "concept"
graphify update . && ~/.claude/scripts/generate-graph-summary.sh .
```
