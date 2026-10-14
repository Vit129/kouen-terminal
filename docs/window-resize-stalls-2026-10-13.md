# Window resize stalls — 2026-10-13

Branch: `fix/window-resize-stalls`. Baseline: `acf99ae`, installed Harness 2.4.0 (137).

## Cause and change

Live resize enabled `CAMetalLayer.presentsWithTransaction`, acquired drawables on the
main thread, joined the render queue, and waited for GPU scheduling. Renderer backpressure
therefore blocked AppKit's window interaction even at an idle prompt. Cache misses could
also force a synchronous emulator build, and settled resize invalidated that cache with a
synchronous queue join.

Resize now uses the existing bounded asynchronous drawable/render pipeline. An explicit
resize lifecycle flag preserves reflow, PTY sizing, and frozen padding origin independently
of Metal presentation. Cache invalidation and text-blink updates are queued without joining
workers. Obsolete drawable geometry retries the latest frame; preview tokens remain checked
through submission and completion so an old preview cannot restore an intermediate width.

## Evidence

A deterministic test held the render queue for two seconds. Before the change, resize
callbacks took 2,056.8 ms and failed the assertion that they return before the worker is
released. Afterward the blocked-render case took about 9 ms. The committed assertions test
queue independence rather than enforcing machine-dependent timing thresholds.

Mouse-event validation used separate baseline and patched GUI processes, homes, sockets,
and session services. Each resize run sent 360 drag events, cycling window width between
740 and 1,000 points. Streaming runs used two panes, 12,000 history lines, and output at
100 lines/second. Five-second stack samples found these main-thread stack occurrences:

| Run | Main-thread samples | `nextDrawable` | `waitUntilScheduled` |
| --- | ---: | ---: | ---: |
| 2.4.0, idle | 3,131 | 1,300 | 165 |
| Patched, idle | 2,908 | 0 | 0 |
| 2.4.0, streaming | 2,928 | 1,247 | 159 |
| Patched, streaming | 2,399 | 0 | 0 |

These identify blocking locations, not frame rate or input-to-photon latency. The baseline
was the installed release binary; the patched app was a debug preview. Both returned to the
requested size, title-bar movement completed after resizing, and the patched terminal
retained the final `RESIZE-STRESS-COMPLETE` output. Raw traces, driver scripts, and summary
are under ignored `.benchmark-results/resize-stalls/`.

For isolated reproduction, remove inherited `HARNESS_*` variables before setting the test
`HARNESS_HOME`. In particular, `HARNESS_SERVER` overrides the CLI connection target, and an
inherited `HARNESS_HOME` overrides a preview bundle's home. Verify distinct service PIDs and
socket files before creating test panes. An initial validation run inherited the installed
connection; its two temporary panes were removed and the measurements above were rerun
with verified isolation.

## Checks

`swift test --filter 'HarnessTerminalKitTests|HarnessTerminalRendererTests|HarnessAppTests'`

- Terminal kit: 265 tests, including 40 resize cases.
- Renderer: 193 tests; two require the unavailable 3270 Nerd Font and are skipped.
- App: 108 tests; two opt-in session-host lifecycle tests are skipped.
- No failures. Preview build and `git diff --check` pass.

Regression coverage includes blocked rendering, acquisition, and parsing; resize without a
cached frame; rapid direction changes; final grid convergence; stale queued previews after
returning to the original size; output arriving during a drag; and detach/remount behavior.
