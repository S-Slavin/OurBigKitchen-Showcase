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

@MainActor
class AppState: ObservableObject {
    @Published var userProfile: AppModels.User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: Error?
    @Published var hasAcceptedTerms: Bool = false
    @Published var hasAcceptedHealthProtocols: Bool = false
    @Published var userType: AppModels.UserRole?
    @Published var isSigningUp = false // Track if user is in signup flow
    @Published var needsToChooseVolunteerType = false // Track if user needs to choose volunteer type
    @Published var hasCompletedRegistration = false // Track if user has completed registration
    @Published var selectedVolunteerType: VolunteerType? // Track the selected volunteer type
    
    private let authManager = AuthManager.shared
    private let termsManager = TermsManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Add a debouncer to prevent rapid UserDefaults updates
    private var saveAuthStateDebouncer: AnyCancellable?
    private var saveTermsStateDebouncer: AnyCancellable?
    
    init() {
        print("DEBUG: AppState initializing")
        
        // Initialize with a loading state
        isLoading = true
        
        // Set authenticated state immediately to prevent login loop
        if UserDefaults.standard.bool(forKey: "isAuthenticated") || UserDefaults.standard.bool(forKey: "hasSignedIn") {
            print("DEBUG: Setting authenticated state immediately from UserDefaults")
            self.isAuthenticated = true
        }
        
        // Move all I/O operations to background thread to avoid main thread warnings
        Task.detached {
            // Load saved state instead of resetting
            // Initialize terms status
            let termsAccepted = await MainActor.run { self.termsManager.checkTermsStatus() } || UserDefaults.standard.bool(forKey: "hasAcceptedTerms")
            
            // Initialize health protocols status
            let healthProtocolsAccepted = UserDefaults.standard.bool(forKey: "hasAcceptedHealthProtocols")
            
            // Initialize auth status from manager or UserDefaults
            let authenticated = await MainActor.run { self.authManager.isAuthenticated } || UserDefaults.standard.bool(forKey: "isAuthenticated")
            let profile = await MainActor.run { self.authManager.currentUser }
            
            // If user has completed onboarding and signed in, we should ensure they're authenticated
            let finalAuthState = authenticated || (UserDefaults.standard.bool(forKey: "hasSeenOnboarding") && 
                                                   UserDefaults.standard.bool(forKey: "hasSignedIn"))
            
            // Update UI on main thread
            await MainActor.run {
                // First update the loading state
                self.isLoading = false
                
                // Then update all other states in a single batch
                withAnimation {
                    self.hasAcceptedTerms = termsAccepted
                    self.hasAcceptedHealthProtocols = healthProtocolsAccepted
                    self.isAuthenticated = finalAuthState
                    self.userProfile = profile
                }
                
                print("DEBUG: AppState initial values:")
                print("   - hasAcceptedTerms: \(self.hasAcceptedTerms)")
                print("   - isAuthenticated: \(self.isAuthenticated)")
                print("   - hasAcceptedHealthProtocols: \(self.hasAcceptedHealthProtocols)")
                print("   - hasSeenOnboarding: \(UserDefaults.standard.bool(forKey: "hasSeenOnboarding"))")
                print("   - hasSignedIn: \(UserDefaults.standard.bool(forKey: "hasSignedIn"))")
                
                // Persist the auth state to prevent it from being lost
                if self.isAuthenticated {
                    // Use more efficient batch updating
                    let defaults = UserDefaults.standard
                    defaults.set(true, forKey: "isAuthenticated")
                    defaults.set(true, forKey: "hasSignedIn")
                    // No synchronize call needed
                }
                
                // Post notification to ensure UI updates
                NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
            }
        }
        
        // Set up notification observers
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        // Subscribe to auth notifications - use debounce to reduce rapid updates
        NotificationCenter.default.publisher(for: .didUpdateAuth)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshAuthState()
            }
            .store(in: &cancellables)
        
        // Subscribe to terms manager changes
        termsManager.$hasAcceptedTerms
            .dropFirst() // Skip the initial value
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink { [weak self] accepted in
                print("DEBUG: AppState received terms update: \(accepted)")
                self?.hasAcceptedTerms = accepted
            }
            .store(in: &cancellables)
        
