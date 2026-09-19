import AppKit
import KouenCore
import Observation
import SwiftUI

// MARK: - Persistent data model

/// A user-defined category folder grouping repos in the project tree.
struct ProjectCategory: Codable, Hashable, Identifiable {
    var id: String          // stable UUID string
    var name: String
}

/// Per-project metadata persisted alongside the path list.
struct ProjectEntry: Codable, Equatable, Identifiable {
    var path: String
    var categoryID: String?     // nil → "Uncategorized"

    var id: String { path }
}

// MARK: - Store

/// Thin persistence layer: categories + project list in UserDefaults (same store as
/// `KouenSidebarPanelViewController.recentProjectsKey`).
@Observable @MainActor
final class ProjectStore {
    private static let categoriesKey = "ProjectCategories"
    private static let projectsKey = "ProjectEntries"

    var categories: [ProjectCategory] = []
    var projects: [ProjectEntry] = []

    init() {
        load()
        absorbLegacyRecents()
    }

    // MARK: - Persistence

    private func load() {
        if let data = UserDefaults.standard.data(forKey: Self.categoriesKey),
           let decoded = try? JSONDecoder().decode([ProjectCategory].self, from: data) {
            categories = decoded
        }
        if let data = UserDefaults.standard.data(forKey: Self.projectsKey),
           let decoded = try? JSONDecoder().decode([ProjectEntry].self, from: data) {
            let home = FileManager.default.homeDirectoryForCurrentUser.path
            projects = decoded.filter {
                !$0.path.hasSuffix("/.git") && ($0.path as NSString).lastPathComponent != ".git" && $0.path != home
            }
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(data, forKey: Self.categoriesKey)
        }
        if let data = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(data, forKey: Self.projectsKey)
        }
    }

    private func absorbLegacyRecents() {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let existing = Set(projects.map(\.path))
        let legacyPaths = (UserDefaults.standard.stringArray(forKey: "RecentProjectPaths") ?? [])
            .filter { !existing.contains($0) && !$0.hasSuffix("/.git") && ($0 as NSString).lastPathComponent != ".git" && $0 != home }
        guard !legacyPaths.isEmpty else { return }
        for path in legacyPaths {
            projects.append(ProjectEntry(path: path))
        }
        save()
    }

    // MARK: - Mutations

    func addProject(_ path: String, categoryID: String? = nil) {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        guard !path.isEmpty, !path.hasSuffix("/.git"), (path as NSString).lastPathComponent != ".git", path != home else { return }
        guard !projects.contains(where: { $0.path == path }) else {
            if let categoryID, let idx = projects.firstIndex(where: { $0.path == path }) {
                projects[idx].categoryID = categoryID
                save()
            }
            return
        }
        projects.insert(ProjectEntry(path: path, categoryID: categoryID), at: 0)
        save()
        KouenSidebarPanelViewController.recordRecentProject(path)
    }

    func removeProject(_ path: String) {
        projects.removeAll { $0.path == path }
        save()
    }

    func moveProject(_ path: String, toCategory categoryID: String?) {
        guard let idx = projects.firstIndex(where: { $0.path == path }) else { return }
        projects[idx].categoryID = categoryID
        save()
    }

    func addCategory(name: String) -> ProjectCategory {
        let cat = ProjectCategory(id: UUID().uuidString, name: name)
        categories.append(cat)
        save()
        return cat
    }

    func removeCategory(_ id: String) {
        categories.removeAll { $0.id == id }
        for idx in projects.indices where projects[idx].categoryID == id {
            projects[idx].categoryID = nil
        }
        save()
    }

    func removeCategoryAndProjects(_ id: String) {
        categories.removeAll { $0.id == id }
        projects.removeAll { $0.categoryID == id }
        save()
    }

    func renameCategory(_ id: String, to name: String) {
        guard let idx = categories.firstIndex(where: { $0.id == id }) else { return }
        categories[idx].name = name
        save()
    }

    // MARK: - Queries

    func projects(inCategory categoryID: String?) -> [ProjectEntry] {
        projects.filter { $0.categoryID == categoryID }
    }
}

