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
| Dev iteration | `make start` → `Preview build` (or `make start 2`) |
| Release (with bump) | `make start` → `Full cycle` → patch / minor / major |
| Release (no bump) | `make start` → `Full cycle` → skip |
| AI / Non-interactive Commit | `make start 1 msg="<message>"` (or `COMMIT_MESSAGE="..." make start 1`) |
| AI / Non-interactive Release | `make start patch msg="<message>" y=1` (or `COMMIT_MESSAGE="..." make start 3 minor y=1`) |

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

## Graphify before every delivery commit

Normal commit+push, full-cycle (including skip), direct version bump, and final changelog commits await `Scripts/graphify-commit.sh` after the last source/version edits. Refresh failures stop before commit/push. Tracked graph artifacts join the product/version files in the same commit; untracked queries/caches remain local. `GRAPHIFY_SKIP_HOOK=1` suppresses only the redundant post-commit Graphify refresh. Other Git hooks still run. A dirty main checkout, including graph edits, blocks worktree release rather than being discarded.

The Git panel's commit and Commit & Push actions use the daemon's `GitCommitCommand` preparation, including on other graphified repositories. The daemon stops before Git on refresh failure; Push of already committed history does not create a new commit.
