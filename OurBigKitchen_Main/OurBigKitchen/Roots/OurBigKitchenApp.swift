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
            
            // Debug logging - MORE DETAILED
            let _ = print("DEBUG RootView: ===== NAVIGATION DECISION =====")
            let _ = print("DEBUG RootView: hasSeenOnboarding=\(hasSeenOnboarding)")
            let _ = print("DEBUG RootView: isAuthenticated=\(appState.isAuthenticated)")
            let _ = print("DEBUG RootView: needsToChooseVolunteerType=\(appState.needsToChooseVolunteerType)")
            let _ = print("DEBUG RootView: hasAcceptedTerms=\(appState.hasAcceptedTerms)")
            let _ = print("DEBUG RootView: hasAcceptedHealthProtocols=\(appState.hasAcceptedHealthProtocols)")
            
            // Check ALL UserDefaults values
            let _ = print("DEBUG RootView: ALL UserDefaults values:")
            let _ = print("DEBUG RootView: - hasSeenOnboarding: \(UserDefaults.standard.bool(forKey: "hasSeenOnboarding"))")
            let _ = print("DEBUG RootView: - hasSignedIn: \(UserDefaults.standard.bool(forKey: "hasSignedIn"))")
            let _ = print("DEBUG RootView: - hasAcceptedTerms: \(UserDefaults.standard.bool(forKey: "hasAcceptedTerms"))")
            let _ = print("DEBUG RootView: - hasAcceptedHealthProtocols: \(UserDefaults.standard.bool(forKey: "hasAcceptedHealthProtocols"))")
            let _ = print("DEBUG RootView: =================================")
            
            if !hasSeenOnboarding {
                let _ = print("DEBUG RootView: DECISION: Showing UserWelcomeView")
                UserWelcomeView(onComplete: {
                    print("DEBUG RootView: UserWelcomeView completed, setting hasSeenOnboarding=true")
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    print("DEBUG RootView: hasSeenOnboarding set to true in UserDefaults")
                    print("DEBUG RootView: About to call appState.objectWillChange.send()")
                    appState.objectWillChange.send()
                    print("DEBUG RootView: appState.objectWillChange.send() completed")
                    print("DEBUG RootView: Current UserDefaults value: \(UserDefaults.standard.bool(forKey: "hasSeenOnboarding"))")
                })
            } else if !appState.isAuthenticated {
                let _ = print("DEBUG RootView: DECISION: Showing AuthTypeSelectionView")
                AuthTypeSelectionView()
            } else if appState.needsToChooseVolunteerType {
                let _ = print("DEBUG RootView: DECISION: Showing VolunteerTypeSelectionView")
                VolunteerTypeSelectionView()
            } else if !appState.hasAcceptedTerms {
                let _ = print("DEBUG RootView: DECISION: Showing SimpleTermsView")
                SimpleTermsView()
            } else if !appState.hasAcceptedHealthProtocols {
                let _ = print("DEBUG RootView: DECISION: Showing HealthProtocolView")
                HealthProtocolView()
            } else {
                let _ = print("DEBUG RootView: DECISION: Showing ContentView")
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