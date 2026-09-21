import Foundation

/// Detects when an interactive AI agent (Claude Code, Antigravity, Cursor Agent, Codex, Aider, etc.)
/// or CLI tool is waiting for user approval or input.
///
/// Operates on trailing terminal output and OSC sequences without requiring special hooks.
/// Completely pure and thread-safe (Sendable).
public enum AgentAttentionDetector: Sendable {

    public enum PromptKind: String, Sendable, Equatable {
        case approval       // Tool/command execution approval
        case confirmation   // [y/N], (y/n), proceed?
        case choice         // Menu selection [1-4]
        case input          // Text input prompt
        case osc            // Explicit OSC sequence (OSC 26, OSC 9;4)
    }

    public struct AttentionPrompt: Sendable, Equatable {
        public let kind: PromptKind
        public let summary: String
        public let matchedPattern: String

        public init(kind: PromptKind, summary: String, matchedPattern: String) {
            self.kind = kind
            self.summary = summary
            self.matchedPattern = matchedPattern
        }
    }

    // MARK: - Prompt Signatures

    private static let confirmationRegex: NSRegularExpression? = {
        let pattern = #"(?i)(\[[yY]/[nN]\]|\([yY]/[nN]\)|\[yes/no\]|\(yes/no\))"#
        return try? NSRegularExpression(pattern: pattern)
    }()

    private static let approvalRegex: NSRegularExpression? = {
        let pattern = #"(?i)\b(allow|approve|approval required|permission)\b.*[\?:>]"#
        return try? NSRegularExpression(pattern: pattern)
    }()

    private static let proceedRegex: NSRegularExpression? = {
        let pattern = #"(?i)\b(do you want to (proceed|continue|execute|run)|run (this )?command|execute (this )?command)\b.*[\?:>]"#
        return try? NSRegularExpression(pattern: pattern)
    }()

    private static let choiceRegex: NSRegularExpression? = {
        let pattern = #"(?i)\b(choice|select)\s*(\[\d+-\d+\]|\(\d+-\d+\)|[1-9]\))"#
        return try? NSRegularExpression(pattern: pattern)
    }()

    private static let pressEnterRegex: NSRegularExpression? = {
        let pattern = #"(?i)\bpress enter to (continue|proceed)\b"#
        return try? NSRegularExpression(pattern: pattern)
    }()

    private static let waitingForInputRegex: NSRegularExpression? = {
        let pattern = #"(?i)\bwaiting for (user )?(input|approval|response)\b"#
        return try? NSRegularExpression(pattern: pattern)
    }()

    private static let interactiveQuestionRegex: NSRegularExpression? = {
        // Line ending with "?" or "? " or "? (default: ...)" typical of inquirer / prompts.js
        let pattern = #"(?:^|\n)[^\n\r]*\?\s+(?:\[[^\]]+\]|\([^\)]+\)|[A-Za-z0-9_].*)?$"#
        return try? NSRegularExpression(pattern: pattern)
    }()

    // MARK: - ANSI Stripping

    private static let ansiRegex: NSRegularExpression? = {
        // Strips CSI sequences, OSC sequences, and single-char control escapes
        let pattern = #"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~]|\].*?(?:\x07|\x1B\\))"#
        return try? NSRegularExpression(pattern: pattern)
    }()

    public static func stripAnsiSequences(from text: String) -> String {
        guard let regex = ansiRegex else { return text }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")
    }

    // MARK: - Prompt Detection

    /// Analyzes the trailing output text from a surface.
    /// Returns an `AttentionPrompt` if a waiting signature is found at the tail.
    public static func detectPrompt(in rawText: String) -> AttentionPrompt? {
        guard !rawText.isEmpty else { return nil }

        // Take up to the last 2048 characters to keep regex performance instantaneous (<1ms)
        let tail = rawText.suffix(2048)
        let clean = stripAnsiSequences(from: String(tail))
            .replacingOccurrences(of: "\r", with: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !clean.isEmpty else { return nil }

        // 1. Explicit Confirmation [y/N]
        if let regex = confirmationRegex,
           let match = lastMatch(in: clean, regex: regex) {
            let matched = substring(clean, range: match.range)
            return AttentionPrompt(kind: .confirmation, summary: "Approve [y/n]?", matchedPattern: matched)
        }

        // 2. Permission / Approval required
        if let regex = approvalRegex,
           let match = lastMatch(in: clean, regex: regex) {
            let matched = substring(clean, range: match.range)
            return AttentionPrompt(kind: .approval, summary: "Tool approval required", matchedPattern: matched)
        }

        // 3. Do you want to proceed? / Run command?
        if let regex = proceedRegex,
           let match = lastMatch(in: clean, regex: regex) {
            let matched = substring(clean, range: match.range)
            return AttentionPrompt(kind: .approval, summary: "Approval required", matchedPattern: matched)
        }

        // 4. Choice selection [1-4]
        if let regex = choiceRegex,
           let match = lastMatch(in: clean, regex: regex) {
            let matched = substring(clean, range: match.range)
            return AttentionPrompt(kind: .choice, summary: "Choice selection required", matchedPattern: matched)
        }

        // 5. Press Enter to continue
        if let regex = pressEnterRegex,
           let match = lastMatch(in: clean, regex: regex) {
            let matched = substring(clean, range: match.range)
            return AttentionPrompt(kind: .confirmation, summary: "Press Enter to continue", matchedPattern: matched)
        }

        // 6. Waiting for input
        if let regex = waitingForInputRegex,
           let match = lastMatch(in: clean, regex: regex) {
            let matched = substring(clean, range: match.range)
            return AttentionPrompt(kind: .input, summary: "Waiting for user input", matchedPattern: matched)
        }

        // 7. Interactive question prompt (e.g. "? Select tool (Use arrow keys)")
        if let regex = interactiveQuestionRegex,
           let match = lastMatch(in: clean, regex: regex) {
            let matched = substring(clean, range: match.range).trimmingCharacters(in: .whitespacesAndNewlines)
            let firstLine = matched.components(separatedBy: .newlines).last ?? matched
            let summary = firstLine.prefix(40)
            return AttentionPrompt(kind: .input, summary: String(summary), matchedPattern: matched)
        }

        return nil
    }

    /// Detects OSC 9;4 or OSC 26 agent attention markers in raw stream data.
    public static func detectOSC(in data: Data) -> AttentionPrompt? {
        guard let text = String(data: data, encoding: .utf8) else { return nil }
        return detectOSC(in: text)
    }

    /// Detects OSC 9;4 or OSC 26 agent attention markers in text.
    public static func detectOSC(in text: String) -> AttentionPrompt? {
        // OSC 9;4;3 or OSC 9;4;4 (Ghostty/terminal agent state 3=waiting, 4=paused)
        if text.contains("9;4;3") || text.contains("9;4;4") {
            return AttentionPrompt(kind: .osc, summary: "Agent waiting for approval", matchedPattern: "OSC 9;4")
        }

        // OSC 26;...status=waiting_input or status=awaiting
        if text.contains("26;") && (text.contains("status=waiting_input") || text.contains("status=awaiting")) {
            return AttentionPrompt(kind: .osc, summary: "Agent waiting for input", matchedPattern: "OSC 26")
        }

        return nil
    }

    // MARK: - Helpers

    private static func lastMatch(in text: String, regex: NSRegularExpression) -> NSTextCheckingResult? {
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = regex.matches(in: text, options: [], range: range)
        return matches.last
    }

    private static func substring(_ text: String, range: NSRange) -> String {
        guard let r = Range(range, in: text) else { return "" }
        return String(text[r])
    }
}