// MARK: - Git status

struct ProjectGitStatus: Sendable {
    var branch: String
    var isDirty: Bool
}

func fetchGitStatus(for path: String) async -> ProjectGitStatus? {
    guard FileManager.default.fileExists(atPath: path) else { return nil }
    return await Task.detached(priority: .utility) {
        func run(_ args: [String]) -> String? {
            let p = Process()
            p.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            p.arguments = args
            p.currentDirectoryURL = URL(fileURLWithPath: path)
            let pipe = Pipe()
            p.standardOutput = pipe
            // stderr is never inspected here — route to the null device rather than an
            // undrained Pipe(), which is itself a deadlock risk (see
            // agent-memory/knowledge/patterns/process-pipe-deadlock.md).
            p.standardError = FileHandle.nullDevice
            try? p.run()
            // Read to EOF BEFORE waitUntilExit(): git status --porcelain on a repo with many
            // changed/untracked files can exceed the pipe buffer, so waiting for exit first
            // deadlocks deterministically (child blocks in write(), parent blocks in
            // waitUntilExit() — same failure mode fixed at 7 other call sites 2026-08-19).
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            p.waitUntilExit()
            guard p.terminationStatus == 0 else { return nil }
            return String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard let branch = run(["-C", path, "branch", "--show-current"]), !branch.isEmpty else {
            return nil
        }
        let dirty = run(["-C", path, "status", "--porcelain"])
            .map { !$0.isEmpty } ?? false
        return ProjectGitStatus(branch: branch, isDirty: dirty)
    }.value
}

// MARK: - Folder Scanner (Auto-detecting Multi-Repo / Group vs Per-Project)

struct DiscoveredRepoItem: Identifiable, Hashable {
    let id: String           // Path
    let name: String         // Component name
    let path: String
    let isGitRepo: Bool
    let isEnvFolder: Bool    // .claude, .gemini, .copilot
    var isSelected: Bool = true
}

@MainActor
enum FolderScanner {
    private static let ignoredDirNames: Set<String> = [
        ".DS_Store", ".git", ".Trash", ".build", "node_modules", "DerivedData",
        ".gradle", ".idea", ".vscode", "Pods", "Carthage", "target", "dist",
        "build", "vendor", ".venv", "venv", "__pycache__"
    ]

    static func inspect(path: String, maxDepth: Int = 3) -> (isMultiRepo: Bool, items: [DiscoveredRepoItem]) {
        let fm = FileManager.default
        let hasOwnGit = isDirectGitRepo(at: path)

        guard let contents = try? fm.contentsOfDirectory(atPath: path) else {
            let name = (path as NSString).lastPathComponent
            return (false, [DiscoveredRepoItem(id: path, name: name, path: path, isGitRepo: hasOwnGit, isEnvFolder: name.hasPrefix("."))])
        }

        var candidates: [DiscoveredRepoItem] = []
        for item in contents {
            if ignoredDirNames.contains(item) { continue }
            let isEnv = item.hasPrefix(".claude") || item.hasPrefix(".copilot") || item.hasPrefix(".gemini") || item.hasPrefix(".cursor")
            if item.hasPrefix(".") && !isEnv {
                continue
            }
            let itemPath = (path as NSString).appendingPathComponent(item)
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: itemPath, isDirectory: &isDir), isDir.boolValue else {
                continue
            }

            if isDirectGitRepo(at: itemPath) {
                candidates.append(DiscoveredRepoItem(
                    id: itemPath,
                    name: item,
                    path: itemPath,
                    isGitRepo: true,
                    isEnvFolder: isEnv,
                    isSelected: true
                ))
            } else if isEnv {
                candidates.append(DiscoveredRepoItem(
                    id: itemPath,
                    name: item,
                    path: itemPath,
                    isGitRepo: false,
                    isEnvFolder: true,
                    isSelected: true
                ))
            } else {
                // Search deeper up to maxDepth (default 3 levels) for git repos
                var nestedRepos: [DiscoveredRepoItem] = []
                scanForGitRepos(at: itemPath, basePath: path, currentDepth: 2, maxDepth: maxDepth, results: &nestedRepos)

                if !nestedRepos.isEmpty {
                    candidates.append(contentsOf: nestedRepos)
                } else {
                    candidates.append(DiscoveredRepoItem(
                        id: itemPath,
                        name: item,
                        path: itemPath,
                        isGitRepo: false,
                        isEnvFolder: false,
                        isSelected: true
                    ))
                }
            }
        }

        if (candidates.count > 1 || (candidates.count == 1 && candidates.first?.path != path)) && !hasOwnGit {
            return (true, candidates.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
        } else {
            let name = (path as NSString).lastPathComponent
            return (false, [DiscoveredRepoItem(id: path, name: name, path: path, isGitRepo: hasOwnGit, isEnvFolder: name.hasPrefix("."))])
        }
    }

    private static func isDirectGitRepo(at path: String) -> Bool {
        let fm = FileManager.default
        let gitPath = (path as NSString).appendingPathComponent(".git")
        return fm.fileExists(atPath: gitPath)
    }

    private static func scanForGitRepos(
        at dirPath: String,
        basePath: String,
        currentDepth: Int,
        maxDepth: Int,
        results: inout [DiscoveredRepoItem]
    ) {
        let fm = FileManager.default
        guard let entries = try? fm.contentsOfDirectory(atPath: dirPath) else { return }

        for entry in entries {
            if ignoredDirNames.contains(entry) || entry.hasPrefix(".") { continue }

            let entryPath = (dirPath as NSString).appendingPathComponent(entry)
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: entryPath, isDirectory: &isDir), isDir.boolValue else {
                continue
            }

            if isDirectGitRepo(at: entryPath) {
                let relName: String
                if entryPath.hasPrefix(basePath) {
                    let suffix = String(entryPath.dropFirst(basePath.count))
                    relName = suffix.hasPrefix("/") ? String(suffix.dropFirst()) : suffix
                } else {
                    relName = entry
                }

                results.append(DiscoveredRepoItem(
                    id: entryPath,
                    name: relName,
                    path: entryPath,
                    isGitRepo: true,
                    isEnvFolder: false,
                    isSelected: true
                ))
            } else if currentDepth < maxDepth {
                scanForGitRepos(
                    at: entryPath,
                    basePath: basePath,
                    currentDepth: currentDepth + 1,
                    maxDepth: maxDepth,
                    results: &results
                )
            }
        }
    }
}

