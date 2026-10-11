# Terminal quality follow-up audit

The follow-up audit fixed the reported startup layout jump and one security-review finding. The changes remain local and unreleased. No GitHub Actions workflow, publishing, benchmark comparison, or release was run.

## Startup and layout corrections

The main split previously applied the saved sidebar state on a queued main-thread callback, after the window could become visible. The first frame could therefore show an equal split and the wrong tab-row arrangement. The controller now applies visibility synchronously, establishes usable initial frames, and resolves the divider against the final window bounds before presentation. Restored secondary windows receive their saved frame before being shown.

The coordinator now begins with an empty snapshot instead of an invented workspace and pane. This removes the needless initial attachment attempt and its temporary reconnecting state. The launch window survives settings and appearance notifications while awaiting its first real snapshot. The default resize overlay ignores grid changes while the window is hidden.

The startup checks also exposed conflicting constraints. Collapsing the sidebar now clips controls at their minimum usable width; new tab pills start with usable bounds; and the hidden connection notice can relax its width limit during installation. The final focused layout run reported no constraint warnings. Loading the window no longer rewrites the saved sidebar preference.

## Security review

One specialized security reviewer examined the working-tree changes. The confirmed finding was fixed and covered by regression tests.

| Severity | Location (file:line) | Finding |
| --- | --- | --- |
| P2 — fixed | IPCCodec.swift:54; TerminalHostView.swift:1691 | Malformed output sequence spans could overflow client sequence arithmetic and crash the GUI. All JSON and binary reply decoding paths now reject overflowing spans. Acknowledgement thresholds use a safe difference, including valid spans ending at UInt64.max. |

The review found no additional concrete security issues in the reviewed anchors, command metadata, Unicode, shell integration, font controls, output receiver, or related transport changes. This is a scoped code review, not a security certification.

## Verification

- **93 distinct focused tests passed; zero failures or skips.** The 50 transport/receiver tests cover malformed binary and JSON frames, valid sequence limits, consumption acknowledgements, replay, and bounded receiver behavior. The final 43 app/resize tests cover initial sidebar geometry before the first run-loop turn, empty startup state, tab layout, appearance, and live-resize rendering. Results identify their logs in [test-results.json](test-results.json).
- **Final optimized macOS build passed:** `swift build -c release`, 72.30 seconds. Local app packaging and ad-hoc signing succeeded. The existing vendored MCP `NetworkTransport.swift` capture warning remains; it is unrelated to these changes.
- `git diff --check` passed.
- The [source manifest](source-sha256.txt) records 884 source files. Earlier implementation and benchmark receipts retain their own source snapshots and are not substituted for this audit's results.

## Native app observations

An isolated app bundle used `com.robert.harness.qolaudit` and `/tmp/harness-qol-audit`, leaving normal Harness sessions alone. During this audit, actual AppKit interaction verified:

- Unicode output containing CJK, a skin-tone emoji ZWJ sequence, accented Latin, Thai, and Indic text; native Option-E composition committed and rendered `café`.
- The command context menu selected the precise command output. Whole-buffer search found two occurrences; command-scoped search found only the output occurrence.
- Font fallback and OpenType settings accepted valid values, rejected invalid feature syntax, persisted the valid configuration, and repainted text.
- Typing and echo in one pane completed while another pane was still producing a 6,000-line paced output stream. This was a responsiveness smoke check, not a latency benchmark.
- The final rebuilt app reopened its existing two-pane session with the sidebar hidden, toggled into sidebar mode, and reopened again with the saved 264-point sidebar. Output remained available and a new command executed after restart. The startup regression test checks geometry before presentation; the UI observations confirm the resulting native window and restoration.

The test GUI was closed and its isolated helpers stopped after verification. The local test bundle remains in `.benchmark-results/terminal-quality-audit/Harness.app`.

## Scope limits

No claim is made that Harness outperforms Ghostty. No broad benchmark matrix was rerun. Full CJK input-method candidate interaction, remote SSH upgrade scenarios, a new Linux build, distribution signing, and notarization were not performed in this pass. Native pointer-drag automation returned `noWindowsAvailable`; live-resize coverage comes from the focused rendering tests and observed pane-width changes during sidebar toggles, not a claimed successful mouse-drag check. The earlier implementation receipt records two unavailable-font skips in its separate test set.
