# SwiftUI State Management

## Wrapper Quick-Pick

| Wrapper | Owner | Use |
|---|---|---|
| `@State` | View | Local value/object |
| `@Binding` | View | Two-way link to parent |
| `@StateObject` | View | Owns `ObservableObject` (macOS 11–13) |
| `@ObservedObject` | View | References `ObservableObject` not owned |
| `@EnvironmentObject` | View | Injected `ObservableObject` from ancestor |
| `@Observable` + `@State` | View | Owns new Observation object (macOS 14+) |
| `@Bindable` | View | Creates bindings to `@Observable` |
| `@Environment` | View | System or custom environment values |

## @Observable (macOS 14+ / Swift 5.9) — prefer this

```swift
@Observable
class FileTreeModel {
    var files: [FileNode] = []
    var selectedID: FileNode.ID? = nil

    @ObservationIgnored           // opt-out specific property from tracking
    private var cancellables: Set<AnyCancellable> = []
}

// Owns it
struct FileTreeView: View {
    @State private var model = FileTreeModel()
    var body: some View { FileList(model: model) }
}

// Passed in — no wrapper needed, auto-tracked
struct FileList: View {
    var model: FileTreeModel
    var body: some View { List(model.files) { Text($0.name) } }
}

// Bindings to @Observable
struct SearchBar: View {
    @Bindable var model: FileTreeModel
    var body: some View { TextField("Search", text: $model.searchQuery) }
}

// Environment injection
struct MyApp: App {
    @State private var model = FileTreeModel()
    var body: some Scene {
        WindowGroup { ContentView().environment(model) }
    }
}
struct ContentView: View {
    @Environment(FileTreeModel.self) private var model
}
```

## ObservableObject (macOS 11–13 compat)

```swift
class LegacyModel: ObservableObject {
    @Published var files: [FileItem] = []
}
struct LegacyView: View {
    @StateObject private var model = LegacyModel()
}
```

## @Observable vs ObservableObject

| | `ObservableObject` | `@Observable` |
|---|---|---|
| Re-render granularity | Any `@Published` change → all subscribers | Per-property — only views that READ the changed property |
| In view (owned) | `@StateObject` | `@State` |
| In view (passed in) | `@ObservedObject` | plain `var` |
| Environment | `.environmentObject` / `@EnvironmentObject` | `.environment` / `@Environment(Type.self)` |
| Min macOS | 11 | 14 |
