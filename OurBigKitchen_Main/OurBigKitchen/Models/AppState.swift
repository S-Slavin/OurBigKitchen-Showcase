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
    private var cancellables = Set<AnyCancellable>()
    private var saveAuthStateDebouncer: AnyCancellable?
    private var saveTermsStateDebouncer: AnyCancellable?
    
    // MARK: - Initialization
    
    init() {
        isLoading = true
        
        if UserDefaults.standard.bool(forKey: "isAuthenticated") || UserDefaults.standard.bool(forKey: "hasSignedIn") {
            self.isAuthenticated = true
        }
        
        Task.detached {
            let termsAccepted = await MainActor.run { self.termsManager.checkTermsStatus() } || UserDefaults.standard.bool(forKey: "hasAcceptedTerms")
            let healthProtocolsAccepted = UserDefaults.standard.bool(forKey: "hasAcceptedHealthProtocols")
            let authenticated = await MainActor.run { self.authManager.isAuthenticated } || UserDefaults.standard.bool(forKey: "isAuthenticated")
            let profile = await MainActor.run { self.authManager.currentUser }
            
            let finalAuthState = authenticated || (UserDefaults.standard.bool(forKey: "hasSeenOnboarding") && 
                                                   UserDefaults.standard.bool(forKey: "hasSignedIn"))
            
            await MainActor.run {
                self.isLoading = false
                
                withAnimation {
                    self.hasAcceptedTerms = termsAccepted
                    self.hasAcceptedHealthProtocols = healthProtocolsAccepted
                    self.isAuthenticated = finalAuthState
                    self.userProfile = profile
                }
                
                if self.isAuthenticated {
                    let defaults = UserDefaults.standard
                    defaults.set(true, forKey: "isAuthenticated")
                    defaults.set(true, forKey: "hasSignedIn")
                }
                
                NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
            }
        }
        
        setupNotificationObservers()
    }
    
    // MARK: - Notification Setup
    
    private func setupNotificationObservers() {
        NotificationCenter.default.publisher(for: .didUpdateAuth)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshAuthState()
            }
            .store(in: &cancellables)
        
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
    
    func refreshAuthState() {
        Task.detached {
            let isAuthenticatedInDefaults = UserDefaults.standard.bool(forKey: "isAuthenticated")
            let isAuthenticatedInManager = await MainActor.run { self.authManager.isAuthenticated }
            
            let newAuthState = isAuthenticatedInManager || isAuthenticatedInDefaults
            let profile = await MainActor.run { self.authManager.currentUser }
            
            if newAuthState && !isAuthenticatedInDefaults {
                await MainActor.run {
                    self.saveAuthStateDebouncer?.cancel()
                    self.saveAuthStateDebouncer = Just(())
                        .delay(for: .milliseconds(200), scheduler: RunLoop.main)
                        .sink { _ in
                            UserDefaults.standard.set(true, forKey: "isAuthenticated")
                            UserDefaults.standard.set(true, forKey: "hasSignedIn")
                        }
                    
                    self.isAuthenticated = newAuthState
                    self.userProfile = profile
                }
            } else {
                await MainActor.run {
                    self.isAuthenticated = newAuthState
                    self.userProfile = profile
                }
            }
        }
    }
    
    func refreshTermsState() {
        Task.detached {
            let termsAccepted = await MainActor.run { self.termsManager.checkTermsStatus() }
            
            await MainActor.run {
                self.hasAcceptedTerms = termsAccepted
            }
        }
    }
    
    // MARK: - Public Methods
    
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
