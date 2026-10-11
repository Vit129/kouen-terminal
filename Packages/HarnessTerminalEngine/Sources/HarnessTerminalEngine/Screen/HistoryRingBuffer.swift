import Foundation

/// A growable ring buffer (deque) for scrollback history. Newest entries are appended at the tail;
/// the oldest are dropped from the head. Dropping the oldest entries advances a head index instead
/// of shifting the survivors, so a long-running session that trims to a scrollback cap no longer
/// pays an O(retained-count) array shift per trim — it pays only O(dropped). Logical index 0 is
/// always the oldest retained element, matching the `[HistoryLine]` array it replaces, so every
/// reader (random access, iteration, `count`) is a drop-in.
///
/// Internal by design: it is an implementation detail of `TerminalScreen`'s scrollback, not part of
/// the engine's public surface.
struct HistoryRingBuffer<Element> {
    /// Backing storage sized to `capacity`. Slots outside `[head, head+count)` (mod capacity) are
    /// `nil` so dropped/empty entries don't retain references (e.g. a `HistoryLine`'s cell arrays).
    private var storage: ContiguousArray<Element?>
    /// Backing index of the oldest retained element (logical index 0). Meaningful only when
    /// `count > 0`; otherwise the buffer is treated as empty regardless of `head`.
    private var head: Int
    /// Number of retained elements.
    private(set) var count: Int

    init() {
        storage = []
        head = 0
        count = 0
    }

    /// Build from a sequence, oldest first. Used by reflow, which recomputes the whole history.
    init<S: Sequence>(_ elements: S) where S.Element == Element {
        self.init()
        for element in elements { append(element) }
    }

    var isEmpty: Bool { count == 0 }
    var storageBytes: Int { storage.capacity * MemoryLayout<Element?>.stride }

    mutating func compactIfUnderused() {
        if count == 0 { removeAll() }
        else if count < storage.count / 4 { growStorage(to: Swift.max(1, count * 2)) }
    }

    /// Append a new newest element. O(1) amortized; grows the backing store (doubling) when full.
    mutating func append(_ element: Element) {
        if count == storage.count {
            growStorage(to: Swift.max(1, storage.count * 2))
        }
        storage[backingIndex(count)] = element
        count += 1
    }

    /// Random access by logical index (0 = oldest). The setter lets callers mutate an element in
    /// place (e.g. `buffer[i].field = x`), which a plain array's element subscript also allows.
    subscript(index: Int) -> Element {
        get {
            precondition(index >= 0 && index < count, "HistoryRingBuffer index out of range")
            return storage[backingIndex(index)]!
        }
        set {
            precondition(index >= 0 && index < count, "HistoryRingBuffer index out of range")
            storage[backingIndex(index)] = newValue
        }
    }

    func withElement<Result>(at index: Int, _ body: (borrowing Element) -> Result) -> Result {
        precondition(index >= 0 && index < count, "HistoryRingBuffer index out of range")
        return storage.withUnsafeBufferPointer { body($0[backingIndex(index)]!) }
    }

    /// Drop the oldest `n` entries (clamped to `count`). Advances `head` rather than shifting the
    /// survivors; the vacated slots are niled so their elements are released.
    mutating func removeFirst(_ n: Int = 1) {
        let drop = Swift.min(Swift.max(0, n), count)
        guard drop > 0 else { return }
        for i in 0 ..< drop { storage[backingIndex(i)] = nil }
        head = (head + drop) & (storage.count - 1)
        count -= drop
    }

    /// Drop the newest `n` entries (clamped to `count`). Decrements `count` and niles the vacated
    /// tail slots so their elements release. The mirror of `removeFirst` for the tail — used by the
    /// width-unchanged resize fast path, which moves the history↔viewport boundary by pulling the
    /// most-recent history lines back down into the viewport (grow).
    mutating func removeLast(_ n: Int = 1) {
        let drop = Swift.min(Swift.max(0, n), count)
        guard drop > 0 else { return }
        for i in (count - drop) ..< count { storage[backingIndex(i)] = nil }
        count -= drop
    }

    mutating func removeAll() {
        storage = []
        head = 0
        count = 0
    }

    /// Map a logical index (0 = oldest) to its slot in `storage`. Only called when `count > 0` (or
    /// from `append` after ensuring capacity), so `storage.count > 0` holds.
    private func backingIndex(_ logical: Int) -> Int {
        (head + logical) & (storage.count - 1)
    }

    /// Re-lay the retained elements out from index 0 into a larger backing store, then pad with nil.
    private mutating func growStorage(to newCapacity: Int) {
        let capacity = 1 << (Int.bitWidth - (Swift.max(1, newCapacity) - 1).leadingZeroBitCount)
        var next = ContiguousArray<Element?>()
        next.reserveCapacity(capacity)
        for i in 0 ..< count { next.append(storage[backingIndex(i)]) }
        while next.count < capacity { next.append(nil) }
        storage = next
        head = 0
    }
}

extension HistoryRingBuffer: Sequence {
    func makeIterator() -> Iterator { Iterator(buffer: self) }

    struct Iterator: IteratorProtocol {
        private let buffer: HistoryRingBuffer
        private var index = 0
        init(buffer: HistoryRingBuffer) { self.buffer = buffer }
        mutating func next() -> Element? {
            guard index < buffer.count else { return nil }
            defer { index += 1 }
            return buffer[index]
        }
    }
}

extension HistoryRingBuffer: Sendable where Element: Sendable {}
