import Foundation

// Ported (trimmed) from the Kouen monorepo:
//   • Identifiers / SplitDirection / PaneNode — Packages/KouenCore/.../Models/
//   • PaneRectSolver                          — Packages/KouenCore/.../Session/PaneRectSolver.swift
// daemon-surface bookkeeping is dropped (we never attach to a live daemon).

public typealias PaneID = UUID
public typealias SurfaceID = UUID

public enum SplitDirection: String, Codable, Sendable {
    case horizontal
    case vertical
}

public struct PaneLeaf: Sendable, Equatable {
    public var id: PaneID
    public var surfaceID: SurfaceID
    public init(id: PaneID = UUID(), surfaceID: SurfaceID = UUID()) {
        self.id = id; self.surfaceID = surfaceID
    }
}

public enum PaneNode: Sendable, Equatable {
    case leaf(PaneLeaf)
    indirect case branch(direction: SplitDirection, ratio: Double, first: PaneNode, second: PaneNode)

    public func allLeaves() -> [PaneLeaf] {
        switch self {
        case let .leaf(leaf): [leaf]
        case let .branch(_, _, first, second): first.allLeaves() + second.allLeaves()
        }
    }
}

/// The interior rectangle a single pane renders into, in terminal cell coordinates
/// (origin top-left). Excludes the 1-cell dividers between panes.
public struct PaneRect: Sendable, Equatable {
    public var paneID: PaneID
    public var surfaceID: SurfaceID
    public var x: Int
    public var y: Int
    public var cols: Int
    public var rows: Int
    /// Absolute row for this pane's border-status label, or nil when off.
    public var labelRow: Int?

    public init(paneID: PaneID, surfaceID: SurfaceID, x: Int, y: Int, cols: Int, rows: Int, labelRow: Int? = nil) {
        self.paneID = paneID; self.surfaceID = surfaceID
        self.x = x; self.y = y; self.cols = cols; self.rows = rows; self.labelRow = labelRow
    }
}

public enum PaneBorderStatus: String, Sendable, Equatable {
    case off, top, bottom
    public init(option value: String) { self = PaneBorderStatus(rawValue: value.lowercased()) ?? .off }
}

/// Computes pane interior rectangles from a `PaneNode` split tree, reserving one cell
/// between siblings for a border. A `.horizontal` branch is side-by-side; `.vertical` is stacked.
public enum PaneRectSolver {
    public static func solve(
        _ node: PaneNode, cols: Int, rows: Int,
        border: Bool = true, paneBorderStatus: PaneBorderStatus = .off
    ) -> [PaneRect] {
        guard cols > 0, rows > 0 else { return [] }
        var out: [PaneRect] = []
        solve(node, x: 0, y: 0, cols: cols, rows: rows, border: border, status: paneBorderStatus, into: &out)
        return out
    }

    private static func solve(
        _ node: PaneNode, x: Int, y: Int, cols: Int, rows: Int,
        border: Bool, status: PaneBorderStatus, into out: inout [PaneRect]
    ) {
        guard cols > 0, rows > 0 else { return }
        switch node {
        case let .leaf(leaf):
            var iy = y, irows = rows, labelRow: Int? = nil
            if status != .off, rows >= 2 {
                switch status {
                case .top: labelRow = y; iy = y + 1; irows = rows - 1
                case .bottom: labelRow = y + rows - 1; irows = rows - 1
                case .off: break
                }
            }
            out.append(PaneRect(paneID: leaf.id, surfaceID: leaf.surfaceID,
                                x: x, y: iy, cols: cols, rows: irows, labelRow: labelRow))
        case let .branch(direction, ratio, first, second):
            switch direction {
            case .horizontal:
                let (firstCols, gap, secondCols) = split(total: cols, ratio: ratio, border: border)
                solve(first, x: x, y: y, cols: firstCols, rows: rows, border: border, status: status, into: &out)
                solve(second, x: x + firstCols + gap, y: y, cols: secondCols, rows: rows, border: border, status: status, into: &out)
            case .vertical:
                let (firstRows, gap, secondRows) = split(total: rows, ratio: ratio, border: border)
                solve(first, x: x, y: y, cols: cols, rows: firstRows, border: border, status: status, into: &out)
                solve(second, x: x, y: y + firstRows + gap, cols: cols, rows: secondRows, border: border, status: status, into: &out)
            }
        }
    }

    private static func split(total: Int, ratio: Double, border: Bool) -> (Int, Int, Int) {
        let wantGap = border && total >= 3
        let gap = wantGap ? 1 : 0
        let available = total - gap
        let r = ratio.isFinite ? min(max(ratio, 0), 1) : 0.5
        var first = Int((Double(available) * r).rounded())
        first = min(max(first, 1), max(available - 1, 1))
        let second = available - first
        return (first, gap, second)
    }
}
