// Generated from the CHANGELOG.md [4.22.14] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.22.14",
        changelogDigest: "0d942fcd9fe6a00f",
        sections: [
            Section(title: "Fixed", items: [
                "Read only the log tail so a huge job log no longer spikes app memory (d78b1d3)",
                "Let make start release from a worktree when only graphify-out is dirty in main (69b2665)",
            ]),
        ]
    )
}
