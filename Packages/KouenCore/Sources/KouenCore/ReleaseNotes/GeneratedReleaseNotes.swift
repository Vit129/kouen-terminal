// Generated from the CHANGELOG.md [4.24.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.24.0",
        changelogDigest: "667464705cf9284e",
        sections: [
            Section(title: "Added", items: [
                "Consolidate sidebar projects and add clone and create actions (6d1a715)",
                "Consolidate session history in the sidebar (dc47c60)",
                "Add Review Changes and PR feedback with IPC 15 (fd16f5d)",
            ]),
            Section(title: "Documentation", items: [
                "Archive older changelog entries (5b2bd1f)",
                "Point agent memory path to unified-memory-vault (#154) (e675adc)",
                "Update project behavior and shortcut references (82a78ad)",
            ]),
            Section(title: "Fixed", items: [
                "Bound history storage and close subprocess pipes (4abcc79)",
                "Stabilize browser pane navigation and lifecycle (7b86569)",
                "Clear synchronized terminal output after SIGINT (32f4484)",
                "Run ProcessRunner pipe readers on dedicated threads (6591580)",
                "Reap PTY children on dedicated threads instead of the GCD pool (509bfd7)",
            ]),
        ]
    )
}
