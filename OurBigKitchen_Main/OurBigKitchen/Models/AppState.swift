import Foundation
import SwiftUI
import Combine

// MARK: - Volunteer Type

public enum VolunteerType: String, CaseIterable, Codable {
    case individual = "individual"
    case corporate = "corporate"
    
    var displayName: String {
        switch self {
        case .individual:
            return "Individual Volunteer"
        case .corporate:
            return "Corporate/Group"
        }
    }
    
    var description: String {
        switch self {
        case .individual:
            return "Join as an individual volunteer to help in our community kitchen"
        case .corporate:
            return "Organize group volunteering events for your company or organization"
        }
    }
    
    var icon: String {
        switch self {
        case .individual:
            return "person.fill"
        case .corporate:
            return "person.3.fill"
        }
    }
}

// MARK: - App State

@MainActor
class AppState: ObservableObject {
    
    // MARK: - Published Properties
    @Published var userProfile: AppModels.User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: Error?
    @Published var hasSeenOnboarding: Bool = false
    @Published var hasSignedIn: Bool = false
    @Published var hasAcceptedTerms: Bool = false
    @Published var hasAcceptedHealthProtocols: Bool = false
    @Published var userType: AppModels.UserRole?
    @Published var isSigningUp = false
    @Published var needsToChooseVolunteerType = false
    @Published var hasCompletedRegistration = false
    @Published var selectedVolunteerType: VolunteerType?
    
    // MARK: - Private Properties
    private let authManager = AuthManager.shared
    private let termsManager = TermsManager()
    // Health protocols are managed directly through UserDefaults
    private var cancellables = Set<AnyCancellable>()
    private var saveAuthStateDebouncer: AnyCancellable?
    private var saveTermsStateDebouncer: AnyCancellable?
    
    // MARK: - Initialization
    
    init() {
        // Initialize with UserDefaults values
        let defaults = UserDefaults.standard
        
        // Read UserDefaults values synchronously to avoid blocking UI
        hasSeenOnboarding = defaults.bool(forKey: "hasSeenOnboarding")
        hasSignedIn = defaults.bool(forKey: "hasSignedIn")
        hasAcceptedTerms = defaults.bool(forKey: "hasAcceptedTerms")
        hasAcceptedHealthProtocols = defaults.bool(forKey: "hasAcceptedHealthProtocols")
        needsToChooseVolunteerType = defaults.bool(forKey: "needsToChooseVolunteerType")
        hasCompletedRegistration = defaults.bool(forKey: "hasCompletedRegistration")
        
        // Set authentication state based on sign-in status
        if hasSignedIn {
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }
        
        isLoading = false
        
        // Perform async initialization in background
        Task {
            await performAsyncInitialization()
        }
    }
    
    // MARK: - Async Initialization
    
    private func performAsyncInitialization() async {
        // Update terms status
        let termsAccepted = termsManager.checkTermsStatus()
        if termsAccepted != hasAcceptedTerms {
            hasAcceptedTerms = termsAccepted
        }
        
        // Health protocols status is already set from UserDefaults in init()
    }
    
    // MARK: - Notification Setup
    
    private func setupNotificationObservers() {
        // REMOVED: Circular dependency - was listening to didUpdateAuth and calling refreshAuthState()
        // which would post didUpdateAuth again, causing infinite loop
        
        termsManager.$hasAcceptedTerms
            .dropFirst()
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink { [weak self] accepted in
                self?.hasAcceptedTerms = accepted
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .didUpdateTerms)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshTermsState()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .didUpdateHealthProtocols)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                let protocolsAccepted = UserDefaults.standard.bool(forKey: "hasAcceptedHealthProtocols")
                
                if protocolsAccepted && !self.hasAcceptedHealthProtocols {
                    self.hasAcceptedHealthProtocols = true
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - State Management
    
    func resetOnboardingState() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "hasSeenOnboarding")
        defaults.set(false, forKey: "hasSignedIn")
        defaults.set(false, forKey: "isAuthenticated")
        defaults.set(false, forKey: "hasAcceptedTerms")
        defaults.set(false, forKey: "hasAcceptedHealthProtocols")
        defaults.set(false, forKey: "needsToChooseVolunteerType")
        defaults.set(false, forKey: "hasCompletedRegistration")
        defaults.synchronize()
        
        // Reset local state
        self.isAuthenticated = false
        self.hasAcceptedTerms = false
        self.hasAcceptedHealthProtocols = false
        self.needsToChooseVolunteerType = false
        self.hasCompletedRegistration = false
        self.userProfile = nil
        self.selectedVolunteerType = nil
        
