import JavaScriptCore
import XCTest
@testable import KouenApp

@MainActor
final class NetworkCaptureDecisionTests: XCTestCase {
    private func shouldCapture(_ contentType: String?, _ contentLength: String?) -> Bool {
        let ctx = JSContext()!
        ctx.evaluateScript(BrowserPaneView.networkCaptureDecisionJS)
        let ct = contentType.map { "'\($0)'" } ?? "null"
        let cl = contentLength.map { "'\($0)'" } ?? "null"
        return ctx.evaluateScript("__kouenShouldCaptureBody(\(ct), \(cl))")!.toBool()
    }

    func test_TC1001_FEUT_skipsEventStream() {
        XCTAssertFalse(shouldCapture("text/event-stream; charset=utf-8", "100"))
    }

    func test_TC1001_FEUT_skipsBodyWithoutContentLength() {
        XCTAssertFalse(shouldCapture("application/json", nil))
    }

    func test_TC1001_FEUT_skipsBodyOverLimit() {
        XCTAssertFalse(shouldCapture("application/json", "5000000"))
    }

    func test_TC1001_FEUT_capturesSmallJSON() {
        XCTAssertTrue(shouldCapture("application/json", "1200"))
    }
}

@MainActor
final class ConsoleLineCapTests: XCTestCase {
    func test_TC1203_FEUT_consoleLineIsCapped() {
        let line = BrowserPaneView.consoleLogLine(level: "log", text: String(repeating: "x", count: 100_000))
        XCTAssertLessThanOrEqual(line.count, BrowserPaneView.maxConsoleLineLength + 16)
        XCTAssertTrue(line.hasPrefix("[LOG] x"))
    }
}
