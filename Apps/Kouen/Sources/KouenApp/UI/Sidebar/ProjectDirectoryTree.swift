import AppKit
import KouenCore
import KouenGit
import Observation
import SwiftUI

// MARK: - Persistent data model

/// A user-defined category folder grouping repos in the project tree.
struct ProjectCategory: Codable, Hashable, Identifiable {
    var id: String          // stable UUID string
    var name: String
    var sourceFolder: String?
    var excludedPaths: Set<String>

    enum CodingKeys: String, CodingKey {
        case id, name, sourceFolder, excludedPaths
    }

    init(id: String, name: String, sourceFolder: String? = nil, excludedPaths: Set<String> = []) {
        self.id = id
        self.name = name
        self.sourceFolder = sourceFolder
        self.excludedPaths = excludedPaths
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        sourceFolder = try container.decodeIfPresent(String.self, forKey: .sourceFolder)
        excludedPaths = try container.decodeIfPresent(Set<String>.self, forKey: .excludedPaths) ?? []
    }
}

/// Per-project metadata persisted alongside the path list.
struct ProjectEntry: Codable, Equatable, Identifiable {
    var path: String
    var categoryID: String?     // nil → "Uncategorized"
    var stableID: String

    var id: String { stableID }

    init(path: String, categoryID: String? = nil, stableID: String = UUID().uuidString) {
        self.path = path
        self.categoryID = categoryID
        self.stableID = stableID
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        path = try values.decode(String.self, forKey: .path)
        categoryID = try values.decodeIfPresent(String.self, forKey: .categoryID)
        stableID = try values.decodeIfPresent(String.self, forKey: .stableID) ?? UUID().uuidString
    }
}

// MARK: - Store

/// Thin persistence layer: categories + project list in UserDefaults (same store as
/// `KouenSidebarPanelViewController.recentProjectsKey`).
@Observable @MainActor
final class ProjectStore {
    private static let categoriesKey = "ProjectCategories"
    private static let projectsKey = "ProjectEntries"
    private static let pendingReconciliationsKey = "PendingProjectReconciliations"

