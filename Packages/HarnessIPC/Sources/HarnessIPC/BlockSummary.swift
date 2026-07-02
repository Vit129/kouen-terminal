import Foundation

/// A shell command + its output, exit code, and timing — the wire shape for `getBlock`
/// (P34 F3: `harnessGetLastBlock`/`harnessGetBlock` MCP tools). `output` is pre-joined text
/// (the tool caller doesn't get a second round-trip to fetch it), unlike the engine-side
/// `TerminalBlock` which only stores a line range.
public struct BlockSummary: Codable, Sendable, Equatable {
    public let id: Int
    public let command: String
    public let output: String
    public let exitCode: Int?
    public let startedAt: Date
    public let finishedAt: Date?

    public init(id: Int, command: String, output: String, exitCode: Int?, startedAt: Date, finishedAt: Date?) {
        self.id = id
        self.command = command
        self.output = output
        self.exitCode = exitCode
        self.startedAt = startedAt
        self.finishedAt = finishedAt
    }
}
