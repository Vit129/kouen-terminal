import AppKit
import SwiftUI
import HarnessCore

@MainActor @Observable
private final class FileEditorTabBarModel {
    var tabs: [FileTabManager.FileTab] = []
    var activeID: FileTabID?
    var onSelect: ((FileTabID) -> Void)?
    var onClose: ((FileTabID) -> Void)?
}

@MainActor
final class FileEditorTabBarView: NSView {
    private let model = FileEditorTabBarModel()

    var onSelect: ((FileTabID) -> Void)? { didSet { model.onSelect = onSelect } }
    var onClose: ((FileTabID) -> Void)? { didSet { model.onClose = onClose } }

    override init(frame: NSRect) {
        super.init(frame: frame)
        let host = NSHostingView(rootView: FileEditorTabBarBody(model: model))
        host.translatesAutoresizingMaskIntoConstraints = false
        addSubview(host)
        NSLayoutConstraint.activate([
            host.topAnchor.constraint(equalTo: topAnchor),
            host.leadingAnchor.constraint(equalTo: leadingAnchor),
            host.trailingAnchor.constraint(equalTo: trailingAnchor),
            host.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable) required init?(coder: NSCoder) { fatalError() }

    func reload(tabs: [FileTabManager.FileTab], activeID: FileTabID?) {
        model.tabs = tabs
        model.activeID = activeID
    }
}

private struct FileEditorTabBarBody: View {
    var model: FileEditorTabBarModel

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 1) {
                    ForEach(model.tabs, id: \.id) { tab in
                        FileTabPillView(
                            tab: tab,
                            isActive: tab.id == model.activeID,
                            onSelect: { model.onSelect?($0) },
                            onClose: { model.onClose?($0) }
                        )
                    }
                }
            }
            Rectangle()
                .fill(Color(HarnessDesign.chrome.border))
                .frame(height: 1)
        }
    }
}

private struct FileTabPillView: View {
    let tab: FileTabManager.FileTab
    let isActive: Bool
    let onSelect: (FileTabID) -> Void
    let onClose: (FileTabID) -> Void
    @State private var isHovered = false

    var body: some View {
        let c = HarnessDesign.chrome
        HStack(spacing: 4) {
            Text(tab.title)
                .font(.system(size: 12, weight: isActive ? .semibold : .medium))
                .foregroundStyle(isActive ? Color(c.textPrimary) : Color(c.textSecondary))
                .lineLimit(1)
                .truncationMode(.middle)
            Button { onClose(tab.id) } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Color(c.textSecondary))
                    .frame(width: 14, height: 14)
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 8)
        .padding(.trailing, 4)
        .frame(minWidth: 80, maxWidth: 160, minHeight: 26, maxHeight: 26)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    isActive ? Color(c.rowSelectedFill)
                    : isHovered ? Color(c.textPrimary).opacity(0.06)
                    : Color.clear
                )
        )
        .overlay {
            if isActive {
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(Color(c.accent).opacity(0.5), lineWidth: 1)
            }
        }
        .onHover { isHovered = $0 }
        .onTapGesture { onSelect(tab.id) }
    }
}
