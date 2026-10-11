import Foundation

/// A position in retained history followed by the live viewport. `column` may be one
/// past the final cell when representing a command boundary rather than a selected cell.
public struct TerminalTextPosition: Sendable, Hashable, Codable {
    public var line: Int
    public var column: Int

    public init(line: Int, column: Int) {
        self.line = line
        self.column = column
    }
}

/// Coordinates captured with a rendered grid or main-thread state mirror. Registration is
/// immediate and never waits for the parser queue. Head eviction translates the coordinates;
/// a structural edit rejects an obsolete coordinate space instead of selecting different text.
public struct TerminalTextAnchorContext: Sendable {
    fileprivate let store: TerminalTextAnchorStore
    fileprivate let origin: Int
    fileprivate let revision: UInt64
    fileprivate let lineCount: Int
    fileprivate let columns: Int

    public func makeAnchor(line: Int, column: Int) -> TerminalTextAnchor? {
        store.make(line: line, column: column, in: self)
    }
}

enum TerminalTextAnchorAffinity { case cell, boundary }

/// A text position that follows reflow and scrolling. Reading does not enter the
/// parser queue. An erased selected cell or evicted position becomes nil and never revives.
public final class TerminalTextAnchor: @unchecked Sendable {
    fileprivate let store: TerminalTextAnchorStore
    fileprivate let affinity: TerminalTextAnchorAffinity
    fileprivate var absolutePosition: TerminalTextPosition?
    fileprivate init(store: TerminalTextAnchorStore, position: TerminalTextPosition,
                     affinity: TerminalTextAnchorAffinity = .cell) {
        self.store = store
        self.affinity = affinity
        absolutePosition = position
    }

    public var position: TerminalTextPosition? { store.position(of: self) }

    deinit { store.remove(self) }
}

/// Screen-confined mutations, independently synchronized readers. The shared origin
/// makes normal scrollback eviction constant-time regardless of the number of anchors.
final class TerminalTextAnchorStore: @unchecked Sendable {
    private struct WeakAnchor { weak var value: TerminalTextAnchor? }
    // Dropping the final temporary reference during a registry traversal can invoke deinit.
    private let lock = NSRecursiveLock()
    private var anchors: [ObjectIdentifier: WeakAnchor] = [:]
    // Prompt redraw erases are frequent; they must not scan retained command boundaries.
    private var cellAnchors: [ObjectIdentifier: WeakAnchor] = [:]
    private var origin = 0
    private var revision: UInt64 = 0
    private var remapping = false
    private var successor: TerminalTextAnchorStore?
    private struct WeakStore { weak var value: TerminalTextAnchorStore? }
    private var predecessors: [WeakStore] = []

    func make(line: Int, column: Int, affinity: TerminalTextAnchorAffinity = .cell) -> TerminalTextAnchor {
        lock.lock(); defer { lock.unlock() }
        let anchor = TerminalTextAnchor(store: self, position: .init(line: line + origin, column: column), affinity: affinity)
        let id = ObjectIdentifier(anchor)
        let entry = WeakAnchor(value: anchor)
        anchors[id] = entry
        if affinity == .cell { cellAnchors[id] = entry }
        return anchor
    }

    func context(lineCount: Int, columns: Int) -> TerminalTextAnchorContext {
        lock.lock(); defer { lock.unlock() }
        return .init(store: self, origin: origin, revision: revision, lineCount: lineCount, columns: columns)
    }

    fileprivate func make(line: Int, column: Int, in context: TerminalTextAnchorContext) -> TerminalTextAnchor? {
        lock.lock(); defer { lock.unlock() }
        guard successor == nil, !remapping, context.revision == revision,
              line >= 0, line < context.lineCount, column >= 0, column <= context.columns,
              line + context.origin >= origin else { return nil }
        let anchor = TerminalTextAnchor(store: self, position: .init(line: line + context.origin, column: column))
        let id = ObjectIdentifier(anchor)
        let entry = WeakAnchor(value: anchor)
        anchors[id] = entry
        cellAnchors[id] = entry
        return anchor
    }

