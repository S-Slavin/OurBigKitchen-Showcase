import Foundation
import SwiftUI
import ComposableArchitecture

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@Observable
class AppState: ObservableObject, @unchecked Sendable {
    static let shared = AppState()
    
    public init() {}
    
    var isAuthenticated: Bool = false
    var currentUser: AppModels.User?
    var userProfile: AppModels.User? { currentUser }  // Computed property for compatibility
    var selectedTab: Int = 0
    var showingOnboarding: Bool = true
    var hasAcceptedHealthProtocols: Bool = false
    var hasAcceptedTerms: Bool = false
    var showingLogin: Bool = false
    var showingRegistration: Bool = false
    var showingTerms: Bool = false
    var showingPrivacyPolicy: Bool = false
    var showingHealthProtocol: Bool = false
    var showingFoodSafety: Bool = false
    var showingVolunteerForm: Bool = false
    var showingEventRegistration: Bool = false
    var showingImpactDashboard: Bool = false
    var showingSettings: Bool = false
    var showingProfile: Bool = false
    
    var navigationPath = NavigationPath()
    
    func reset() {
        isAuthenticated = false
        currentUser = nil
        selectedTab = 0
        showingOnboarding = true
        showingLogin = false
        showingRegistration = false
        showingTerms = false
        showingPrivacyPolicy = false
        showingHealthProtocol = false
        showingFoodSafety = false
        showingVolunteerForm = false
        showingEventRegistration = false
        showingImpactDashboard = false
        showingSettings = false
        showingProfile = false
        navigationPath = NavigationPath()
    }
    
    func setUser(_ user: AppModels.User) {
        currentUser = user
        isAuthenticated = true
    }
    
    func clearUser() {
        currentUser = nil
        isAuthenticated = false
    }
    
    func updateUser(_ user: AppModels.User) {
        currentUser = user
    }
    
    func showOnboarding() {
        showingOnboarding = true
    }
    
    func hideOnboarding() {
        showingOnboarding = false
    }
    
    func showLogin() {
        showingLogin = true
    }
    
    func hideLogin() {
        showingLogin = false
    }
    
    func showRegistration() {
        showingRegistration = true
    }
    
    func hideRegistration() {
        showingRegistration = false
    }
    
    func showTerms() {
        showingTerms = true
    }
    
    func hideTerms() {
        showingTerms = false
    }
    
    func showPrivacyPolicy() {
        showingPrivacyPolicy = true
    }
    
    func hidePrivacyPolicy() {
        showingPrivacyPolicy = false
    }
    
    func showHealthProtocol() {
        showingHealthProtocol = true
    }
    
    func hideHealthProtocol() {
        showingHealthProtocol = false
    }
    
    func showFoodSafety() {
        showingFoodSafety = true
    }
    
    func hideFoodSafety() {
        showingFoodSafety = false
    }
    
    func showVolunteerForm() {
        showingVolunteerForm = true
    }
    
    func hideVolunteerForm() {
        showingVolunteerForm = false
    }
    
    func showEventRegistration() {
        showingEventRegistration = true
    }
    
    func hideEventRegistration() {
        showingEventRegistration = false
    }
    
    func showImpactDashboard() {
        showingImpactDashboard = true
    }
    
    func hideImpactDashboard() {
        showingImpactDashboard = false
    }
    
    func showSettings() {
        showingSettings = true
    }
    
    func hideSettings() {
        showingSettings = false
    }
    
    func showProfile() {
        showingProfile = true
    }
    
    func hideProfile() {
        showingProfile = false
    }
    
    // MARK: - Health Protocols
    
    func acceptHealthProtocols() {
        hasAcceptedHealthProtocols = true
        UserDefaults.standard.set(true, forKey: "hasAcceptedHealthProtocols")
    }
    
    // MARK: - Terms Management
    
    func acceptTerms() {
        hasAcceptedTerms = true
        UserDefaults.standard.set(true, forKey: "hasAcceptedTerms")
    }
    
    // MARK: - Authentication
    
    func forceLogout() {
        clearUser()
        reset()
        UserDefaults.standard.removeObject(forKey: "hasAcceptedTerms")
        UserDefaults.standard.removeObject(forKey: "hasAcceptedHealthProtocols")
    }
} 