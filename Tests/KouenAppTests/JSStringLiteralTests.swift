import JavaScriptCore
import XCTest
@testable import KouenApp

@MainActor
final class JSStringLiteralTests: XCTestCase {
    func test_TC1204_FEUT_carriageReturnAndQuotesRoundTrip() {
        let input = "a\r\nb\t\"q\" \\ 'x' \u{2028}"
        let ctx = JSContext()!
        let result = ctx.evaluateScript("(\(DaemonSyncService.jsStringLiteral(input)))")
        XCTAssertEqual(result?.toString(), input)
    }
}
