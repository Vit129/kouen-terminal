# Service Decomposition — SessionCoordinator (P17)

## Pattern

God-object `@MainActor final class` (2050 LOC, 80+ methods) decomposed into
focused services, each owning a single domain. Coordinator remains as thin facade.

## Architecture

```
SessionCoordinator (397 LOC facade)
├── DaemonSyncService (233) — daemon IPC, snapshot hydration, metadata refresh
├── SessionLifecycleService (360) — workspace/session/tab create/close/select
├── SplitPaneCoordinator (157) — split/kill/focus panes
├── NotificationCoordinator (247) — agent alerts, desktop notifications, waiting rings
├── ThemeService (178) — theme apply, setTheme, auto light/dark
├── ActivePaneService (197) — surface focus, borders, sync-panes, zoom, cycle
├── SessionCoordinator+HostDelegate (86) — TerminalHostDelegate conformance
└── SessionCoordinatorTypes (47) — NotificationEntry, DesktopNotifier, HarnessPathDisplay
```

## Key Design Decisions

1. **`unowned let coord`** — each service holds unowned reference to coordinator (no retain cycle, coordinator always outlives services)
2. **`lazy var`** — services init'd lazily from coordinator properties (avoids init-order issues)
3. **Internal setters** — shared state (`activeSurfaceID`, `lastActiveSurfaceID`, `structureRevision`) uses `var` not `private(set)` so services can write
4. **Facade delegates** — coordinator keeps the public API unchanged; callers don't know about services
5. **Build-per-step** — each extraction step was `swift build` verified before continuing

## When to Apply This Pattern

- Class exceeds ~500 LOC with 3+ distinct responsibilities
- New features keep threading through the same coordinator
- Unit testing requires mocking the entire coordinator

## Anti-Patterns Avoided

- ❌ Protocol-based delegation (over-abstract for same-module services)
- ❌ Moving tests (tests stay in place, only imports change)
- ❌ Extracting tightly-coupled state machines (those stay as extensions)
