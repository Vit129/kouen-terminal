import Foundation
import KouenCore

/// Access is confined to the registry lock. At capacity, refuse new attempts so an
/// acknowledged ID can never become eligible again during this daemon lifetime.
struct ReviewFeedbackAttempts {
    private var accepted: Set<UUID> = []
    var isFull: Bool { accepted.count >= 16_384 }
    func contains(_ id: UUID) -> Bool { accepted.contains(id) }
    mutating func acknowledge(_ id: UUID) { accepted.insert(id) }

    static func rejection(expected: ReviewFeedbackRequest, actualTarget: ReviewFeedbackTarget?,
                          actualWorktree: ReviewWorktreeBinding?, idle: Bool) -> ReviewFeedbackDelivery? {
        guard actualTarget == expected.target else { return .targetChanged }
        guard idle else { return .notIdle }
        guard let actualWorktree, actualWorktree == expected.worktree,
              actualWorktree.head == expected.headSHA else { return .worktreeChanged }
        return nil
    }
}
