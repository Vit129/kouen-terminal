import Foundation

/// Finds clickable URLs in a line of terminal text — the fallback when a cell carries no OSC 8
/// hyperlink, so plain `https://...` output is still command-clickable.
/// Pure and Foundation-only (uses `NSDataDetector` on Darwin), so it's unit-testable off the GUI.
public enum URLDetection {
    /// The URL covering character offset `column` in `line`, or nil. Callers should build `line`
    /// as one character per cell (so `column` is the clicked grid column); URLs are ASCII, so wide
    /// chars don't shift the mapping.
    public static func url(in line: String, at column: Int) -> String? {
        match(in: line, at: column)?.url
    }

    /// As `url(in:at:)`, but also returns the matched span as a half-open column range,
    /// so callers can underline the link on hover. `columns` uses the same one-character-
    /// per-cell convention as the input `line`.
    public static func match(in line: String, at column: Int) -> (url: String, columns: Range<Int>)? {
        guard !line.isEmpty, column >= 0 else { return nil }
        #if canImport(Darwin)
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        else { return nil }
        let full = NSRange(line.startIndex ..< line.endIndex, in: line)
        var result: (url: String, columns: Range<Int>)?
        detector.enumerateMatches(in: line, options: [], range: full) { match, _, stop in
            guard let match, let r = Range(match.range, in: line) else { return }
            let lower = line.distance(from: line.startIndex, to: r.lowerBound)
            let upper = line.distance(from: line.startIndex, to: r.upperBound)
            if column >= lower, column < upper {
                result = (match.url?.absoluteString ?? String(line[r]), lower ..< upper)
                stop.pointee = true
            }
        }
        return result
        #else
        // `NSDataDetector` isn't implemented in swift-corelibs-foundation (Linux). Fall back to a
        // whitespace-delimited token scan: the token covering `column` is a URL if it carries a
        // `scheme://`. Sufficient for the headless build (URL clicking is a GUI affordance).
        return tokenMatch(in: line, at: column)
        #endif
    }

    /// Detects if the text at `column` in `line` is a file path (absolute or relative).
    /// Handles single-quoted or double-quoted paths with spaces, and unquoted paths containing `/`.
    public static func detectFilePath(in line: String, at column: Int) -> (url: String, columns: Range<Int>)? {
        let chars = Array(line)
        guard !line.isEmpty, column >= 0, column < chars.count else { return nil }

        // 1. Check for single-quoted path wrapping the column
        var lo = column
        var hi = column
        while lo > 0, chars[lo] != "'" { lo -= 1 }
        while hi < chars.count - 1, chars[hi] != "'" { hi += 1 }
        if lo < hi, chars[lo] == "'", chars[hi] == "'" {
            let token = String(chars[lo...hi])
            if token.contains("/") {
                return (token, lo ..< (hi + 1))
            }
        }

        // 2. Check for double-quoted path wrapping the column
        lo = column
        hi = column
        while lo > 0, chars[lo] != "\"" { lo -= 1 }
        while hi < chars.count - 1, chars[hi] != "\"" { hi += 1 }
        if lo < hi, chars[lo] == "\"", chars[hi] == "\"" {
            let token = String(chars[lo...hi])
            if token.contains("/") {
                return (token, lo ..< (hi + 1))
            }
        }

        // 3. Fallback: Check for unquoted whitespace-delimited token containing "/"
        func isBoundary(_ c: Character) -> Bool { c == " " || c == "\t" || c == "'" || c == "\"" }
        if !isBoundary(chars[column]) {
            lo = column
            hi = column
            while lo > 0, !isBoundary(chars[lo - 1]) { lo -= 1 }
            while hi + 1 < chars.count, !isBoundary(chars[hi + 1]) { hi += 1 }
            var token = String(chars[lo...hi])
            while let last = token.last, ").,;:!?'\\\"]>".contains(last) {
                token.removeLast()
            }
            if !token.isEmpty && token.contains("/") && (token.hasPrefix("/") || token.hasPrefix("~") || token.hasPrefix(".")) {
                return (token, lo ..< (lo + token.count))
            }
        }

        return nil
    }

    /// True if `host` is an IPv4 literal in a private (RFC 1918) range — 10.0.0.0/8,
    /// 172.16.0.0/12, or 192.168.0.0/16 — the LAN addresses dev servers print alongside
    /// `localhost` (e.g. Vite's "Network: http://192.168.x.x:5173").
    private static func isPrivateIPv4(_ host: some StringProtocol) -> Bool {
        let parts = host.split(separator: ".")
        guard parts.count == 4 else { return false }
        var octets: [Int] = []
        for part in parts {
            guard let value = Int(part), (0 ... 255).contains(value) else { return false }
            octets.append(value)
        }
        switch octets[0] {
        case 10: return true
        case 172: return (16 ... 31).contains(octets[1])
        case 192: return octets[1] == 168
        default: return false
        }
    }

