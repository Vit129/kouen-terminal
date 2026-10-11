# Benchmarks

## In-process baseline gate

`make bench-check` compares single-run component timings with `benchmark-baselines.json`.
A cold CPU or background build can change those timings substantially. Record baselines
only deliberately on the owner hardware, using the median of three warm runs. For a
performance-change receipt, use one warm-up and five measured samples with no concurrent
builds, profiles, VMs or other benchmark workloads. CI’s hardware differs; its benchmark
job is advisory.

`PerformanceBenchmarks.testConsumerScoreboard` measures parser + render mirror + direct
frame construction at 160×48. It excludes transport, queue scheduling, Metal encoding,
GPU completion and visible scanout. The historical helper used the previous production
snapshot/frame path; the current helper uses `consumeDamage`, `updateRenderMirror` and
`FrameBuilder.buildDirect`. `feedNanos` and `frameBuildNanos` separate those CPU costs.
`testIPCInclusiveScoreboard` adds real binary output framing at 64 KiB / 4 KiB chunk sizes.
These component results do not establish an end-to-end GUI throughput or latency claim.

The scalar parser entry point is a reference-test seam. Production always uses the
bulk path; there is no runtime parser-selection flag.

## File-fed GUI parsing fence

Generate and hash the payloads before timing:

```bash
python3 Scripts/benchmarks/consumer_ack_runner.py --generate .benchmark-results/payloads
# Run this inside the terminal pane being measured:
python3 Scripts/benchmarks/consumer_ack_runner.py harness .benchmark-results/harness.jsonl \
  --payloads .benchmark-results/payloads
```

This feeds pre-generated 64 MiB ASCII, SGR and mixed-Unicode files with `/bin/cat`, then
waits for a DSR cursor report. Sample zero warms up; samples one through five are measured.
`write_ms` ends at producer completion; `consumer_ms` ends after ordered parsing answers
the query. Neither boundary establishes GPU presentation. Cat startup and fence round
trip are included. Each receipt contains byte count, SHA-256, actual grid and timing.

Match font, size, opacity, blur, padding, scrollback budget, window geometry and visibility.
Use the same payload manifests before and after; do not normalize unlike hardware using
an assumed multiplier. Harness’s mandatory consumers now throttle PTY reads when behind,
but producer completion can still lead parsing by the bounded in-flight budget.

For a recorded coding-agent UI, add `--agent-session path/to/session.cast` during generation.
The fixture documentation must state whether it includes an actual model turn. Generation
removes recorded DSR queries so an earlier query cannot falsely satisfy the final fence;
the original recording stays unchanged. Use `--case agent_session` to run it separately.

`terminal_stress_runner.py` remains a quick write-drain probe. Its Python generation can
cap the observed rate and it has no parsing fence, so it is unsuitable as the headline
measurement for engine or GUI improvements.

## Settled scale, startup and input

`harness_scale_runner.py` requires an explicit isolated home, bundle CLI and exact
app/daemon/host PIDs. It visits every pane, fills 10,000 styled lines and verifies its
parsing fence. It records 1/10/30/50 sessions with 30 seconds settling and a 60-second
CPU window. Physical footprint is recorded per process; report Harness-owned totals
separately from shells and agents. An optional agent command runs in the last ten panes.
Never direct benchmark commands into an existing personal agent session.

`harness_startup_runner.py` stops only the named benchmark GUI and reopens its bundle
against a pre-armed existing-shell probe. One warm-up and five samples use the shared
macOS `CLOCK_MONOTONIC_RAW` clock. This is warm GUI reconnect, not fresh shell startup.
The DSR polling adds at most 5 ms quantization. `--prompt-metrics` additionally records
an outer observation of successful prompt-frame CPU submission; that is not visible
scanout. The final GUI is stopped when the runner finishes.

`HARNESS_FRAME_SIGNPOSTS=1` is diagnostic instrumentation, disabled by default. Native
input measurements use `echo-sample` rows in `logs/frame-metrics.jsonl`; require matching
surface identity and a newer output generation. Ignore the aggregate
`echo-submission-proxy` rows when counting samples. These timings are CPU submission
proxies, not key-to-photon latency. Record idle and ten background output floods separately.

Keep full logs under ignored `.benchmark-results/`; copy scoped raw JSON receipts,
conditions and honest target outcomes into `docs/benchmarks/` for review. A missed target
stays a missed target; unlike measurement layers cannot establish an overall winner.