    var categories: [ProjectCategory] = []
    var projects: [ProjectEntry] = []
    var pendingReconciliationPaths: Set<String> = []
    private(set) var missingProjectPaths: Set<String> = []
    private let userDefaults: UserDefaults
    private(set) var watcher: ProjectGroupWatcher?

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        load()
        absorbLegacyRecents()
        setupWatcher()
    }

    convenience init(userDefaultsSuite suiteName: String) {
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        self.init(userDefaults: defaults)
    }

    private func setupWatcher() {
        let w = ProjectGroupWatcher()
        self.watcher = w
        updateWatchedFolders()
    }

    func updateWatchedFolders() {
        guard let watcher else { return }
        let validFolders = categories.compactMap { cat -> (id: String, folder: String)? in
            guard let folder = cat.sourceFolder, !folder.isEmpty else { return nil }
            return (id: cat.id, folder: folder)
        }
        watcher.update(folders: validFolders) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.syncAllWatchedCategories()
            }
        }
    }

    // MARK: - Persistence

    private func load() {
        if let data = userDefaults.data(forKey: Self.categoriesKey),
           let decoded = try? JSONDecoder().decode([ProjectCategory].self, from: data) {
            categories = decoded
        }
        if let data = userDefaults.data(forKey: Self.projectsKey),
           let decoded = try? JSONDecoder().decode([ProjectEntry].self, from: data) {
            let home = FileManager.default.homeDirectoryForCurrentUser.path
            projects = decoded.filter {
                !$0.path.hasSuffix("/.git") && ($0.path as NSString).lastPathComponent != ".git"
                    && !$0.path.split(separator: "/").contains("testing-repo") && $0.path != home
            }
            if let rows = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               rows.contains(where: { $0["stableID"] == nil }),
               let migrated = try? JSONEncoder().encode(projects) {
                userDefaults.set(migrated, forKey: Self.projectsKey)
            }
        }
        pendingReconciliationPaths = Set(userDefaults.stringArray(forKey: Self.pendingReconciliationsKey) ?? [])
    }

    func save() {
        if let data = try? JSONEncoder().encode(categories) {
            userDefaults.set(data, forKey: Self.categoriesKey)
        }
        if let data = try? JSONEncoder().encode(projects) {
            userDefaults.set(data, forKey: Self.projectsKey)
        }
        userDefaults.set(Array(pendingReconciliationPaths), forKey: Self.pendingReconciliationsKey)
    }

    private func absorbLegacyRecents() {
        let home = Self.directoryIdentity(FileManager.default.homeDirectoryForCurrentUser.path)
        var existing = Set(projects.map { Self.directoryIdentity($0.path) })
        let legacyPaths = (userDefaults.stringArray(forKey: "RecentProjectPaths") ?? [])
            .filter { path in
                let identity = Self.directoryIdentity(path)
                return identity != home && WorkspaceRepositoryScanner.isPrimaryRepository(path)
                    && existing.insert(identity).inserted
            }
        guard !legacyPaths.isEmpty else { return }
        for path in legacyPaths {
            projects.append(ProjectEntry(path: path))
        }
        save()
    }

    // MARK: - Mutations

    @discardableResult
    func addProject(_ path: String, categoryID: String? = nil) -> (entry: ProjectEntry, inserted: Bool)? {
        guard !path.isEmpty else { return nil }
        let identity = Self.directoryIdentity(path)
        let home = Self.directoryIdentity(FileManager.default.homeDirectoryForCurrentUser.path)
        guard (path as NSString).lastPathComponent != ".git",
              (identity as NSString).lastPathComponent != ".git", identity != home else { return nil }
        if let existing = project(at: path) {
            return (existing, false)
        }
        if let categoryID, let catIdx = categories.firstIndex(where: { $0.id == categoryID }) {
            categories[catIdx].excludedPaths = categories[catIdx].excludedPaths.filter {
                Self.directoryIdentity($0) != identity
            }
        }
        pendingReconciliationPaths.remove(path)
        let entry = ProjectEntry(path: path, categoryID: categoryID)
        projects.insert(entry, at: 0)
        save()
        KouenSidebarPanelViewController.recordRecentProject(path)
        return (entry, true)
    }

    /// Relocation follows the same non-destructive validation as batch reconciliation.
    @discardableResult
    func relocateProject(_ oldPath: String, to newPath: String) -> Bool {
        guard let preview = previewMoves([oldPath: newPath]) else { return false }
        return applyMoves(preview)
    }

    func removeProject(_ path: String) {
        // If this project belonged to a category with a sourceFolder, add to excludedPaths
        if let project = projects.first(where: { $0.path == path }),
           let catID = project.categoryID,
           let catIdx = categories.firstIndex(where: { $0.id == catID }) {
            if let sourceFolder = categories[catIdx].sourceFolder, path.hasPrefix(sourceFolder) {
                categories[catIdx].excludedPaths.insert(path)
            }
        }
        projects.removeAll { $0.path == path }
        pendingReconciliationPaths.remove(path)
        save()
    }

    func moveProject(_ path: String, toCategory categoryID: String?) {
        guard let idx = projects.firstIndex(where: { $0.path == path }) else { return }
        projects[idx].categoryID = categoryID
        save()
    }

    @discardableResult
    func addCategory(name: String, sourceFolder: String? = nil) -> ProjectCategory {
        let cat = ProjectCategory(id: UUID().uuidString, name: name, sourceFolder: sourceFolder)
        categories.append(cat)
        save()
        updateWatchedFolders()
        return cat
    }

    func setCategorySourceFolder(categoryID: String, sourceFolder: String?) {
        guard let idx = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        categories[idx].sourceFolder = sourceFolder
        save()
        updateWatchedFolders()
    }

    func excludeProjects(_ paths: Set<String>, from categoryID: String) {
        guard let index = categories.firstIndex(where: { $0.id == categoryID }), !paths.isEmpty else { return }
        categories[index].excludedPaths.formUnion(paths)
        projects.removeAll { $0.categoryID == categoryID && paths.contains($0.path) }
        save()
    }

    func removeCategory(_ id: String) {
        let paths = Set(projects.filter { $0.categoryID == id }.map(\.path))
        categories.removeAll { $0.id == id }
        for idx in projects.indices where projects[idx].categoryID == id {
            projects[idx].categoryID = nil
        }
        pendingReconciliationPaths.subtract(paths)
        save()
        updateWatchedFolders()
    }

    func removeCategoryAndProjects(_ id: String) {
        let paths = Set(projects.filter { $0.categoryID == id }.map(\.path))
        categories.removeAll { $0.id == id }
        projects.removeAll { $0.categoryID == id }
        pendingReconciliationPaths.subtract(paths)
        save()
        updateWatchedFolders()
    }

    func renameCategory(_ id: String, to name: String) {
        guard let idx = categories.firstIndex(where: { $0.id == id }) else { return }
        categories[idx].name = name
        save()
    }

    // MARK: - Auto-Sync (P54)

    private struct CategoryScanSnapshot {
        let category: ProjectCategory
        let items: [DiscoveredRepoItem]
    }

    private func scan(_ category: ProjectCategory) async -> CategoryScanSnapshot? {
        guard let root = category.sourceFolder, !root.isEmpty else { return nil }
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: root, isDirectory: &isDirectory), isDirectory.boolValue else { return nil }
        guard let items = await Task.detached(priority: .utility, operation: {
            try? WorkspaceRepositoryScanner.scan(root: root).map { repo in
                DiscoveredRepoItem(id: repo, name: (repo as NSString).lastPathComponent,
                                   path: repo, isGitRepo: true, isEnvFolder: false)
            }
        }).value else { return nil }
        return CategoryScanSnapshot(category: category, items: items)
    }

    private func isWithin(_ path: String, root: String) -> Bool {
        let child = URL(fileURLWithPath: path).standardizedFileURL.path
        let parent = URL(fileURLWithPath: root).standardizedFileURL.path
        return child == parent || child.hasPrefix(parent.hasSuffix("/") ? parent : parent + "/")
    }

    private func applyScans(_ snapshots: [CategoryScanSnapshot], pruneConfirmedMissing: Bool) {
        let validSnapshots = snapshots.filter { snapshot in
            categories.first(where: { $0.id == snapshot.category.id }) == snapshot.category
        }
        guard !validSnapshots.isEmpty || pruneConfirmedMissing else { return }

        let previousPendingPaths = pendingReconciliationPaths
        let missingPaths = projects.filter {
            $0.categoryID != nil && !FileManager.default.fileExists(atPath: $0.path)
        }.map(\.path)
        var trackedPaths = Set(projects.map { Self.directoryIdentity($0.path) })
        var seenDestinations = trackedPaths
        let eligibleDestinations = validSnapshots.flatMap { snapshot in
            snapshot.items.map(\.path).filter {
                seenDestinations.insert(Self.directoryIdentity($0)).inserted
            }
        }
        let moveCandidates = WorkspaceReconciliation.candidates(
            missing: missingPaths,
            discovered: eligibleDestinations
        )
        let moveSources = Set(moveCandidates.map(\.oldPath))
        let moveDestinations = Set(moveCandidates.map { Self.directoryIdentity($0.newPath) })
        var updatedProjects = projects

        for snapshot in validSnapshots {
            let excluded = Set(snapshot.category.excludedPaths.map(Self.directoryIdentity))
            for item in snapshot.items {
                let identity = Self.directoryIdentity(item.path)
                guard !excluded.contains(identity), !moveDestinations.contains(identity),
                      trackedPaths.insert(identity).inserted else { continue }
                updatedProjects.append(ProjectEntry(path: item.path, categoryID: snapshot.category.id))
            }
        }

        if pruneConfirmedMissing {
            let scannedRoots = Dictionary(uniqueKeysWithValues: validSnapshots.compactMap { snapshot in
                snapshot.category.sourceFolder.map { (snapshot.category.id, $0) }
            })
            let confirmedMissing = projects.filter { project in
                guard !FileManager.default.fileExists(atPath: project.path),
                      let categoryID = project.categoryID,
                      let root = scannedRoots[categoryID] else { return false }
                return isWithin(project.path, root: root)
            }
            pendingReconciliationPaths.formUnion(confirmedMissing.map(\.path))
            pendingReconciliationPaths.formUnion(moveSources)
            pendingReconciliationPaths.subtract(updatedProjects.filter {
                FileManager.default.fileExists(atPath: $0.path)
            }.map(\.path))
        }

        if updatedProjects != projects || pendingReconciliationPaths != previousPendingPaths {
            projects = updatedProjects
            save()
        }
    }

    func syncCategory(id: String) async {
        guard let category = categories.first(where: { $0.id == id }),
              let snapshot = await scan(category) else { return }
        applyScans([snapshot], pruneConfirmedMissing: false)
    }

    func syncAllWatchedCategories() async {
        let watchedCategories = categories.filter { $0.sourceFolder != nil }
        var snapshots: [CategoryScanSnapshot] = []
        for category in watchedCategories {
            if let result = await scan(category) { snapshots.append(result) }
        }
        applyScans(snapshots, pruneConfirmedMissing: true)
    }

    /// A readable parent distinguishes a removed entry from an unavailable volume or denied path.
    func refreshProjectAvailability() async {
        let paths = Set(projects.map(\.path))
        let previouslyMissing = missingProjectPaths
        let missing = await Task.detached(priority: .utility) {
            let fileManager = FileManager.default
            return paths.filter { path in
                guard !fileManager.fileExists(atPath: path) else { return false }
                let url = URL(fileURLWithPath: path).standardizedFileURL
                guard let entries = try? fileManager.contentsOfDirectory(
                    atPath: url.deletingLastPathComponent().path
                ) else { return previouslyMissing.contains(path) }
                return !entries.contains(url.lastPathComponent)
            }
        }.value
        guard !Task.isCancelled, paths == Set(projects.map(\.path)) else { return }
        if missing != missingProjectPaths { missingProjectPaths = missing }
    }

    // MARK: - Queries

    nonisolated static func directoryIdentity(_ path: String) -> String {
        URL(fileURLWithPath: (path as NSString).expandingTildeInPath)
            .standardizedFileURL.resolvingSymlinksInPath().standardizedFileURL.path
    }

    /// Call off the main actor. Checkout roots retain their stored spelling for existing rows.
    nonisolated static func repositoryProjectPath(_ path: String) -> String {
        guard !path.isEmpty else { return path }
        let identity = directoryIdentity(path)
        guard !FileManager.default.fileExists(atPath: identity + "/.git"),
              let topLevel = GitMetadataProvider.topLevel(at: identity),
              directoryIdentity(topLevel) != identity else { return path }
        return directoryIdentity(topLevel)
    }

    private var visibleProjects: [ProjectEntry] {
        var seen = Set<String>()
        return projects.filter { seen.insert(Self.directoryIdentity($0.path)).inserted }
    }

    func project(at path: String) -> ProjectEntry? {
        let identity = Self.directoryIdentity(path)
        return projects.first { Self.directoryIdentity($0.path) == identity }
    }

    func projects(inCategory categoryID: String?, revealing path: String? = nil) -> [ProjectEntry] {
        visibleProjects.filter {
            $0.categoryID == categoryID && !missingProjectPaths.contains($0.path)
                && ($0.path == path || !pendingReconciliationPaths.contains($0.path))
        }
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
        guard let branch = GitRunner.shared.executeOutput(["branch", "--show-current"], in: path),
              !branch.isEmpty else {
            return nil
        }
        let dirtyOutput = GitRunner.shared.executeOutput(["status", "--porcelain"], in: path)
        let isDirty = (dirtyOutput?.isEmpty == false)
        return ProjectGitStatus(branch: branch, isDirty: isDirty)
    }.value
}

