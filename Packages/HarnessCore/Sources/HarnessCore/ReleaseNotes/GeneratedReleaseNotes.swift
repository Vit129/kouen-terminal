// Generated from the CHANGELOG.md [3.3.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.3.0",
        changelogDigest: "ec4ff3407b0c26dc",
        sections: [
            Section(title: "Added", items: [
                "Single source of truth for keybindings (BannerShortcutRegistry.Keybinding)",
                "⌘W close pane/tab (iTerm2/Warp pattern), ⌘T new tab",
                "IDE-like navigation: folder double-click cd, ⌘P zoxide jump, :cd to shell",
                "Interactive cheat sheet (make cheatsheet)",
                "Welcome banner with categorized shortcuts (Sessions/Navigation/Search & Navigate/Shell)",
                "Robot Framework: keybinding_crash_regression.robot",
            ]),
            Section(title: "Fixed", items: [
                "Zombie crash (RL-040/041): guard window != nil in keyDown/keyUp",
                "full-cycle.sh now auto-tags + creates GitHub release",
            ]),
        ]
    )
}