// MARK: - Unified Add / Selection Sheet (Orca Import Repositories from Folder)

/// Exact Orca design modal: Header with Back & Close buttons, "Import repositories from folder",
/// "Found N repositories in <path>", checklist with Select/Deselect all and git branch icon,
/// "Group these repositories?" section with editable group name, and dual action buttons:
/// "No, import separately" vs "Yes, import as group".
struct AddToWorkspaceSheet: View {
    let folderPath: String
    @Bindable var store: ProjectStore
    let onConfirm: (_ paths: [String], _ categoryID: String?) -> Void
    let onCancel: () -> Void

    @State private var items: [DiscoveredRepoItem]
    @State private var groupName: String

    init(
        folderPath: String,
        store: ProjectStore,
        onConfirm: @escaping (_ paths: [String], _ categoryID: String?) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.folderPath = folderPath
        self.store = store
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        let scan = FolderScanner.inspect(path: folderPath)
        self._items = State(initialValue: scan.items)
        self._groupName = State(initialValue: (folderPath as NSString).lastPathComponent)
    }

    private var folderName: String { (folderPath as NSString).lastPathComponent }

    private var listHeight: CGFloat {
        let count = CGFloat(items.count)
        guard count > 0 else { return 44 }
        return min(max(count * 34, 44), 200)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top Navigation Bar
            HStack {
                Button(action: onCancel) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            // Title & Subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text("Import repositories and folders")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Found \(items.count) item\(items.count == 1 ? "" : "s") in \(folderPath).")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            // Checklist Box
            VStack(spacing: 0) {
                // Header of checklist: Select/Deselect all + count
                HStack {
                    Toggle(isOn: Binding(
                        get: { allSelected },
                        set: { toggleAll($0) }
                    )) {
                        Text(allSelected ? "Deselect all" : "Select all")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .toggleStyle(.checkbox)

                    Spacer()

                    Text("\(selectedCount) of \(items.count) selected")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.primary.opacity(0.03))

                Divider()

                // List of items
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        ForEach($items) { $item in
                            HStack(spacing: 10) {
                                Toggle(isOn: $item.isSelected) {
                                    EmptyView()
                                }
                                .toggleStyle(.checkbox)
                                .labelsHidden()

                                Image(systemName: item.isGitRepo ? "arrow.triangle.branch" : (item.isEnvFolder ? "gearshape" : "folder"))
                                    .font(.system(size: 11))
                                    .foregroundStyle(item.isGitRepo ? Color.accentColor : Color.secondary)
                                    .frame(width: 14)

                                Text(item.name)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.primary)

                                Spacer()

                                if item.isEnvFolder {
                                    Text("config")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.tertiary)
                                } else if !item.isGitRepo {
                                    Text("folder")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                item.isSelected.toggle()
                            }

                            Divider()
                                .padding(.leading, 36)
                        }
                    }
                }
                .frame(height: listHeight)
            }
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.primary.opacity(0.02)))
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.primary.opacity(0.08), lineWidth: 1))

            // Group these repositories?
            VStack(alignment: .leading, spacing: 5) {
                Text("Group these repositories?")
                    .font(.system(size: 13, weight: .bold))

                Text("Choose this if these projects belong together — a monorepo, or just a set of related repos. Kouen will group them and let you work from the parent folder.")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)

                Text("Group name")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)

                TextField("", text: $groupName)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
            }

            // Dual Action Buttons (Orca Style)
            HStack(spacing: 10) {
                Spacer()

                Button("No, import separately") {
                    let selected = items.filter(\.isSelected).map(\.path)
                    let chosen = selected.isEmpty ? [folderPath] : selected
                    onConfirm(chosen, nil) // nil = separate / uncategorized
                }
                .keyboardShortcut(.cancelAction)
                .buttonStyle(.bordered)
                .controlSize(.regular)

                Button("Yes, import as group") {
                    let selected = items.filter(\.isSelected).map(\.path)
                    let chosen = selected.isEmpty ? [folderPath] : selected

                    let trimmedGroup = groupName.trimmingCharacters(in: .whitespaces)
                    var targetCatID: String? = nil
                    if !trimmedGroup.isEmpty {
                        if let existing = store.categories.first(where: { $0.name.lowercased() == trimmedGroup.lowercased() }) {
                            targetCatID = existing.id
                        } else {
                            let newCat = store.addCategory(name: trimmedGroup)
                            targetCatID = newCat.id
                        }
                    }
                    onConfirm(chosen, targetCatID)
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .frame(width: 480)
        .onAppear {
            if items.isEmpty {
                let scan = FolderScanner.inspect(path: folderPath)
                self.items = scan.items
                self.groupName = folderName
            }
        }
    }

    private var selectedCount: Int {
        items.filter(\.isSelected).count
    }

    private var allSelected: Bool {
        !items.isEmpty && items.allSatisfy(\.isSelected)
    }

    private func toggleAll(_ value: Bool) {
        for i in items.indices {
            items[i].isSelected = value
        }
    }
}

