import Foundation
import KouenCore

/// A reviewable batch binds the selection to catalog state and destination identities.
struct ProjectMovePreview {
    struct Move {
        let oldPath: String
        let newPath: String
        let fileNumber: NSNumber
        let systemNumber: NSNumber
    }
    let projects: [ProjectEntry]
    let categories: [ProjectCategory]
    let moves: [Move]
}

extension ProjectStore {
    func previewMoves(_ mapping: [String: String]) -> ProjectMovePreview? {
        guard !mapping.isEmpty, Set(mapping.values).count == mapping.count else { return nil }
        let fm = FileManager.default
        var moves: [ProjectMovePreview.Move] = []
        for (old, new) in mapping.sorted(by: { $0.key < $1.key }) {
            guard projects.contains(where: { $0.path == old }),
                  !fm.fileExists(atPath: old),
                  !projects.contains(where: { $0.path == new }),
                  WorkspaceRepositoryScanner.isPrimaryRepository(new),
                  let attributes = try? fm.attributesOfItem(atPath: new),
                  attributes[.type] as? FileAttributeType == .typeDirectory,
                  let number = attributes[.systemFileNumber] as? NSNumber,
                  let system = attributes[.systemNumber] as? NSNumber else { return nil }
            moves.append(.init(oldPath: old, newPath: new, fileNumber: number, systemNumber: system))
        }
        return ProjectMovePreview(projects: projects, categories: categories, moves: moves)
    }

    @discardableResult
    func applyMoves(_ preview: ProjectMovePreview) -> Bool {
        guard projects == preview.projects, categories == preview.categories,
              let current = previewMoves(Dictionary(uniqueKeysWithValues: preview.moves.map { ($0.oldPath, $0.newPath) })),
              zip(current.moves, preview.moves).allSatisfy({ $0.fileNumber == $1.fileNumber && $0.systemNumber == $1.systemNumber }) else { return false }
        let mapping = Dictionary(uniqueKeysWithValues: preview.moves.map { ($0.oldPath, $0.newPath) })
        projects = projects.map { entry in
            var updated = entry
            if let destination = mapping[entry.path] { updated.path = destination }
            return updated
        }
        save()
        return true
    }
}
