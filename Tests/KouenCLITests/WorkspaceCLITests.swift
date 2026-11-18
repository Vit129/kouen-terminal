import Foundation
import XCTest
@testable import KouenCLI

final class WorkspaceCLITests: XCTestCase {
    func test_TS_0003_BE_UT_nestedCommandsAndProjectSelectors() throws {
        XCTAssertEqual(KouenCLI.normalizeWorkspaceArguments(["project", "scan", "/tmp/work"]), ["workspace-scan", "--path", "/tmp/work"])
        XCTAssertEqual(KouenCLI.normalizeWorkspaceArguments(["workspace", "open", "Company/Ordering", "--branch", "main"]), ["workspace-open", "--project", "Company/Ordering", "--branch", "main"])
        let suite = "workspace-cli-\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(Data("[{\"id\":\"group-id\",\"name\":\"Company\"}]".utf8), forKey: "ProjectCategories")
        defaults.set(Data("[{\"path\":\"/a/Ordering\",\"categoryID\":\"group-id\",\"stableID\":\"project-id\"},{\"path\":\"/b/Ordering\",\"stableID\":\"other-id\"}]".utf8), forKey: "ProjectEntries")
        let domain = ["--catalog-domain", suite]
        XCTAssertEqual(try KouenCLI.resolveWorkspaceProject(["--project", "Company/Ordering"] + domain), "/a/Ordering")
        XCTAssertEqual(try KouenCLI.resolveWorkspaceProject(["--project", "project-id"] + domain), "/a/Ordering")
        XCTAssertThrowsError(try KouenCLI.resolveWorkspaceProject(["--project", "Ordering"] + domain))
        XCTAssertEqual(try KouenCLI.resolveWorkspaceProject(["--project", "/explicit/path"] + domain), "/explicit/path")
    }
}
