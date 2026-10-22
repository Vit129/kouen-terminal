// Generated from the CHANGELOG.md [4.21.12] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.21.12",
        changelogDigest: "2a4727f3a5d4e972",
        sections: [
            Section(title: "Added", items: [
                "Keep Mac awake while AI provider apps run alongside Kouen (bf06d3d)",
                "Opt-in closed-lid keep-awake via pmset disablesleep helper (a909285)",
            ]),
        ]
    )
}
