import SwiftUI

@main
struct OurBigKitchenApp: App {
    // Initialize the persistence controller
    let persistenceController = PersistenceController.shared
    
    // Create app state object with simplified initialization
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if !UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                // Onboarding welcome slides
                UserWelcomeView(onComplete: {
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                })
                .ignoresSafeArea()
            } else if !appState.isAuthenticated && !UserDefaults.standard.bool(forKey: "isAuthenticated") && !UserDefaults.standard.bool(forKey: "hasSignedIn") {
                // Authentication view
                AuthTypeSelectionView()
                    .navigationViewStyle(StackNavigationViewStyle())
            } else if !appState.hasAcceptedTerms {
                // Terms view
                SimpleTermsView()
                    .navigationViewStyle(StackNavigationViewStyle())
            } else if !appState.hasAcceptedHealthProtocols {
                // Health protocols view
                HealthProtocolView()
                    .navigationViewStyle(StackNavigationViewStyle())
            } else {
                // Main content view
                ContentView()
            }
        }
    }
}

// Add an extension to detect preview context
private struct IsPreviewEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

extension EnvironmentValues {
    var isPreview: Bool {
        get { self[IsPreviewEnvironmentKey.self] }
        set { self[IsPreviewEnvironmentKey.self] = newValue }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RootView(forceFreshStart: true)
                .environmentObject(AppState())
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .previewDisplayName("RootView")
        }
    }
}

#Preview {
    let persistenceController = PersistenceController.shared
    let appState = AppState()
    
    return RootView(forceFreshStart: true)
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environmentObject(appState)
}

