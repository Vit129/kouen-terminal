import AppKit

extension KouenSidebarPanelViewController {
    func handleProjectAdd(_ action: ProjectAddAction, scope: ProjectAddScope) {
        switch action {
        case .browse:
            browseForProject(scope: scope)
        case .clone, .create:
            presentAcquisitionSheet(mode: action == .clone ? .clone : .create, scope: scope)
        }
    }

    private func browseForProject(scope: ProjectAddScope) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = scope.groupName.map { "Add to \($0)" } ?? "Open"
        panel.message = scope.groupName.map { "Choose a project folder to add to \($0)" }
            ?? "Choose a project folder"
        panel.begin { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            Task { @MainActor in self?.presentCategorySheet(for: url.path, scope: scope) }
        }
    }

    func presentCategorySheet(for path: String, scope: ProjectAddScope = .projects) {
        Task { [weak self] in
            guard let self, let projectPath = await sidebarListModel.projectPathForAdd(path) else { return }
            if projectPath != path {
                confirmProjectImport(paths: [projectPath], scope: scope)
                return
            }
            let scan = FolderScanner.inspect(path: path)
            guard scan.isMultiRepo, let window = view.window else {
                confirmProjectImport(paths: scan.items.map(\.path), scope: scope)
                return
            }

            let close: () -> Void = { [weak window] in
                guard let window, let sheet = window.attachedSheet else { return }
                window.endSheet(sheet)
            }
            let sheet = AddToWorkspaceSheet(
                folderPath: path,
                store: projectStore,
                groupScope: scope.groupName,
                onConfirm: { [weak self] paths, categoryID in
                    close()
                    self?.confirmProjectImport(paths: paths, scope: scope, selectedCategoryID: categoryID)
                },
                onCancel: close
            )
            presentProjectSheet(sheet, in: window)
        }
    }

    func confirmProjectImport(
        paths: [String],
        scope: ProjectAddScope,
        selectedCategoryID: String? = nil
    ) {
        finalizeAddProject(
            paths: paths,
            categoryID: scope.categoryForConfirmation(selectedCategoryID),
            openFirstSession: scope.opensFirstSession
        )
    }

    private func presentAcquisitionSheet(mode: ProjectAcquisitionService.Mode, scope: ProjectAddScope) {
        guard let window = view.window else { return }
        let sheet = ProjectAddSheet(
            mode: mode,
            groupName: scope.groupName,
            register: { [weak self] checkout in
                self?.finalizeAddProject(paths: [checkout.path], categoryID: scope.groupID, openFirstSession: false)
                    ?? false
            },
            onClose: { [weak window] in
                guard let window, let sheet = window.attachedSheet else { return }
                window.endSheet(sheet)
            }
        )
        presentProjectSheet(sheet, in: window, closable: false)
    }

    @discardableResult
    func finalizeAddProject(paths: [String], categoryID: String?, openFirstSession: Bool) -> Bool {
        var registered = false
        var duplicate: ProjectEntry?
        for (index, path) in paths.enumerated() {
            guard let result = projectStore.addProject(path, categoryID: categoryID) else { continue }
            registered = true
            if !result.inserted {
                if duplicate == nil { duplicate = result.entry }
            } else if index == 0, openFirstSession, sessions.isEmpty, let id = activeWorkspaceID {
                SessionCoordinator.shared.addSession(to: id, cwd: path, name: (path as NSString).lastPathComponent)
            }
        }
        if let duplicate {
            sidebarListModel.revealProject(duplicate)
        } else {
            sidebarListModel.scheduleRebuild()
        }
        sidebarListModel.updateWorktrees()
        return registered
    }

}
