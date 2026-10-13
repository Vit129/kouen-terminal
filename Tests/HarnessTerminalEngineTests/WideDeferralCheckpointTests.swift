import XCTest
@testable import HarnessTerminalEngine

/// Checkpoints written before rows carried the wide-deferral flag still drop the gap.
final class WideDeferralCheckpointTests: XCTestCase {
    private func screen(_ text: String) -> TerminalScreen {
        let screen = TerminalScreen(cols: 4, rows: 3)
        for scalar in text.unicodeScalars { screen.print(scalar.value) }
        return screen
    }

    func testLegacyCheckpointInfersTheFlagFromTheGap() throws {
        var deferred = screen("abc漢").checkpointState()
        deferred.rowWideDeferred = nil
        XCTAssertEqual(try TerminalScreen.restored(from: deferred, remapImage: { $0 }).wideDeferralGap(atBufferLine: 0), 1)

        var written = screen("abc 漢").checkpointState()
        written.rowWideDeferred = nil
        XCTAssertEqual(try TerminalScreen.restored(from: written, remapImage: { $0 }).wideDeferralGap(atBufferLine: 0), 0)
    }
}
