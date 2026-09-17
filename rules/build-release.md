# Build, Release & Git Workflow

## Build / Test / Run

| Command | What it does |
|---------|-------------|
| `make preview` | Isolated preview build (own bundle id, socket, state) — dev use |
| `make prod` | Release build, signs, opens `Kouen.app` at repo root |
| `make run` | Re-open existing `Kouen.app`, no rebuild |
| `make install-graceful` | Release build, graceful copy to `/Applications/Kouen.app` (preserves session layout; quits/relaunches Kouen) |
| `swift build --product Kouen` | GUI app only |
| `swift test` | Full test suite |
| `swift test --filter <name>` | Filtered test |
| `Tests/robot/run.sh` | Run BEFORE every build — regression invariants |
| `EXPORT_THEMES=1 swift test --filter ThemeCatalogEmbedTests` | Regenerate `BundledThemesData.swift` after theme edits |

**Release entry point: always `make start`** — never bump version manually.

| Flow | Command |
|------|---------|
| Dev iteration | `make start` → `Preview build` |
| Release (with bump) | `make start` → `Full cycle` → patch / minor / major |
| Release (no bump) | `make start` → `Full cycle` → skip |

Full cycle: verify → bump → commit+push → prod → CHANGELOG → tag → GitHub release → install.

**Version sync rule** — these 4 files must always match. `prepare-release.sh` updates all 4 atomic — never edit one alone:
- `Apps/Kouen/Sources/KouenApp/Resources/Info.plist` (`CFBundleShortVersionString` + `CFBundleVersion`)
- `Packages/KouenCore/Sources/KouenCore/KouenVersion.swift` (`short` + `build`)
- `Packages/KouenCore/Sources/KouenCore/ReleaseNotes/GeneratedReleaseNotes.swift` (via `make release-notes`)
- `CHANGELOG.md` (via `git-cliff --tag vX.Y.Z`)

**Git hooks**: `.githooks/commit-msg` blocks Info.plist in non-version commits. Activate after clone: `git config core.hooksPath .githooks`

## Release packaging order

`dmg`/`sign`/`finalize` operate on existing `Kouen.app` — wrong order rebuilds away signature.

## Worktree constraint

No worktree nested inside `.kouen-worktrees/`: never `git worktree add` a path under an existing `.kouen-worktrees/<name>` checkout. Create new worktrees only from the main repo root (`~/Git/Personal/kouen-terminal/.kouen-worktrees/<new-name>`), never from inside another worktree.