        // Also listen for terms update notifications
        NotificationCenter.default.publisher(for: .didUpdateTerms)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                print("DEBUG: AppState received didUpdateTerms notification")
                self?.refreshTermsState()
            }
            .store(in: &cancellables)
        
        // Add a direct listener for health protocol updates
        NotificationCenter.default.publisher(for: .didUpdateHealthProtocols)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                print("DEBUG: AppState received didUpdateHealthProtocols notification")
                // Check UserDefaults and update state directly
                let protocolsAccepted = UserDefaults.standard.bool(forKey: "hasAcceptedHealthProtocols")
                
                // If UserDefaults says protocols are accepted, update state
                if protocolsAccepted && !self.hasAcceptedHealthProtocols {
                    print("DEBUG: Updating hasAcceptedHealthProtocols based on UserDefaults")
                    self.hasAcceptedHealthProtocols = true
                }
            }
            .store(in: &cancellables)
    }
    
    func refreshAuthState() {
        // Move I/O operations to background thread
        Task.detached {
            // Check UserDefaults first
            let isAuthenticatedInDefaults = UserDefaults.standard.bool(forKey: "isAuthenticated")
            
            // Check auth manager
            let isAuthenticatedInManager = await MainActor.run { self.authManager.isAuthenticated }
            
            // Use both sources
            let newAuthState = isAuthenticatedInManager || isAuthenticatedInDefaults
            let profile = await MainActor.run { self.authManager.currentUser }
            
            // Save authentication state to UserDefaults for persistence - only if changed
            if newAuthState && !isAuthenticatedInDefaults {
                // Update UI on main thread and handle debouncer
                await MainActor.run {
                    // Use debouncer to prevent rapid consecutive writes
                    self.saveAuthStateDebouncer?.cancel()
                    self.saveAuthStateDebouncer = Just(())
                        .delay(for: .milliseconds(200), scheduler: RunLoop.main)
                        .sink { _ in
                            UserDefaults.standard.set(true, forKey: "isAuthenticated")
                            UserDefaults.standard.set(true, forKey: "hasSignedIn")
                            // No synchronize needed
                        }
                }
            }
            
            // Update UI on main thread
            await MainActor.run {
                self.isAuthenticated = newAuthState
                self.userProfile = profile
                print("DEBUG: Auth state refreshed - isAuthenticated: \(self.isAuthenticated)")
            }
        }
    }
    
    func refreshTermsState() {
        let newValue = termsManager.checkTermsStatus() || UserDefaults.standard.bool(forKey: "hasAcceptedTerms") || UserDefaults.standard.bool(forKey: "termsAccepted")
        
        if hasAcceptedTerms != newValue {
            print("DEBUG: AppState updating hasAcceptedTerms from \(hasAcceptedTerms) to \(newValue)")
            hasAcceptedTerms = newValue
        }
    }
    
    func acceptTerms() {
        print("DEBUG: AppState.acceptTerms() called")
        
        // Debounce rapid terms updates
        saveTermsStateDebouncer?.cancel()
        saveTermsStateDebouncer = Just(())
            .delay(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                // Use batch update for UserDefaults
                UserDefaults.standard.set(true, forKey: "hasAcceptedTerms")
                UserDefaults.standard.set(true, forKey: "termsAccepted")
                // No synchronize needed
                
                // Use the manager to ensure all subscribers are notified
                self.termsManager.acceptTerms()
                
                // Manually update our state immediately
                self.hasAcceptedTerms = true
                
                // Post notification for immediate UI refresh
                NotificationCenter.default.post(name: .didUpdateTerms, object: nil)
                
                print("DEBUG: AppState.acceptTerms() complete, hasAcceptedTerms: \(self.hasAcceptedTerms)")
            }
    }
    
    func acceptHealthProtocols() {
        print("DEBUG: AppState.acceptHealthProtocols() called")
        
        // Update UserDefaults with all required flags
        UserDefaults.standard.set(true, forKey: "hasAcceptedHealthProtocols")
        // No synchronize needed
        
        // Immediately update our state with animation
        withAnimation {
            hasAcceptedHealthProtocols = true
        }
        
        print("DEBUG: AppState.acceptHealthProtocols() complete, hasAcceptedHealthProtocols: \(hasAcceptedHealthProtocols)")
        
        // Notify of update
        NotificationCenter.default.post(name: .didUpdateHealthProtocols, object: nil)
    }
    
    func resetHealthProtocols() {
        UserDefaults.standard.set(false, forKey: "hasAcceptedHealthProtocols")
        hasAcceptedHealthProtocols = false
        
        // Notify of update
        NotificationCenter.default.post(name: .didUpdateHealthProtocols, object: nil)
    }
    
    func resetOnboarding() {
        print("DEBUG: AppState.resetOnboarding() called")
        
        // Reset onboarding flags but keep authentication if desired
        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
        // No synchronize needed
        
        // Post notification
        NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
    }
    
    func forceLogout() {
        print("DEBUG: AppState.forceLogout() called")
        
        // Reset all auth-related flags
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        UserDefaults.standard.set(false, forKey: "hasSignedIn")
        // No synchronize needed
        
        // Update state
        isAuthenticated = false
        userProfile = nil
        
        // Post notification
        NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
    }
    
    func login(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Use the regular login method
            let user = try await authManager.login(email: email, password: password).async()
            
            // Update state after successful login
            isAuthenticated = true
            userProfile = user
            
            // Notify others of auth change
            NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
        } catch {
            self.error = error
            throw error
        }
    }
    
    func loginWithApple() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Use the regular login method
            let user = try await authManager.loginWithApplePublisher().async()
            
            // Update state after successful login
            isAuthenticated = true
            userProfile = user
            
            // Notify others of auth change
            NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
        } catch {
            self.error = error
            throw error
        }
    }
    
    func loginWithGmail() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Use the regular login method
            let user = try await authManager.loginWithGmailPublisher().async()
            
            // Update state after successful login
            isAuthenticated = true
            userProfile = user
            
            // Notify others of auth change
            NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
        } catch {
            self.error = error
            throw error
        }
    }
    
    func logout() async {
        isLoading = true
        defer { isLoading = false }
        
        authManager.logout()
        
        // Clear user data
        userProfile = nil
        isAuthenticated = false
        
        // Notify others of auth change
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
