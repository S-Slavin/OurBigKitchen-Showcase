import SwiftUI
import Combine

// ButtonStyles is imported from the project module
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var showingLoginSheet = false
    @Published var userType: AppModels.UserRole?
    @Published var hasReadTerms = false
    @Published var hasAcceptedTerms = false
    @Published var showTermsSheet = false
    
    private let authManager = AuthManager.shared
    private let termsManager = TermsManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Check if user is already authenticated
        isAuthenticated = authManager.isAuthenticated
        userType = authManager.currentUser?.role
        
        // Use the TermsManager to get terms acceptance status
        hasAcceptedTerms = termsManager.checkTermsStatus()
        
        // Subscribe to the TermsManager to stay updated
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
        
        // Listen for authentication updates
        NotificationCenter.default.addObserver(self, 
            selector: #selector(refreshAuthState), 
            name: .didUpdateAuth, 
            object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func refreshAuthState() {
        Task { @MainActor in
            self.checkAuthentication()
        }
    }
    
    func checkAuthentication() {
        Task { @MainActor in
            self.isAuthenticated = authManager.isAuthenticated
            self.userType = authManager.currentUser?.role
        }
    }
    
    func logout() {
        // Call the synchronous logout method directly
        authManager.logout()
        
        // Update our local state
        self.isAuthenticated = false
        self.userType = nil
        
        // This notification post is likely redundant as authManager already posts it,
        // but keeping it for safety
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

class ContentViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userType: AppModels.UserRole?
    @Published var hasAcceptedTerms = false
    
    private let authManager = AuthManager.shared
    private let termsManager = TermsManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
        checkAuthentication()
    }
    
    private func setupSubscriptions() {
        NotificationCenter.default
            .publisher(for: .didUpdateAuth)
            .sink { [weak self] _ in
                self?.checkAuthentication()
            }
            .store(in: &cancellables)
            
        termsManager.$hasAcceptedTerms
            .sink { [weak self] accepted in
                self?.hasAcceptedTerms = accepted
            }
            .store(in: &cancellables)
    }
    
    private func checkAuthentication() {
        isAuthenticated = authManager.isAuthenticated
        userType = authManager.currentUser?.role
    }
}

// Activity model for recent activities
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

struct ContentView: View {
    @State private var selectedTab = 0
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                ImpactViewWrapper()
                    .tabItem {
                        Label("Impact", systemImage: "chart.bar.fill")
                    }
                    .tag(1)
                EventsViewWrapper()
                    .tabItem {
                        Label("Events", systemImage: "calendar")
                    }
                    .tag(2)
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(3)
            }
        }
    }
}

// Wrapper for EventsView to avoid ambiguity
struct EventsViewWrapper: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            EventsView()
                .environmentObject(appState)
        }
    }
}

// Wrapper for ImpactView to avoid ambiguity
struct ImpactViewWrapper: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            ImpactView()
                .environmentObject(appState)
        }
    }
}

// HomeView struct with improved visual design

// Terms acceptance view to show before authentication
struct TermsAcceptanceView: View {
    var onAccept: () -> Void
    var onDecline: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // App header
            VStack(spacing: 16) {
                Image(systemName: "heart.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("let's build a kinder world")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 40)
            .padding(.bottom, 20)
            
            // Terms content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("TERMS AND CONDITIONS")
                        .font(.headline)
                        .padding(.bottom, 10)
                    
                    Group {
                        Text("1. Food Safety")
                            .fontWeight(.semibold)
                        Text("Volunteers must follow all food safety guidelines. Wash hands regularly, wear gloves when handling food, and report any illness to supervisors.")
                            .padding(.bottom)
                        
                        Text("2. Environmental Impact")
                            .fontWeight(.semibold)
                        Text("By logging your meals and hours, you're helping us track our environmental impact. We use this data to calculate food waste saved and CO2 emissions reduced.")
                            .padding(.bottom)
                        
                        Text("3. Privacy")
                            .fontWeight(.semibold)
                        Text("We respect your privacy. Your data will only be used to calculate impact metrics and will not be shared with third parties without consent.")
                            .padding(.bottom)
                        
                        Text("4. Sharing")
                            .fontWeight(.semibold)
                        Text("When you share your impact metrics, you are representing the organization. Please ensure all shared content is appropriate and respectful.")
                    }
                }
                .padding()
            }
            .frame(maxHeight: 300)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Acceptance toggles
            VStack(spacing: 12) {
                Toggle("I have read the terms and conditions", isOn: .constant(true))
                    .padding()
                    .background(Color(.systemGray6).opacity(0.3))
                    .cornerRadius(8)
                
                Toggle("I accept the terms and conditions", isOn: .constant(true))
                    .padding()
                    .background(Color(.systemGray6).opacity(0.3))
                    .cornerRadius(8)
            }
            .padding(.vertical)
            
            // Continue button
            Button {
                onAccept()
            } label: {
                Text("Continue")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue)
            }
            .buttonStyle(ButtonStyles.scale)
            .padding(.horizontal, 30)
            .padding(.top)
        }
        .padding()
    }
}

// Add UserTypeSelectionView after TermsAcceptanceView

struct UserTypeSelectionView: View {
    var onSelect: (AppModels.UserRole) -> Void
    @State private var selectedType: AppModels.UserRole = .volunteer

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Your User Type")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top, 40)

            VStack(spacing: 16) {
                Button(action: { selectedType = .manager }) {
                    HStack {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 24))
                        Text("I am a Corporate")
                            .font(.headline)
                        Spacer()
                        if selectedType == .manager {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedType == .manager ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: { selectedType = .volunteer }) {
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.system(size: 24))
                        Text("I am a Volunteer")
                            .font(.headline)
                        Spacer()
                        if selectedType == .volunteer {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedType == .volunteer ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)

            Button(action: { onSelect(selectedType) }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

