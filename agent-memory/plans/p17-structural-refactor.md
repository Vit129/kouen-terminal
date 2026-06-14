# P17 — Structural Refactor

Status: **planned** — not started, intentionally sequenced after P15 integration completes
Priority: **P3** — structural improvement, no new features
Owner surface: HarnessApp, HarnessCore
Created: 2026-06-14
Prerequisite: P15 steps 3-5 done (harness.events bridge, P11 PBI-SCRIPT-004/005, P12 PBI-ORCH-005)

---

## Goal

Reduce complexity in the two largest targets (HarnessApp 29K LOC, HarnessCore 15K LOC)
by decomposing god objects, organizing flat directories into feature domains, and
optionally splitting HarnessCore into focused packages for build-time isolation.

All changes are **purely structural** — no behavior changes, no new features.
The full test suite (1500+ tests) must pass identically before and after each PBI.

---

## Principles

1. **One PBI = one reviewable PR.** Never mix structural moves with behavior changes.
2. **Preserve public API.** Thin facades remain at original call sites; callers don't change in the same PR.
3. **Tests don't move.** Test files stay in their current targets. Only `import` statements change if a type moves packages.
4. **Ship incrementally.** Each PBI is independently mergeable. If we stop after PBI-002, the codebase is still better.

---

## PBI-REFACTOR-001: Decompose SessionCoordinator (2050 LOC → ~400 LOC coordinator + 4 focused services)

Status: **DONE** — SessionCoordinator 2050→397 LOC. 8 files total:
- `DaemonSyncService` (233 LOC)
- `NotificationCoordinator` (247 LOC)
- `SessionLifecycleService` (360 LOC)
- `SplitPaneCoordinator` (157 LOC)
- `ThemeService` (178 LOC)
- `ActivePaneService` (197 LOC)
- `SessionCoordinator+HostDelegate.swift` (86 LOC)
- `SessionCoordinatorTypes.swift` (47 LOC)
- `SessionCoordinator.swift` (397 LOC — thin facade)

**Decomposition:**

| New type | Responsibility | Methods moved | ~LOC |
|----------|---------------|---------------|------|
| `DaemonSyncService` | `syncFromDaemon` (sync + async), `buildSurfaceIndex`, `structureFingerprint`, `scheduleSnapshotRefresh`, `startMetadataRefresh`, `requestDaemon`, `closeEphemeralSessionsBeforeQuit` | 7 methods | ~350 |
| `SplitPaneCoordinator` | `splitActivePane`, `splitActivePaneAndRun`, `focusPaneDirectional`, `splitPaneSurface`, `splitTab`, `splitSession`, `killActivePane`, `killPane`, `paneID(for:in:)`, `firstSurfaceID(forTab:)` | 10 methods | ~300 |
| `SessionLifecycleService` | `addWorkspace`, `addSession`, `addTab`, `openDefaultTerminalLaunch`, `selectWorkspace`, `selectSession`, `selectTab`, `selectAdjacentSession`, `moveActiveSession`, `closeActiveTab*`, `closeSession`, `closeActiveWorkspace`, `closeWorkspace`, `closeOtherTabs`, `closeTabs(under:)`, `reopenLastClosedTab`, `openTabInActiveWorkspace` | 17 methods | ~400 |
| `NotificationCoordinator` | `pushNewRemoteNotifications`, `pushAgentActivityNotifications`, `deliverAgentAlert`, `handleNotification`, `clearNotification*`, `clearAllNotifications`, `jumpToLatestNotification`, `notificationsList`, `agentsList`, `openAgent`, `openNotification`, `updateDockBadge`, `syncWaitingRings`, `isSurfaceWaiting`, `firstWaitingTab`, `canonicalNotificationSurface` | 16 methods | ~400 |

**SessionCoordinator residual (~400 LOC):** Holds `@Published` state properties, `terminalHosts` dictionary, settings observation, theme application (`setTheme`, `applyAutoTheme`, `applySettingsToHosts`), `TerminalHostDelegate` callbacks, font size, find bar, rename. Delegates to the 4 services above.

**Pattern:** Each extracted service is a `@MainActor final class` initialized with a reference to `SessionCoordinator` (or the specific subset of state it needs). SessionCoordinator creates them in `init` and exposes them as `let` properties.

