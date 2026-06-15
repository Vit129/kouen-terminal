// Generated from the CHANGELOG.md [3.1.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.1.0",
        changelogDigest: "afb7d800a77d6618",
        sections: [
            Section(title: "Added", items: [
                "Session status indicators",
                "Multi-branch / multi-agent visibility",
                "⌘⇧I Notifications Inbox",
                "⌘F Find in Files",
                "⌘P Command Palette",
                "⌘⌥W Close Pane",
                "Close confirmation dialog on all paths",
                "IDE-like Terminal Workbench docs",
            ]),
            Section(title: "Changed", items: [
                "⌘K removed",
                "⌘⇧U changed to ⌘⇧I",
                "⌘F",
                "⌘⇧T Reopen Closed Tab removed",
                "BoardModel.columnKind() made public; BoardModel.shellNames made public — all surfaces share one classification implementation",
                "BoardColumnKind.color extension added in HarnessApp for canonical status colors",
                "Docs consolidated: Modes and Migration summaries added to USAGE.md; MANUAL_TEST_PLAN moved to agent-memory",
            ]),
            Section(title: "Fixed", items: [
                "Sidebar session group header chevron rendered too large; fixed frame (10×10), removed scale-to-fill, weight reduced to regular",
                "Sidebar group header click hit-test used wrong coordinate space for add/options buttons; now uses convert(bounds:from:)",
            ]),
        ]
    )
}
