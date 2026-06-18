# Build Scripts Self-Kill Protection

## Problem

`run.sh prod` and `full-cycle.sh` call `kill_stale_prod()` which kills `/Applications/Harness.app` + its daemon. When the user runs `make start` (option 3 or 4) **from inside Harness itself**, this kills the terminal session hosting the script → script dies mid-execution.

## Detection

`TERM_PROGRAM=Harness` is set in all Harness-hosted shell sessions.

## Fix (applied in `Scripts/run.sh`)

1. `kill_stale_prod()` — when `TERM_PROGRAM=Harness`, skip killing `/Applications` instance and its daemon. Still kills repo-root `Harness.app` (stale previous builds).
2. `prod` / `run` cases — skip `Scripts/clear-runtime-state.sh` when inside Harness (would destroy live sessions/socket).
3. Use `open -n Harness.app` (always) — launches a new instance even if another Harness is running with the same bundle ID.

## Key Invariant

**Never move `kill_stale_prod` before `swift build`** — even from an external terminal, the kill+open gap should be minimized. Build first, kill+open atomically after.

## Related

- `TERM_PROGRAM=Harness` — set by `HarnessDaemonCore` when spawning PTY sessions
- `HARNESS_SURFACE`, `HARNESS_SOCK`, `HARNESS_HOME` — also available for detection
- Commit `5bffd70` broke this by moving kill before build (reverted)