**Verification:** `swift build` + `swift test --filter HarnessAppTests` + `swift test --filter HarnessCoreTests` must pass. No test logic changes.

---

## PBI-REFACTOR-002: Organize HarnessApp/UI/ into feature subfolders

**Problem:** 50+ files in a flat `UI/` directory. Only `Notch/` is sub-grouped. File names like `Phase67UI.swift`, `HarnessChrome.swift`, `HarnessControls.swift` are opaque.

**Target layout:**

```
UI/
├── Terminal/
│   ├── TerminalTabBarView.swift
│   ├── StatusLineView.swift
│   └── CompletionPopupView.swift
├── Sidebar/
│   ├── HarnessSidebarPanelViewController.swift
│   ├── HarnessSidebarPanelViewController+SessionMenu.swift
│   ├── HarnessSidebarPanelViewController+RecentProjects.swift
│   ├── HarnessSidebarPanelViewController+DragReorder.swift
│   ├── SidebarSessionRows.swift
│   ├── SidebarWorkspaceViews.swift
│   └── BoardViewController.swift
├── FileEditor/
│   ├── SyntaxTextView.swift
│   ├── ViNormalMode.swift
│   ├── FileEditorView.swift
│   ├── FileEditorTabBarView.swift
│   ├── FileViewerViewController.swift
│   ├── FileTabManager.swift
│   ├── FuzzyPathResolver.swift
│   └── LSPFileSession.swift
├── FileTree/
│   ├── FileTreeSwiftUIView.swift
│   ├── FileTreeKeyboardNav.swift
│   └── WorkspaceFileTreeView.swift
├── Git/
│   └── GitPanelView.swift
├── CommandPalette/
│   ├── CommandPaletteController.swift
│   ├── CommandPromptController.swift
│   └── CommandHistorySearchController.swift
├── Search/
│   └── SearchPanelView.swift
├── Notifications/
│   ├── NotificationDropdownPanel.swift
│   ├── NotificationBellButton.swift
│   └── AgentInboxPanelView.swift
├── Notch/                    (already exists)
├── Chrome/
│   ├── MainWindowController.swift
│   ├── MainSplitViewController.swift
│   ├── ContentAreaViewController.swift
│   ├── WindowTitleStripView.swift
│   ├── WindowBorderOverlayView.swift
│   ├── WindowBlur.swift
│   ├── HarnessChrome.swift
│   ├── MainMenuBuilder.swift
│   └── MenuBarController.swift
├── Agents/
│   ├── AgentChatPanelView.swift
│   ├── AgentIconArt.swift
│   └── AgentIconRenderer.swift
└── Shared/
    ├── HarnessControls.swift
    ├── HarnessDesign.swift
    ├── PrefixKeymap.swift
    ├── Phase67UI.swift
    ├── Toast.swift
    ├── AboutPanelController.swift
    ├── DisplayPanesOverlay.swift
    └── OnboardingController.swift
```

**Execution:** Move files + update any relative path references. SPM doesn't care about subfolder structure within a target — this is purely organizational.

**Verification:** `swift build` must pass. No code changes, only file moves.

---

## PBI-REFACTOR-003: Decompose ViNormalMode.swift (1792 LOC → 5 files)

**Problem:** Single file contains the full vi engine: state machine, motions, operators, text objects, ex commands, macros, registers, jump list, search.

**Split:**

| File | Contents | ~LOC |
|------|----------|------|
| `ViEngine.swift` | State machine, mode transitions, main dispatch, cursor movement helpers | ~400 |
| `ViMotions.swift` | Character/word/line/paragraph/search motions, `%` matching | ~350 |
| `ViOperators.swift` | Delete/change/yank/put/indent, visual mode operations | ~300 |
| `ViExCommands.swift` | `:w/:q/:s/:set/:e/:bn/:bp/:ls/:find/:view` parsing + dispatch | ~350 |
| `ViRegisters.swift` | Named registers, `@` macro recording/playback, `"` register selection, jump list, mark storage | ~300 |

**Pattern:** `ViEngine` remains the entry point. Extract methods as `extension ViEngine` in separate files, or as internal helper types if they carry their own state (registers, jump list).

**Verification:** `swift test --filter HarnessAppTests` (vi-related tests) must pass unchanged.

---

## PBI-REFACTOR-004: Split HarnessCore into focused packages (optional, highest effort)

