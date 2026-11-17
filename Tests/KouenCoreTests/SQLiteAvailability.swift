import XCTest

/// The history FTS index is compiled out where `SQLite3` can't be imported (the Linux headless
/// build), so tests that assert on indexed search results can only run on Apple platforms.
func skipUnlessSQLiteAvailable() throws {
    #if !canImport(SQLite3)
    throw XCTSkip("AgentHistoryFTSIndex needs SQLite3, unavailable on this platform")
    #endif
}
