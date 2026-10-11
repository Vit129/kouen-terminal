import XCTest
@testable import HarnessTerminalEngine

final class CommandCheckpointTests: XCTestCase {
    private func mark(_ kind: String) -> String { "\u{1b}]133;\(kind)\u{7}" }

    func testInputBoundaryContinuesThroughCheckpoint() throws {
        let source = TerminalEmulator(cols: 40, rows: 8)
        source.feed(mark("A") + "prompt> " + mark("B") + "echo hello")
        let restored = TerminalEmulator(cols: 40, rows: 8)
        try restored.restore(source.checkpoint())
        let id = try XCTUnwrap(restored.commandRegions.first?.id)
        restored.feed("\r\n" + mark("C") + "hello\r\n" + mark("D;0"))
        let command = try XCTUnwrap(restored.lastCompletedCommand)
        XCTAssertEqual(command.id, id)
        XCTAssertEqual(command.inputRange?.start, .init(line: 0, column: 8))
        XCTAssertEqual(command.outputRange?.start, .init(line: 1, column: 0))
        XCTAssertEqual(command.outputRange?.end, .init(line: 2, column: 0))
        XCTAssertEqual(command.exitCode, 0)
    }

    func testCompletedViewportCommandRetainsBoundariesAfterRestoreAndReflow() throws {
        let source = TerminalEmulator(cols: 20, rows: 6)
        source.feed(mark("A") + "> " + mark("B") + "run\r\n" + mark("C") + "abcdefghijk\r\n" + mark("D;7"))
        let restored = TerminalEmulator(cols: 20, rows: 6)
        try restored.restore(source.checkpoint())
        XCTAssertEqual(restored.lastCompletedCommand?.outputRange?.start, .init(line: 1, column: 0))
        XCTAssertEqual(restored.lastCompletedCommand?.exitCode, 7)
        restored.resize(cols: 6, rows: 6)
        XCTAssertNotNil(restored.lastCompletedCommand?.outputRange)
    }

    func testHistoryCommandsAreDroppedAndViewportCoordinatesRebased() throws {
        let source = TerminalEmulator(cols: 20, rows: 3)
        source.feed(mark("A") + "> " + mark("B") + "old\r\n" + mark("C") + "old output\r\n" + mark("D;0"))
        source.feed("\r\n\r\n\r\n" + mark("A") + "> " + mark("B"))
        XCTAssertGreaterThan(source.historyCount, 0)
        let restored = TerminalEmulator(cols: 20, rows: 3)
        try restored.restore(source.checkpoint())
        XCTAssertEqual(restored.commandRegions.count, 1)
        XCTAssertNil(restored.lastCompletedCommand)
        XCTAssertEqual(restored.commandRegions.first?.input?.position, .init(line: 2, column: 2))
    }

    func testInvalidCommandCheckpointDoesNotReplaceLiveTerminal() throws {
        let source = TerminalEmulator(cols: 20, rows: 3)
        source.feed(mark("A") + "> " + mark("B"))
        let checkpoint = try source.checkpoint()
        var payload = try XCTUnwrap(PropertyListSerialization.propertyList(from: checkpoint.payload, format: nil) as? [String: Any])
        var history = try XCTUnwrap(payload["commandHistory"] as? [String: Any])
        var active = try XCTUnwrap(history["active"] as? [String: Any])
        active["prompt"] = ["line": -1, "column": 0]
        history["active"] = active
        payload["commandHistory"] = history
        let invalid = try TerminalCheckpoint(payload: PropertyListSerialization.data(fromPropertyList: payload, format: .binary, options: 0))
        let destination = TerminalEmulator(cols: 20, rows: 3)
        destination.feed("keep this")
        let before = destination.readGrid()
        XCTAssertThrowsError(try destination.restore(invalid))
        XCTAssertEqual(destination.readGrid(), before)
    }
}
