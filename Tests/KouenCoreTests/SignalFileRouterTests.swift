import XCTest
@testable import KouenCore

final class SignalFileRouterTests: XCTestCase {
    private func tmpDir() -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("kouen-signalfile-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    func testSwiftPackageDetected() {
        let dir = tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        FileManager.default.createFile(atPath: dir.appendingPathComponent("Package.swift").path, contents: Data())

        XCTAssertEqual(SignalFileRouter.detectProfile(at: dir.path)?.stack, "swift")
    }

    func testNextJsDetectedOverPlainReact() {
        let dir = tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        let packageJSON = """
        {"dependencies": {"react": "18.0.0", "next": "14.0.0"}}
        """
        FileManager.default.createFile(
            atPath: dir.appendingPathComponent("package.json").path,
            contents: packageJSON.data(using: .utf8)
        )

        XCTAssertEqual(SignalFileRouter.detectProfile(at: dir.path)?.stack, "nextjs")
    }

    func testPlainReactDetected() {
        let dir = tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        let packageJSON = """
        {"dependencies": {"react": "18.0.0", "react-dom": "18.0.0"}}
        """
        FileManager.default.createFile(
            atPath: dir.appendingPathComponent("package.json").path,
            contents: packageJSON.data(using: .utf8)
        )

        XCTAssertEqual(SignalFileRouter.detectProfile(at: dir.path)?.stack, "react")
    }

    func testEmptyDirectoryDetectsNothing() {
        let dir = tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        XCTAssertNil(SignalFileRouter.detectProfile(at: dir.path))
    }

    // MARK: - validationSteps (P39/MAW handoff-merge validate gate)

    func testSwiftValidationStepsAreBuildThenTest() {
        let dir = tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        FileManager.default.createFile(atPath: dir.appendingPathComponent("Package.swift").path, contents: Data())

        XCTAssertEqual(SignalFileRouter.validationSteps(at: dir.path), [["swift", "build"], ["swift", "test"]])
    }

    func testPythonValidationStepsRunPytest() {
        let dir = tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        FileManager.default.createFile(atPath: dir.appendingPathComponent("requirements.txt").path, contents: Data())

        XCTAssertEqual(SignalFileRouter.validationSteps(at: dir.path), [["python3", "-m", "pytest", "-q"]])
    }

    func testNodeWithoutTestScriptSkipsValidation() {
        let dir = tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        let packageJSON = """
        {"dependencies": {"react": "18.0.0"}, "scripts": {"start": "react-scripts start"}}
        """
        FileManager.default.createFile(
            atPath: dir.appendingPathComponent("package.json").path,
            contents: packageJSON.data(using: .utf8)
        )

        XCTAssertEqual(SignalFileRouter.validationSteps(at: dir.path), [], "no test script — validate must skip, not fail")
    }

    func testNodeWithTestScriptPicksPackageManagerFromLockfile() {
        let dir = tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        let packageJSON = """
        {"dependencies": {"react": "18.0.0"}, "scripts": {"test": "vitest run"}}
        """
        FileManager.default.createFile(
            atPath: dir.appendingPathComponent("package.json").path,
            contents: packageJSON.data(using: .utf8)
        )
        FileManager.default.createFile(atPath: dir.appendingPathComponent("pnpm-lock.yaml").path, contents: Data())

        XCTAssertEqual(SignalFileRouter.validationSteps(at: dir.path), [["pnpm", "test"]])
    }

    func testEmptyDirectorySkipsValidation() {
        let dir = tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        XCTAssertEqual(SignalFileRouter.validationSteps(at: dir.path), [])
    }

    // MARK: - handoffNote (MAW handoff-doc reuse: GitPanelView merge dialog + kouenSpawnAgent)

    func testHandoffInfoExtractsNoteAndSuggestedSkills() {
        let dir = tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        try? FileManager.default.createDirectory(at: dir.appendingPathComponent("agent-memory"), withIntermediateDirectories: true)
        let handoff = """
        From: claude-code
        To: (open)
        Suggested skills: dev-architect
        Note: Implemented the login form; validation still needs a real backend check.
        """
        try? handoff.write(to: dir.appendingPathComponent("agent-memory/HANDOFF.md"), atomically: true, encoding: .utf8)

        let info = SignalFileRouter.handoffInfo(at: dir.path)
        XCTAssertEqual(info?.note, "Implemented the login form; validation still needs a real backend check.")
        XCTAssertEqual(info?.suggestedSkills, "dev-architect")
    }

    func testHandoffInfoNilWhenNoFile() {
        let dir = tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        XCTAssertNil(SignalFileRouter.handoffInfo(at: dir.path))
    }

    func testHandoffInfoNilWhenNoteFieldEmpty() {
        let dir = tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        try? FileManager.default.createDirectory(at: dir.appendingPathComponent("agent-memory"), withIntermediateDirectories: true)
        let handoff = "From: claude-code\nTo: (open)\nNote:   \n"
        try? handoff.write(to: dir.appendingPathComponent("agent-memory/HANDOFF.md"), atomically: true, encoding: .utf8)

        XCTAssertNil(SignalFileRouter.handoffInfo(at: dir.path))
    }

    func testHandoffInfoReturnsFullNoteUntruncated() {
        let dir = tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        try? FileManager.default.createDirectory(at: dir.appendingPathComponent("agent-memory"), withIntermediateDirectories: true)
        let longNote = String(repeating: "x", count: 500)
        try? "Note: \(longNote)".write(to: dir.appendingPathComponent("agent-memory/HANDOFF.md"), atomically: true, encoding: .utf8)

        XCTAssertEqual(
            SignalFileRouter.handoffInfo(at: dir.path)?.note, longNote,
            "a continuing agent needs the full note, not a display-truncated preview"
        )
    }

    func testHandoffInfoSuggestedSkillsNilWhenFieldMissing() {
        let dir = tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        try? FileManager.default.createDirectory(at: dir.appendingPathComponent("agent-memory"), withIntermediateDirectories: true)
        let handoff = "From: claude-code\nTo: (open)\nNote: All done.\n"
        try? handoff.write(to: dir.appendingPathComponent("agent-memory/HANDOFF.md"), atomically: true, encoding: .utf8)

        XCTAssertNil(SignalFileRouter.handoffInfo(at: dir.path)?.suggestedSkills)
    }
}
