// Generated from the CHANGELOG.md [3.10.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.10.0",
        changelogDigest: "f4a571039c16a7b0",
        sections: [
            Section(title: "Added", items: [
                "Full-cycle --no-bump flag + start.mjs asks version bump before full run (10346cb)",
                "SwiftUI settings foundation — SettingsModel + Terminal page (4435619)",
                "SwiftUI Settings — Appearance page (S2) (dd1ca45)",
                "SwiftUI Settings S3–S5 — Colors, Keys, Agents pages (c572ed4)",
                "SwiftUI Settings S6–S9 — Advanced, Remote, root wiring, AppKit deleted (94c9491)",
                "Migrate WorkspacePillButton to SwiftUI (204dcf2)",
                "Migrate sidebar section label + footer to SwiftUI (a072edf)",
                "Migrate sidebar tab bar from NSSegmentedControl to SwiftUI Picker (a6d59a9)",
                "Open With Harness for source files + file preview routing (36fde38)",
                "Open With file → terminal at git root + tree reveals file (cabcb86)",
                "File tree roots at git root, expands to CWD on cd (d3a700f)",
                "AppKit → SwiftUI wave 2 — 4 UI components migrated (760705a)",
            ]),
            Section(title: "Changed", items: [
                "Migrate Toast+About to SwiftUI, delete dead NotificationBellButton + DragReorder stub (94f4d54)",
            ]),
            Section(title: "Documentation", items: [
                "Update knowledge — CASE-042/043 + cwd-worktree-bleed companion fix + memory decisions (c67a980)",
                "Update CONTEXT — SwiftUI Settings S6–S9 complete (654fe82)",
                "Update CONTEXT, knowledge, plans, graphify after sidebar SwiftUI wave 2 (95290db)",
                "Update CONTEXT — SwiftUI wave 2 complete (4 components, −424 lines) (139ab6a)",
            ]),
            Section(title: "Fixed", items: [
                "Flush NSHostingView layout after sidebar animation completes (bef888a)",
                "Sidebar animation frames drop on macOS 26 — Task {@MainActor} → assumeIsolated (d5833b0)",
                "Sync Metal terminal frames with CA during sidebar animation (28d0233)",
                "Point Bug 1 robot guard to BrowserIntegrationController where removeValue lives (ad792c9)",
                "Remove presentsWithTransaction from animated sidebar — was blocking main thread every vsync (b9f94cd)",
                "Panel to response slow and move pane to left/right corner (0f71782)",
            ]),
        ]
    )
}