    fileprivate func remove(_ anchor: TerminalTextAnchor) {
        lock.lock()
        if let successor { lock.unlock(); successor.remove(anchor); return }
        defer { lock.unlock() }
        let id = ObjectIdentifier(anchor)
        anchors.removeValue(forKey: id)
        cellAnchors.removeValue(forKey: id)
    }

    fileprivate func position(of anchor: TerminalTextAnchor) -> TerminalTextPosition? {
        lock.lock()
        if let successor { lock.unlock(); return successor.position(of: anchor) }
        defer { lock.unlock() }
        guard var position = anchor.absolutePosition, position.line >= origin else { return nil }
        position.line -= origin
        return position
    }

    func dropHead(_ count: Int) {
        lock.lock(); defer { lock.unlock() }
        origin += count
    }

    func beginRemap() -> [(TerminalTextAnchor, TerminalTextPosition)] {
        lock.lock(); defer { lock.unlock() }
        revision &+= 1
        remapping = true
        return anchors.values.compactMap { entry in
            guard let anchor = entry.value, var position = anchor.absolutePosition,
                  position.line >= origin else { return nil }
            position.line -= origin
            return (anchor, position)
        }
    }

    func remap(_ snapshot: [(TerminalTextAnchor, TerminalTextPosition)],
               _ map: (TerminalTextPosition) -> TerminalTextPosition?) {
        lock.lock(); defer { lock.unlock() }
        for (anchor, previous) in snapshot {
            anchor.absolutePosition = map(previous).map { .init(line: $0.line + origin, column: $0.column) }
        }
        remapping = false
    }

    /// A restored screen inherits live references without exposing a stale queue-bound snapshot.
    func takeAnchors(from previous: TerminalTextAnchorStore, lineOffset: Int) {
        guard previous !== self else { return }
        lock.lock(); defer { lock.unlock() }
        previous.lock.lock()
        revision &+= 1
        previous.revision &+= 1
        for entry in previous.anchors.values {
            guard let anchor = entry.value else { continue }
            if var position = anchor.absolutePosition, position.line >= previous.origin {
                position.line += origin - previous.origin + lineOffset
                anchor.absolutePosition = position.line >= origin ? position : nil
            } else {
                anchor.absolutePosition = nil
            }
            let id = ObjectIdentifier(anchor)
            anchors[id] = entry
            if anchor.affinity == .cell { cellAnchors[id] = entry }
        }
        previous.anchors.removeAll()
        previous.cellAnchors.removeAll()
        let predecessors = previous.predecessors.compactMap(\.value)
        previous.predecessors.removeAll()
        previous.successor = self
        previous.lock.unlock()
        self.predecessors.append(WeakStore(value: previous))
        for predecessor in predecessors {
            predecessor.lock.lock()
            predecessor.successor = self
            predecessor.lock.unlock()
            self.predecessors.append(WeakStore(value: predecessor))
        }
        self.predecessors.removeAll { $0.value == nil }
    }

    func invalidateOwnedAnchors() {
        lock.lock(); defer { lock.unlock() }
        guard successor == nil else { return }
        revision &+= 1
        for entry in anchors.values { entry.value?.absolutePosition = nil }
    }

    func transformCells(_ map: (TerminalTextPosition) -> TerminalTextPosition?) {
        lock.lock(); defer { lock.unlock() }
        revision &+= 1
        for entry in cellAnchors.values {
            guard let anchor = entry.value, let previous = position(of: anchor) else { continue }
            anchor.absolutePosition = map(previous).map { .init(line: $0.line + origin, column: $0.column) }
        }
    }

    func transform(_ map: (TerminalTextPosition) -> TerminalTextPosition?) {
        remap(beginRemap(), map)
    }
}
