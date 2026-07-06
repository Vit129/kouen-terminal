import XCTest
@testable import KouenCore

final class TerminalIdentityTests: XCTestCase {
    func testDefaultsToCompatibleGhostty() {
        // The reported bug (#39) is fixed by reporting a recognized identity by default.
        XCTAssertEqual(TerminalIdentity.mode(nil), .compatible)
        XCTAssertEqual(TerminalIdentity.mode(""), .compatible)
        XCTAssertEqual(TerminalIdentity.mode("nonsense"), .compatible)
        let spec = TerminalIdentity.spec(forOption: nil)
        XCTAssertEqual(spec.name, "ghostty")
        XCTAssertEqual(spec.version, KouenVersion.short)
        XCTAssertEqual(spec.daVersion, KouenVersion.build)
    }

    func testStrictReportsKouen() {
        XCTAssertEqual(TerminalIdentity.mode("kouen"), .kouen)
        XCTAssertEqual(TerminalIdentity.mode("Kouen"), .kouen) // case-insensitive
        let spec = TerminalIdentity.spec(forOption: "kouen")
        XCTAssertEqual(spec.name, "Kouen")
        XCTAssertEqual(spec.version, KouenVersion.short)
    }

    func testOptionStoreShipsCompatibleDefault() {
        // The daemon + app both read this key from options.json; the shipped default must be
        // `compatible` so a fresh install fixes Shift+Enter without any user action.
        let value = OptionStore.builtinDefaults[TerminalIdentity.optionKey]
        XCTAssertEqual(value?.stringValue, TerminalIdentity.Mode.compatible.rawValue)
    }
}
