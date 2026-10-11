# Harness production-readiness audit — October 10, 2026

The complete local change from `3fd9cf174215808af8721eb8a687b75f16514339` was reviewed across engine/history, transport, rendering, services, startup, build integration, tests, and benchmark reporting. Concrete defects found during review were fixed. The final local gates pass; no reproducible correctness blocker remains from this audit. This is a local readiness assessment, not release certification or a guarantee of zero defects.

**Nothing was released, pushed, deployed, or dispatched to GitHub Actions or a cloud agent.** The normal Harness daemon and its sessions were preserved. Temporary review runtimes and the local Linux build VM were stopped.

Final source receipt: `8b47956cd11a2a79ad9050c2c5fa6e1205a846b07e579401b6c97126e8804b82` across 880 source/test files, with packaged executable hashes. See [source receipt](production-readiness-2026-10-10/source-receipt.json), [full changed-file inventory](production-readiness-2026-10-10/changed-files.json), and [files changed during this audit](production-readiness-2026-10-10/audit-source-changes.json). The preceding rebuild report identifies a different, historical candidate.

## What was fixed

| Area | Defect and resulting behavior |
|---|---|
| Mandatory host observations | Plain-output acknowledgements previously reset their comparison baseline on each small batch and could permanently exhaust the 4 MiB window. Acknowledgements now accumulate from the first pending sequence. Recovery acknowledges the consumed prefix when returning, including partial recovery. |
| GUI reconnect | Reattaching before admitted parser work drained could replay bytes twice; publishing the advertised replay end before consuming it could skip bytes. Reconnect now waits for admitted work and resumes from the consumed fence. Intentional detach preserves already-admitted work. |
| Flow-control binding | Applying a remembered pause after releasing its lock could overwrite a concurrent resume. GUI and CLI bind pause state under the same budget lock. |
| Cursor blink | A blink could replace a newer pending output/selection frame with the last presented frame. Busy blink falls back to current state instead. Idle blink still avoids row reencoding. |
| Transaction resize | Joining an earlier worker encode could invalidate cached row coherence, and its delayed completion could overwrite newer presentation metadata. Transaction repaint revalidates rows and reserves a later presentation identity. Unchanged rows can still be reused after content validation. |
| Raw history eviction | Removing the first compressed block repeatedly shifted the entire retained array. Eviction now clears a logical prefix immediately and compacts amortized over prior removals, preserving value semantics and byte order. |
| File observation | Watching only the parent directory missed edits to an existing file. A file vnode watcher now covers in-place writes while the directory watcher handles creation, replacement, and deletion. |
| Agent lifecycle | Process-exit callbacks now close the latest run metadata. Recovery replaces old process watches, and an immediate generation check reconciles stale restored PIDs before waiting for exit. |
| Schedules and fanout | Bounded pages continue without another external event; schedule outcomes and triggers share a rotating page. Fanout wakes preserve unfinished reconciliation instead of repeatedly restarting at the first group. Activation cutoffs retain missed-event behavior. |
| Registry/handover | Lazy service references are read under their ownership locks. Hosted exits and resumed ownership wake relevant services so one-shot observation cannot become stranded. |
| Notification delivery | Redaction rearms the delivery deadline. Failed durable retirement backs off for five seconds rather than spinning on an expired deadline; delivery resumes when storage recovers. |
| Power management | A transient native sleep-assertion acquisition failure schedules a bounded retry while policy still requests a hold. Releasing the hold clears obsolete assertion errors. |
| Startup and settings | A cold start refreshes stale installed helpers before launching them. A final readiness probe handles socket publication preceding `listen()`. An absent optional settings file keeps defaults/last working policy without a false failure. |
| Native shortcuts | Native smoke exposed an existing optional-return bug: `self?.handle(event) ?? event` forwarded events whose handler intentionally returned `nil`. Prefix and palette monitors now preserve the consumed result. Zoom no longer also types its key into the shell. |
| Cleanup and benchmark tooling | Removed the unused CPU cursor-color path and obsolete comments; the prior rebuild already removed the alternate parser switch and duplicate GUI shell tracker. Local benchmark drivers strip inherited routing variables, validate isolated ownership/grid, and clean up their own child processes on failure. |

No new compatibility switch, legacy rendering path, history migration, or encryption exception was added. Appearance and terminal workflows remain the constraints. Public protocol 2/private host protocol 10 still require the coordinated runtime transition documented in the rebuild report; this audit adds no further protocol change.

