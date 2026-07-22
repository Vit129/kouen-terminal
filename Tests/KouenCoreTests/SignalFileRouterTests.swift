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
}
