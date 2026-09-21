import XCTest
@testable import KouenCore

/// P46 Phase 4: only tests detection (pure filesystem checks) — running `swift build`/`tsc`/
/// `cargo check` etc. for real is slow and depends on toolchains that may not be installed in
/// every test environment, so `VerificationRunner.run` itself stays untested here.
final class VerificationRunnerTests: XCTestCase {
    private var tempDir: String!

    override func setUpWithError() throws {
        tempDir = NSTemporaryDirectory() + "kouen-verify-test-\(UUID().uuidString.prefix(8))"
        try FileManager.default.createDirectory(atPath: tempDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let tempDir { try? FileManager.default.removeItem(atPath: tempDir) }
    }

    private func touch(_ name: String) {
        FileManager.default.createFile(atPath: tempDir + "/" + name, contents: Data())
    }

    func testTier1DetectsSwiftPackageBeforeAnythingElse() {
        touch("Package.swift")
        XCTAssertEqual(VerificationRunner.detectTier1Command(cwd: tempDir), ["swift", "build"])
    }

    func testTier1DetectsTypeScriptViaTsconfig() {
        touch("tsconfig.json")
        XCTAssertEqual(VerificationRunner.detectTier1Command(cwd: tempDir), ["npx", "--no-install", "tsc", "--noEmit"])
    }

    func testTier1DetectsGoModule() {
        touch("go.mod")
        XCTAssertEqual(VerificationRunner.detectTier1Command(cwd: tempDir), ["go", "vet", "./..."])
    }

    func testTier1DetectsRustCargo() {
        touch("Cargo.toml")
        XCTAssertEqual(VerificationRunner.detectTier1Command(cwd: tempDir), ["cargo", "check"])
    }

    func testTier1DetectsPythonViaPyproject() {
        touch("pyproject.toml")
        XCTAssertEqual(VerificationRunner.detectTier1Command(cwd: tempDir), ["ruff", "check", "."])
    }

    func testTier1ReturnsNilForAnUnrecognizedProject() {
        touch("README.md")
        XCTAssertNil(VerificationRunner.detectTier1Command(cwd: tempDir))
    }

    func testTier2DetectsSwiftTestCommand() {
        touch("Package.swift")
        XCTAssertEqual(VerificationRunner.detectTier2Command(cwd: tempDir), ["swift", "test"])
    }

    func testTier2DetectsNpmTestForAPlainNodeProject() {
        touch("package.json")
        XCTAssertEqual(VerificationRunner.detectTier2Command(cwd: tempDir), ["npm", "test", "--silent"])
    }

    func testTier2DetectsPytestForASetupPyProject() {
        touch("setup.py")
        XCTAssertEqual(VerificationRunner.detectTier2Command(cwd: tempDir), ["pytest", "-q"])
    }

    func testTier2ReturnsNilForAnUnrecognizedProject() {
        touch("README.md")
        XCTAssertNil(VerificationRunner.detectTier2Command(cwd: tempDir))
    }
}
