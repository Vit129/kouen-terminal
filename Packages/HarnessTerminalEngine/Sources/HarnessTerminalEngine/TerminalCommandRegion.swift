import Foundation

/// Shell-delimited text. The end is exclusive; anchors follow the text through reflow.
public struct TerminalTextRange: Sendable {
    public let start: TerminalTextPosition
    public let end: TerminalTextPosition

    public init?(start: TerminalTextPosition?, end: TerminalTextPosition?) {
        guard let start, let end, (start.line, start.column) < (end.line, end.column) else { return nil }
        self.start = start
        self.end = end
    }
}

public struct TerminalCommandRegion: Sendable {
    public let id: UInt64
    public let prompt: TerminalTextAnchor
    public internal(set) var input: TerminalTextAnchor?
    public internal(set) var output: TerminalTextAnchor?
    public internal(set) var end: TerminalTextAnchor?
    public internal(set) var exitCode: Int?

    public var inputRange: TerminalTextRange? {
        TerminalTextRange(start: input?.position, end: output?.position)
    }

    public var outputRange: TerminalTextRange? {
        TerminalTextRange(start: output?.position, end: end?.position)
    }
}

/// Retains only bounded shell metadata, never a second copy of terminal output.
final class TerminalCommandHistory {
    private var completed = HistoryRingBuffer<TerminalCommandRegion>()
    private var active: TerminalCommandRegion?
    private var nextID: UInt64 = 0
    private static let capacity = 4096

    var commands: [TerminalCommandRegion] {
        completed.filter { $0.prompt.position != nil } + (active.map { [$0] } ?? [])
    }

    var lastCompleted: TerminalCommandRegion? { completed.isEmpty ? nil : completed[completed.count - 1] }

    func startPrompt(at anchor: TerminalTextAnchor) {
        // Repainted prompts replace an unfinished input region; they aren't new commands.
        if active?.output != nil { finish(at: anchor, exitCode: nil) }
        while !completed.isEmpty, completed[0].end?.position == nil || completed.count >= Self.capacity {
            completed.removeFirst()
        }
        nextID &+= 1
        active = TerminalCommandRegion(id: nextID, prompt: anchor)
    }

    func startInput(at anchor: TerminalTextAnchor) { active?.input = anchor }
    func startOutput(at anchor: TerminalTextAnchor) { active?.output = anchor }

    func finish(at anchor: TerminalTextAnchor, exitCode: Int?) {
        guard var command = active else { return }
        command.end = anchor
        command.exitCode = exitCode
        completed.append(command)
        active = nil
    }

    func reset() {
        completed.removeAll()
        active = nil
    }
}

extension TerminalCommandHistory {
    struct CheckpointRegion: Codable {
        var id: UInt64
        var prompt: TerminalTextPosition
        var input: TerminalTextPosition?
        var output: TerminalTextPosition?
        var end: TerminalTextPosition?
        var exitCode: Int?
    }

    struct CheckpointState: Codable {
        var completed: [CheckpointRegion]
        var active: CheckpointRegion?
        var nextID: UInt64
    }

    /// The checkpoint contains the viewport only. A missing prompt drops its command;
    /// missing optional boundaries stay missing instead of inventing a clipped range.
    func checkpointState(historyCount: Int, rows: Int, columns: Int) -> CheckpointState {
        func position(_ anchor: TerminalTextAnchor?) -> TerminalTextPosition? {
            guard let point = anchor?.position else { return nil }
            let line = point.line - historyCount
            guard (0..<rows).contains(line), (0...columns).contains(point.column) else { return nil }
            return TerminalTextPosition(line: line, column: point.column)
        }
        func region(_ command: TerminalCommandRegion) -> CheckpointRegion? {
            guard let prompt = position(command.prompt) else { return nil }
            return CheckpointRegion(id: command.id, prompt: prompt, input: position(command.input),
                output: position(command.output), end: position(command.end), exitCode: command.exitCode)
        }
        return CheckpointState(completed: completed.compactMap(region).filter { $0.end != nil },
            active: active.flatMap(region), nextID: nextID)
    }

    static func restored(from state: CheckpointState, rows: Int, columns: Int,
                         makeAnchor: (TerminalTextPosition) -> TerminalTextAnchor) throws -> TerminalCommandHistory {
        guard state.completed.count <= capacity, state.nextID < UInt64.max else { throw TerminalCheckpointError.invalidState }
        let regions = state.completed + (state.active.map { [$0] } ?? [])
        guard state.completed.allSatisfy({ $0.end != nil }), state.active?.end == nil,
              state.active?.exitCode == nil,
              Set(regions.map(\.id)).count == regions.count,
              regions.allSatisfy({ region in
                  region.id > 0 && region.id <= state.nextID &&
                  ([region.prompt] + [region.input, region.output, region.end].compactMap { $0 }).allSatisfy {
                      (0..<rows).contains($0.line) && (0...columns).contains($0.column)
                  }
              }) else { throw TerminalCheckpointError.invalidState }
        func region(_ saved: CheckpointRegion) -> TerminalCommandRegion {
            TerminalCommandRegion(id: saved.id, prompt: makeAnchor(saved.prompt),
                input: saved.input.map(makeAnchor), output: saved.output.map(makeAnchor),
                end: saved.end.map(makeAnchor), exitCode: saved.exitCode)
        }
        let history = TerminalCommandHistory()
        for saved in state.completed { history.completed.append(region(saved)) }
        history.active = state.active.map(region)
        history.nextID = state.nextID
        return history
    }
}
