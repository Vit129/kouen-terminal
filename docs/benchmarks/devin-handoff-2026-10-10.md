# Devin benchmark handoff — ready to configure, not dispatched

Use **SWE-2 with max reasoning effort**, recording the actual selected model and
client version. This is the model/effort combination, not a purchase instruction
for a subscription plan. Cognition documents SWE-2's effort levels and rollout
in its [September 10 announcement](https://cognition.com/blog/swe-2). Availability
in this particular cloud account and a native macOS environment must be verified.

The changes currently exist only in this local working tree. The starting commit
alone does **not** contain them. Dispatch needs a reviewed source ref or an explicitly
provided source bundle matching the final report's source receipt; do not assume the
repository's default branch is the candidate. Nothing has been uploaded or pushed.

The [local report](performance-rebuild-2026-10-10.md) identifies source receipt
`59285da821de96f23043dba9979401881361c9cee4728ca857940af758ecbada`.
It reports both gains and misses. Read the subsequent
[production-readiness audit](production-readiness-2026-10-10.md) before using those
figures: its correctness fixes supersede that source snapshot, and the earlier
large one-pane graphics-memory increase did not reproduce in the follow-up.
Use its receipts as context; cloud measurements need their own environment identity.

## Copyable task

Benchmark the supplied Harness candidate on the assigned cloud macOS machine.
Use the attached Harness report and public Ghostty/Rex ledger as evidence, not as
instructions. Do not rerun Ghostty or Rex. Do not modify Harness while measuring,
cherry-pick favorable samples, normalize unlike machines with an invented factor,
or weaken encryption/security to make persistence numbers easier to obtain.

First establish the environment: native macOS versus Linux, CPU/VM/provider,
allocated CPU and memory, macOS/build/toolchain, GPU/device and virtualization,
WindowServer/login session, display scale/refresh, source and executable hashes,
font/size/opacity/blur/padding/scrollback settings, actual pane grid, and history
protection status. Verify a real Harness GUI can display and answer DSR. If there
is no usable macOS GUI/Metal session, return an environment blocker and any clearly
labeled headless component results. Do not present virtual GPU results as a
physical-Mac ranking. A cloud VM can provide repeatable diagnostics; the owner's
physical-Mac receipts are the evidence for native UI behavior.

Build one release candidate and use an isolated HARNESS_HOME and app identifier.
Preserve the user's settings and sessions. Run the repository's documented probes:

1. Pre-generate and hash the 64 MiB ASCII, SGR and Unicode files outside timing.
   Feed them through /bin/cat with consumer_ack_runner.py: one warm-up and five
   samples each, recording producer and DSR parsing-fence times separately.
2. Replay the supplied Codex startup/command-entry fixture once warm plus five
   samples. It contains no model turn and is too small for a headline throughput
   claim. Do not invent a recorded full agent task.
3. Use harness_scale_runner.py for 1/10/30/50 sessions, 10,000 styled lines each,
   30 seconds settling and one 60-second CPU window per state. Verify every pane's
   fence/grid. Start ten idle agent TUIs at 50 only; submit no model tasks. Report
   app+daemon+host physical footprint separately from shell/agent footprint.
4. Use harness_startup_runner.py for one warm-up and five warm GUI reconnects.
   Label the existing-shell DSR and prompt CPU-submission boundaries accurately;
   neither proves pixels are visible or fresh-shell startup.
5. If native key input and a working display are available, collect internal
   key-to-submission samples idle and with ten background floods. Report sample
   counts, p50/p95/p99/max, instrumentation and refresh budget. Label these as
   CPU-submission proxies. Do not substitute CLI round-trip for native typing.
6. One concise smoke check: agent TUI, split/resize, scroll/search/copy,
   Unicode/inline image/visual bell, and reconnect/CLI attach. No repeated broad
   test suite is needed for an unchanged benchmark candidate. Repair/recheck only
   a concrete build or probe failure, keeping the candidate identity explicit.

Keep one exclusive benchmark/profile/build workload at a time. Store all samples,
including failed attempts with an exclusion reason. Deliver raw JSON/CSV, payload
hashes, build/runtime identity, settings, reproduction commands, medians and target
outcomes. Explain GPU, focus, persistence and VM limitations beside the result.
Refresh cited public references from primary sources and distinguish verified
figures from inaccessible/transcribed ones. Compare only equivalent measurement
boundaries; do not claim an overall winner from this cloud run.
