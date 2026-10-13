// Generated from the CHANGELOG.md [4.21.6] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.21.6",
        changelogDigest: "43649eca05cb7602",
        sections: [
            Section(title: "Added", items: [
                "Companion chat UI — image chips, model/mode meta, agent commands from the phone (8f7f13b)",
                "Model/effort picker for agy and keep the Companion on the open session across reloads (c735460)",
                "Read agy's model list from agy models instead of a hand-copied one (d4e1db1)",
            ]),
            Section(title: "Fixed", items: [
                "Give the preview daemon its own Companion port so it doesn't collide with installed Kouen (535885a)",
                "Drop TUI spinner/border redraw frames from the Companion feed (b1843fa)",
                "Preview daemon picks Companion port 8081 itself, however it was started (064bc4d)",
                "Key Companion credentials by host:port and drop rejected ones so the QR can pair (06ffbcd)",
                "Agy model switch when the detector misses the pane; keep Claude transcripts on in preview (68eefa2)",
                "Fall back to the page's agent hint when the detector reports an unsupported kind (78f61b5)",
                "Drop Claude harness plumbing, show agy tool-only replies, survive agy db writes (2fb464d)",
            ]),
        ]
    )
}