// MARK: - Tree view model

@Observable @MainActor
final class ProjectDirectoryTreeModel {
    let store: ProjectStore
    var isExpanded: Bool {
        get { UserDefaults.standard.bool(forKey: "ProjectDirectoryTreeExpanded") }
        set { UserDefaults.standard.set(newValue, forKey: "ProjectDirectoryTreeExpanded") }
    }

    var gitStatuses: [String: ProjectGitStatus] = [:]
    var hoveredPath: String? = nil

    init(store: ProjectStore) {
        self.store = store
        if UserDefaults.standard.object(forKey: "ProjectDirectoryTreeExpanded") == nil {
            isExpanded = true
        }
    }

    func refreshGitStatuses() {
        let paths = store.projects.map(\.path)
        for path in paths {
            guard gitStatuses[path] == nil else { continue }
            Task { @MainActor in
                let status = await fetchGitStatus(for: path)
                gitStatuses[path] = status
            }
        }
    }

    func invalidateGitStatus(for path: String) {
        gitStatuses.removeValue(forKey: path)
        Task { @MainActor in
            let status = await fetchGitStatus(for: path)
            gitStatuses[path] = status
        }
    }
}

// MARK: - Header view (collapse toggle + "+" add)

private struct ProjectTreeHeaderView: View {
    @Bindable var model: ProjectDirectoryTreeModel
    let onAdd: () -> Void
    @State private var isHovered = false

