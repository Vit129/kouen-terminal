// Generated from the CHANGELOG.md [3.11.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.11.0",
        changelogDigest: "30d9c63580090721",
        sections: [
            Section(title: "Added", items: [
                "Floating Terminal ⌘⌥F — NSPanel workspace persists frame across toggles (68c4906)",
                "Tab Overview ⌘⇧\\ — thumbnail grid of all open tabs, click to switch (68c4906)",
                "Block output overlay — per-command tint, rounded border, ⌘-click block select, collapse/expand triangle, Copy / AI ✦ / Re-run action bar (196c362, 0e608ce, 49d25b2)",
                "Vi modal editing ⌘⌃V — Esc/hjkl/wb/x/i/a/A with visual mode toggle (5a7eb10)",
                "OSC 26 agent protocol — emulator parses identity/status/prompt; drives status dot + agent hooks (b6154c2)",
                "Fork Tab ⌘⇧K — new tab at active pane CWD (b6154c2)",
                "Agent approval bar — slide-up Allow (↵) / Deny (^C) on OSC 26 waiting_input (b6154c2)",
                "Zoxide integration in directory picker + ⌘↩ opens selection in new tab (e64bbc8)",
            ]),
            Section(title: "Fixed", items: [
                "CPU peg (99.4%) — BlockTintOverlay called emulatorSync { promptRows } on every mouse move (60–120 Hz); now cached and refreshed once per command (b6154c2)",
                "FrecencyDirectoryStore wrote JSON synchronously on main thread on every cd — debounced 0.5 s + background write (b6154c2)",
                "Tab Overview blocked main thread on open — thumbnails now render deferred async after panel appears (372886a)",
                "Scrollbar went dark after block overlay installed — onScrollChanged was replaced instead of chained (b6154c2)",
            ]),
        ]
    )
}