// MARK: - Folder Scanner (Auto-detecting Multi-Repo / Group vs Per-Project)

struct DiscoveredRepoItem: Identifiable, Hashable, Sendable {
    let id: String           // Path
    let name: String         // Component name
    let path: String
    let isGitRepo: Bool
    let isEnvFolder: Bool    // .claude, .gemini, .copilot
    var isSelected: Bool = true
}

enum FolderScanner: Sendable {
    static func inspect(path: String, maxDepth: Int = 3) -> (isMultiRepo: Bool, items: [DiscoveredRepoItem]) {
        let paths = (try? WorkspaceRepositoryScanner.scan(root: path, maxDepth: maxDepth)) ?? []
        let items = paths.map { repo in
            DiscoveredRepoItem(id: repo, name: (repo as NSString).lastPathComponent,
                               path: repo, isGitRepo: true, isEnvFolder: false)
        }
        if items.isEmpty {
            let folder = DiscoveredRepoItem(id: path, name: (path as NSString).lastPathComponent,
                                            path: path, isGitRepo: false, isEnvFolder: false)
            return (false, [folder])
        }
        return (items.count != 1 || ProjectStore.directoryIdentity(items[0].path) != ProjectStore.directoryIdentity(path), items)
    }
}

// MARK: - Unified Add / Selection Sheet (Orca Import Repositories from Folder)

