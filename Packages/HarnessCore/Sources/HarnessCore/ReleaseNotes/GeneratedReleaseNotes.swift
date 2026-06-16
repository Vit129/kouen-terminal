// Generated from the CHANGELOG.md [3.2.1] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.2.1",
        changelogDigest: "a7c3e1f04b2d9801",
        sections: [
            Section(title: "Fixed", items: [
                "UAF crash on pane rebuild (deferred dealloc of retired PaneContainerView)",
                "UAF crash on tab bar rebuild (deferred dealloc of retired TabPillView)",
                "Off-main-thread layout() crash — Thread.isMainThread guard on 15 custom NSView subclasses",
            ]),
        ]
    )
}
