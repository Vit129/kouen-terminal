import Foundation

public struct BrowserLeaf: Codable, Sendable, Equatable {
    public var id: PaneID
    public var url: URL
    public init(id: PaneID = UUID(), url: URL) { self.id = id; self.url = url }
}

public enum PaneNode: Codable, Sendable, Equatable {
    case leaf(PaneLeaf)
    case browser(BrowserLeaf)
    indirect case branch(direction: SplitDirection, ratio: Double, first: PaneNode, second: PaneNode)

    public var paneID: PaneID? {
        switch self {
        case let .leaf(leaf): return leaf.id
        case let .browser(leaf): return leaf.id
        case .branch: return nil
        }
    }

    public var surfaceID: SurfaceID? {
        switch self {
        case let .leaf(leaf): return leaf.activeSurfaceID ?? leaf.surfaceID
        case .browser: return nil
        case .branch: return nil
        }
    }

    public mutating func replaceSurface(_ surfaceID: SurfaceID, in paneID: PaneID) {
        switch self {
        case var .leaf(leaf):
            if leaf.id == paneID {
                leaf.surfaceID = surfaceID
                leaf.activeSurfaceID = surfaceID
                if !leaf.surfaces.contains(where: { $0.id == surfaceID }) {
                    leaf.surfaces.append(PaneSurface(id: surfaceID, daemonSurfaceID: leaf.daemonSurfaceID))
                }
                self = .leaf(leaf)
            }
        case .branch(let direction, let ratio, var first, var second):
            first.replaceSurface(surfaceID, in: paneID)
            second.replaceSurface(surfaceID, in: paneID)
            self = .branch(direction: direction, ratio: ratio, first: first, second: second)
        case .browser:
            break
        }
    }

    /// Sets `label` on the `PaneSurface` matching `surfaceID`, wherever it is in the tree.
    /// Returns false if no surface with that id exists (nothing to update).
    @discardableResult
    public mutating func setSurfaceLabel(_ surfaceID: SurfaceID, label: String?) -> Bool {
        switch self {
        case var .leaf(leaf):
            guard let index = leaf.surfaces.firstIndex(where: { $0.id == surfaceID }) else { return false }
            leaf.surfaces[index].label = label
            self = .leaf(leaf)
            return true
        case .branch(let direction, let ratio, var first, var second):
            if first.setSurfaceLabel(surfaceID, label: label) {
                self = .branch(direction: direction, ratio: ratio, first: first, second: second)
                return true
            }
            if second.setSurfaceLabel(surfaceID, label: label) {
                self = .branch(direction: direction, ratio: ratio, first: first, second: second)
                return true
            }
            return false
        case .browser:
            return false
        }
    }

    public func allSurfaceIDs() -> [SurfaceID] {
        switch self {
        case let .leaf(leaf):
            return leaf.surfaceIDs
        case let .branch(_, _, first, second):
            return first.allSurfaceIDs() + second.allSurfaceIDs()
        case .browser:
            return []
        }
    }

    public func allPaneIDs() -> [PaneID] {
        switch self {
        case let .leaf(leaf):
            return [leaf.id]
        case let .branch(_, _, first, second):
            return first.allPaneIDs() + second.allPaneIDs()
        case let .browser(leaf):
            return [leaf.id]
        }
    }

    /// All leaves in the same first-then-second order as `allPaneIDs()`/`allSurfaceIDs()` and
    /// `display-panes`/`select-pane` numbering — pairs each pane id with its surface atomically.
    /// All browser pane leaves in the tree.
    public func allBrowserLeaves() -> [BrowserLeaf] {
        switch self {
        case .leaf: return []
        case let .browser(leaf): return [leaf]
        case let .branch(_, _, first, second): return first.allBrowserLeaves() + second.allBrowserLeaves()
        }
    }

    public func allLeaves() -> [PaneLeaf] {
        switch self {
        case let .leaf(leaf):
            return [leaf]
        case let .branch(_, _, first, second):
            return first.allLeaves() + second.allLeaves()
        case .browser:
            return []
        }
    }
}

/// A CMUX-style surface tab inside a pane. This is intentionally smaller than
/// `Tab`: a workspace/session owns split layout, while a pane can hold multiple
/// terminal surfaces and switch between them.
public struct PaneSurface: Codable, Sendable, Identifiable, Equatable {
    public var id: SurfaceID
    public var daemonSurfaceID: DaemonSurfaceID?
    public var title: String
    public var cwd: String?
    /// Agent/human-set purpose annotation (e.g. "build pane", "claude"), distinct from `title`.
    /// Never touched by OSC/shell title updates — only `setPaneLabel` writes it, so it survives
    /// whatever the shell prints next. Nil = unset.
    public var label: String?

    public init(
        id: SurfaceID = UUID(),
        daemonSurfaceID: DaemonSurfaceID? = nil,
        title: String = "Shell",
        cwd: String? = nil,
        label: String? = nil
    ) {
        self.id = id
        self.daemonSurfaceID = daemonSurfaceID
        self.title = title
        self.cwd = cwd
        self.label = label
    }
}

public struct PaneLeaf: Codable, Sendable, Equatable {
    public var id: PaneID
    /// Legacy primary surface for this pane. Kept as the active surface during the
    /// migration to CMUX-style pane-local surface tabs.
    public var surfaceID: SurfaceID
    public var daemonSurfaceID: DaemonSurfaceID?
    public var surfaces: [PaneSurface]
    public var activeSurfaceID: SurfaceID?

    public init(
        id: PaneID = UUID(),
        surfaceID: SurfaceID = UUID(),
        daemonSurfaceID: DaemonSurfaceID? = nil,
        surfaces: [PaneSurface]? = nil,
        activeSurfaceID: SurfaceID? = nil
    ) {
        self.id = id
        self.surfaceID = surfaceID
        self.daemonSurfaceID = daemonSurfaceID
        let resolvedSurfaces = surfaces ?? [
            PaneSurface(id: surfaceID, daemonSurfaceID: daemonSurfaceID)
        ]
        self.surfaces = resolvedSurfaces.isEmpty
            ? [PaneSurface(id: surfaceID, daemonSurfaceID: daemonSurfaceID)]
            : resolvedSurfaces
        self.activeSurfaceID = activeSurfaceID ?? surfaceID
    }

    public var surfaceIDs: [SurfaceID] {
        let ids = surfaces.map(\.id)
        return ids.isEmpty ? [surfaceID] : ids
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case surfaceID
        case daemonSurfaceID
        case surfaces
        case activeSurfaceID
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(PaneID.self, forKey: .id) ?? UUID()
        surfaceID = try c.decodeIfPresent(SurfaceID.self, forKey: .surfaceID) ?? UUID()
        daemonSurfaceID = try c.decodeIfPresent(DaemonSurfaceID.self, forKey: .daemonSurfaceID)
        let decodedSurfaces = try c.decodeIfPresent([PaneSurface].self, forKey: .surfaces) ?? []
        surfaces = decodedSurfaces.isEmpty
            ? [PaneSurface(id: surfaceID, daemonSurfaceID: daemonSurfaceID)]
            : decodedSurfaces
        activeSurfaceID = try c.decodeIfPresent(SurfaceID.self, forKey: .activeSurfaceID) ?? surfaceID
        if !surfaces.contains(where: { $0.id == surfaceID }) {
            surfaces.insert(PaneSurface(id: surfaceID, daemonSurfaceID: daemonSurfaceID), at: 0)
        }
    }
}
