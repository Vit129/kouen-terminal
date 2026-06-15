// Generated from the CHANGELOG.md [3.0.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.0.0",
        changelogDigest: "2d44e7e589e95255",
        sections: [
            Section(title: "Added", items: [
                "Terminal Workbench aggregation now collects the P4-P19 Vi/Unix/terminal/panel surface into one terminal-first workflow layer: :recent, :copy-path, :grep, :errors, :make, :attention, :ack, and the scriptable IDE-migrant profile",
                "Pane-aware workbench context resolves the focused terminal pane first, so cwd and current-file behavior follow the active project surface instead of a tab-level fallback",
            ]),
            Section(title: "Changed", items: [
                "Sidebar session groups keep a visible header from the first row, and the expand chevron swaps symbols instead of rotating inside layout",
            ]),
        ]
    )
}
