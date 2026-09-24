import XCTest
@testable import KouenCore

final class ClaudeSessionModeTests: XCTestCase {
    func testLaunchCommands() {
        XCTAssertEqual(ClaudeSessionMode.local.launchCommand, "claude")
        XCTAssertEqual(
            ClaudeSessionMode.remoteControl.launchCommand,
            "claude --remote-control --remote-control-session-name-prefix kouen"
        )
        XCTAssertEqual(ClaudeSessionMode.cloud.launchCommand, "claude --cloud")
    }

    func testCloudResumeFallsBackToRemoteControl() {
        XCTAssertEqual(ClaudeSessionMode.local.resumeCommand(sessionID: "abc"), "claude --resume abc")
        XCTAssertEqual(
            ClaudeSessionMode.cloud.resumeCommand(sessionID: "abc"),
            "claude --resume abc --remote-control --remote-control-session-name-prefix kouen"
        )
        XCTAssertEqual(
            ClaudeSessionMode.cloud.resumeCommand(sessionID: "abc"),
            ClaudeSessionMode.remoteControl.resumeCommand(sessionID: "abc")
        )
    }

    func testAgentKindResumeHonorsModeOnlyForClaude() {
        XCTAssertEqual(AgentKind.claudeCode.resumeCommand(sessionID: "abc"), "claude --resume abc")
        XCTAssertEqual(
            AgentKind.claudeCode.resumeCommand(sessionID: "abc", claudeMode: .cloud),
            ClaudeSessionMode.cloud.resumeCommand(sessionID: "abc")
        )
        XCTAssertEqual(AgentKind.codex.resumeCommand(sessionID: "abc", claudeMode: .cloud), "codex resume abc")
    }

    func testSettingsDefaultIsCloud() {
        XCTAssertEqual(KouenSettings().claudeSessionMode, .cloud)
    }

    func testSettingsDecodesClaudeSessionMode() throws {
        try withTemporaryKouenHome { root in
            try KouenPaths.ensureDirectories()
            try Data("""
            { "claudeSessionMode": "remote-control" }
            """.utf8).write(to: root.appendingPathComponent("settings.json"))
            XCTAssertEqual(KouenSettings.load().claudeSessionMode, .remoteControl)
        }
    }

    func testSettingsMissingClaudeSessionModeDefaultsToCloud() throws {
        try withTemporaryKouenHome { root in
            try KouenPaths.ensureDirectories()
            try Data("{ \"fontSize\": 14 }".utf8).write(to: root.appendingPathComponent("settings.json"))
            XCTAssertEqual(KouenSettings.load().claudeSessionMode, .cloud)
        }
    }

    private func withTemporaryKouenHome(_ body: (URL) throws -> Void) throws {
        let previousHome = getenv("KOUEN_HOME").map { String(cString: $0) }
        let root = URL(fileURLWithPath: "/tmp/kouen-claude-mode-\(UUID().uuidString.prefix(8))", isDirectory: true)
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
