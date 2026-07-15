# P38 Phase E — Scripting Hooks — Dev Task Progress

Design: `design.md` (same folder).

- [x] 1. Audit confirmed via Fable consult: capability parity already exists, no hook-parity build needed.
- [x] 2. `ScriptRuntime`: `lastKnownPaneIDs` seeded at init (not empty) to avoid spurious first-fire.
- [x] 3. `dispatchPaneDiff()` — diffs pane-ID set on each `snapshotChanged`, dispatches `paneCreated`/`paneRemoved`.
- [x] 4. Tests: bridge payload contract + no-spurious-fire regression guard (2 new tests).
- [x] 5. Gate: `swift build --product Kouen` + new tests isolated (2/2) + `Tests/robot/run.sh` (26/26) green.
- [ ] 6. **Live check (recommended, not blocking)**: real `make preview` with a test plugin registering `kouen.plugin.on("paneCreated"/"paneRemoved", ...)`, split/close a pane, confirm events fire. Lower priority than B/C/D's live checks — this is a narrow scripting-API fix, not a user-visible UI feature. **Deferred to end of session** alongside Phase B/C/D live checks.

## Summary

Completed: 5, Remaining: 1 (live check, low priority)

## Status: Implementation complete, build/test/robot green.
