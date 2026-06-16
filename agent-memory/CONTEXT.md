# Context — harness-terminal

## Now
- **Task:** Investigate terminal panel black-flash when opening file preview (Task 51)
- **Plan:** [p22-long-session-responsiveness](plans/p22-long-session-responsiveness.md)
- **Branch:** main
- **Latest release:** v3.2.0 (build 144)
- **Status:** in progress

## Open Questions
- Black-flash root cause not yet confirmed — may be related to Metal surface reparenting

## Key Files
- `HarnessApp/UI/ContentAreaViewController.swift` — file preview split logic
- `HarnessTerminalKit/HarnessTerminalSurfaceView.swift` — Metal surface

## Session Notes
- Build: `make preview` (uses `.harness-preview/` dir)
- Never reparent Metal terminal surfaces — causes black screen (RL-004)
- Read `knowledge/background-polling.md` before touching DaemonSyncService
