import SwiftUI
import Combine

// MARK: - Content View Model

@MainActor
final class ContentViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var showingLoginSheet = false
    @Published var userType: AppModels.UserRole?
    @Published var hasAcceptedTerms = false
    @Published var showTermsSheet = false
    
    // MARK: - Private Properties
    private let authManager = AuthManager.shared
    private let termsManager = TermsManager()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        isAuthenticated = authManager.isAuthenticated
        userType = authManager.currentUser?.role
        hasAcceptedTerms = termsManager.checkTermsStatus()
        
        setupSubscriptions()
    }
    
    // MARK: - Setup
    
    private func setupSubscriptions() {
        termsManager.$hasAcceptedTerms
            .sink { [weak self] accepted in
                guard let self = self else { return }
                if self.hasAcceptedTerms != accepted {
                    Task { @MainActor in
                        self.hasAcceptedTerms = accepted
                    }
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: .didUpdateAuth)
            .sink { [weak self] _ in
                self?.checkAuthentication()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func checkAuthentication() {
        isAuthenticated = authManager.isAuthenticated
        userType = authManager.currentUser?.role
    }
    
    func logout() {
        authManager.logout()
        self.isAuthenticated = false
        self.userType = nil
        NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
    }
    
    func acceptTerms() {
        termsManager.acceptTerms()
        
        Task { @MainActor in
            self.hasAcceptedTerms = true
            NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
        }
    }
}

// MARK: - Home Activity Item

struct HomeActivityItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let timestamp: Date
    let type: ActivityType
    
    enum ActivityType {
        case mealPrep
        case volunteer
        case event
    }
}

// MARK: - Content View

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                
                ImpactDashboardView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Impact")
                    }
                    .tag(1)
                
                VolunteerView()
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text("Volunteer")
                    }
                    .tag(2)
                
                SocialSharingView()
                    .tabItem {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .tag(3)
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag(4)
            }
            .accentColor(.orange)
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