    /// True if `host` is an IPv6 literal in a link-local (fe80::/10) or unique-local (fc00::/7)
    /// range — the IPv6 analogues of private IPv4 LAN addresses.
    private static func isPrivateIPv6(_ host: some StringProtocol) -> Bool {
        let lower = host.lowercased()
        guard lower.contains(":") else { return false }
        if lower.hasPrefix("fc") || lower.hasPrefix("fd") { return true }
        return ["fe8", "fe9", "fea", "feb"].contains { lower.hasPrefix($0) }
    }

    /// True if `host` is a loopback/unspecified address or a private-LAN IPv4/IPv6 literal —
    /// i.e. an address a local dev server might bind to. Used to decide whether a clicked URL
    /// should open in Harness's in-app Browser Pane instead of the system browser. `host` may
    /// be bracketed (`[::1]`), as returned from a raw `host:port` token.
    public static func isLocalDevHost(_ host: String) -> Bool {
        var lower = host.lowercased()
        if lower.hasPrefix("["), lower.hasSuffix("]") {
            lower = String(lower.dropFirst().dropLast())
        }
        return lower == "localhost" || lower == "127.0.0.1" || lower == "0.0.0.0"
            || lower == "::1" || isPrivateIPv4(lower) || isPrivateIPv6(lower)
    }

    /// Detects a bare `host:port[/path]` reference to a local or LAN dev server (no `http://`
    /// scheme), e.g. `localhost:3000`, `127.0.0.1:8080/api`, or `192.168.1.5:5173` from
    /// dev-server startup banners. Returns the token with an `http://` scheme prepended (and
    /// `0.0.0.0` rewritten to `localhost`, since `0.0.0.0` isn't directly browsable).
    public static func detectLocalhost(in line: String, at column: Int) -> (url: String, columns: Range<Int>)? {
        let chars = Array(line)
        guard !line.isEmpty, column >= 0, column < chars.count else { return nil }
        func isBoundary(_ c: Character) -> Bool { c == " " || c == "\t" || c == "'" || c == "\"" }
        guard !isBoundary(chars[column]) else { return nil }
        var lo = column
        var hi = column
        while lo > 0, !isBoundary(chars[lo - 1]) { lo -= 1 }
        while hi + 1 < chars.count, !isBoundary(chars[hi + 1]) { hi += 1 }
        var token = String(chars[lo ... hi])
        while let last = token.last, ").,;:!?'\\\"]>".contains(last) {
            token.removeLast()
            hi -= 1
        }
        guard hi >= lo, column <= hi else { return nil }

        var rest = Substring(token)
        let scheme: String
        if rest.lowercased().hasPrefix("https://") {
            scheme = "https://"
            rest = rest.dropFirst(scheme.count)
        } else if rest.lowercased().hasPrefix("http://") {
            scheme = "http://"
            rest = rest.dropFirst(scheme.count)
        } else {
            scheme = "http://"
        }

        let hostAndPath = rest.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: false)
        let hostPort = hostAndPath[0]
        let host: Substring
        if hostPort.hasPrefix("[") {
            // Bracketed IPv6 literal, e.g. "[fe80::1]:8080" — the host is everything
            // between the brackets, since the address itself contains colons.
            guard let closeBracket = hostPort.firstIndex(of: "]") else { return nil }
            host = hostPort[hostPort.index(after: hostPort.startIndex) ..< closeBracket]
        } else {
            host = hostPort.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)[0]
        }
        guard isLocalDevHost(String(host)) else {
            return nil
        }
        let normalizedHostPort = host.lowercased() == "0.0.0.0" ? hostPort.replacingOccurrences(of: "0.0.0.0", with: "localhost") : String(hostPort)
        let path = hostAndPath.count > 1 ? "/" + hostAndPath[1] : ""
        return (scheme + normalizedHostPort + path, lo ..< (hi + 1))
    }

    #if !canImport(Darwin)
    private static func tokenMatch(in line: String, at column: Int) -> (url: String, columns: Range<Int>)? {
        let chars = Array(line)
        guard column < chars.count else { return nil }
        func isBoundary(_ c: Character) -> Bool { c == " " || c == "\t" }
        guard !isBoundary(chars[column]) else { return nil }
        var lo = column
        var hi = column
        while lo > 0, !isBoundary(chars[lo - 1]) { lo -= 1 }
        while hi + 1 < chars.count, !isBoundary(chars[hi + 1]) { hi += 1 }
        var token = String(chars[lo ... hi])
        while let last = token.last, ").,;:!?'\\\"]>".contains(last) { token.removeLast() }
        guard let schemeEnd = token.range(of: "://"),
              token[token.startIndex ..< schemeEnd.lowerBound].allSatisfy({ $0.isLetter }),
              schemeEnd.lowerBound != token.startIndex
        else { return nil }
        return (token, lo ..< (lo + token.count))
    }
    #endif
}
