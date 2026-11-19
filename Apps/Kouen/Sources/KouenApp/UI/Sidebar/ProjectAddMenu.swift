import SwiftUI

enum ProjectAddAction {
    case browse, clone, create
}

enum ProjectAddScope {
    case projects
    case group(name: String, id: String)

    var groupID: String? {
        if case let .group(_, id) = self { return id }
        return nil
    }

    var groupName: String? {
        if case let .group(name, _) = self { return name }
        return nil
    }

    var opensFirstSession: Bool { groupID == nil }

    func categoryForConfirmation(_ selectedCategoryID: String?) -> String? {
        groupID ?? selectedCategoryID
    }
}

struct ProjectAddMenu: View {
    let scope: ProjectAddScope
    let onSelect: (ProjectAddAction) -> Void

    var body: some View {
        let title = scope.groupName.map { "Add project to \($0)" } ?? "Add project"
        Menu {
            Button("Browse folder…") { onSelect(.browse) }
            Button("Clone from URL…") { onSelect(.clone) }
            Button("Create new project…") { onSelect(.create) }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color(nsColor: KouenDesign.chrome.textSecondary))
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(width: 20, height: 20)
        .help(title)
        .accessibilityLabel(title)
        .accessibilityIdentifier(scope.groupID.map { "btn_addProject-\($0)_projectsSidebar" }
            ?? "btn_addProject_projectsSidebar")
    }
}
