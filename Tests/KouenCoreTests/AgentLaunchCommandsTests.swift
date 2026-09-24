import XCTest
@testable import KouenCore
@testable import KouenIPC
@testable import KouenSettings

final class AgentLaunchCommandsTests: XCTestCase {
    // [TC-P50-B01]: Mode enum and legacy decoding
    func testAgentSessionModeCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let localData = try encoder.encode(AgentSessionMode.local)
        XCTAssertEqual(try decoder.decode(AgentSessionMode.self, from: localData), .local)

        let remoteData = try encoder.encode(AgentSessionMode.remoteControl)
        XCTAssertEqual(try decoder.decode(AgentSessionMode.self, from: remoteData), .remoteControl)

        let cloudData = try encoder.encode(AgentSessionMode.cloud)
        XCTAssertEqual(try decoder.decode(AgentSessionMode.self, from: cloudData), .cloud)
    }

    // [TC-P50-B02]: Default values of agentSessionModes in KouenSettings
    func testDefaultAgentSessionModes() {
        let settings = KouenSettings()
        XCTAssertEqual(settings.sessionMode(for: .claudeCode), .remoteControl)
        XCTAssertEqual(settings.sessionMode(for: .codex), .remoteControl)
        XCTAssertEqual(settings.sessionMode(for: .antigravity), .remoteControl)
        XCTAssertEqual(settings.sessionMode(for: .copilot), .remoteControl)
        XCTAssertEqual(settings.sessionMode(for: .gemini), .local)
        XCTAssertEqual(settings.sessionMode(for: .kiro), .local)
    }

    func testLegacyClaudeSessionModeDecodesAndFoldsIntoAgentSessionModes() throws {
        try withTemporaryKouenHome { root in
            try KouenPaths.ensureDirectories()
            let json = """
            { "claudeSessionMode": "remote-control" }
            """
            try Data(json.utf8).write(to: root.appendingPathComponent("settings.json"))
            let loaded = KouenSettings.load()
            XCTAssertEqual(loaded.claudeSessionMode, .remoteControl)
            XCTAssertEqual(loaded.sessionMode(for: .claudeCode), .remoteControl)
            // Other agents still have their defaults
            XCTAssertEqual(loaded.sessionMode(for: .codex), .remoteControl)
            XCTAssertEqual(loaded.sessionMode(for: .antigravity), .remoteControl)
            XCTAssertEqual(loaded.sessionMode(for: .copilot), .remoteControl)
        }
    }

    func testAgentSessionModesDecodesExplicitMap() throws {
        try withTemporaryKouenHome { root in
            try KouenPaths.ensureDirectories()
            let json = """
            {
                "agentSessionModes": {
                    "claude-code": "local",
                    "codex": "local",
                    "antigravity": "local",
                    "copilot": "remote-control"
                }
            }
            """
            try Data(json.utf8).write(to: root.appendingPathComponent("settings.json"))
            let loaded = KouenSettings.load()
            XCTAssertEqual(loaded.sessionMode(for: .claudeCode), .local)
            XCTAssertEqual(loaded.claudeSessionMode, .local)
            XCTAssertEqual(loaded.sessionMode(for: .codex), .local)
            XCTAssertEqual(loaded.sessionMode(for: .antigravity), .local)
            XCTAssertEqual(loaded.sessionMode(for: .copilot), .remoteControl)
        }
    }

    // [TC-P50-B03]: AgentLaunchCommands.launch(kind:mode:)
    func testClaudeLaunchCommands() {
        XCTAssertEqual(AgentLaunchCommands.launch(kind: .claudeCode, mode: .local), "claude")
        XCTAssertEqual(
            AgentLaunchCommands.launch(kind: .claudeCode, mode: .remoteControl),
            "claude --remote-control --remote-control-session-name-prefix kouen"
        )
        XCTAssertEqual(AgentLaunchCommands.launch(kind: .claudeCode, mode: .cloud), "claude --cloud")
    }

    func testAntigravityLaunchCommands() {
        XCTAssertEqual(AgentLaunchCommands.launch(kind: .antigravity, mode: .local), "agy")
        XCTAssertEqual(AgentLaunchCommands.launch(kind: .antigravity, mode: .remoteControl), "agy --remote-control")
        // Cloud falls back to remoteControl for agy
        XCTAssertEqual(AgentLaunchCommands.launch(kind: .antigravity, mode: .cloud), "agy --remote-control")
    }

    func testCopilotLaunchCommands() {
        XCTAssertEqual(AgentLaunchCommands.launch(kind: .copilot, mode: .local), "copilot")
        XCTAssertEqual(AgentLaunchCommands.launch(kind: .copilot, mode: .remoteControl), "copilot --remote")
        // Cloud falls back to remoteControl for copilot
        XCTAssertEqual(AgentLaunchCommands.launch(kind: .copilot, mode: .cloud), "copilot --remote")
    }

    func testCodexLaunchCommands() {
        XCTAssertEqual(AgentLaunchCommands.launch(kind: .codex, mode: .local), "codex")
        // Codex remote control is managed via daemon, launch command is plain codex
        XCTAssertEqual(AgentLaunchCommands.launch(kind: .codex, mode: .remoteControl), "codex")
        // Cloud falls back to remoteControl for interactive codex
        XCTAssertEqual(AgentLaunchCommands.launch(kind: .codex, mode: .cloud), "codex")
    }

    func testOtherAgentsLaunchCommands() {
        XCTAssertEqual(AgentLaunchCommands.launch(kind: .kiro, mode: .local), "kiro")
        XCTAssertEqual(AgentLaunchCommands.launch(kind: .gemini, mode: .local), "gemini")
        XCTAssertEqual(AgentLaunchCommands.launch(kind: .cursor, mode: .local, cwd: "/path/to/project"), "cursor /path/to/project")
    }

    // [TC-P50-B04]: AgentLaunchCommands.resume(kind:sessionID:mode:)
    func testResumeCommands() {
        // Claude
        XCTAssertEqual(
            AgentLaunchCommands.resume(kind: .claudeCode, sessionID: "s-123", mode: .local),
            "claude --resume s-123"
        )
        XCTAssertEqual(
            AgentLaunchCommands.resume(kind: .claudeCode, sessionID: "s-123", mode: .remoteControl),
            "claude --resume s-123 --remote-control --remote-control-session-name-prefix kouen"
        )
        XCTAssertEqual(
            AgentLaunchCommands.resume(kind: .claudeCode, sessionID: "s-123", mode: .cloud),
            "claude --resume s-123 --remote-control --remote-control-session-name-prefix kouen"
        )

        // Antigravity
        XCTAssertEqual(
            AgentLaunchCommands.resume(kind: .antigravity, sessionID: "s-123", mode: .local),
            "agy --conversation s-123"
        )
        XCTAssertEqual(
            AgentLaunchCommands.resume(kind: .antigravity, sessionID: "s-123", mode: .remoteControl),
            "agy --conversation s-123 --remote-control"
        )
        XCTAssertEqual(
            AgentLaunchCommands.resume(kind: .antigravity, sessionID: "s-123", mode: .cloud),
            "agy --conversation s-123 --remote-control"
        )

        // Copilot
        XCTAssertEqual(
            AgentLaunchCommands.resume(kind: .copilot, sessionID: "s-123", mode: .local),
            "copilot --resume s-123"
        )
        XCTAssertEqual(
            AgentLaunchCommands.resume(kind: .copilot, sessionID: "s-123", mode: .remoteControl),
            "copilot --resume s-123 --remote"
        )
        XCTAssertEqual(
            AgentLaunchCommands.resume(kind: .copilot, sessionID: "s-123", mode: .cloud),
            "copilot --resume s-123 --remote"
        )

        // Codex
        XCTAssertEqual(
            AgentLaunchCommands.resume(kind: .codex, sessionID: "s-123", mode: .local),
            "codex resume s-123"
        )
        XCTAssertEqual(
            AgentLaunchCommands.resume(kind: .codex, sessionID: "s-123", mode: .remoteControl),
            "codex resume s-123"
        )

        // Hermes (extensibility check)
        XCTAssertEqual(
            AgentLaunchCommands.launch(kind: .hermes, mode: .remoteControl),
            "hermes --remote"
        )
        XCTAssertEqual(
            AgentLaunchCommands.resume(kind: .hermes, sessionID: "s-123", mode: .remoteControl),
            "hermes --resume s-123 --remote"
        )

        // Non-Claude resume safety (must never produce claude --resume)
        XCTAssertEqual(
            AgentLaunchCommands.resume(kind: .gemini, sessionID: "s-123", mode: .local),
            "gemini --resume s-123"
        )
        XCTAssertEqual(
            AgentLaunchCommands.resume(kind: .kiro, sessionID: "s-123", mode: .local),
            "kiro --resume s-123"
        )
    }

    func testSettingsResolvedLaunchCommand() {
        let settings = KouenSettings()
        // Default claude mode is remoteControl
        XCTAssertEqual(
            settings.resolvedLaunchCommand(for: "claude"),
            "claude --remote-control --remote-control-session-name-prefix kouen\n"
        )
        // Aliases resolve correctly
        XCTAssertEqual(
            settings.resolvedLaunchCommand(for: "agy"),
            "agy --remote-control\n"
        )
        XCTAssertEqual(
            settings.resolvedLaunchCommand(for: "codex"),
            "codex\n"
        )
    }

    func testAgentKindHelperAliasing() {
        XCTAssertEqual(AgentLaunchCommands.kind(from: "claude"), .claudeCode)
        XCTAssertEqual(AgentLaunchCommands.kind(from: "claude-code"), .claudeCode)
        XCTAssertEqual(AgentLaunchCommands.kind(from: "codex"), .codex)
        XCTAssertEqual(AgentLaunchCommands.kind(from: "agy"), .antigravity)
        XCTAssertEqual(AgentLaunchCommands.kind(from: "antigravity"), .antigravity)
        XCTAssertEqual(AgentLaunchCommands.kind(from: "copilot"), .copilot)
        XCTAssertEqual(AgentLaunchCommands.kind(from: "github-copilot"), .copilot)
        XCTAssertEqual(AgentLaunchCommands.kind(from: "kiro"), .kiro)
        XCTAssertEqual(AgentLaunchCommands.kind(from: "gemini"), .gemini)
        XCTAssertEqual(AgentLaunchCommands.kind(from: "cursor"), .cursor)
    }

    private func withTemporaryKouenHome(_ body: (URL) throws -> Void) throws {
        let previousHome = getenv("KOUEN_HOME").map { String(cString: $0) }
        let root = URL(fileURLWithPath: "/tmp/kouen-agent-mode-\(UUID().uuidString.prefix(8))", isDirectory: true)
        setenv("KOUEN_HOME", root.path, 1)
        defer {
            if let previousHome {
                setenv("KOUEN_HOME", previousHome, 1)
            } else {
                unsetenv("KOUEN_HOME")
            }
            try? FileManager.default.removeItem(at: root)
        }
        try body(root)
    }
}
