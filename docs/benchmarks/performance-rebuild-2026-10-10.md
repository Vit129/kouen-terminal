# Harness performance rebuild — 2026-10-10

Historical measurement snapshot, before the subsequent [production-readiness audit](production-readiness-2026-10-10.md).
That audit fixes correctness issues and adds a one-pane memory follow-up: the large
graphics allocation occurred in both baseline and candidate and later fell without
code changes. The 2.75× one-pane ratio below did not reproduce and must not be used
as a stable regression estimate. Original receipts remain unchanged.

Local working-tree implementation from `3fd9cf174215808af8721eb8a687b75f16514339`.
Final source receipt: `59285da821de96f23043dba9979401881361c9cee4728ca857940af758ecbada`.
Appearance, terminal workflows and features remain the design constraint. No release,
push, GitHub Actions run or deployment was performed. Measurements use an isolated
release bundle on the owner's physical Apple M5 Max. See
[comparison quality and baseline](performance-rebuild-baseline-2026-10-10.md) for
why the supplied VM report and public Ghostty/Rex figures cannot establish a ranking.

## Implementation

- Engine: concrete parser dispatch, fixed CSI storage, canonical 32-byte cell words,
  power-of-two history ring, packed wrap marks and bitset damage. An independent
  row mirror shares clean rows and updates damaged rows. Production uses one worker
  parser path; the runtime parser switch and obsolete GUI shell tracker are removed.
- History: shared 128-row packed blocks with style tables and sparse metadata,
  trimmed default blanks, lossless complex cells, and synchronized snapshot reads.
  Raw parked output uses independently compressed sealed blocks and a hot tail.
  Durable checkpoint and encrypted-history formats are unchanged.
- Transport: 64 KiB / 1 ms read batching, direct ordered worker ingress, bounded
  4 MiB / 1 MiB flow control, segmented/coalesced 32 MiB channel writes, and one
  typed host observation stream. Semantic events retain their ordered byte fences.
  Controlling GUI/CLI clients acknowledge consumed bytes after parsing or writing;
  the slowest mandatory consumer throttles reads. Optional consumers explicitly
  resynchronize. Large replay streams pump bounded chunks ahead of live output.
- Services/startup: shared process observations and cached agent/settings data,
  event-driven updates with backed-off fallback scans, real service deadlines,
  revision-based checkpoint acceptance, and trusted helper installation stamps.
  Background refresh waits for a submitted shell prompt; attach establishes the
  surface and stream together. Private host protocol is 10; components need one
  coordinated restart. Public protocol remains 2.
- Rendering: direct row snapshots feed GPU instances without production flat cell
  arrays. Serial off-main encoding owns renderer state, while transaction resize
  retains its synchronized path. Cursor blink changes uniforms without rebuilding
  rows. Hidden panes parse at utility priority and do not request frames.
- Graphics lifetime: detached or explicitly hidden panes replace their Metal layer
  to release its drawable pool, retaining renderer, atlas, history and appearance.
  Ordinary window occlusion does not churn layers. Two fixed acquisition lanes
  are separate from encoding. Each render operation drains temporary autoreleased
  Metal objects, following [Apple’s ownership guidance](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Cmd-Submiss/Cmd-Submiss.html).
  Callbacks from replaced layers cannot consume
  a remounted pane's pending frame. Repeated rapid remounts may still wait for a
  bounded drawable timeout; they do not block main or create unbounded queues.

## Measurement method

Same pre-generated and hashed 64 MiB ASCII/SGR/Unicode payloads, one warm-up and
five samples, file-fed `/bin/cat` followed by DSR at 100×30. DSR fences parsing;
it does not measure GPU completion or photons. Font and appearance were captured
after the baseline, copied to the candidate, and grid size verified per sample.

The scale fixture visits every pane, fills 10,000 uniformly colored 72-character
rows, settles for 30 seconds, then measures 60 seconds of CPU and per-process
physical footprint. The previous history representation already compacted uniform
rows. Harness-owned memory includes app, host and daemon; shells and agents are
separate. Ten real Codex TUIs are started at 50 panes; no model tasks are submitted.
Each scale state is one settled sample, not a confidence interval.

The isolated ad-hoc signed app cannot access the production shared Keychain group.
Its daemon reports `historyProtection: keyUnavailable`; the throughput figures do
not measure production encrypted persistence overhead. Crypto and durability are
covered separately by correctness tests. No security setting was weakened.

