import Foundation

extension DaemonSyncService {
    /// A JS string literal (quotes included) for `value`. The JSON encoding escapes every control
    /// character (`\r`, `\t`, ...), which hand-rolled backslash/quote/newline replacement missed.
    static func jsStringLiteral(_ value: String) -> String {
        guard let data = try? JSONEncoder().encode(value), let literal = String(data: data, encoding: .utf8) else {
            return "\"\""
        }
        return literal
    }
}
