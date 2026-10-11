import XCTest
@testable import HarnessCore
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

final class StoppedOwnerSocketTests: XCTestCase {
    private func withSocket(_ body: (URL, URL, Int32) throws -> Void) throws {
        let root = URL(fileURLWithPath: "/tmp/hss-\(UUID().uuidString.prefix(8))")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let url = root.appendingPathComponent("control.sock")
        let fd = try bindSocket(url)
        defer { close(fd) }
        try body(url, root.appendingPathComponent("daemon.pid"), fd)
    }

    private func bindSocket(_ url: URL) throws -> Int32 {
        #if canImport(Darwin)
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        #else
        let fd = socket(AF_UNIX, Int32(SOCK_STREAM.rawValue), 0)
        #endif
        guard fd >= 0 else { throw POSIXError(.EIO) }
        var address = sockaddr_un(); address.sun_family = sa_family_t(AF_UNIX)
        let capacity = MemoryLayout.size(ofValue: address.sun_path)
        url.path.withCString { source in
            withUnsafeMutablePointer(to: &address.sun_path) {
                strncpy(UnsafeMutableRawPointer($0).assumingMemoryBound(to: CChar.self), source, capacity - 1)
            }
        }
        let result = withUnsafePointer(to: &address) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                #if canImport(Darwin)
                Darwin.bind(fd, $0, socklen_t(MemoryLayout<sockaddr_un>.size))
                #else
                Glibc.bind(fd, $0, socklen_t(MemoryLayout<sockaddr_un>.size))
                #endif
            }
        }
        guard result == 0, listen(fd, 1) == 0 else { close(fd); throw POSIXError(.EIO) }
        return fd
    }

    private func exitedOwner() throws -> (Int32, String) {
        let input = Pipe(), process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", "read fixture"]
        process.standardInput = input
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try process.run()
        let generation = ProcessScan.generation(process.processIdentifier)
        try input.fileHandleForWriting.close()
        process.waitUntilExit()
        return (process.processIdentifier, try XCTUnwrap(generation))
    }

    func testExplicitStopReclaimsSocketStillOpenInChildren() throws {
        let (pid, generation) = try exitedOwner()
        try withSocket { url, pidFile, _ in
            let endpoint = try XCTUnwrap(StoppedOwnerSocket(at: url))
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            try endpoint.removeAfterExit(pid: pid, generation: generation, pidFile: pidFile)
            XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
            let replacement = try bindSocket(url)
            close(replacement)
        }
    }

    func testReplacementEndpointIsPreserved() throws {
        let (pid, generation) = try exitedOwner()
        try withSocket { url, pidFile, _ in
            let endpoint = try XCTUnwrap(StoppedOwnerSocket(at: url))
            try FileManager.default.removeItem(at: url)
            let replacement = try bindSocket(url)
            defer { close(replacement) }
            try endpoint.removeAfterExit(pid: pid, generation: generation, pidFile: pidFile)
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        }
    }

    func testLiveOwnerAndNewOwnerClaimArePreserved() throws {
        let (pid, generation) = try exitedOwner()
        try withSocket { url, pidFile, _ in
            let endpoint = try XCTUnwrap(StoppedOwnerSocket(at: url))
            try endpoint.removeAfterExit(pid: getpid(), generation: try XCTUnwrap(ProcessScan.generation(getpid())), pidFile: pidFile)
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            try "\(getpid())\n".write(to: pidFile, atomically: true, encoding: .utf8)
            try endpoint.removeAfterExit(pid: pid, generation: generation, pidFile: pidFile)
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        }
    }

    func testUnverifiedFileAndSymlinkAreNotSocketIdentities() throws {
        try withSocket { url, _, _ in
            let regular = url.deletingLastPathComponent().appendingPathComponent("regular")
            try Data().write(to: regular)
            XCTAssertNil(StoppedOwnerSocket(at: regular))
            let link = url.deletingLastPathComponent().appendingPathComponent("link")
            try FileManager.default.createSymbolicLink(at: link, withDestinationURL: url)
            XCTAssertNil(StoppedOwnerSocket(at: link))
        }
    }
}
