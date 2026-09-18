import AppKit
import SwiftUI
import KouenCore
import KouenIPC

// MARK: - Diff Models

public enum DiffFileStatus: String, Sendable, Equatable {
    case modified = "M"
    case added = "A"
    case deleted = "D"
    case renamed = "R"

    public var color: Color {
        switch self {
        case .modified: return .blue
        case .added: return .green
        case .deleted: return .red
        case .renamed: return .purple
        }
    }
}

public struct DiffFileItem: Identifiable, Sendable, Equatable {
    public let id: String
    public let fileName: String
    public let directory: String
    public let fullPath: String
    public let additions: Int
    public let deletions: Int
    public let status: DiffFileStatus
    public let textRange: NSRange
}

public struct DiffAnalysis: @unchecked Sendable, Equatable {
    public let files: [DiffFileItem]
    public let totalAdditions: Int
    public let totalDeletions: Int
    public let attributedDiff: NSAttributedString
    public let rawText: String

    public static let empty = DiffAnalysis(files: [], totalAdditions: 0, totalDeletions: 0, attributedDiff: NSAttributedString(), rawText: "")
}

// MARK: - Diff Parser

@MainActor
public enum DiffParser {
    public static func parse(text: String) -> DiffAnalysis {
        let lines = text.components(separatedBy: "\n")
        var files: [DiffFileItem] = []
        var totalAdd = 0
        var totalDel = 0

        let mono = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        let monoBold = NSFont.monospacedSystemFont(ofSize: 11, weight: .bold)
        let c = KouenDesign.chrome
        let baseAttrs: [NSAttributedString.Key: Any] = [.font: mono, .foregroundColor: c.textPrimary]

        let attributed = NSMutableAttributedString()

        var currentFile: String?
        var currentFileStart = 0
        var currentAdd = 0
        var currentDel = 0
        var currentStatus = DiffFileStatus.modified

        func finalizeCurrentFile(endLocation: Int) {
            guard let file = currentFile else { return }
            let nsPath = file as NSString
            let fileName = nsPath.lastPathComponent
            let dir = nsPath.deletingLastPathComponent
            let item = DiffFileItem(
                id: file,
                fileName: fileName,
                directory: dir.isEmpty ? "." : dir,
                fullPath: file,
                additions: currentAdd,
                deletions: currentDel,
                status: currentStatus,
                textRange: NSRange(location: currentFileStart, length: max(0, endLocation - currentFileStart))
            )
            files.append(item)
            totalAdd += currentAdd
            totalDel += currentDel
        }

        for (i, line) in lines.enumerated() {
            let lineStartLoc = attributed.length
            let suffix = i < lines.count - 1 ? "\n" : ""
            let full = line + suffix

            if line.hasPrefix("diff --git ") {
                finalizeCurrentFile(endLocation: lineStartLoc)
                currentFileStart = lineStartLoc
                currentAdd = 0
                currentDel = 0
                currentStatus = .modified

                let parts = line.split(separator: " ")
                if parts.count >= 4 {
                    let bPath = String(parts.last!)
                    currentFile = bPath.hasPrefix("b/") ? String(bPath.dropFirst(2)) : bPath
                } else {
                    currentFile = line
                }
                attributed.append(NSAttributedString(string: full, attributes: [
                    .font: monoBold,
                    .foregroundColor: NSColor.systemBlue
                ]))
            } else if line.hasPrefix("new file mode") {
                currentStatus = .added
                attributed.append(NSAttributedString(string: full, attributes: [.font: mono, .foregroundColor: c.textTertiary]))
            } else if line.hasPrefix("deleted file mode") {
                currentStatus = .deleted
                attributed.append(NSAttributedString(string: full, attributes: [.font: mono, .foregroundColor: c.textTertiary]))
            } else if line.hasPrefix("rename from") || line.hasPrefix("rename to") {
                currentStatus = .renamed
                attributed.append(NSAttributedString(string: full, attributes: [.font: mono, .foregroundColor: c.textTertiary]))
            } else if line.hasPrefix("@@") {
                attributed.append(NSAttributedString(string: full, attributes: [
                    .font: monoBold,
                    .foregroundColor: NSColor.systemPurple
                ]))
            } else if line.hasPrefix("+") && !line.hasPrefix("+++") {
                currentAdd += 1
                attributed.append(NSAttributedString(string: full, attributes: [
                    .font: mono,
                    .foregroundColor: NSColor.systemGreen
                ]))
            } else if line.hasPrefix("-") && !line.hasPrefix("---") {
                currentDel += 1
                attributed.append(NSAttributedString(string: full, attributes: [
                    .font: mono,
                    .foregroundColor: NSColor.systemRed
                ]))
            } else if line.hasPrefix("+++") || line.hasPrefix("---") {
                attributed.append(NSAttributedString(string: full, attributes: [
                    .font: monoBold,
                    .foregroundColor: c.textSecondary
                ]))
            } else {
                attributed.append(NSAttributedString(string: full, attributes: baseAttrs))
            }
        }
        finalizeCurrentFile(endLocation: attributed.length)

        return DiffAnalysis(
            files: files,
            totalAdditions: totalAdd,
            totalDeletions: totalDel,
            attributedDiff: attributed,
            rawText: text
        )
    }
}

