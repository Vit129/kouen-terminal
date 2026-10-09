// Generated from the CHANGELOG.md [4.21.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.21.0",
        changelogDigest: "bdfb921b837abf41",
        sections: [
            Section(title: "Added", items: [
                "Add multi-select AI filter chips to history tab (b430be0)",
                "Project folder auto-sync, fold fleet into projects & auto-open chrome on rc (P54) (d1ab7f8)",
            ]),
            Section(title: "Changed", items: [
                "Optimize startup cold scan, keystroke search latency, and file matching (e39e891)",
                "Eliminate tab-open lag and search keystroke render bottlenecks (6a2dc1d)",
                "Stop git and IPC work from stalling the daemon (P53 Tier 1/3/4) (7de2d80)",
                "Cut per-chunk and per-keystroke work in the terminal (P53 Tier 2-4) (c2bdcc6)",
                "Move git and daemon round-trips off the main thread (P53 Tier 1/2/5) (2b72cf3)",
            ]),
            Section(title: "Fixed", items: [
                "Resolve code review defects in history scanner, search ranking, and session cache (a8be384)",
                "Only prune sessions whose transcript is gone from disk (7842c89)",
                "Regenerate notes so they match the v4.20.16 CHANGELOG block (666b20c)",
                "Guard SQLite3 import and test with canImport(SQLite3) for Linux headless CI (8cde11a)",
                "Use Sendable box for notification check on Linux & increase timeout in GitStatusProvider test (77a1e51)",
                "Stop new panes landing in .kouen-worktrees after a worktree is removed (9a80861)",
                "Stop the git status timeout from crashing the app (fd9aa12)",
                "Refresh installed wrapper scripts on launch (a754dd5)",
                "Don't touch UNUserNotificationCenter from an unbundled binary (c400452)",
                "Build the What's New block from real commits, not a placeholder (626404a)",
            ]),
        ]
    )
}
