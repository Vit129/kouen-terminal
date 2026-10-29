// Generated from the CHANGELOG.md [4.22.3] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.22.3",
        changelogDigest: "3a541d690d9fe5bd",
        sections: [
            Section(title: "Added", items: [
                "Auto-expand revealed directories and add pasted images section (2473a54)",
            ]),
            Section(title: "Documentation", items: [
                "Record lesson on WKWebView transparent repaint and compositor waking (b0c0d6b)",
            ]),
            Section(title: "Fixed", items: [
                "Stop ScriptingTests crashing/flaking so the full suite is green (16860d7)",
                "Wake compositor on window attach and commit to prevent black screen (67f2b45)",
                "Resolve compositor kick drop, sidebar reveal race, and main-thread I/O (6febe9b)",
            ]),
        ]
    )
}
