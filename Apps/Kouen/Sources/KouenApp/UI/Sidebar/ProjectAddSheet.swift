import SwiftUI
import UniformTypeIdentifiers

@Observable @MainActor
final class ProjectAddSubmission {
    private(set) var checkout: URL?
    private(set) var error: String?

    func submit(
        _ request: ProjectAcquisitionService.Request,
        register: (URL) -> Bool
    ) async -> Bool {
        if checkout == nil {
            do {
                checkout = try await ProjectAcquisitionService.acquire(request)
            } catch {
                self.error = error.localizedDescription
                return false
            }
        }
        guard let checkout else { return false }
        if register(checkout) {
            error = nil
            return true
        }
        error = "Git succeeded at \(checkout.path). Retry to add this checkout to Projects."
        return false
    }

    func reportPickerError(_ error: Error) {
        self.error = error.localizedDescription
    }
}

struct ProjectAddSheet: View {
    let mode: ProjectAcquisitionService.Mode
    let groupName: String?
    let register: (URL) -> Bool
    let onClose: () -> Void

    @State private var input = ""
    @State private var parent: URL?
    @State private var choosingParent = false
    @State private var operation: Task<Void, Never>?
    @State private var stopping = false
    @State private var submission = ProjectAddSubmission()

    private var request: ProjectAcquisitionService.Request? {
        parent.map { .init(mode: mode, input: input, parent: $0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(mode == .clone ? "Clone from URL" : "Create new project")
                .font(.headline)
            Text(groupName.map { "Local Mac · \($0)" } ?? "Local Mac")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                TextField(mode == .clone ? "Git URL" : "Project name", text: $input)
                    .accessibilityIdentifier("txt_projectAcquisitionInput")
                HStack {
                    Text(parent?.path ?? "Choose a parent folder")
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    Button("Choose…") { choosingParent = true }
                        .accessibilityIdentifier("btn_projectAcquisitionParent")
                }
            }
            .disabled(operation != nil || submission.checkout != nil)

            if let request, !input.isEmpty {
                switch Result(catching: { try request.destination() }) {
                case let .success(destination):
                    Text(destination.path)
                        .textSelection(.enabled)
                        .accessibilityLabel("Destination \(destination.path)")
                case let .failure(error):
                    Text(error.localizedDescription).foregroundStyle(.secondary)
                }
            }

            if let error = submission.error {
                ScrollView {
                    Text(error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 120)
                .foregroundStyle(.red)
            }

            HStack {
                if operation != nil {
                    ProgressView().controlSize(.small)
                    Text(stopping ? "Canceling…" : "Running Git…")
                }
                Spacer()
                Button(operation == nil ? "Close" : "Cancel Git") {
                    if let operation {
                        stopping = true
                        operation.cancel()
                    } else {
                        onClose()
                    }
                }
                .keyboardShortcut(.cancelAction)
                .disabled(stopping)

                Button(submission.checkout != nil ? "Retry adding to Projects" : (mode == .clone ? "Clone" : "Create")) {
                    guard let request else { return }
                    operation = Task {
                        let added = await submission.submit(request, register: register)
                        operation = nil
                        stopping = false
                        if added { onClose() }
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(operation != nil || request.flatMap { try? $0.destination() } == nil)
                .accessibilityIdentifier("btn_projectAcquisitionSubmit")
            }
        }
        .padding(20)
        .frame(width: 480)
        .fileImporter(isPresented: $choosingParent, allowedContentTypes: [.folder]) { result in
            switch result {
            case let .success(url): parent = url
            case let .failure(error): submission.reportPickerError(error)
            }
        }
        .onDisappear { operation?.cancel() }
    }
}