## Verification without repeating unaffected work

**106 distinct focused tests pass, with no remaining skips or failures in that set.** Coverage includes real PTY pressure, observation fences, reconnect draining, history snapshots/eviction, file edits, agent exits/PID reuse, notifications, schedule continuation, managed fanout jobs, rendering/pixel parity, live resize, and shortcut key normalization. New assertions target failure modes rather than duplicating implementation. Native shortcut consumption was checked in the actual packaged app.

The first resize assertion incorrectly demanded rebuilding all rows; it now requires full revalidation, rebuilding the changed row, and safe reuse of the unchanged rows. All 36 resize tests passed on rerun. The managed-job fixture initially received a nonexistent products path from the review command; it passed against the verified release products. These attempts remain recorded in the [test summary](production-readiness-2026-10-10/test-summary.json).

Final build gates:

- macOS optimized release build and isolated application packaging/ad-hoc signing.
- Xcode Debug build of the final source, with code signing disabled.
- Linux ARM64 release package using the pinned toolchain and dynamic-dependency gate.
- Python syntax checks for the changed benchmark drivers and `git diff --check`.

The native smoke exercised sustained output, history search, splits, styled Unicode paste, zoom/unzoom, live settings reload, prefix/palette shortcuts, and GUI restart with retained sessions. Three output markers and a separate Unicode marker written in a narrow pane survived width changes and restart. The final build preserved appearance on visual inspection. Before the shortcut fix, one older output line was absent after a restart; the precise cause was not established. Controlled final repetitions did not reproduce it, and a narrow review found no concrete remaining replay/geometry defect. It is recorded as an observation, not attributed to an unproven fix.

The earlier broad suite remains historical evidence for unchanged paths; it was not rerun wholesale to inflate the count. [Verification receipt](production-readiness-2026-10-10/verification.json) records final gates and log hashes. Full local build/test logs remain under `.benchmark-results/production-readiness-2026-10-10/`. Unchanged vendored MCP and Linux Foundation compiler/linker warnings remain; no new warning was identified in changed Harness source.

## One-pane memory follow-up

The earlier 2.75× one-pane memory ratio did **not** reproduce. Fresh baseline and candidate processes both exhibited a large unmapped graphics allocation, which later fell to about 12.9 MiB without code changes. This demonstrates transient graphics residency in both versions; it does not prove a particular driver or onboarding cause. Their initial samples were taken at different process ages and must not be compared as a cold-start result.

After the same 64 MiB ASCII/SGR/Unicode workloads and then 10,000 styled lines at 100×30, with 30 seconds of settling per state:

| Owned physical footprint: app + host + daemon | Baseline | Audited candidate |
|---|---:|---:|
| After sustained output | 119.27 MiB | 120.08 MiB |
| After styled history | 118.89 MiB | 120.28 MiB |

These are diagnostic point samples, not confidence intervals or a claim that one-pane memory improved. The candidate is about 1.2% higher in the styled sample. The previous large one-pane regression estimate is withdrawn as a stable conclusion; original receipts are retained. Multi-pane memory gains and missed performance targets remain scoped historical results, not newly remeasured claims.

The memory probe used source `ac0fa28920d89c71d2359fa4570979d141f2b1bc4c50633a429860d715f9af46`; only the two native event-monitor fixes followed it. See [memory summary](production-readiness-2026-10-10/memory-summary.json), raw process/category receipts alongside it, and the frozen [diagnostic driver source](production-readiness-2026-10-10/memory-probe-source.txt). The driver was executed from `.benchmark-results/production-readiness-2026-10-10/`; its relative paths assume that location. The workload runs diagnose residency and are not promoted into a new throughput ranking.

## Qualification limits

Production signing/notarization, a signed shared-Keychain end-to-end run, and a real remote SSH upgrade were not performed. The isolated ad-hoc runtime reports `historyProtection: keyUnavailable`; no encryption setting was weakened. Existing crypto/durability tests provide correctness evidence, but this audit does not measure encrypted-persistence overhead or certify the signed upgrade path. External key-to-photon latency, wakeups, other GPU families, Linux x86_64, and a new full 1/10/30/50-pane performance matrix were not added to this review.

Those are remaining release-qualification limits, not hidden claims of completion. The local implementation is ready for that next validation stage. The [cleanup receipt](production-readiness-2026-10-10/cleanup.json) confirms only isolated review services were stopped and the normal daemon remained alive.
