// Generated from the CHANGELOG.md [3.9.2] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.9.2",
        changelogDigest: "b34e6e95893e8074",
        sections: [
            Section(title: "Fixed", items: [
                "Terminal flash eliminated",
                "Removed 5 BLINKDBG debug log statements left in production code (HarnessTerminalSurfaceView, PaneLifecycleManager, FilePreviewCoordinator)",
            ]),
        ]
    )
}
