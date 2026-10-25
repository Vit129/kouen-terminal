// Generated from the CHANGELOG.md [4.22.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.22.0",
        changelogDigest: "a9226930ef0f9819",
        sections: [
            Section(title: "Changed", items: [
                "Establish QA architecture guard and extract KouenGit package (f6b40e3)",
                "Extract KouenCompositor, eliminate onboarding fork, and purify design token logic (2c7640f)",
                "Decouple MainSplitViewController from GitPanelView and hoist pure parsers to KouenGit (f6400a0)",
                "Purify KouenIPC, extract MobileBridge web assets, and unify Layer 2 tokens (c95e9eb)",
            ]),
            Section(title: "Documentation", items: [
                "Update copyright notice with co-authors (91f453d)",
            ]),
            Section(title: "Fixed", items: [
                "Resolve claude audit findings (swiftui font import, git background execution, worktree lock parsing) (aa779fb)",
            ]),
        ]
    )
}
