// Generated from the CHANGELOG.md [1.12.1] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "1.12.1",
        changelogDigest: "c174065d9efa81cb",
        sections: [
            Section(title: "Fixed", items: [
                "Re-importing your terminal config no longer wipes output triggers or per-host profiles",
                "Slow memory growth across many pane open/close cycles",
            ]),
        ]
    )
}
