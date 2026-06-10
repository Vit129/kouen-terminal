// Generated from the CHANGELOG.md [1.10.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "1.10.0",
        changelogDigest: "c284bda8c9c85ca6",
        sections: [
            Section(title: "Added", items: [
                "Shell integration is auto-injected at spawn",
                "Parity long tail (engine/core half): the numeric keypad honors DECKPAM/DECKPNM — application mode emits the xterm SS3 forms, numeric mode stays byte-identical to plain typing, and the kitty protocol reports the functional KP codepoints; OSC 1337 CurrentDir= reports the cwd (absolute paths only, the OSC 7 trust policy) and SetUserVar= stores per-surface user variables (base64-decoded, name/size/population bounded, cleared by RIS) that the GUI surfaces as pane-scoped @name user options — readable from #{@name} format tokens; new windowInheritCWD setting (default on, matching the shipped behavior and Ghostty's default) lets new tabs/windows be pinned to defaultCWD instead of inheriting the focused pane's directory",
                "persist-scrollback option (default on, per-pane with global fallback): turning it off stops writing a surface's scrollback to disk AND synchronously wipes what's already there — the secrets-at-rest control documented in the new docs/SECURITY-POSTURE.md (which also records the no-sandbox rationale, the hardened-runtime/notarization and Sparkle EdDSA/HTTPS audit, the Services surface, and the control-socket posture)",
                "Scripts/scorecard.sh + docs/SCORECARD.md: the Harness-vs-Ghostty comparative scorecard — cold start (per-phase from startup.log vs wall-clock-to-window), sustained PTY throughput (the cross-terminal stress runner, including the issue #27 re-measure set), idle power (powermetrics, app + daemon summed), long-session memory, and Harness-side input-to-photon percentiles",
                "VT conformance polish (engine): DA1 now identifies as a VT220-class terminal with Sixel and ANSI color (CSI ?62;4;22c); DA3 (CSI = c) replies with DECRPTUI; DECRQM gains the ANSI (non-private) form (CSI Ps $ p) with the conformance-correct state-0 reply for unrecognized modes, and the private form now also reports modes 5/12/47/1047/1048/1049/1016; DECSET 1048 saves/restores the cursor; DECSET/DECRST 12 (att610) controls cursor blink; DECSET 5 (DECSCNM reverse video) and DECSET 1016 (SGR-pixel mouse) are tracked and reported (rendering/encoding land with the kit half); XTWINOPS CSI 22/23 t push/pop the title on a depth-capped stack and CSI 18/14 t report the text-area size in characters/pixels — the pixel report derives from the same host-supplied cell metrics inline images use (window resize/move remain deliberate non-goals)",
                "VT polish, kit/renderer half: any-event mouse tracking (DECSET 1003) now reports button-less pointer motion (deduped per cell), and SGR-pixel mouse (DECSET 1016) encodes pixel coordinates — taking precedence over 1006, degrading to cell coordinates when the host can't supply pixels; DECSCNM reverse video actually renders (the screen's default fg/bg swap, in every pipeline including resize previews and copy mode — explicit SGR colors keep their values); SGR blink (SGR 5) renders — blinking cells' glyphs hide on the off-phase, driven by a timer that exists only while blinking content is visible, and a phase flip re-encodes exactly the rows containing blink cells; dotted/dashed/undercurl underline patterns keep a continuous phase across cells instead of restarting at every cell boundary",
                "Session navigation from the prefix keymap",
                "Crisp text rendering now thickens glyphs",
                "System appearance mode",
            ]),
            Section(title: "Changed", items: [
                "The Option key now types composed characters by default",
                "Mechanical decomposition (renderer): the Metal renderer's CPU-side instance/cache value types (GPU instance layouts, per-row encode caches, upload-cache keys) moved to TerminalRenderInstances.swift — same definitions, zero logic change",
                "Mechanical decomposition (daemon + core): SurfaceRegistry's output monitoring and the version-banner one-shot moved to extension files (same members, same locks — the single-lock serialization is untouched); SessionEditor's split-tree algebra (the pure PaneNode walks/rewrites) moved to SessionEditor+SplitTree.swift; and HarnessSettings.init(from:)'s 35 uniform hand-written decodeIfPresent ?? fallback lines now funnel through a default-instance-driven keypath decoder — the typo class where a line decodes one key but falls back to a different field's default can no longer be written (migrations and deliberate non-default fallbacks stay hand-written)",
            ]),
            Section(title: "Fixed", items: [
                "Follow-macOS appearance now re-skins the terminal on the system light/dark flip",
                "A stale scrollback index can no longer crash a shipping build: HistoryRingBuffer's empty-buffer release trap is replaced by a graceful fallback to the most recently appended line (the debug assert stays)",
                "Unicode width tables are now derived from the Unicode Character Database",
                "Configured terminal fonts resolve through one shared TerminalFontResolver (#48): the requested family is matched once against its family/PostScript/full/display names — detecting CTFontCreateWithName's silent proportional substitution — and an unmatched family walks an explicit fallback chain (the default JetBrainsMono Nerd Font, then Menlo, then Monaco) before landing on monospace Menlo, the #37-era guarantee",
                "The Xcode scheme now runs ten test targets instead of four — engine conformance, reflow goldens, renderer parity, theme, onboarding, and compositor-parity suites were silently skipped in Product → Test (CI's swift test covered them; local Xcode runs did not)",
                "Sparkle is pinned to the same version (2.9.2, up-to-next-minor) in all three manifests (Package.swift, project.yml, project.pbxproj); they had drifted (2.6.0 in the Xcode path), letting SPM and Xcode builds ship different versions of the auto-update framework",
                "The stale-daemon PID-file identity check compares the exact executable basename instead of a spoofable substring match; the daemon's control socket is created under umask(0o177) so it never exists with broader permissions, even momentarily",
                "Scrollback persistence is fsync'd: appends reach stable storage before the debounce window closes, and compaction syncs the replacement file before the atomic rename — a daemon crash can no longer lose the last ~2 s of scrollback or leave a truncated log",
                "wait-for channels cap concurrent waiters (1 024) instead of accumulating blocked fds without bound; the agent scanner skips a tick when the previous scan is still running instead of queuing scans behind each other under load",
                "The onboarding installer and the in-app \"Install CLI\" flow no longer run launchctl and version probes on the main thread (up to ~8 s of beachball on first run); the menu-bar menu no longer performs a blocking daemon round-trip inside menuNeedsUpdate",
                "Structure changes in background tabs (e.g",
                "Store writes (options, hooks, environment, paste buffers) are debounced (150 ms) instead of hitting the disk synchronously under lock on every mutation; a graceful shutdown flushes all debounce windows",
                "Option/buffer save failures and remote-host lock degradation are logged to stderr instead of being silently swallowed",
            ]),
            Section(title: "Performance", items: [
                "Frame building with the find bar open no longer scans every search match per cell (O(matches × cells) — hundreds of matches over a 19 K-cell viewport while scrolling): highlights are bucketed once per build into per-row sorted merged column intervals that appendRow consumes with a monotonic cursor",
                "Idle-efficiency bundle: the cursor-blink timer now exists only while its pane is effectively focused and un-occluded (unfocused panes used to tick a 0.53 s timer forever just to early-out — 20 background panes ≈ 40 pointless main-runloop wakeups/s); the daemon's 500 ms monitor tick skips the registry lock and option reads entirely when no fresh output/bell arrived and silence monitoring is disarmed (the orphan sweep is preserved — racing-read entries are born flagged); and the shell cwd tracker parks its 2 Hz process-tree scan while the app is inactive, relaxes to 0.5 Hz after ~5 s of no cwd movement, and snaps back on tab/pane creation, focus change, or any observed change",
                "Git branch labels are event-driven instead of polled: the app watches each repository's resolved HEAD file (one watcher per repo/worktree, shared by all its tabs) and reads the branch in-process — no more git rev-parse subprocess per tab every 2 seconds, and labels update instantly on checkout instead of up to 2 s late",
                "The GUI subscribes to the daemon's snapshot-push channel (the same one attach-window uses), so external structure changes (harness-cli split-pane against a GUI session) arrive instantly via push instead of being discovered by the old 0.5 Hz blind full-snapshot poll — which is gone, along with its forever-ticking fetch+decode even while idle and inactive",
                "The PTY-output and keystroke IPC read loops consume frames in O(1) amortized via an offset-tracking read buffer (IPCReadBuffer) instead of Data.removeFirst's O(remaining) byte shift per frame — quadratic under flood on both the app's subscription loop and the daemon's per-client loop",
                "The status line no longer constructs a DateFormatter per #{time:…} evaluation (cached by format, ~0.3 ms per 750 ms tick) nor re-resolves #{host}/#{user} via syscalls each tick; the daemon logger reuses one ISO-8601 formatter",
                "On Linux, post-fork fd cleanup uses close_range(2) (kernel 5.9+, loop fallback) instead of up to 65 k close syscalls per shell spawn",
                "The benchmark suite is now enforceable: Scripts/benchmarks/compare_benchmarks.py plus make bench-record / make bench-check gate hot-path regressions (>15 %) against a committed baseline (benchmark-baselines.json, recorded deliberately on real hardware)",
            ]),
            Section(title: "Removed", items: [
                "Two dead empty-bodied functions that ran O(hosts × tabs) scans on every daemon sync (syncWaitingRings, PaneContainerView.refreshChrome), the stale video-* Makefile targets, and the 300 ms timing kick after tab/session creation (replaced by the notification-driven cwd scan)",
            ]),
        ]
    )
}
