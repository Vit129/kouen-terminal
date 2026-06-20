// Generated from the CHANGELOG.md [3.5.1] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.5.1",
        changelogDigest: "0fbfccbc3ae0d0a6",
        sections: [
            Section(title: "Fixed", items: [
                "6 RL-040 zombie crashes on macOS 26 / Swift 6.3.2 (@objc thunk executor check)",
                "14 Remote SSH settings bugs (hitTest, rename overwrite, observer leak, constraints)",
                "5 additional Remote bugs (concurrent connect, dead endpoint, error feedback)",
                "Terminal blinks on ⌘D split / ⌘W close / tab switch (presentsWithTransaction)",
                "Browser tab close button unclickable (CASE-038 gesture recognizer)",
                "Notification attributed to Script Editor instead of Harness (osascript)",
                "Pre-existing Sendable compile errors in ClaudeDirectClient/HarnessAIChatView",
            ]),
        ]
    )
}
