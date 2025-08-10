import SwiftUI

@main
struct OurBigKitchenApp: App {
    // Initialize the persistence controller
    let persistenceController = PersistenceController.shared
    
    // Create app state object but don't use the stored values during initialization
    @StateObject private var appState = {
        print("Creating AppState without reset")
        // Create a fresh state without forcing reset
        let state = AppState()
        return state
    }()
    
    // Add ImpactService as a StateObject to provide it to the environment
    @StateObject private var impactService = ImpactService.shared
    
    // For development purposes
    #if DEBUG
    @State private var showResetButton = true // Visible by default for testing
    // Add a force refresh state
    @State private var forceRefresh = false
    #endif
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Use a persistent view without forcing recreation
                RootView(forceFreshStart: false)
                    // Remove the unique ID to allow view persistence
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(appState)
                    .environmentObject(impactService) // Add ImpactService to environment
                    .onAppear {
                        print("OurBigKitchenApp RootView appeared with persistent state")
                        // Simplified initialization to avoid main thread blocking
                        DispatchQueue.global(qos: .userInitiated).async {
                            // Check initialization state only once
                            let needsInitialization = !UserDefaults.standard.bool(forKey: "appStateInitialized")
                            
                            // Perform UI updates on main thread
                            DispatchQueue.main.async {
                                // Post notifications only if needed - reduce redundant calls
                                if needsInitialization {
                                    print("DEBUG: Initializing app state for first time")
                                    // Set flag first to prevent repeated initialization
                                    UserDefaults.standard.set(true, forKey: "appStateInitialized")
                                    // Post notifications sequentially with small delays
                                    NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
                                    
                                    // Stagger notifications to avoid overloading observers
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        NotificationCenter.default.post(name: .didUpdateTerms, object: nil)
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        NotificationCenter.default.post(name: .didUpdateHealthProtocols, object: nil)
                                    }
                                } else {
                                    print("DEBUG: App already initialized, skipping redundant notifications")
                                }
                            }
                        }
                    }
                
                // Add debug reset button
                #if DEBUG
                VStack {
                    HStack {
                        Spacer()
                        
                        if showResetButton {
                            VStack(spacing: 8) {
                                Button(action: {
                                    print("DEBUG: Manual reset triggered")
                                    // Perform reset operations on background thread
                                    DispatchQueue.global(qos: .userInitiated).async {
                                        ResetAppState.resetOnboardingFlow()
                                        
                                        // Return to main thread for UI updates
                                        DispatchQueue.main.async {
                                            appState.forceLogout()
                                        }
                                    }
                                }) {
                                    Text("Reset")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.red.opacity(0.8))
                                        .clipShape(Capsule())
                                }
                                
                                Button(action: {
                                    print("DEBUG: Showing Auth Test View")
                                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                                    let window = windowScene?.windows.first
                                    let testView = UIHostingController(rootView: AuthTestView())
                                    window?.rootViewController?.present(testView, animated: true)
                                }) {
                                    Text("Auth Test")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.blue.opacity(0.8))
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.top, 40)
                            .padding(.trailing, 20)
                        }
                    }
                    
                    Spacer()
                }
                #endif
            }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLoading = false // Set to false by default to skip loading screen
    // Add state to ensure navigation to impact tab happens when needed
    @State private var navigateToImpactTab = false
    
    // Environment property to detect if we're in preview mode
    @Environment(\.isPreview) private var isPreview
    
    // Add a new parameter to the initializer
    var forceFreshStart: Bool = false
    
    init(forceFreshStart: Bool = false) {
        self.forceFreshStart = forceFreshStart
        print("RootView initialized with forceFreshStart=\(forceFreshStart)")
    }
    
    @ViewBuilder
    private var rootContent: some View {
        if isPreview {
            // Simplified view for preview
            VStack(spacing: 20) {
                Text("Our Big Kitchen")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Preview Mode")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "heart.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text("This is a simplified preview of the app")
                    .multilineTextAlignment(.center)
            }
            .padding()
        } else if !UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
            // Onboarding welcome slides
            UserWelcomeView(onComplete: {
                // Optimized onboarding completion handler
                // First set the flag to prevent redundant processing
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                
                // Then notify UI to update in a controlled sequence
                // Use a single main thread call for better performance
                DispatchQueue.main.async {
                    print("DEBUG: Onboarding complete, proceeding to next screen")
                    
                    // Post relevant notifications with slight delays
                    NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
                    
                    // Force UI refresh with animation
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.isLoading = false
                    }
                }
            })
            .onAppear {
                print("DEBUG: Showing UserWelcomeView")
            }
            .ignoresSafeArea()
        } else if !appState.isAuthenticated && !UserDefaults.standard.bool(forKey: "isAuthenticated") && !UserDefaults.standard.bool(forKey: "hasSignedIn") {
            // Only show sign in if truly not authenticated in all sources
            // Use the new AuthTypeSelectionView for better user experience
            AuthTypeSelectionView()
                .navigationViewStyle(StackNavigationViewStyle())
                .onAppear {
                    print("DEBUG: Showing AuthTypeSelectionView, isAuthenticated=\(appState.isAuthenticated), hasSeenOnboarding=\(UserDefaults.standard.bool(forKey: "hasSeenOnboarding"))")
                }
        } else if !appState.hasAcceptedTerms {
            // Terms view
            SimpleTermsView()
                .navigationViewStyle(StackNavigationViewStyle())
                .onAppear {
                    print("DEBUG: Showing SimpleTermsView, hasAcceptedTerms: \(appState.hasAcceptedTerms), hasAcceptedHealthProtocols: \(appState.hasAcceptedHealthProtocols)")
                }
        } else if !appState.hasAcceptedHealthProtocols {
            // Health protocols view
            HealthProtocolView()
                .navigationViewStyle(StackNavigationViewStyle())
                .onAppear {
                    print("DEBUG: Showing HealthProtocolView")
                }
        } else {
            // Main content view
            ContentView()
                .onAppear {
                    print("DEBUG: Showing ContentView")
                    // Avoid redundant UserDefaults operations
                    if !UserDefaults.standard.bool(forKey: "isAuthenticated") {
                        // Set both flags at once to reduce writes
                        let defaults = UserDefaults.standard
                        defaults.set(true, forKey: "isAuthenticated")
                        defaults.set(true, forKey: "hasSignedIn")
                        // No synchronize call needed - it's deprecated and can cause freezing
                    }
                }
        }
    }
    
    var body: some View {
        // Simple conditional approach
        rootContent
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

