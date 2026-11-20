// Generated from the CHANGELOG.md [4.24.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.24.0",
        changelogDigest: "0932f34bb50f15d8",
        sections: [
            Section(title: "Added", items: [
                "Consolidate sidebar projects and add clone and create actions (7c6582a)",
                "Consolidate session history in the sidebar (c92eea4)",
                "Add Review Changes and PR feedback with IPC 15 (86894bc)",
            ]),
            Section(title: "Documentation", items: [
                "Archive older changelog entries (5b2bd1f)",
                "Point agent memory path to unified-memory-vault (#154) (e675adc)",
                "Update project behavior and shortcut references (5543a3f)",
            ]),
            Section(title: "Fixed", items: [
                "Bound history storage and close subprocess pipes (50bfba3)",
                "Stabilize browser pane navigation and lifecycle (c509d36)",
                "Clear synchronized terminal output after SIGINT (5c7c1ae)",
                "Run ProcessRunner pipe readers on dedicated threads (eb25258)",
                "Reap PTY children on dedicated threads instead of the GCD pool (1c69f3c)",
            ]),
        ]
    )
}