        print("DEBUG: AppState - Reset onboarding state complete")
    }
    
    func resetAllUserDefaults() {
        let defaults = UserDefaults.standard
        let domain = Bundle.main.bundleIdentifier ?? "com.shaina.obk.OurBigKitchen"
        
        // Remove all keys for this app
        if let bundleID = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleID)
        }
        
        // Also remove standard keys
        defaults.removeObject(forKey: "hasSeenOnboarding")
        defaults.removeObject(forKey: "hasSignedIn")
        defaults.removeObject(forKey: "isAuthenticated")
        defaults.removeObject(forKey: "hasAcceptedTerms")
        defaults.removeObject(forKey: "hasAcceptedHealthProtocols")
        defaults.removeObject(forKey: "needsToChooseVolunteerType")
        defaults.removeObject(forKey: "hasCompletedRegistration")
        defaults.synchronize()
        
        // Reset local state
        self.isAuthenticated = false
        self.hasAcceptedTerms = false
        self.hasAcceptedHealthProtocols = false
        self.needsToChooseVolunteerType = false
        self.hasCompletedRegistration = false
        self.userProfile = nil
        self.selectedVolunteerType = nil
        
        print("DEBUG: AppState - Reset ALL UserDefaults complete")
        print("DEBUG: AppState - Current UserDefaults values:")
        print("DEBUG: AppState - - hasSeenOnboarding: \(UserDefaults.standard.bool(forKey: "hasSeenOnboarding"))")
        print("DEBUG: AppState - - hasSignedIn: \(UserDefaults.standard.bool(forKey: "hasSignedIn"))")
        print("DEBUG: AppState - - isAuthenticated: \(UserDefaults.standard.bool(forKey: "isAuthenticated"))")
        print("DEBUG: AppState - - hasAcceptedTerms: \(UserDefaults.standard.bool(forKey: "hasAcceptedTerms"))")
        print("DEBUG: AppState - - hasAcceptedHealthProtocols: \(UserDefaults.standard.bool(forKey: "hasAcceptedHealthProtocols"))")
    }
    
    func refreshAuthState() {
        print("DEBUG: AppState - Refreshing auth state")
        
        // Simplified synchronous refresh instead of Task.detached
        let isAuthenticatedInDefaults = UserDefaults.standard.bool(forKey: "isAuthenticated")
        let isAuthenticatedInManager = authManager.isAuthenticated
        
        let newAuthState = isAuthenticatedInManager || isAuthenticatedInDefaults
        let profile = authManager.currentUser
        
        if newAuthState != isAuthenticated {
            isAuthenticated = newAuthState
            userProfile = profile
            
            if newAuthState && !isAuthenticatedInDefaults {
                UserDefaults.standard.set(true, forKey: "isAuthenticated")
                UserDefaults.standard.set(true, forKey: "hasSignedIn")
            }
            
            print("DEBUG: AppState - Auth state updated: \(newAuthState)")
        }
    }
    
    func refreshTermsState() {
        print("DEBUG: AppState - Refreshing terms state")
        
        // Simplified synchronous refresh instead of Task.detached
        let termsAccepted = termsManager.checkTermsStatus()
        
        if termsAccepted != hasAcceptedTerms {
            hasAcceptedTerms = termsAccepted
            print("DEBUG: AppState - Terms state updated: \(termsAccepted)")
        }
    }
    
    // MARK: - Public Methods
    
    func ensureStateConsistency() {
        print("DEBUG: AppState - Ensuring state consistency")
        
        // Check for invalid state combinations
        if isAuthenticated && !hasAcceptedTerms {
            print("DEBUG: AppState - Invalid state: authenticated but no terms accepted")
            // Reset to valid state
            isAuthenticated = false
            needsToChooseVolunteerType = false
        }
        
        if needsToChooseVolunteerType && !isAuthenticated {
            print("DEBUG: AppState - Invalid state: needs volunteer type but not authenticated")
            needsToChooseVolunteerType = false
        }
        
        print("DEBUG: AppState - Final state: isAuthenticated=\(isAuthenticated), needsToChooseVolunteerType=\(needsToChooseVolunteerType), hasAcceptedTerms=\(hasAcceptedTerms)")
    }
    
    func resetToLoginState() {
        print("DEBUG: AppState - Resetting to login state")
        isAuthenticated = false
        needsToChooseVolunteerType = false
        hasAcceptedTerms = false
        hasAcceptedHealthProtocols = false
        userProfile = nil
        selectedVolunteerType = nil
        
        // Clear UserDefaults
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "isAuthenticated")
        defaults.set(false, forKey: "hasSignedIn")
        defaults.set(false, forKey: "hasAcceptedTerms")
        defaults.set(false, forKey: "hasAcceptedHealthProtocols")
        
        objectWillChange.send()
    }
    
    func forceLogout() {
        isAuthenticated = false
        userProfile = nil
        hasAcceptedTerms = false
        hasAcceptedHealthProtocols = false
        userType = nil
        isSigningUp = false
        needsToChooseVolunteerType = false
        hasCompletedRegistration = false
        selectedVolunteerType = nil
        
        UserDefaults.standard.removeObject(forKey: "isAuthenticated")
        UserDefaults.standard.removeObject(forKey: "hasSignedIn")
        UserDefaults.standard.removeObject(forKey: "hasAcceptedTerms")
        UserDefaults.standard.removeObject(forKey: "hasAcceptedHealthProtocols")
        
        NotificationCenter.default.post(name: .didLogout, object: nil)
    }
    
    func acceptTerms() {
        hasAcceptedTerms = true
        UserDefaults.standard.set(true, forKey: "hasAcceptedTerms")
        NotificationCenter.default.post(name: .didUpdateTerms, object: nil)
    }
    
    func acceptHealthProtocols() {
        hasAcceptedHealthProtocols = true
        UserDefaults.standard.set(true, forKey: "hasAcceptedHealthProtocols")
        NotificationCenter.default.post(name: .didUpdateHealthProtocols, object: nil)
    }
    
    func setUserType(_ type: AppModels.UserRole) {
        userType = type
    }
    
    func setVolunteerType(_ type: VolunteerType) {
        selectedVolunteerType = type
        needsToChooseVolunteerType = false
    }
    
    func completeRegistration() {
        hasCompletedRegistration = true
    }
    
    func startSignup() {
        isSigningUp = true
    }
    
    func finishSignup() {
        isSigningUp = false
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let didUpdateAuth = Notification.Name("didUpdateAuth")
    static let didUpdateTerms = Notification.Name("didUpdateTerms")
    static let didUpdateHealthProtocols = Notification.Name("didUpdateHealthProtocols")
    static let didLogout = Notification.Name("didLogout")
} 
