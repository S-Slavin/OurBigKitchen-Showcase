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
            
            // Debug logging
            let _ = print("DEBUG RootView: hasSeenOnboarding=\(hasSeenOnboarding), isAuthenticated=\(appState.isAuthenticated), needsToChooseVolunteerType=\(appState.needsToChooseVolunteerType)")
            
            if !hasSeenOnboarding {
                let _ = print("DEBUG RootView: Showing UserWelcomeView")
                UserWelcomeView(onComplete: {
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    appState.objectWillChange.send()
                })
            } else if !appState.isAuthenticated {
                let _ = print("DEBUG RootView: Showing AuthTypeSelectionView")
                VStack(spacing: 20) {
                    AuthTypeSelectionView()
                    
                    // Enhanced debug button to reset onboarding
                    VStack(spacing: 8) {
                        Text("Debug Tools")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 10)
                        
                        Button(action: {
                            UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                            UserDefaults.standard.set(false, forKey: "hasSignedIn")
                            UserDefaults.standard.set(false, forKey: "isAuthenticated")
                            appState.objectWillChange.send()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.system(size: 16))
                                Text("Reset Onboarding")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 0.2), value: true)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            } else if appState.needsToChooseVolunteerType {
                let _ = print("DEBUG RootView: Showing VolunteerTypeSelectionView")
                VolunteerTypeSelectionView()
            } else if !appState.hasAcceptedTerms {
                let _ = print("DEBUG RootView: Showing SimpleTermsView")
                SimpleTermsView()
            } else if !appState.hasAcceptedHealthProtocols {
                let _ = print("DEBUG RootView: Showing HealthProtocolView")
                HealthProtocolView()
            } else {
                let _ = print("DEBUG RootView: Showing ContentView")
                ContentView()
            }
        }
        .onReceive(appState.$isAuthenticated) { _ in
            print("DEBUG RootView: isAuthenticated changed, forcing update")
            appState.objectWillChange.send()
        }
        .onReceive(appState.$needsToChooseVolunteerType) { _ in
            print("DEBUG RootView: needsToChooseVolunteerType changed, forcing update")
            appState.objectWillChange.send()
        }
        .onAppear {
            print("DEBUG RootView: View appeared, checking state consistency")
            appState.ensureStateConsistency()
        }
    }
}