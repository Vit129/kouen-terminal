# Changelog

All notable changes to this project will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2.0.0] - 2026-06-07

### Philosophy
**Terminal First, IDE Convenience** — Harness is a terminal, not an editor with a terminal panel. Every IDE feature is a shortcut that saves you from typing `cat`, `git status`, or `vim`.

### Added
- **File Editor Panel** — Split panel file viewer in the content area (30% editor, 70% terminal). Click a file in sidebar to preview; terminal stays dominant and fully usable.
- **Vi-like editing** — Files open in read-only mode (like `less`). Press `i` to enter INSERT mode, `Esc` to return to normal mode. `⌘S` to save.
- **Syntax highlighting** — Regex-based highlighting for Swift, TypeScript/JavaScript, Python, Rust, Go, JSON, YAML. Keywords, strings, comments, and numbers colored.
- **Line numbers gutter** — Monospaced line numbers alongside the editor with scroll sync.
- **Git diff gutter** — Colored 3px bars next to line numbers: green (added), yellow (modified), red (deleted). Runs `git diff` async on file load.
- **File tabs** — Open multiple files in tabs with close buttons. Tab bar above editor panel.
- **Quick Look** — Images and PDFs rendered inline (PNG, JPG, GIF, WebP, SVG, PDF).
- **Find & Replace** — `⌘F` for find bar, `⌘⇧F` for find and replace (native macOS NSTextFinder).
- **Undo/Redo** — `⌘Z` / `⌘⇧Z` with full NSTextView undo stack.
- **File tree context menu** — New File, New Folder, Reveal in Finder, Open in Default App, Copy Path, Copy Relative Path, Rename, Duplicate, Move to Trash.
- **Real-time sidebar position toggle** — Move sidebar left/right instantly via View menu or right-click toggle button. No restart required.
- **Right-click sidebar toggle** — Context menu on toggle button and session rows for "Move Sidebar to Left/Right".

### Changed
- **Split Down removed** — Vertical/downward splits removed from all menus, command palette, context menus, keybindings, and documentation. Split Right remains fully functional.
- **UI Polish (P6)** — SF Symbols everywhere, animated disclosure chevrons, `configurePillButton` shared helper, sidebar vibrancy `.sidebar` material, git stage checkbox pulse animation.
- **Git panel toasts** — Progress feedback for fetch/pull/push/stage operations.
- **Metal CADisplayLink fix** — `viewDidMoveToSuperview()` restarts display link on reparent, fixing terminal black screen after split.

## [1.6.0] - 2026-06-07

### Added
- **Right Sidebar support** — Added settings configuration to align the main Sessions/Files sidebar to either the left or right side of the window. Can be toggled via Settings panel under "Window" or via "View" menu ("Move Sidebar to Right" / "Move Sidebar to Left").
- **Dynamic Icons & Insets** — Sidebar toggle button symbols and position constraints dynamically update to match the sidebar alignment (e.g. `sidebar.left`/`sidebar.right`), preventing overlap with traffic lights and other controls.

## [1.5.0] - 2026-06-06

### Added
- **CMUX-style split panes** — Split right with ⌘D, navigate panes with ⌥⌘←→↑↓, close pane with ⌥⇧⌘W. Split buttons (split right + close) appear at top-right corner of each pane.
- **Enhanced Git panel** — Commit ▼ dropdown menu (Commit Tracked, Amend, Signoff). Sync button with per-remote submenus (Fetch From, Pull Rebase, Push To). Auto-switches between "Fetch ▼" and "Push ▼" based on upstream status.

### Changed
- **Removed pane-local surface tabs (S1/S2/S3)** — Replaced broken drag-to-split UX with CMUX-inspired keyboard shortcuts and icon buttons. Each pane is now 1 terminal (no multi-surface per pane).

### Known Issues
- Split down (⌘⇧D) causes terminal to go black (Metal CADisplayLink not re-activated on same-window reparent).
- Split 3+ panes stack to the right (nested binary 50/50). Planned fix: N-ary PaneNode + single NSSplitView with adjustSubviews().

## [1.3.0] - 2026-06-06

### Added
- **Antigravity / agy and Kiro support** — Full native support for the Antigravity agent family (process-tree detection, `agy`/`antigravity` title inference, custom brand color, and the Gemini spark vector brand mark) and the Kiro agent family (process-tree detection, custom brand color, and the official Kiro brand mark in the session UI).
- **File Tree Auto-Update & Git Status** — Integrated real-time FSEvents filesystem watcher for auto-refreshing the file tree on branch switches and file changes. Added Git status color indicators directly in the file tree (yellow for modified, green for untracked, red/strikethrough for deleted).
- **Richer Sidebar UI** — Default session titles now show the active AI agent name (e.g., `Claude Code`, `Codex`, `Antigravity`, `Kiro`), while the subtitle shows the repository name, active Git branch, running command/process, and directory path.
- **Dynamic Session Group Headers** — Enlarged font size/weight of group session names (`13 semibold`) and disclosure chevrons (`15 bold`), with dynamic color highlights on hover (`textSecondary` -> `textPrimary` white).

### Fixed
- **Sidebar Reload Performance (P1)** — Cached row calculations to eliminate O(N²) calculations during table reload.
- **O(1) Surface/Tab Registry Lookup (P3)** — Added `surfaceIndex` flat map dictionary to bypass triple-nested workspace/session/tab scanning.
- **Redundant Theme Application (P4)** — Guarded `applyThemeToAllHosts()` with a theme signature key to prevent expensive restyling on simple pane switches.
- **Split Pane Layout Flicker (P5)** — Synchronously enforced `layoutSubtreeIfNeeded()` during split pane construction to eliminate double-layout layout stutter/PTY SIGWINCH.
- **Metadata Probe Deduplication (P6)** — Deduplicated CWD path checking during metadata refreshes and extended the poll interval.

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
