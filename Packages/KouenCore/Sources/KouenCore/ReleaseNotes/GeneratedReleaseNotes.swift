// Generated from the CHANGELOG.md [4.0.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.0.0",
        changelogDigest: "5608f5c03255cac5",
        sections: [
            Section(title: "Changed", items: [
                "Renamed the product from Kouen to Kouen (公園, \"public park\") — \"Kouen\" collided with Kouen.io, a real CI/CD platform whose CLI is literally named kouen",
                "New app icon and in-app brand mark, traced from the approved reference design",
                "Renamed the executables and CLI surface: Kouen → Kouen, KouenDaemon → KouenDaemon, kouen-cli → kouen-cli, kouen-mcp → kouen-mcp",
                "Renamed the bundle identifier namespace (com.vit129.kouen.* → com.vit129.kouen.*)",
                "Renamed the GitHub repository (kouen-terminal → kouen-terminal)",
                "Added a KOUEN_HOME environment variable (falls back to the pre-rename KOUEN_HOME so existing shell profiles keep working)",
                "Migrated the personal script/plugin/project-config directory (~/.config/kouen/ → ~/.config/kouen/, with a fallback to the old location so existing scripts and plugins keep loading unmoved)",
                "Renamed the control socket (kouen.sock → kouen.sock) and shell-completion files (kouen-cli.fish → kouen-cli.fish, etc.)",
            ]),
            Section(title: "Fixed", items: [
                "Agent hook notify commands (Claude Code, Codex, Cursor, Grok, OpenCode, Pi, Hermes, OpenClaw) and shell completions (fish/zsh/bash) still referenced the pre-rename kouen-cli binary name after the executable rename — corrected, with old installs converging to the corrected command on reinstall instead of silently failing",
            ]),
        ]
    )
}