// MARK: - SwiftUI Diff Pane View

public struct DiffPaneView: View {
    public let diffText: String
    public let title: String

    @State private var analysis: DiffAnalysis = .empty
    @State private var selectedFileID: String?
    @State private var filterQuery: String = ""
    @State private var showAnnotateSheet = false
    @State private var annotationInstruction = ""
    @State private var selectedSnippet = ""
    @State private var selectedFileForAnnotation: String = ""
    @State private var toastMessage: String?

    public init(diffText: String, title: String = "Diff Viewer") {
        self.diffText = diffText
        self.title = title
    }

    public var body: some View {
        let c = KouenDesign.chrome
        VStack(spacing: 0) {
            // Header Bar
            headerBar(c: c)

            Divider()

            // 2-Column Split: File list on left, Rich diff on right
            GeometryReader { geo in
                HStack(spacing: 0) {
                    // Left Column: File Tree / List
                    fileListSidebar(c: c)
                        .frame(width: max(180, min(260, geo.size.width * 0.28)))

                    Divider()

                    // Right Column: Diff Text Viewer
                    diffTextViewer(c: c)
                }
            }
        }
        .background(Color(nsColor: c.terminalBackground))
        .onAppear {
            analysis = DiffParser.parse(text: diffText)
            if let first = analysis.files.first {
                selectedFileID = first.id
                selectedFileForAnnotation = first.fullPath
            }
        }
        .sheet(isPresented: $showAnnotateSheet) {
            annotateSheetView(c: c)
        }
        .overlay(alignment: .bottom) {
            if let msg = toastMessage {
                Text(msg)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.85), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func headerBar(c: KouenChromePalette) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(nsColor: c.accent))

            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color(nsColor: c.textPrimary))
                .lineLimit(1)

