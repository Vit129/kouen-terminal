// Generated from the CHANGELOG.md [4.22.2] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.22.2",
        changelogDigest: "80eb6fddff968788",
        sections: [
            Section(title: "Fixed", items: [
                "Resolve ProcessRunner regressions in timeouts, output draining, and async concurrency (993bfd9)",
            ]),
        ]
    )
}