    var body: some View {
        let c = KouenDesign.chrome
        HStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { model.isExpanded.toggle() }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color(nsColor: c.textTertiary))
                        .rotationEffect(.degrees(model.isExpanded ? 90 : 0))
                    Text("PROJECTS")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color(nsColor: c.textTertiary))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(nsColor: c.textSecondary))
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .help("Add project or folder group")
        }
        .padding(.horizontal, KouenDesign.horizontalInset)
        .frame(height: 24)
        .background(Color(nsColor: c.sidebarBackground))
    }
}

// MARK: - Per-repo row (Clean: No Favorite Star)

private struct ProjectRowView: View {
    let entry: ProjectEntry
    @Bindable var model: ProjectDirectoryTreeModel
    let onOpen: (String) -> Void
    let onRemove: (String) -> Void

    @State private var isHovered = false

    private var displayName: String { (entry.path as NSString).lastPathComponent }
    private var gitStatus: ProjectGitStatus? { model.gitStatuses[entry.path] }
    private var c: KouenChromePalette { KouenDesign.chrome }

    var body: some View {
        HStack(spacing: 6) {
            // Project / Folder icon
            Text(displayName.hasPrefix(".") ? "⚙️" : (gitStatus != nil ? "📦" : "📁"))
                .font(.system(size: 11))

            // Repo name
            Button {
                onOpen(entry.path)
            } label: {
                HStack(spacing: 4) {
                    Text(displayName)
                        .font(Font(KouenDesign.Typography.sidebarLabel))
                        .foregroundStyle(Color(nsColor: isHovered ? c.textPrimary : c.textSecondary))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let status = gitStatus {
                        if status.isDirty {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 5, height: 5)
                                .help("Uncommitted changes")
                        }
                        Text(status.branch)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(Color(nsColor: c.textTertiary))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .fill(Color(nsColor: c.textPrimary.withAlphaComponent(0.08)))
                            )
                            .lineLimit(1)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(entry.path)

            // Remove button — hover only
            if isHovered {
                Button {
                    onRemove(entry.path)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color(nsColor: c.textTertiary))
                        .frame(width: 14, height: 14)
                }
                .buttonStyle(.plain)
                .help("Remove from project list")
            }
        }
        .padding(.horizontal, KouenDesign.horizontalInset)
        .frame(height: 26)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color(nsColor: isHovered
                    ? c.textPrimary.withAlphaComponent(0.07)
                    : NSColor.clear))
                .padding(.horizontal, 4)
        )
        .onHover { isHovered = $0 }
    }
}

// MARK: - Category section

private struct ProjectCategorySection: View {
    let categoryID: String?
    let categoryName: String
    @Bindable var model: ProjectDirectoryTreeModel
    let onOpen: (String) -> Void
    let onRemove: (String) -> Void

    @State private var isSectionCollapsed = false

    private var entries: [ProjectEntry] {
        model.store.projects(inCategory: categoryID)
            .sorted { $0.path.lowercased() < $1.path.lowercased() }
    }
    private var c: KouenChromePalette { KouenDesign.chrome }

