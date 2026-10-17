// Generated from the CHANGELOG.md [4.21.8] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.21.8",
        changelogDigest: "119cd4f853a03d57",
        sections: [
            Section(title: "Added", items: [
                "Route file types via shared FileViewRouting; map .gs to JavaScript (3aa3e6e)",
                "Cmd+click and viewer cover Office/Apple docs, AI data files, Xcode files and more languages (eb4172e)",
                "Multi-agent transcript and usage metrics across CLI, Web, and Desktop (02c98d8)",
                "Support AI and non-interactive execution in make start (3750b49)",
            ]),
            Section(title: "Documentation", items: [
                "Kouen-file-open — three open paths and where each extension list lives (d4825b8)",
            ]),
            Section(title: "Fixed", items: [
                "Re-check Tailscale every 2s for real and stop leaking late-bound listeners (971ec5d)",
                "Follow Tailscale IP/Serve changes and keep pairing URL and shell wrapper as designed (8a2887a)",
                "Stop leaking pipe fds that froze the app on \"Reconnecting\" (a7989b6)",
                "Close the port scanner's pipe explicitly too (d26932f)",
                "Map any LaunchAgent to its repo, not only .sh jobs (be47019)",
                "Cmd+click opens bare .gs/xlsx/heic/RAW filenames — extension was missing from the link allowlist (6b3064f)",
                "Handle graphify refresh before rebase and auto-default build/commit in release (5f6394b)",
            ]),
        ]
    )
}
