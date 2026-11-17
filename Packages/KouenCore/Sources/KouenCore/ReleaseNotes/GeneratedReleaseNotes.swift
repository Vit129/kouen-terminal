// Generated from the CHANGELOG.md [4.23.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.23.0",
        changelogDigest: "3469f19d9b36efaf",
        sections: [
            Section(title: "Added", items: [
                "Let users hide the menu bar icon (45fb779)",
            ]),
            Section(title: "Changed", items: [
                "Brief 2 hot-path fixes (fingerprint, cwd probe, debounced commits, task request sharing, git refresh gate, dock badge, spool cap) (078177e)",
                "Tear down LSP on editor hide, reuse client, bounded shutdown, cached graph lookup (330fd2e)",
                "Release markdown webview/QuickLook when hidden, skip redundant symbol scan, cheaper dirty check, cached regexes (f956e0e)",
                "Drop bad stdio frames and cap sizes, shell timeout and output cap, readFile cap, SSE parked wait and request deadline (18139ff)",
                "Finish incremental history and resource lifecycle fixes (700a303)",
            ]),
            Section(title: "Fixed", items: [
                "Stream JSONL parsing and bound history scan memory (c7dbda6)",
                "Keep real exit code on truncated output; drain grace after exit (23bdec8)",
                "Allow runCommand up to 600s; keep 120s for quick helpers (764b95c)",
                "Bound terminal image retention and release idle buffers (70cfbbc)",
                "Bound SSH socket detection and notch state retention (f0fb764)",
                "Release resources when panes close (e36acbf)",
                "Isolate pairing loop wakeups across restarts (8a1a640)",
                "Linux build of history index and stale release-notes digest (0e471e6)",
                "Autoreleasepool shim for Linux history scanner (28f2c1e)",
                "Keep agy turn helpers outside the SQLite3 guard (6611167)",
                "Guard Apple-only MobileBridge files for Linux; widen ProcessRunner timeout margin (002e0c7)",
                "Guard TranscriptFileWatcher tests for Linux (234b886)",
                "Skip SQLite-FTS history tests on Linux (9d095bc)",
                "Disable automatic Graphify in start menu (274a772)",
            ]),
        ]
    )
}
