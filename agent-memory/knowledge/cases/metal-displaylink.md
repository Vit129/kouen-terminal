# CASE — AppKit / Metal / Display Link

Grep target: `grep -n "CASE-\|<keyword>" knowledge/cases/metal-displaylink.md`

| ID | Trigger | Fix |
|----|---------|-----|
| CASE-003 | Terminal goes black after pane rebuild (remove+re-add) | stop+start display link in `viewDidMoveToSuperview()` if window!=nil |
| CASE-004 | Overlay NSView above Metal surface not visible | zPosition=1000 on overlay layer (full-frame blocks Metal) |
| CASE-012 | File preview causes 1-2s black screen (Metal dies on reparent) | Constraint-based sibling panel, never reparent terminal views |
| CASE-025 | Terminal flickers on file preview open/close | `presentsWithTransaction = true` during programmatic resize |
| CASE-026 | New session occasionally shows black (no prompt) | Always stop+start display link in viewDidMoveToWindow |
| CASE-028 | Metal surfaces accumulate (async sync skips prune) | Add `terminalHosts.prune(keeping:)` to async syncFromDaemon variant |
| CASE-031 | Crash: CADisplayLink fires on deallocated surface | `deinit { renderLink?.invalidate() }` — macOS doesn't retain target |
| CASE-039 | Terminal blink on sidebar toggle/file preview/split after adding `adjustSubviews()` | Remove `adjustSubviews()` from sidebar toggle path — use `setSidebarWidth() + split.layout()`. See RL-058. |
| CASE-040 | Tab switch (⌘1/2/3) shows black screen on revisit | 4 compounding failure modes in container-caching fast path — see `knowledge/bugs/tab-switch-black-screen.md`. Key: never call `detachHostsOnly()` before caching; validate host set before fast-path reveal. |
| CASE-041 | Metal black after external display switch | `CAMetalLayer` loses drawable on display reconfiguration. Fix: `displayLink.preferredFrameRateRange` reset + `scheduler.forceRender()` in `viewDidChangeBackingProperties`. |
