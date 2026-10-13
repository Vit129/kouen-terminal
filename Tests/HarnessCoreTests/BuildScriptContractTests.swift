import XCTest

/// The preview and release scripts build every product in one pass, and copy the helpers the
/// Xcode project bundles.
final class BuildScriptContractTests: XCTestCase {
    private func read(_ path: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath) // Tests/HarnessCoreTests/<this file>
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent(path), encoding: .utf8)
    }

    func testScriptsBuildInOnePassAndCopyTheBundledHelpers() throws {
        let preview = try read("Scripts/preview.sh")
        let release = try read("Scripts/build-release.sh")
        let project = try read("project.yml")
        XCTAssertFalse(preview.contains("swift build --product"), "preview.sh builds every product in one pass")
        XCTAssertFalse(release.contains("swift build -c release --product"), "build-release.sh builds every product in one pass")
        for helper in ["HarnessSessionHost", "HarnessDaemon", "harness-cli"] {
            XCTAssertTrue(project.contains("$(BUILT_PRODUCTS_DIR)/\(helper)"), "project.yml bundles \(helper)")
            XCTAssertTrue(preview.contains("$BUILD_DIR/\(helper)"), "preview.sh copies \(helper)")
        }
    }
}
