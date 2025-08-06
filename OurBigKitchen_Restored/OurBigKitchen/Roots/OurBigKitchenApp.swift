import SwiftUI

@main
struct OurBigKitchenApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var appState = AppState()
    @StateObject private var impactService = ImpactService.shared
    @StateObject private var authService = AuthService.shared
    @StateObject private var sessionService = SessionService.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
                .environmentObject(impactService)
                .environmentObject(authService)
                .environmentObject(sessionService)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            Button("↻") {
                                ResetAppState.resetOnboardingFlow()
                                appState.isAuthenticated = false
                                appState.forceLogout()
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.red.opacity(0.7))
                            .clipShape(Circle())
                        }
                        .padding(.top, 40)
                        .padding(.trailing, 20)
                        Spacer()
                    }
                )
        }
    }
}

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if !UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                UserWelcomeView(onComplete: {
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                })
            } else if !appState.isAuthenticated {
                AuthTypeSelectionView()
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