    var body: some View {
        if !entries.isEmpty || categoryID != nil {
            VStack(alignment: .leading, spacing: 0) {
                if categoryID != nil || !model.store.categories.isEmpty {
                    Button {
                        withAnimation(.easeInOut(duration: 0.12)) {
                            isSectionCollapsed.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(Color(nsColor: c.textTertiary))
                                .rotationEffect(.degrees(isSectionCollapsed ? 0 : 90))
                            Text(categoryName.uppercased())
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Color(nsColor: c.textTertiary))
                            Spacer()
                            Text("\(entries.count)")
                                .font(.system(size: 9.5))
                                .foregroundStyle(Color(nsColor: c.textTertiary))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, KouenDesign.horizontalInset)
                        .padding(.vertical, 3)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                if !isSectionCollapsed {
                    ForEach(entries) { entry in
                        ProjectRowView(
                            entry: entry,
                            model: model,
                            onOpen: onOpen,
                            onRemove: onRemove
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Root tree view

struct ProjectDirectoryTreeView: View {
    @Bindable var model: ProjectDirectoryTreeModel
    let onOpenProject: (String) -> Void
    let onAddProject: () -> Void

    private var store: ProjectStore { model.store }
    private var c: KouenChromePalette { KouenDesign.chrome }

    private var visibleCategoryIDs: [String?] {
        let usedIDs = Set(store.projects.compactMap(\.categoryID))
        var result: [String?] = store.categories
            .filter { usedIDs.contains($0.id) }
            .map { Optional($0.id) }
        if store.projects.contains(where: { $0.categoryID == nil }) {
            result.append(nil)
        }
        return result
    }

    private func categoryName(for id: String?) -> String {
        guard let id else { return "Uncategorized" }
        return store.categories.first(where: { $0.id == id })?.name ?? "Uncategorized"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .overlay(Color(nsColor: c.textPrimary.withAlphaComponent(0.08)))

            ProjectTreeHeaderView(model: model, onAdd: onAddProject)

            if model.isExpanded {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        if store.projects.isEmpty {
                            Text("No projects — press + to add")
                                .font(.system(size: 11))
                                .foregroundStyle(Color(nsColor: c.textTertiary))
                                .padding(.horizontal, KouenDesign.horizontalInset)
                                .padding(.vertical, 8)
                        } else if store.categories.isEmpty {
                            ForEach(store.projects.sorted { $0.path.lowercased() < $1.path.lowercased() }) { entry in
                                ProjectRowView(entry: entry, model: model,
                                              onOpen: onOpenProject, onRemove: handleRemove)
                            }
                        } else {
                            ForEach(visibleCategoryIDs, id: \.self) { catID in
                                ProjectCategorySection(
                                    categoryID: catID,
                                    categoryName: categoryName(for: catID),
                                    model: model,
                                    onOpen: onOpenProject,
                                    onRemove: handleRemove
                                )
                            }
                        }
                    }
                    .padding(.bottom, 4)
                }
                .frame(maxHeight: 220)
                .onAppear { model.refreshGitStatuses() }
            }
        }
        .background(Color(nsColor: c.sidebarBackground))
    }

    private func handleRemove(_ path: String) {
        store.removeProject(path)
    }
}

// MARK: - Drag-and-drop drop target

@MainActor
final class ProjectDropTarget: NSView {
    var onDrop: ((String) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.zPosition = 50
        registerForDraggedTypes([.fileURL])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard folderURL(from: sender) != nil else { return [] }
        highlight(true)
        return .link
    }

    override func draggingExited(_ sender: NSDraggingInfo?) { highlight(false) }
    override func draggingEnded(_ sender: NSDraggingInfo) { highlight(false) }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let url = folderURL(from: sender) else { return false }
        onDrop?(url.path)
        return true
    }

    private func folderURL(from info: NSDraggingInfo) -> URL? {
        guard let items = info.draggingPasteboard.readObjects(
            forClasses: [NSURL.self],
            options: [.urlReadingFileURLsOnly: true]
        ) as? [URL] else { return nil }
        return items.first(where: {
            (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
        })
    }

    private func highlight(_ on: Bool) {
        layer?.borderWidth = on ? 2 : 0
        layer?.borderColor = on ? NSColor.controlAccentColor.cgColor : nil
        layer?.cornerRadius = on ? 6 : 0
    }
}

