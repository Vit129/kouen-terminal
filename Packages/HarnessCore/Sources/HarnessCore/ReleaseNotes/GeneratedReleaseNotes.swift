// Generated from the CHANGELOG.md [1.11.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "1.11.0",
        changelogDigest: "1cbb5667d1bbf5d4",
        sections: [
            Section(title: "Changed", items: [
                "Inline images and clipboard writes parse 7–10× faster",
                "Find-bar keystrokes search the buffer 1.9× faster",
                "Output floods no longer schedule per-chunk work on the main thread",
                "Scrollback compaction streams the log's tail instead of reading the whole file",
                "Renderer encode path sheds its steady-state allocations",
            ]),
            Section(title: "Fixed", items: [
                "A stale hyperlink can no longer point at a different URL",
            ]),
        ]
    )
}
