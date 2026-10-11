// Generated from the CHANGELOG.md [2.3.1] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "2.3.1",
        changelogDigest: "20842f0ac0862ed8",
        sections: [
            Section(title: "Fixed", items: [
                "Launching against an older or unavailable session service shows a clear recovery state instead of an empty window",
                "An explicit service restart removes only the stopped owner's unchanged control socket under the startup lock",
            ]),
        ]
    )
}
