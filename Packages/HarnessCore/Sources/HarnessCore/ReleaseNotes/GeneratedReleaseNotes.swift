// Generated from the CHANGELOG.md [3.5.2] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.5.2",
        changelogDigest: "64f4b8313cd51941",
        sections: [
            Section(title: "Added", items: [
                "4-direction split pane",
            ]),
            Section(title: "Fixed", items: [
                "Window not showing on launch",
                "RL-040 keyDown/keyUp/mouseMoved/resetCursorRects crashes",
                "TerminalTabBarView.layout() crash",
            ]),
            Section(title: "Removed", items: [
                "Built-in AI chat sidebar tab (Harness connects AI via CLI agents + MCP/ACP instead)",
                "Search sessions field from sidebar header (⌘P palette is the primary search)",
                "Search panel sidebar tab (:grep command and ⌘P palette cover this)",
                "Notification bell from sidebar (Notch panel ⌘I is the single notification UI)",
                "MANUAL_TEST_PLAN.md",
            ]),
        ]
    )
}