            HStack(spacing: 4) {
                Text("+\(analysis.totalAdditions)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.green)
                Text("-\(analysis.totalDeletions)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.red)
                Text("across \(analysis.files.count) file\(analysis.files.count == 1 ? "" : "s")")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(nsColor: c.textTertiary))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color(nsColor: c.sidebarBackground).opacity(0.5), in: RoundedRectangle(cornerRadius: 4, style: .continuous))

            Spacer()

            // Annotate AI Diff Button
            Button(action: {
                showAnnotateSheet = true
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Annotate AI Diff")
                        .font(.system(size: 11, weight: .medium))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(nsColor: c.accent), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .help("Send feedback on this diff to the active AI agent")
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(Color(nsColor: c.sidebarBackground))
    }

    @ViewBuilder
    private func fileListSidebar(c: KouenChromePalette) -> some View {
        VStack(spacing: 0) {
            // Search / Filter
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(nsColor: c.textTertiary))
                TextField("Filter files…", text: $filterQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
            }
            .padding(6)
            .background(Color(nsColor: c.sidebarBackground).opacity(0.4), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            .padding(6)

            Divider()

            // Filtered file items
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 1) {
                    let filtered = analysis.files.filter {
                        filterQuery.isEmpty || $0.fullPath.localizedCaseInsensitiveContains(filterQuery)
                    }
                    ForEach(filtered) { file in
                        let isSelected = file.id == selectedFileID
                        HStack(spacing: 6) {
                            Text(file.status.rawValue)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 14, height: 14)
                                .background(file.status.color, in: RoundedRectangle(cornerRadius: 3, style: .continuous))

                            VStack(alignment: .leading, spacing: 1) {
                                Text(file.fileName)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(isSelected ? Color(nsColor: c.textPrimary) : Color(nsColor: c.textSecondary))
                                    .lineLimit(1)
                                if file.directory != "." {
                                    Text(file.directory)
                                        .font(.system(size: 9))
                                        .foregroundStyle(Color(nsColor: c.textTertiary))
                                        .lineLimit(1)
                                }
                            }

                            Spacer()

                            Text("+\(file.additions) -\(file.deletions)")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(Color(nsColor: c.textTertiary))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(isSelected ? Color(nsColor: c.accent).opacity(0.15) : Color.clear)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFileID = file.id
                            selectedFileForAnnotation = file.fullPath
                        }
                    }
                }
                .padding(4)
            }
        }
        .background(Color(nsColor: c.sidebarBackground).opacity(0.6))
    }

    @ViewBuilder
    private func diffTextViewer(c: KouenChromePalette) -> some View {
        DiffTextViewRepresentable(
            attributedDiff: analysis.attributedDiff,
            selectedRange: analysis.files.first(where: { $0.id == selectedFileID })?.textRange,
            onSelectionChanged: { snippet in
                selectedSnippet = snippet
            }
        )
    }

    @ViewBuilder
    private func annotateSheetView(c: KouenChromePalette) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color(nsColor: c.accent))
                Text("Annotate AI Diff")
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                Button("Cancel") { showAnnotateSheet = false }
                    .buttonStyle(.plain)
            }

            Text("Target: \(selectedFileForAnnotation.isEmpty ? "All modified files" : selectedFileForAnnotation)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(nsColor: c.textSecondary))

            if !selectedSnippet.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Selected Diff Snippet:")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color(nsColor: c.textTertiary))
                    ScrollView {
                        Text(selectedSnippet)
                            .font(.system(size: 10, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(6)
                    }
                    .frame(maxHeight: 100)
                    .background(Color(nsColor: c.sidebarBackground), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                }
            }

            Text("Instructions for Agent:")
                .font(.system(size: 11, weight: .medium))

            TextEditor(text: $annotationInstruction)
                .font(.system(size: 12))
                .frame(minHeight: 120)
                .padding(4)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(nsColor: c.border), lineWidth: 1))

            HStack {
                Spacer()
                Button(action: sendAnnotationToAgent) {
                    HStack(spacing: 4) {
                        Image(systemName: "paperplane.fill")
                        Text("Send to Agent")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(nsColor: c.accent), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .disabled(annotationInstruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(16)
        .frame(width: 480, height: 380)
    }

    private func sendAnnotationToAgent() {
        let trimmed = annotationInstruction.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var prompt = "[Review Feedback on Diff: \(selectedFileForAnnotation)]\n\(trimmed)\n"
        if !selectedSnippet.isEmpty {
            prompt += "\nContext:\n```diff\n\(selectedSnippet)\n```\n"
        }

        guard let surfaceID = SessionCoordinator.shared.activeSurfaceID else {
            showToast("No active agent terminal session")
            showAnnotateSheet = false
            return
        }

        Task {
            await SessionCoordinator.shared.requestDaemon(.sendData(surfaceID: surfaceID.uuidString, data: Data(prompt.utf8)))
            showToast("✓ Sent feedback to active agent")
            annotationInstruction = ""
            showAnnotateSheet = false
        }
    }

    private func showToast(_ msg: String) {
        toastMessage = msg
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if toastMessage == msg { toastMessage = nil }
        }
    }
}

// MARK: - Diff TextView Representable

private struct DiffTextViewRepresentable: NSViewRepresentable {
    let attributedDiff: NSAttributedString
    let selectedRange: NSRange?
    var onSelectionChanged: (String) -> Void

    func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSTextView.scrollableTextView()
        let textView = scroll.documentView as! NSTextView
        textView.isEditable = false
        textView.isSelectable = true
        textView.textContainerInset = NSSize(width: 10, height: 10)
        textView.drawsBackground = false
        scroll.drawsBackground = false
        textView.delegate = context.coordinator

        return scroll
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        if textView.attributedString() != attributedDiff {
            textView.textStorage?.setAttributedString(attributedDiff)
        }
        if let range = selectedRange, range.location != NSNotFound, range.location < attributedDiff.length {
            textView.scrollRangeToVisible(range)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelectionChanged: onSelectionChanged)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var onSelectionChanged: (String) -> Void

        init(onSelectionChanged: @escaping (String) -> Void) {
            self.onSelectionChanged = onSelectionChanged
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            let selRange = textView.selectedRange()
            guard selRange.length > 0, let storage = textView.textStorage else {
                onSelectionChanged("")
                return
            }
            let snippet = (storage.string as NSString).substring(with: selRange)
            onSelectionChanged(snippet)
        }
    }
}
