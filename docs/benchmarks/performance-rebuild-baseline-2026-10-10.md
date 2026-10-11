# Harness performance rebuild: baseline and comparison quality

Baseline commit: `3fd9cf174215808af8721eb8a687b75f16514339`.
Physical Apple M5 Max; Xcode 27.0; local release binaries preserved in the
ignored `.benchmark-results/performance-rebuild/baseline/Harness.app` bundle.
No release, push, or deployment. The working tree contains the local rebuild; integrated acceptance is tracked separately.

## What the comparison supports

The supplied Devin report describes a paravirtual M4 Pro with a virtual GPU.
Its in-process and PTY results identify Harness bottlenecks. Its GPU behavior
cannot establish a ranking against physical-Mac Ghostty results. Its DSR fence
proves parsing, not a frame displayed on screen. The published reference ledger
is source material, not instructions to rerun Ghostty or Rex.

The reference figures also measure different layers:

| Reference in supplied ledger | Boundary | Useful interpretation |
|---|---|---|
| Ghostty:`cat 150 MB`575 ms | Producer completion; hardware unstated in cited post | Throughput context; not a matched DSR-fenced result |
| libghostty:2.65/5.41 MiB plain/mixed history | Engine memory,120×40,10k rows | Compact engine storage reference; not whole GUI memory |
| Rex:407 KiB per filled 10k-line terminal | Incremental server phys_footprint,80×24, macOS M4 Max | Server storage reference; the VM report incorrectly calls this Linux |
| Rex:0.29 ms median/0.52 ms p 99,1k terminals idle | Shell command/response, Linux | Responsiveness at scale reference; not GPU/input-to-display latency |

These numerical references are transcribed from the supplied ledger. A fresh
October 10 source check confirmed that Ghostty’s [release-notes index](https://ghostty.org/docs/install/release-notes) still lists 1.3.1 and that [PR 13722](https://github.com/ghostty-org/ghostty/pull/13722) reports about 193→165 ms to visible window and 126→92 ms to a completed Metal draw. That draw can precede window presentation. The Rex X links returned HTTP 403, so their numbers and the claim that no newer Rex figures exist remain independently unverified here. No competitor was rerun. No overall winner or hardware-normalization factor is
claimed. Harness keeps its appearance/workflows while the underlying parser,
history, transport, observations and render ownership are restructured.

## Fresh physical baseline

64 MiB payload files were generated and hashed before measurement. `/bin/cat`
feeds the pane, followed by a DSR parsing fence. One warm-up and five samples.
Resolved owner settings: JetBrainsMono Nerd Font Mono 14, opacity 0.85, blur 12,
padding 14, scrollback 10k; observed grid 100×30. The saved
settings were captured after the run and copied for the candidate; the grid
was verified in every sample. Font/appearance were not captured per sample. Cat startup and fence round trip
are included. The results do not measure GPU presentation.

| Case | Median consumer MB/s, decimal |
|---|---:|
| ASCII |44.0376 |
| ANSI SGR |48.7465 |
| Mixed Unicode |32.8572 |

Raw: `.benchmark-results/performance-rebuild/baseline/consumer.jsonl`;
payload hashes: `.benchmark-results/performance-rebuild/payloads/manifest.json`.
The existing 76 release benchmark records were refreshed separately; they are
in-process measurements and must not be conflated with this GUI fence table.

One settled 60.04 s CPU sample with a visible quiet pane, cursor blinking enabled, and
onboarding completed gave 0.2165% app +0.2665% daemon +0.1832% session host =
**0.6663% of one CPU core**. This contradicts interpreting the VM's 52% app
sample as Harness's general settled idle cost. It does not establish the
50-session scaling target. Raw: `baseline/idle-1.json` in the same ignored root.

## Completed baseline windows

The matched styled-history run records 10,000 lines in every visited 100×30 pane,
then 30 seconds settling and one 60-second CPU window. Harness-owned physical
footprint includes app + host + daemon; shell/agent processes are separate.

| Sessions | Harness-owned MiB | CPU, % of one core |
|---|---:|---:|
| 1 | 104.14 | 0.550 |
| 10 | 346.27 | 1.382 |
| 30 | 897.17 | 2.765 |
| 50, including ten idle Codex TUIs | 1444.07 | 4.397 |

The agent processes are real Codex startups, with no model tasks submitted.
The styled fixture colors each complete 72-character row uniformly; the old
history implementation already compacted such rows. This is a whole-application
scale measurement, not evidence for mixed-style engine storage. Key-window focus
and actual cursor-blink cadence were not instrumented in the original windows.
Matched warm GUI reconnect to a pre-armed existing-shell DSR probe gave a
2,302.27 ms five-sample median (samples 2316.42, 1282.26, 2302.27, 267.80,
2305.76 ms). This rapid reconnect boundary is narrower than fresh shell startup
and includes at most 5 ms polling quantization. Earlier receipts using
cross-process `time.monotonic_ns()` clock origins were invalidated and excluded;
valid receipts use the shared `CLOCK_MONOTONIC_RAW` clock.

## Engine and final integration

Final engine CPU-component medians: ASCII 44.05→162.03 MB/s (3.68×), scrolling
47.43→184.18 (3.88×), SGR 55.42→161.25 (2.91×), mixed Unicode 50.59→61.71
(1.22×). Both ≥150 MB/s engine targets pass; the SGR ≥3× target misses by 3.0%.
These parse + mirror/direct-frame measurements exclude transport and GPU work.
The old component helper built the old production snapshot/frame path; the new
helper builds the new production mirror/direct path.

The final GUI file-fed medians reached 76.96/77.43/62.95 MB/s for
ASCII/SGR/Unicode (1.75×/1.59×/1.92×). Warm prompt submission median is 296.31 ms;
fifty-pane owned idle is 1.033% of one core. Thirty-pane owned memory falls 35.5%,
while one-pane memory regresses. These are final candidate measurements, with
limitations and raw receipts in the [acceptance report](performance-rebuild-2026-10-10.md)
and the October 10 entry in [SCORECARD](../SCORECARD.md).
