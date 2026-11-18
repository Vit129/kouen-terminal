import Foundation

public enum WorkspaceReconciliation {
    public struct Candidate: Codable, Sendable, Equatable {
        public let oldPath: String
        public let newPath: String
        /// Name-only matches always require human review; ambiguity prevents automatic selection.
        public let confidence: String
    }

    public static func candidates(missing: [String], discovered: [String]) -> [Candidate] {
        let pairs = missing.sorted().flatMap { old in
            discovered.sorted().filter { ($0 as NSString).lastPathComponent == (old as NSString).lastPathComponent }
                .map { (old, $0) }
        }
        return pairs.map { old, new in
            let uniqueOld = pairs.filter { $0.0 == old }.count == 1
            let uniqueNew = pairs.filter { $0.1 == new }.count == 1
            return Candidate(oldPath: old, newPath: new, confidence: uniqueOld && uniqueNew ? "weak" : "ambiguous")
        }
    }
}
