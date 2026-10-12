// Generated from the CHANGELOG.md [4.21.4] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.21.4",
        changelogDigest: "ea27e519cc9a4f5a",
        sections: [
            Section(title: "Added", items: [
                "Group Preview links by agent, each at its newest version (9f49576)",
                "Show Antigravity brain artifacts in Preview (7b7e4f0)",
            ]),
            Section(title: "Fixed", items: [
                "Report the idle→working edge so tabs stop showing idle mid-task (3ea2889)",
                "Start the Companion at daemon boot when the setting is on (f05b102)",
                "Strip private-parameter CSI so kitty-keyboard codes don't leak (39c191f)",
                "Preview lists every artifact link at its newest version (c76075e)",
                "Limit Companion file reads to the session cwd and agy's brain dir (b824503)",
            ]),
        ]
    )
}