**Problem:** HarnessCore (91 files, 15K LOC) is depended upon by every target. A change to `FormatString.swift` forces recompilation of CLI, daemon, renderer, and app.

**Proposed split:**

| New Package | Current subdirs | LOC | Depends on |
|-------------|----------------|-----|------------|
| `HarnessIPC` | IPC/, Models/, Notifications/ | ~2,100 | — (leaf) |
| `HarnessCommands` | Commands/, Format/, Session/, Options/, Board/ | ~5,500 | HarnessIPC |
| `HarnessSettings` | Settings/, Keybindings/, Shell/ | ~2,300 | — (leaf) |
| `HarnessCore` (residual) | Agents/, ACP/, Remote/, Paths/, CLI/, Diagnostics/, Persistence/, Platform/, Metadata/, Events/, Buffers/, ReleaseNotes/, Layouts/ | ~5,100 | HarnessIPC, HarnessSettings |

**Dependency graph after split:**

```
HarnessApp ──→ HarnessCore (residual) ──→ HarnessIPC
    │                                  └─→ HarnessSettings
    ├──→ HarnessCommands ──→ HarnessIPC
    ├──→ HarnessSettings
    └──→ HarnessIPC

HarnessDaemon ──→ HarnessCommands ──→ HarnessIPC
             └──→ HarnessCore (residual)

HarnessCLI ──→ HarnessCommands ──→ HarnessIPC
          └──→ HarnessCore (residual)
```

**Risk:** This is the highest-effort PBI. Every `import HarnessCore` in every file must be audited. Tests that reference types from multiple new packages need multiple imports. Consider doing this last and only if build times become problematic.

**Verification:** Full `swift test` (all 1500+ tests) must pass. `swift build --product Harness`, `swift build --product HarnessDaemon`, `swift build --product harness-cli` all succeed.

---

## PBI-REFACTOR-005: Retire shelved ACP code to compilation flag

**Problem:** ~1K LOC of ACP code (`ACPClient`, `ACPSession`, `ACPTransport`, `ACPProcess`, `ACPMessage`, `AgentChatPanelView`) compiles and links into every build despite being shelved indefinitely.

**Options (pick one):**

1. **`#if HARNESS_ACP` flag** — wrap all ACP code. Normal builds skip it. Enable via `swift build -Xswiftc -DHARNESS_ACP` for future development.
2. **Move to separate `HarnessACP` package** — not linked by default. Explicitly add dependency when re-enabling.

**Preferred:** Option 1 (simpler, no Package.swift changes, tests can still compile with the flag).

**Verification:** `swift build` (without flag) succeeds and the binary is slightly smaller. `swift build -Xswiftc -DHARNESS_ACP` also succeeds.

---

## Execution Order

```
PBI-REFACTOR-001  SessionCoordinator decomposition     [High value, medium effort]
PBI-REFACTOR-002  UI/ subfolder organization           [High value, low effort]
PBI-REFACTOR-003  ViNormalMode decomposition           [Medium value, low effort]
PBI-REFACTOR-005  ACP compilation flag                 [Low value, low effort]
PBI-REFACTOR-004  HarnessCore package split            [High value, high effort — optional]
```

Each PBI is one PR. They can be done in any order but the above sequence maximizes
early impact: 001 reduces the biggest maintenance risk (SessionCoordinator), 002 makes
the codebase navigable, 003 is a quick win for vi contributors.

---

## Success Criteria

- [ ] SessionCoordinator.swift < 500 LOC (thin facade)
- [ ] No file in UI/ exceeds 800 LOC without clear justification
- [ ] UI/ has ≥8 feature subfolders
- [ ] Full test suite passes identically (no test logic changes)
- [ ] Build time for incremental change in Settings does not recompile IPC layer (only if PBI-004 done)
- [ ] `swift build` without ACP flag excludes ACP symbols from binary (only if PBI-005 done)

---

## Non-Goals

- No behavior changes. If a method has a bug, fix it in a separate PR.
- No new abstractions (protocols, generics) unless they reduce code. Extraction != abstraction.
- No test file moves. Tests stay where they are; only `import` statements might change.
- No rewrite of `HarnessDesign.swift` or `HarnessControls.swift` — they're large but stable grab-bags. Renaming/splitting them is a cosmetic preference, not a maintenance win.