Warm startup is GUI reconnect to a pre-armed existing shell. The shared macOS
`CLOCK_MONOTONIC_RAW` clock avoids the invalid earlier cross-process clock origins.
DSR polling adds up to 5 ms quantization. Prompt timing observes CPU frame submission,
not visibility. Native key-to-submission samples match the surface and require a
newer output generation; they remain a proxy, not external key-to-photon latency.

## Results

Same-machine component and GUI results below use medians of five samples after one warm-up.

| Boundary | Before | Rebuild | Change |
|---|---:|---:|---:|
| Engine ASCII | 44.05 MB/s | 162.03 MB/s | 3.68× |
| Engine scrolling | 47.43 MB/s | 184.18 MB/s | 3.88× |
| Engine SGR | 55.42 MB/s | 161.25 MB/s | 2.91× |
| GUI ASCII, DSR fence | 44.04 MB/s | 76.96 MB/s | 1.75× |
| GUI SGR, DSR fence | 48.75 MB/s | 77.43 MB/s | 1.59× |
| GUI Unicode, DSR fence | 32.86 MB/s | 62.95 MB/s | 1.92× |
| Recorded agent startup/redraw, 4,750 bytes | 5.474 ms | 4.963 ms | 9% shorter |

The tiny agent trace includes file/process startup and is not a sustained-throughput
claim. Engine measurements retain their final unchanged engine source; GUI, startup,
and scale measurements use the final render ordering and asynchronous drawable fix.
Earlier stage receipts remain under `after/previous-stage/` and the startup diagnosis
folder. The final source receipt covers 880 source/test files and signed binary hashes.


| Attached panes | Before owned MiB | Rebuild owned MiB | Before owned CPU | Rebuild owned CPU |
|---:|---:|---:|---:|---:|
| 1 | 104.14 | 286.94 | 0.550% | 0.350% |
| 10 | 346.27 | 379.16 | 1.382% | 0.516% |
| 30 | 897.17 | 578.39 | 2.765% | 0.750% |
| 50 + ten idle Codex TUIs | 1,444.07 | 780.22 | 4.397% | 1.033% |

CPU is percent of one core, not percent of the whole machine. Fifty-pane owned
CPU fell 76.5%; owned footprint fell 46.0%. Thirty-pane memory fell 35.5%, below
the 60% target. One-pane memory increased from 104.14 to 286.94 MiB (2.75×). Its large fixed unmapped
graphics allocation remains unresolved; it is not concealed by the scale gains.
Replacing hidden layers reduced the prior fifty-pane IOSurface allocation from
about 819 MiB to about 16.4 MiB, but unmapped graphics and heap costs remain.
After throughput, the one-pane app alone held 178.6 MiB of unmapped graphics;
the fifty-pane app held 320.9 MiB. These categories are diagnostic allocations,
not extra memory to add to the physical-footprint totals.
Per-operation autorelease pools did not materially reduce the fixed graphics cost.

The original one-pane quiet receipt was 0.666% of one core; a new focused,
styled 100×30 baseline window measured 0.433% versus the rebuild's focused 0.350%.
Both have blink enabled; actual blink cadence and wakeups were not measured.
There is no measured steady-state CPU regression on this boundary. Full-system
process walks are shared rather than repeated per pane; total host CPU still grows
with active panes, so the entire observation workload is not claimed flat in N.

The engine ASCII/scroll targets and fifty-pane idle target pass. Engine SGR misses
3× by about 3%; GUI throughput misses 3×. A rebuilt terminal is faster on these
boundaries; public Ghostty/Rex scores still do not establish overall superiority.


Startup diagnosis: readiness completed at 164 ms but reached its main callback at
1,246 ms; snapshot response arrived at 1,263 ms but applied at 2,730 ms in the sampled
launch. The [main-thread profile excerpt](performance-rebuild-2026-10-10/after/startup-diagnosis/main-thread-profile-excerpt.txt)
shows 1,631 samples in resize-preview repaint→`CAMetalLayer.nextDrawable` and 332
in layout→forced render→`nextDrawable`, both waiting on the drawable semaphore.
This diagnostic run is excluded from acceptance timings. The fix moves ordinary
forced/repaint presentation onto the existing bounded acquisition lanes; actual
transaction-synchronized live resizing retains its required inline presentation.

The final warm reconnect median is **270.64 ms to the DSR fence**, versus
2,302.27 ms before. Observed prompt-frame CPU submission has a **296.31 ms median**
and **315.81 ms maximum** across five samples. The median meets 300 ms; this is
not a guarantee that every launch or visible prompt completes within 300 ms.

