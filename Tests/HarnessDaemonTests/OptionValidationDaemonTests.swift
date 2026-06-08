import XCTest
@testable import HarnessCore
@testable import HarnessDaemonCore

/// Roadmap PR-9, daemon side: the `setOption` IPC handler rejects unknown option names (so every
/// front-end — CLI, `:` prompt, source-file — inherits the loud failure) while accepting
/// `@`-prefixed user options, which then resolve in `buildFormatContext` for `#{@name}`. Runs
/// against an isolated `HARNESS_HOME` like the other daemon tests.
final class OptionValidationDaemonTests: XCTestCase {
    private var root: URL?
    private var previousHome: String?

    override func setUpWithError() throws {
        previousHome = getenv("HARNESS_HOME").map { String(cString: $0) }
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("harness-optval-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        root = dir
        setenv("HARNESS_HOME", dir.path, 1)
        try HarnessPaths.ensureDirectories()
    }

    override func tearDownWithError() throws {
        if let previousHome { setenv("HARNESS_HOME", previousHome, 1) } else { unsetenv("HARNESS_HOME") }
        if let root { try? FileManager.default.removeItem(at: root) }
    }

    func testSetOptionRejectsUnknownKey() {
        let registry = SurfaceRegistry()
        guard case let .error(message) = registry.handle(.setOption(scope: "global", target: nil, key: "moused", rawValue: "on")) else {
            return XCTFail("expected an error for an unknown option key")
        }
        XCTAssertTrue(message.contains("unknown option"), "error names the problem: \(message)")
        // A real option still sets fine.
        guard case .ok = registry.handle(.setOption(scope: "global", target: nil, key: "mouse", rawValue: "off")) else {
            return XCTFail("a known option must still set")
        }
    }

    func testUserOptionSetsAndRendersViaFormatContext() {
        let registry = SurfaceRegistry()
        guard case .ok = registry.handle(.setOption(scope: "global", target: nil, key: "@theme", rawValue: "dracula")) else {
            return XCTFail("a @user-option must be accepted")
        }
        let context = registry.buildFormatContext()
        XCTAssertEqual(context.userOptions["@theme"], "dracula")
        XCTAssertEqual(FormatString.evaluate("#{@theme}", context: context), "dracula")
    }
}
