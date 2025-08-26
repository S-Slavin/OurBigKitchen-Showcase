import SwiftUI

@main
struct OurBigKitchenApp: App {
    
    // MARK: - Services
    let persistenceController = PersistenceController.shared
    @StateObject private var appState = AppState()
    @StateObject private var impactService = ImpactService.shared
    @StateObject private var authService = RealAuthService.shared
    @StateObject private var sessionService = SessionService.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
                .environmentObject(impactService)
                .environmentObject(authService)
                .environmentObject(sessionService)
        }
    }
}

// MARK: - Root View

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            // Force check onboarding state first, before any authentication logic
            let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
            
            if !hasSeenOnboarding {
                UserWelcomeView(onComplete: {
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    appState.objectWillChange.send()
                })
            } else if !appState.isAuthenticated {
                VStack {
                    AuthTypeSelectionView()
                    
                    // Temporary debug button to reset onboarding
                    Button("Reset Onboarding (Debug)") {
                        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                        UserDefaults.standard.set(false, forKey: "hasSignedIn")
                        UserDefaults.standard.set(false, forKey: "isAuthenticated")
                        appState.objectWillChange.send()
                    }
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            } else if appState.needsToChooseVolunteerType {
                VolunteerTypeSelectionView()
            } else if !appState.hasAcceptedTerms {
                SimpleTermsView()
            } else if !appState.hasAcceptedHealthProtocols {
                HealthProtocolView()
            } else {
                ContentView()
            }
        }
    }
}