#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import XCTest
@testable import HarnessCore

/// Roadmap PR-12: `ProcessScan.parentMap()` is the single `pid → ppid` snapshot the agent scanner
/// (and the GUI shell tracker) build once per tick and share across surfaces, replacing the prior
/// per-surface rebuilds. These cover the primitive itself.
final class ProcessScanTests: XCTestCase {
    func testParentMapLinksCurrentProcessToItsParent() {
        let map = ProcessScan.parentMap()
        let me = getpid()
        XCTAssertFalse(map.isEmpty, "the live system always has processes")
        XCTAssertNotNil(map[me], "the current process must be in the map")
        XCTAssertEqual(map[me], getppid(), "its recorded parent must be the real ppid")
        XCTAssertEqual(map[me], ProcessScan.parentPID(me), "the map agrees with the single-PID lookup")
    }

    func testParentMapCapturesASpawnedChildsParent() throws {
        let child = Process()
        child.executableURL = URL(fileURLWithPath: "/bin/sleep")
        child.arguments = ["5"]
        try child.run()
        defer { if child.isRunning { child.terminate() } }

        let map = ProcessScan.parentMap()
        // A `Process`-spawned child is a direct child of the test runner.
        XCTAssertEqual(map[child.processIdentifier], getpid(),
                       "a spawned child's parent in the map is the test process")
    }

    func testPhysicalFootprintCountsTouchedMemory() throws {
        let before = try XCTUnwrap(ProcessScan.physicalFootprint(getpid()))
        let size = 64 << 20
        let block = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: 4096)
        defer { block.deallocate() }
        block.initializeMemory(as: UInt8.self, repeating: 0xA5, count: size)
        let after = try XCTUnwrap(ProcessScan.physicalFootprint(getpid()))
        XCTAssertGreaterThan(after, before + UInt64(size / 2), "touched pages must be charged to the process")
        XCTAssertNil(ProcessScan.physicalFootprint(0))
    }
}
