import Foundation
import SwiftUI

public enum IssueTrackerType: String, CaseIterable, Identifiable, Sendable, Codable {
    case linear = "Linear"
    case jira = "Jira"
    case azureDevOps = "Azure DevOps"

    public var id: String { rawValue }

    public var symbolName: String {
        switch self {
        case .linear: return "arrow.up.right.square"
        case .jira: return "square.stack.3d.forward.dottedline"
        case .azureDevOps: return "cloud"
        }
    }
}

public enum IssuePriority: String, CaseIterable, Sendable, Codable {
    case urgent = "Urgent"
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    case none = "None"

    public var color: Color {
        switch self {
        case .urgent: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        case .none: return .secondary
        }
    }

    public var symbol: String {
        switch self {
        case .urgent: return "exclamationmark.3"
        case .high: return "exclamationmark.2"
        case .medium: return "exclamationmark"
        case .low: return "arrow.down"
        case .none: return "minus"
        }
    }
}

public struct TrackedIssue: Identifiable, Sendable, Equatable, Codable {
    public let id: String
    public let key: String
    public let title: String
    public let description: String?
    public let priority: IssuePriority
    public let status: String
    public let url: String?
    public let trackerType: IssueTrackerType

    public init(
        id: String,
        key: String,
        title: String,
        description: String? = nil,
        priority: IssuePriority = .medium,
        status: String = "In Progress",
        url: String? = nil,
        trackerType: IssueTrackerType = .linear
    ) {
        self.id = id
        self.key = key
        self.title = title
        self.description = description
        self.priority = priority
        self.status = status
        self.url = url
        self.trackerType = trackerType
    }
}
