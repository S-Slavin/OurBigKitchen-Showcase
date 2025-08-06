import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var userProfile: AppModels.User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: Error?
    @Published var hasAcceptedTerms: Bool = false
    @Published var hasAcceptedHealthProtocols: Bool = false
    @Published var userType: AppModels.UserRole?
    
    private let authManager = AuthManager.shared
    private let termsManager = TermsManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        print("DEBUG: AppState initializing")
        
        // Simple initialization without complex async operations
        self.isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated") || UserDefaults.standard.bool(forKey: "hasSignedIn")
        self.hasAcceptedTerms = UserDefaults.standard.bool(forKey: "hasAcceptedTerms") || UserDefaults.standard.bool(forKey: "termsAccepted")
        self.hasAcceptedHealthProtocols = UserDefaults.standard.bool(forKey: "hasAcceptedHealthProtocols")
        
        // Set up notification observers
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        // Subscribe to auth notifications
        NotificationCenter.default.publisher(for: .didUpdateAuth)
            .sink { [weak self] _ in
                self?.refreshAuthState()
            }
            .store(in: &cancellables)
        
        // Subscribe to terms manager changes
        termsManager.$hasAcceptedTerms
            .sink { [weak self] accepted in
                self?.hasAcceptedTerms = accepted
            }
            .store(in: &cancellables)
        
        // Listen for terms update notifications
        NotificationCenter.default.publisher(for: .didUpdateTerms)
            .sink { [weak self] _ in
                self?.refreshTermsState()
            }
            .store(in: &cancellables)
        
        // Listen for health protocol updates
        NotificationCenter.default.publisher(for: .didUpdateHealthProtocols)
            .sink { [weak self] _ in
                let protocolsAccepted = UserDefaults.standard.bool(forKey: "hasAcceptedHealthProtocols")
                self?.hasAcceptedHealthProtocols = protocolsAccepted
            }
            .store(in: &cancellables)
    }
    
    func refreshAuthState() {
        let newAuthState = authManager.isAuthenticated || UserDefaults.standard.bool(forKey: "isAuthenticated")
        let profile = authManager.currentUser
        
        DispatchQueue.main.async {
            self.isAuthenticated = newAuthState
            self.userProfile = profile
        }
    }
    
    func refreshTermsState() {
        let newValue = termsManager.checkTermsStatus() || UserDefaults.standard.bool(forKey: "hasAcceptedTerms") || UserDefaults.standard.bool(forKey: "termsAccepted")
        hasAcceptedTerms = newValue
    }
    
    func acceptTerms() {
        UserDefaults.standard.set(true, forKey: "hasAcceptedTerms")
        UserDefaults.standard.set(true, forKey: "termsAccepted")
        termsManager.acceptTerms()
    }
    
    func acceptHealthProtocols() {
        UserDefaults.standard.set(true, forKey: "hasAcceptedHealthProtocols")
        hasAcceptedHealthProtocols = true
        NotificationCenter.default.post(name: .didUpdateHealthProtocols, object: nil)
    }
    
    func forceLogout() {
        isAuthenticated = false
        userProfile = nil
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        UserDefaults.standard.set(false, forKey: "hasSignedIn")
        NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
    }
}

// MARK: - AuthState Management Methods
extension AppState {
    // Helper method to check if user is signed in
    var isUserSignedIn: Bool {
        return isAuthenticated || UserDefaults.standard.bool(forKey: "isAuthenticated") || UserDefaults.standard.bool(forKey: "hasSignedIn")
    }
    
    // Helper method to check if all onboarding is complete
    var isOnboardingComplete: Bool {
        return UserDefaults.standard.bool(forKey: "hasSeenOnboarding") && 
               hasAcceptedTerms && 
               hasAcceptedHealthProtocols
    }
    
    // Consolidated method to update auth state
    func updateAuthState(_ isAuthenticated: Bool) {
        if isAuthenticated != self.isAuthenticated {
            print("DEBUG: Updating auth state to \(isAuthenticated)")
            self.isAuthenticated = isAuthenticated
            
            // Batch update UserDefaults if necessary
            if isAuthenticated {
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "isAuthenticated")
                defaults.set(true, forKey: "hasSignedIn")
            }
        }
    }
}

// Used for debugging - only add in DEBUG builds
#if DEBUG
extension AppState {
    // Print full state for debugging
    func printDebugState() {
        print("==== AppState Debug ====")
        print("isAuthenticated: \(isAuthenticated)")
        print("hasAcceptedTerms: \(hasAcceptedTerms)")
        print("hasAcceptedHealthProtocols: \(hasAcceptedHealthProtocols)")
        print("isLoading: \(isLoading)")
        print("userProfile: \(userProfile?.fullName ?? "nil")")
        
        // Check UserDefaults values
        let defaults = UserDefaults.standard
        print("UserDefaults:")
        print("- isAuthenticated: \(defaults.bool(forKey: "isAuthenticated"))")
        print("- hasSignedIn: \(defaults.bool(forKey: "hasSignedIn"))")
        print("- hasSeenOnboarding: \(defaults.bool(forKey: "hasSeenOnboarding"))")
        print("- hasAcceptedTerms: \(defaults.bool(forKey: "hasAcceptedTerms"))")
        print("- termsAccepted: \(defaults.bool(forKey: "termsAccepted"))")
        print("- hasAcceptedHealthProtocols: \(defaults.bool(forKey: "hasAcceptedHealthProtocols"))")
        print("=======================")
    }
}
#endif

struct UserProfile: Codable {
    let id: UUID
    let name: String
    let email: String
    let isCorporate: Bool
    let organization: String?
    let phoneNumber: String?
    
    // Additional fields can be added as needed
} 
