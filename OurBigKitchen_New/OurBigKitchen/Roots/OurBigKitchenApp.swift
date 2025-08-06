import SwiftUI
import ComposableArchitecture

@main
struct OurBigKitchenApp: App {
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(store: Self.store)
        }
    }
}

// MARK: - Preview Environment Detection
private struct IsPreviewEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

extension EnvironmentValues {
    var isPreview: Bool {
        get { self[IsPreviewEnvironmentKey.self] }
        set { self[IsPreviewEnvironmentKey.self] = newValue }
    }
}

