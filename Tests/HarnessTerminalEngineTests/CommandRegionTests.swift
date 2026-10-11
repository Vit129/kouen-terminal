import XCTest
@testable import HarnessTerminalEngine

final class CommandRegionTests: XCTestCase {
    func testSearchScopeUsesExactColumnsAndRegexBoundaries() throws {
        let terminal = TerminalEmulator(cols: 40, rows: 4)
        terminal.feed("\u{1b}]133;A\u{7}prompt> \u{1b}]133;B\u{7}echo target\r\n\u{1b}]133;C\u{7}target\u{1b}]133;D;0\u{7}\u{1b}]133;A\u{7}target> ")
        let range = try XCTUnwrap(terminal.lastCompletedCommand?.outputRange)
        let snapshot = terminal.textSnapshot()
        let result = TerminalBufferSearch.search(query: "^target$", options: .init(isRegex: true),
            lineCount: snapshot.lineCount, clusters: snapshot.clusters, within: range,
            isWrapped: snapshot.isWrapped, line: snapshot.line)
        XCTAssertEqual(result, .matches([.init(bufferLine: 1, columns: 0..<6)], limited: false))
        XCTAssertEqual(terminal.command(atBufferLine: 1, column: 0)?.id, terminal.lastCompletedCommand?.id)
        XCTAssertNotEqual(terminal.command(atBufferLine: 1, column: 7)?.id, terminal.lastCompletedCommand?.id)
    }

    func testMultilineCommandAndCompletedOutputBoundariesSurviveResize() throws {
        let terminal = TerminalEmulator(cols: 12, rows: 6)
        terminal.feed("\u{1b}]133;A\u{7}long prompt> \u{1b}]133;B\u{7}echo one two\r\n\u{1b}]133;C\u{7}one two\r\n\u{1b}]133;D;1\u{7}")
        let command = try XCTUnwrap(terminal.lastCompletedCommand)
        XCTAssertEqual(command.exitCode, 1)
        for width in [5, 30, 8] {
            terminal.resize(cols: width, rows: 6)
            let scope = try XCTUnwrap(command.outputRange)
            let snapshot = terminal.textSnapshot()
            let result = TerminalBufferSearch.search(query: "one two", lineCount: snapshot.lineCount,
                clusters: snapshot.clusters, within: scope, isWrapped: snapshot.isWrapped, line: snapshot.line)
            guard case let .matches(matches, _) = result else { return XCTFail("No matches") }
            XCTAssertEqual(matches.count, 1)
            XCTAssertNotNil(command.inputRange)
        }
    }

    func testPromptRedrawDoesNotFinishACommandOrRetainAbandonedInput() {
        let terminal = TerminalEmulator(cols: 30, rows: 4)
        terminal.feed("\u{1b}]133;A\u{7}$ \u{1b}]133;B\u{7}unfinished\r\u{1b}[K\u{1b}]133;A\u{7}$ \u{1b}]133;B\u{7}real\r\n\u{1b}]133;C\u{7}ok\r\n\u{1b}]133;D;0\u{7}")
        XCTAssertEqual(terminal.commandRegions.count, 1)
        XCTAssertNotNil(terminal.lastCompletedCommand?.outputRange)
        terminal.feed("\u{1b}c")
        XCTAssertTrue(terminal.commandRegions.isEmpty)
    }
    func testSearchAcrossWideDeferralUsesTheSameTextAsCopyAndReflow() throws {
        let terminal = TerminalEmulator(cols: 8, rows: 4)
        terminal.feed("1234567界end")
        let snapshot = terminal.textSnapshot()
        let result = TerminalBufferSearch.search(query: "7界end", lineCount: snapshot.lineCount,
            clusters: snapshot.clusters, isWrapped: snapshot.isWrapped, line: snapshot.line)
        guard case let .matches(matches, _) = result else { return XCTFail("No matches") }
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches.first?.spans, [.init(bufferLine: 0, columns: 6..<7), .init(bufferLine: 1, columns: 0..<5)])
        XCTAssertTrue(snapshot.logicalText(startingAt: 0).text.text.hasPrefix("1234567界end"))
    }

}
