import Foundation

/// Scans workspace files and extracts identifiers for local completion.
/// Runs off-main. Debounced rescan on file changes.
@MainActor
final class WorkspaceSymbolIndex {
    private(set) var symbols: Set<String> = [] {
        didSet { sortedSymbols = symbols.sorted() }
    }
    private(set) var currentFileSymbols: Set<String> = [] {
        didSet { sortedCurrentFileSymbols = currentFileSymbols.sorted() }
    }
    private var sortedSymbols: [String] = []
    private var sortedCurrentFileSymbols: [String] = []
    private(set) var scanTask: Task<Void, Never>?
    private var rootCache: [String: Set<String>] = [:]

    func scan(root: String) {
        scanTask?.cancel()
        if let cached = rootCache[root] {
            self.symbols = cached
        }
        scanTask = Task.detached(priority: .utility) {
            let result = Self.extractSymbols(root: root)
            guard !Task.isCancelled else { return }
            await MainActor.run { [weak self] in
                guard let self, !Task.isCancelled else { return }
                if self.rootCache.count > 20 {
                    self.rootCache.removeAll()
                }
                self.rootCache[root] = result
                self.symbols = result
            }
        }
    }

    /// Extract identifiers from source files using a simple regex.
    /// Matches: func/class/struct/enum/let/var/def/const/function declarations.
    nonisolated private static func extractSymbols(root: String) -> Set<String> {
        var result = Set<String>()
        let expanded = (root as NSString).expandingTildeInPath
        let rootURL = URL(fileURLWithPath: expanded).resolvingSymlinksInPath()
        let allowedExtensions: Set<String> = ["swift", "ts", "js", "py", "go", "rs", "rb"]
        
        crawl(url: rootURL, depth: 1, maxDepth: 4, allowedExtensions: allowedExtensions, symbols: &result)
        return result
    }

    nonisolated private static let symbolDefRegex: NSRegularExpression? = {
        let pattern = "\\b(?:func|class|struct|enum|protocol|let|var|def|const|function|type|interface)\\s+([A-Za-z_]\\w*)"
        return try? NSRegularExpression(pattern: pattern, options: [])
    }()

    nonisolated private static let currentFileSymbolRegex: NSRegularExpression? = {
        let pattern = "\\b[A-Za-z_]\\w{3,}\\b"
        return try? NSRegularExpression(pattern: pattern, options: [])
    }()

    nonisolated private static let excludedDirNames: Set<String> = [
        "node_modules", "build", "dist", "Pods", "DerivedData", "target", "vendor", ".build", ".gradle", ".next", ".terraform", ".venv", "__pycache__"
    ]

    nonisolated private static func crawl(url: URL, depth: Int, maxDepth: Int, allowedExtensions: Set<String>, symbols: inout Set<String>) {
        guard depth <= maxDepth, !Task.isCancelled else { return }
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey], options: [.skipsHiddenFiles]) else {
            return
        }
        for fileURL in contents {
            guard !Task.isCancelled else { return }
            let name = fileURL.lastPathComponent
            if excludedDirNames.contains(name) { continue }

            let resourceValues = try? fileURL.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey])
            let isDir: Bool
            if let d = resourceValues?.isDirectory {
                isDir = d
            } else {
                var dirObjC: ObjCBool = false
                isDir = fm.fileExists(atPath: fileURL.path, isDirectory: &dirObjC) && dirObjC.boolValue
            }
            if isDir {
                crawl(url: fileURL, depth: depth + 1, maxDepth: maxDepth, allowedExtensions: allowedExtensions, symbols: &symbols)
            } else {
                let ext = fileURL.pathExtension.lowercased()
                if allowedExtensions.contains(ext) {
                    let size = resourceValues?.fileSize ?? 0
                    if size <= 100_000 { // Skip files > 100KB
                        if let content = try? String(contentsOf: fileURL, encoding: .utf8) {
                            parseSymbols(from: content, into: &symbols)
                        }
                    }
                }
            }
            if symbols.count >= 10_000 || Task.isCancelled {
                return
            }
        }
    }

    nonisolated private static func parseSymbols(from content: String, into symbols: inout Set<String>) {
        guard let regex = symbolDefRegex else { return }
        let nsString = content as NSString
        let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: nsString.length))
        for match in matches {
            if match.numberOfRanges > 1 {
                let range = match.range(at: 1)
                if range.location != NSNotFound {
                    let symbol = nsString.substring(with: range)
                    symbols.insert(symbol)
                    if symbols.count >= 10_000 {
                        return
                    }
                }
            }
        }
    }

    func updateCurrentFileSymbols(text: String) {
        guard let regex = Self.currentFileSymbolRegex else { return }
        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        var temp = Set<String>()
        for match in matches {
            let symbol = nsString.substring(with: match.range)
            temp.insert(symbol)
            if temp.count >= 2000 {
                break
            }
        }
        self.currentFileSymbols = temp
    }

    func completions(prefix: String, limit: Int = 20) -> [String] {
        guard !prefix.isEmpty else { return [] }
        var matches = Set<String>()

        func collect(from array: [String]) {
            var low = 0
            var high = array.count
            while low < high {
                let mid = (low + high) / 2
                if array[mid] < prefix {
                    low = mid + 1
                } else {
                    high = mid
                }
            }
            var idx = low
            while idx < array.count {
                let item = array[idx]
                guard item.hasPrefix(prefix) else { break }
                if item != prefix {
                    matches.insert(item)
                    if matches.count >= limit { return }
                }
                idx += 1
            }
        }

        collect(from: sortedCurrentFileSymbols)
        if matches.count < limit {
            collect(from: sortedSymbols)
        }
        return matches.sorted().prefix(limit).map { String($0) }
    }
}
