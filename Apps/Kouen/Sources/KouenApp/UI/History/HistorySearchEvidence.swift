import AppKit
import KouenCore
import SwiftUI

/// Explains why a session matched without requiring the user to open it.
struct HistorySearchEvidence: View {
    let query: String
    let title: String
    let branch: String?
    let repo: String
    let agent: String
    let file: String?
    let tool: String?
    let snippet: String?
    let isSemantic: Bool

    private var terms: [String] {
        SearchMatcher(query: query).tokens.filter { $0.count >= 2 }
    }

    private func matches(_ text: String) -> Bool {
        terms.contains { text.range(of: $0, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
    }

    var body: some View {
        if !terms.isEmpty {
            VStack(alignment: .leading, spacing: 3) {
                if matches(title) {
                    Text("Title match")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color.accentColor)
                }
                if let branch, matches(branch) {
                    evidenceRow("Branch", text: branch, lineLimit: 3)
                }
                if matches(repo) {
                    evidenceRow("Repo", text: repo, lineLimit: 2)
                }
                if matches(agent) {
                    evidenceRow("Agent", text: agent, lineLimit: 2)
                }
                if let file { evidenceRow("File", text: file, lineLimit: 2) }
                if let tool { evidenceRow("Tool", text: tool, lineLimit: 2) }
                if let snippet, !snippet.isEmpty {
                    evidenceRow(isSemantic ? "Related" : "Content", text: snippet, lineLimit: 3)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 2)
        }
    }

    private func evidenceRow(_ label: String, text: String, lineLimit: Int) -> some View {
        HStack(alignment: .top, spacing: 5) {
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Color.accentColor)
            highlighted(text)
                .lineLimit(lineLimit)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func highlighted(_ text: String) -> Text {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10),
            .foregroundColor: NSColor.secondaryLabelColor
        ]
        let result = NSMutableAttributedString(string: text, attributes: attributes)
        let source = text as NSString
        for term in terms {
            var location = 0
            while location < source.length {
                let range = source.range(of: term, options: [.caseInsensitive, .diacriticInsensitive],
                                         range: NSRange(location: location, length: source.length - location))
                guard range.location != NSNotFound, range.length > 0 else { break }
                result.addAttributes([.foregroundColor: NSColor.controlAccentColor,
                                      .font: NSFont.boldSystemFont(ofSize: 10)], range: range)
                location = NSMaxRange(range)
            }
        }
        return Text(AttributedString(result))
    }
}