/// Exact Orca design modal: Header with Back & Close buttons, "Import repositories from folder",
/// "Found N repositories in <path>", checklist with Select/Deselect all and git branch icon,
/// "Group these repositories?" section with editable group name, and dual action buttons:
/// "No, import separately" vs "Yes, import as group".
struct AddToWorkspaceSheet: View {
    let folderPath: String
    let groupScope: String?
    @Bindable var store: ProjectStore
    let onConfirm: (_ paths: [String], _ categoryID: String?) -> Void
    let onCancel: () -> Void

    @State private var items: [DiscoveredRepoItem]
    @State private var groupName: String

    init(
        folderPath: String,
        store: ProjectStore,
        groupScope: String? = nil,
        onConfirm: @escaping (_ paths: [String], _ categoryID: String?) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.folderPath = folderPath
        self.store = store
        self.groupScope = groupScope
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
        ProjectWorkspaceSheetFrame(
            title: "Import repositories and folders",
            subtitle: "Found \(items.count) item\(items.count == 1 ? "" : "s") in \(folderPath).",
            onBack: onCancel,
            onClose: onCancel
        ) {
            VStack(alignment: .leading, spacing: 14) {
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

                if let groupScope {
                    HStack {
                        Button("Cancel", action: onCancel)
                            .keyboardShortcut(.cancelAction)
                        Spacer()
                        Button("Add to \(groupScope)") {
                            onConfirm(items.filter(\.isSelected).map(\.path), nil)
                        }
                        .keyboardShortcut(.defaultAction)
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedCount == 0)
                    }
                } else {
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

                    HStack(spacing: 10) {
                        Button("Cancel", action: onCancel)
                            .keyboardShortcut(.cancelAction)
                        Spacer()

                        Button("No, import separately") {
                            onConfirm(items.filter(\.isSelected).map(\.path), nil)
                        }
                        .disabled(selectedCount == 0)
                        .buttonStyle(.bordered)
                        .controlSize(.regular)

                        Button("Yes, import as group") {
                            let chosen = items.filter(\.isSelected).map(\.path)
                            guard !chosen.isEmpty else { return }
                            let trimmedGroup = groupName.trimmingCharacters(in: .whitespaces)
                            var targetCatID: String? = nil
                            if !trimmedGroup.isEmpty {
                                if let existing = store.categories.first(where: { $0.name.lowercased() == trimmedGroup.lowercased() }) {
                                    targetCatID = existing.id
                                    if existing.sourceFolder == nil {
                                        store.setCategorySourceFolder(categoryID: existing.id, sourceFolder: folderPath)
                                    }
                                } else {
                                    let newCat = store.addCategory(name: trimmedGroup, sourceFolder: folderPath)
                                    targetCatID = newCat.id
                                }
                            }
                            if let targetCatID {
                                store.excludeProjects(Set(items.filter { !$0.isSelected }.map(\.path)), from: targetCatID)
                            }
                            onConfirm(chosen, targetCatID)
                        }
                        .disabled(selectedCount == 0)
                        .keyboardShortcut(.defaultAction)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                    }
                    .padding(.top, 4)
                }
            }
            .onAppear {
                if items.isEmpty {
                    let scan = FolderScanner.inspect(path: folderPath)
                    self.items = scan.items
                    self.groupName = folderName
                }
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