Native typing captured all 180 attempted keys in each phase. With ten continuous
background file-fed floods, p99 increased from **2.885 to 9.373 ms**, a **6.488 ms**
increase within the conservative 8.333 ms budget at the display's maximum 120 Hz.
Idle/loaded p50 were 0.339/0.342 ms; p95 0.389/0.435 ms; maxima 5.875/9.391 ms.
These are instrumented keyDown-to-CPU-submission measurements on the same surface,
not GPU completion or photons; actual variable refresh cadence was not measured.
A wrong filename in initial flood setup was repaired before the loaded window;
the receipt records that setup error rather than discarding timed samples.

| Plan target | Outcome |
|---|---|
| Engine ASCII and scrolling ≥150 MB/s | Pass: 162.03 / 184.18; optional 250 MB/s stretch not reached |
| Engine SGR ≥3× | Miss: 2.91× |
| GUI file-fed fence ≥3× | Miss: 1.75× / 1.59× / 1.92× |
| Fifty-pane owned idle ≤2% of one core | Pass: 1.033%; system PID walk shared, total host work still grows with panes |
| One focused blinking pane, no idle regression / fewer wakeups | CPU passes: 0.433→0.350%; wakeups and blink cadence unmeasured |
| Thirty styled panes ≥60% less owned memory | Miss: 35.5%; one-pane memory also regresses |
| Warm usable prompt ≤300 ms | Median proxy passes at 296.31 ms; max 315.81 ms; visibility not measured |
| Loaded typing p99 within one frame of idle | CPU-submission proxy passes: +6.488 ms versus 8.333 ms budget |

## Verification

One full live-enabled Swift run, followed by the failed classes and daemon classes
left unrun after a test expectation overfulfilled. A final resize-only run settles
warm-up queues deterministically without fixed sleeps. Latest outcomes: 2,381 XCTest
passes, six Swift Testing passes, 63 intentional skips, no unresolved failures.
Random VT/scalar comparisons cover packed storage, reflow, eviction, search and
metadata; retained snapshots are checked during concurrent growth. Real PTY pressure,
40 MiB replay ordering, raw observation windows and split semantic fences are covered.

Sixteen existing IPC/startup tests also pass after the final direct layout RPC change.
The locked arm64 Linux Swift 6.0.3 release build and dynamic-dependency checks pass
after the final shared Core change. Subsequent functional changes are macOS-only
rendering; Linux was not redundantly rebuilt for those changes.
Final Xcode Debug and macOS release builds pass; the isolated release bundle is
packaged locally. The final graphics/order change passes 66 affected terminal checks, including 35
resize/lifecycle checks, plus the actual cursor pixel-parity check. A failed
recorded-search shading assertion exposed stale frame replacement; ordering was
repaired and all affected checks then passed without weakening their assertions. An actual remote SSH host and
external photon/wakeup measurements are not part of the available local evidence.

Native smoke checks verified an actual Codex TUI and command menu; styled Unicode
and a Kitty inline image; find highlighting; native copy/paste with the multiline
paste guard; split, zoom/restore and scrolling; and GUI quit/reopen with both original
shells, history, image and search retained. Read-only CLI attach in a real PTY
received the fixture and history, then detached with Ctrl-A d and exit 0. The first
attach harness stopped draining its outer PTY during detach and timed out; the
corrected harness drains concurrently and explicitly removes inherited routing
variables. GUI reopen proves live host retention, not encrypted disk restoration.
BEL was emitted and semantic events tested; audibility and OS banners were not
asserted. Native screenshots were inspected in the task but not exported as files.

## Receipts and next bottlenecks

The [receipt index](performance-rebuild-2026-10-10/README.md) contains conditions,
verification inventory, payload hashes, baseline/final raw samples, scale process
records, startup phases, input samples, UI outcomes and source/binary hashes.
Full build/test logs and local bundles remain under ignored
`.benchmark-results/performance-rebuild/`. Intermediate stages are labeled separately.

The remaining priorities are the fixed Metal graphics footprint and the measured
engine-to-GUI throughput gap. Address them with allocation and end-to-end profiles
on the production signed build, including encrypted history cost. The current
receipts justify a substantial improvement, not a claim that every target passed
or that Harness beats Ghostty/Rex. The [Devin handoff](devin-handoff-2026-10-10.md)
is prepared for an independent cloud run; no job has been dispatched.
All temporary benchmark processes and the local Linux VM are stopped. The normal
Harness daemon and its sessions remain running.
