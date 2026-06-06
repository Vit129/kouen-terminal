# Changelog

All notable changes to this project will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.2.0] - 2026-06-06

### Added
- **Double-click window zoom & drag** — Enabled full-width window dragging and double-click maximizing/zooming across the entire top panel, including the empty space of the tab bar, the folder path/icon area in the middle of the titlebar, and the sidebar titlebar header region.
- **Grouped sessions options** — Added a context options menu (`...`) on project headers in the sidebar with options such as closing all sessions in the group, alongside disclosure chevrons to expand and collapse groups.

### Changed
- **Sidebar Tabs** — Simplified the sidebar tab navigation to show only "Sessions" and "Files" tabs, hiding the "Git" tab to keep the interface clean and focused.

## [1.1.2] - 2026-06-06

### Added
- **Grouped sessions** — sidebar project groups now render as headers, with a `+` affordance on each header to open a new session in that project root.

### Changed
- README and changelog now describe the grouped session sidebar and the group-header add action.
- Refreshed `graphify-out` artifacts for the current codebase snapshot without committing generated HTML.

### Fixed
- Version metadata is bumped in lockstep across `HarnessVersion.swift` and `Info.plist` for release packaging.

## [1.1.1] - 2026-06-06

### Added
- **Session row close** — session cards now show a `×` close affordance on hover and reuse the existing close-confirmation flow.
- **Run script** — `make run` / `Scripts/run.sh app` now provide one entrypoint for building, packaging, signing, and opening `Harness.app`; `make preview` remains the isolated preview path.

### Fixed
- README IDE sidebar section no longer contains stale merge-conflict markers.
- `HarnessVersion.swift` now matches the app bundle version metadata for packaging.

### Changed
- README quick install keeps developers on `make preview`, while `make run` now opens a production-style app bundle with embedded Sparkle framework.
- Refreshed `graphify-out` navigation artifacts without committed HTML output.

## [1.1.0] - 2026-06-06

### Added
- **Files tab** — SwiftUI rewrite: click folder name to expand/collapse (DisclosureGroup)
- **Files tab** — drag file or folder from tree into terminal pastes shell-quoted path (fixed)
- **Files tab** — lazy child loading on first folder expansion
- **Drag-to-terminal** — image drag support (writes temp PNG, pastes path)
- **Drag-to-terminal** — relaxed operation mask accepts `.generic` / `.every` source masks

### Fixed
- File tree drag-drop broken: removed `registerForDraggedTypes` on NSOutlineView that conflicted with drop routing
- File tree drag-drop broken: removed empty `outlineView.action` that blocked drag initiation
- App crash on launch (macOS 26 beta): `UNUserNotificationCenter.current()` throws during `dispatch_once` init — disabled all `UNUserNotificationCenter` calls in `DesktopNotifier` and `NotificationPermission`; sound fallback preserved

### Changed
- File tree rebuilt in SwiftUI (`List` + `DisclosureGroup`) — replaced 160-line NSOutlineView+delegate implementation with 100-line SwiftUI view
- Desktop notifications disabled on macOS 26 beta (system bug — re-enable when Apple fixes `UNUserNotificationCenter` init)

### Known Issues
- Git tab checkbox stage/unstage not receiving clicks (CASE-001 — needs Xcode View Debugger)
- Desktop notifications unavailable on macOS 26 beta (workaround: sound alert still plays)

## [1.0.0] - 2026-06-05

### Added
- **IDE Sidebar** — Sessions / Files / Git tabs with segmented control
- **Files tab** — project file tree (NSOutlineView) that follows active session cwd
- **Files tab** — right-click Copy Path / Copy Relative Path
- **Files tab** — drag files from tree into terminal to paste shell-quoted path
- **Git tab** — Zed-style Changes / History sub-tabs
- **Git tab** — stage/unstage checkboxes per file, Stage All button
- **Git tab** — commit message area + Commit Tracked button
- **Git tab** — History view with SourceTree-style commit cards (subject + author · time · hash)
- **Git tab** — branch switcher dropdown (click branch name)
- **Git tab** — Fetch ▾ sync dropdown (Fetch / Pull / Push / Force Push)
- **Session-as-tab** — tab bar shows sessions (1 session = 1 project), not tabs within a session
- **Tab bar +** — creates new session
- **Tab bar ✕** — always-visible close button on each tab
- **Sidebar +** — opens Finder to pick project folder for new session
- **Recent projects** — clock button dropdown of last 10 projects, auto-records from active sessions
- **Recent projects** — switches to existing session if project already open
- **Session row ✕** — always-visible close button on sidebar session cards
- **Sidebar toggle** — button appears at left of tab bar when sidebar is closed
- **agent-memory** — project memory system bootstrapped

### Changed
- Version reset to 1.0.0 (build 1) for fork
- README updated with fork links, installation instructions, IDE sidebar docs
- All GitHub links point to Vit129/harness-terminal

### Known Issues
- Git tab checkbox stage/unstage not receiving clicks (CASE-001 — needs Xcode View Debugger)
- File tree click/expand may not work in some layouts (same root cause as CASE-001)
