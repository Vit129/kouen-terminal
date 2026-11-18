import Foundation
import XCTest
@testable import KouenCore

final class WorkspaceRepositoryScannerTests: XCTestCase {
    func test_TS_0001_BE_IT_onlyPrimaryRepositoriesAreDiscovered() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let fm = FileManager.default
        for path in ["project/.git", "nested/other/.git", "testing-repo/ignored/.git", "plain"] {
            try fm.createDirectory(at: root.appendingPathComponent(path), withIntermediateDirectories: true)
        }
        let linked = root.appendingPathComponent("linked")
        try fm.createDirectory(at: linked, withIntermediateDirectories: true)
        try Data("gitdir: elsewhere".utf8).write(to: linked.appendingPathComponent(".git"))
        try fm.createSymbolicLink(at: root.appendingPathComponent("loop"), withDestinationURL: root)
        let result = try WorkspaceRepositoryScanner.scan(root: root.path)
        let actual = result.map { URL(fileURLWithPath: $0).resolvingSymlinksInPath().path }
        let expected = ["project", "nested/other"].map {
            root.appendingPathComponent($0).resolvingSymlinksInPath().path
        }
        XCTAssertEqual(Set(actual), Set(expected))
    }
}
