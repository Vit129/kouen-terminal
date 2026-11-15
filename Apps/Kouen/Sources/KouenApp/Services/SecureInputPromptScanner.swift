import Foundation

/// Detects password-prompt patterns in a PTY byte stream, including a prompt split
/// across two chunks. Pure value type: the caller decides which thread runs it.
struct SecureInputPromptScanner {
    // Substrings covering sudo, ssh, gpg, git, and VT conceal-mode (ESC[8m).
    private static let patterns: [Data] = ["assword", "assphrase", "Enter PIN", "sudo:", "\u{1b}[8m"]
        .map { Data($0.utf8) }
    private static let carryLength = patterns.map(\.count).max()! - 1

    private var carry = Data()

    /// Returns true when `chunk` (joined to the previous tail) holds a prompt pattern.
    /// Only a focused pane may arm Secure Input; an unfocused chunk drops the carry-over
    /// so stale bytes never join a later chunk.
    mutating func feed(_ chunk: Data, focused: Bool) -> Bool {
        guard focused else {
            carry.removeAll(keepingCapacity: true)
            return false
        }
        let window = carry + chunk
        carry = window.suffix(Self.carryLength)
        return Self.patterns.contains { window.range(of: $0) != nil }
    }
}
