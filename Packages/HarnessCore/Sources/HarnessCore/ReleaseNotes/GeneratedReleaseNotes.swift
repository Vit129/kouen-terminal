// Generated from the CHANGELOG.md [3.1.1] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.1.1",
        changelogDigest: "f830f41e46392be7",
        sections: [
            Section(title: "Fixed", items: [
                "Long-session memory growth",
                "Scrollback ring buffer never shrank",
                "Background CPU from shell-cwd polling",
            ]),
        ]
    )
}
