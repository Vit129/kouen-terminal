// Generated from the CHANGELOG.md [2.3.2] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "2.3.2",
        changelogDigest: "b1173312f668a6f5",
        sections: [
            Section(title: "Fixed", items: [
                "App updates stage the current daemon and session-host helpers before connecting",
                "Splitting and closing panes preserve the surviving terminal views, keyboard focus, and render surfaces",
                "Closing a split stops its terminal IO even while its last frame is animating out",
                "Scrolling and reflow correctly upload relocated cached rows to the GPU, keeping terminal text and graphics aligned while retaining row reuse",
                "macOS service restarts recognize exited processes before their parents reap them, preventing false shutdown timeouts",
            ]),
            Section(title: "Changed", items: [
                "Release validation exercises session survival, pane lifecycle, and the installed DMG",
            ]),
        ]
    )
}
