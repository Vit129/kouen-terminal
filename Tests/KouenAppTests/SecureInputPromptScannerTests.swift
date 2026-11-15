import Foundation
import XCTest
@testable import KouenApp

final class SecureInputPromptScannerTests: XCTestCase {
    private func d(_ s: String) -> Data { Data(s.utf8) }

    func test_TC0901_FEUT_backgroundPaneOutputDoesNotArm() {
        var scanner = SecureInputPromptScanner()
        XCTAssertFalse(scanner.feed(d("Password: "), focused: false))
    }

    func test_TC0901_FEUT_focusedPaneArmsOnPrompt() {
        var scanner = SecureInputPromptScanner()
        XCTAssertTrue(scanner.feed(d("[sudo] password for me: "), focused: true))
    }

    func test_TC0901_FEUT_promptSplitAcrossTwoChunksArms() {
        var scanner = SecureInputPromptScanner()
        XCTAssertFalse(scanner.feed(d("Enter Pass"), focused: true))
        XCTAssertTrue(scanner.feed(d("phrase for key:"), focused: true))
    }

    func test_TC0901_FEUT_unfocusedChunkDropsCarryOver() {
        var scanner = SecureInputPromptScanner()
        XCTAssertFalse(scanner.feed(d("Pass"), focused: true))
        XCTAssertFalse(scanner.feed(d("x"), focused: false))
        XCTAssertFalse(scanner.feed(d("word"), focused: true))
    }
}
