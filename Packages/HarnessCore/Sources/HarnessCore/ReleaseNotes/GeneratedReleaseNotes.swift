// Generated from the CHANGELOG.md [3.2.2] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.2.2",
        changelogDigest: "b4e9c2a07f1d3a02",
        sections: [
            Section(title: "Fixed", items: [
                "Blink timer UAF crash (generation-token guard, no assumeIsolated)",
                "renderLink/blinkTimer deinit off-main (sync dispatch to main)",
                "NC observer UAF — removed redundant assumeIsolated wrappers",
                "OverlayWindow/StatusLineView timer leak (added deinit)",
                "GitPanelView FSEvents leak (added deinit)",
                "TerminalHostView NC observer not removed (added removeObserver)",
            ]),
        ]
    )
}
