import Foundation
import XCTest
@testable import HarnessTerminalKit

/// Input attribution requires a newer output frame from the same surface. The sample
/// measures CPU submission latency, before GPU completion and visible scanout.
final class EchoLatencySignpostTests: XCTestCase {
    func testInterleavedSurfacesAndStaleFramesCannotConsumeAnotherSourcesInput() {
        let signposter = FrameSignposter(enabled: true)
        let first = NSObject(), second = NSObject()
        let firstID = ObjectIdentifier(first), secondID = ObjectIdentifier(second)
        signposter.noteKeystroke(source: firstID, outputGeneration: 10, at: 1_000)
        signposter.recordPresent(nanos: 100, source: secondID, outputGeneration: 21, at: 2_000)
        signposter.recordPresent(nanos: 100, source: firstID, outputGeneration: 10, at: 3_000)
        XCTAssertEqual(signposter.testingEchoSampleCount, 0)
        XCTAssertTrue(signposter.testingHasPendingKeystroke)

        signposter.noteKeystroke(source: secondID, outputGeneration: 20, at: 3_500)
        signposter.recordPresent(nanos: 100, source: firstID, outputGeneration: 11, at: 4_000)
        XCTAssertEqual(signposter.testingEchoSampleCount, 1)
        XCTAssertTrue(signposter.testingHasPendingKeystroke)
        signposter.recordPresent(nanos: 100, source: secondID, outputGeneration: 20, at: 4_500)
        XCTAssertEqual(signposter.testingEchoSampleCount, 1)
        signposter.recordPresent(nanos: 100, source: secondID, outputGeneration: 21, at: 5_000)
        XCTAssertEqual(signposter.testingEchoSampleCount, 2)
        XCTAssertFalse(signposter.testingHasPendingKeystroke)

        // An encode can capture its timestamp before a newer main-thread input acquires
        // the state lock. That older frame must leave the future input armed.
        signposter.noteKeystroke(source: firstID, outputGeneration: 22, at: 10_000)
        signposter.recordPresent(nanos: 100, source: firstID, outputGeneration: 23, at: 9_000)
        XCTAssertEqual(signposter.testingEchoSampleCount, 2)
        XCTAssertTrue(signposter.testingHasPendingKeystroke)
        signposter.recordPresent(nanos: 100, source: firstID, outputGeneration: 23, at: 11_000)
        XCTAssertEqual(signposter.testingEchoSampleCount, 3)
        XCTAssertFalse(signposter.testingHasPendingKeystroke)
    }
    func testKeystrokeIsConsumedByTheFirstPresent() {
        let signposter = FrameSignposter(enabled: true)
        signposter.noteKeystroke(at: 1_000)
        XCTAssertTrue(signposter.testingHasPendingKeystroke)

        signposter.recordPresent(nanos: 100, at: 4_000_000) // 4ms later — within the window
        XCTAssertFalse(signposter.testingHasPendingKeystroke)
        XCTAssertEqual(signposter.testingEchoSampleCount, 1)

        signposter.recordPresent(nanos: 100, at: 8_000_000) // no pending — no second sample
        XCTAssertEqual(signposter.testingEchoSampleCount, 1)
    }

    func testStalePresentDropsTheSampleInsteadOfMisattributing() {
        let signposter = FrameSignposter(enabled: true)
        signposter.noteKeystroke(at: 0)
        // 600ms later: outside the 500ms window — the keystroke produced no echo (dead key /
        // swallowed shortcut) and this present is something else (blink, scroll).
        signposter.recordPresent(nanos: 100, at: 600_000_000)
        XCTAssertFalse(signposter.testingHasPendingKeystroke)
        XCTAssertEqual(signposter.testingEchoSampleCount, 0)
    }

    func testRepeatedKeystrokesRearmTheSample() {
        let signposter = FrameSignposter(enabled: true)
        signposter.noteKeystroke(at: 1_000)
        signposter.noteKeystroke(at: 2_000_000) // held key: latest press is the one measured
        signposter.recordPresent(nanos: 100, at: 5_000_000)
        XCTAssertEqual(signposter.testingEchoSampleCount, 1)
    }

    func testDisabledSignposterIsInert() {
        let signposter = FrameSignposter(enabled: false)
        signposter.noteKeystroke(at: 1_000)
        XCTAssertFalse(signposter.testingHasPendingKeystroke)
        signposter.recordPresent(nanos: 100, at: 2_000)
        XCTAssertEqual(signposter.testingEchoSampleCount, 0)
    }
}
