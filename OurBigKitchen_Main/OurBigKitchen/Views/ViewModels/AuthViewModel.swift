import Foundation
import Combine
import SwiftUI

// MARK: - Auth View Model

@MainActor
class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isSignUp: Bool = false
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var rememberPassword: Bool = false
    @Published var hasAcceptedTerms: Bool = false
    
    // MARK: - Dependencies
    private let authService: RealAuthService
    private let userManager: UserManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(authService: RealAuthService,
         userManager: UserManager) {
        self.authService = authService
        self.userManager = userManager
        
        checkAuthenticationStatus()
    }
    
    convenience init() {
        self.init(authService: RealAuthService.shared, userManager: UserManager.shared)
    }
    
    // MARK: - Public Methods
    
    func loginAsIndividual() {
        Task {
            await signIn()
        }
    }
    
    func loginWithApple() {
        Task {
            await signInWithApple()
        }
    }
    
    func signIn() async {
        print("AuthViewModel.signIn() called")
        guard validateSignInInput() else { 
            print("Validation failed")
            return 
        }
        
        print("Validation passed, starting authentication...")
        isLoading = true
        errorMessage = ""
        
        do {
            let user = try await authService.signIn(email: email, password: password)
            
            try PersistenceManager.shared.save(user, forKey: "currentUser")
            
            await MainActor.run {
                self.isAuthenticated = true
                self.isLoading = false
                
                // Update UserDefaults
                UserDefaults.standard.set(true, forKey: "isAuthenticated")
                UserDefaults.standard.set(true, forKey: "hasSignedIn")
                
                if rememberPassword {
                    saveCredentials()
                }
                
                print("DEBUG: AuthViewModel - Authentication successful, posting notification")
                NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
                self.isLoading = false
            }
        }
    }
    
    func signInWithApple() async {
        isLoading = true
        errorMessage = ""
        
        do {
            let user = try await authService.signInWithApple()
            
            try PersistenceManager.shared.save(user, forKey: "currentUser")
            
            self.isAuthenticated = true
            self.isLoading = false
            
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            UserDefaults.standard.set(true, forKey: "hasSignedIn")
            
            NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
            self.isLoading = false
        }
    }
    
    func signUp(firstName: String, lastName: String, email: String, password: String, volunteerType: VolunteerType, dateOfBirth: Date, wwccNumber: String?, wwccExpiryDate: Date?) async {
        guard validateSignUpInput() else { return }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let user = try await authService.signUp(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password,
                volunteerType: volunteerType,
                dob: dateOfBirth,
                wwcNumber: wwccNumber,
                wwcExpiryDate: wwccExpiryDate
            )
            
            try PersistenceManager.shared.save(user, forKey: "currentUser")
            
            self.isAuthenticated = true
            self.isLoading = false
            
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            UserDefaults.standard.set(true, forKey: "hasSignedIn")
            
            NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
            self.isLoading = false
        }
    }
    
    func signOut() async {
        isLoading = true
        
        do {
            try await authService.signOut()
            
            self.isAuthenticated = false
            self.isLoading = false
            
            UserDefaults.standard.removeObject(forKey: "isAuthenticated")
            UserDefaults.standard.removeObject(forKey: "hasSignedIn")
            
            NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
            self.isLoading = false
        }
    }
    
    // MARK: - Private Methods
    
    private func checkAuthenticationStatus() {
        let isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        self.isAuthenticated = isAuthenticated
        
        if isAuthenticated {
            loadSavedUser()
        }
    }
    
    private func loadSavedUser() {
        if let user = try? PersistenceManager.shared.getObject(forKey: "currentUser", as: AppModels.User.self) {
            self.firstName = user.firstName
            self.lastName = user.lastName
            self.email = user.email
        }
    }
    
    private func validateSignInInput() -> Bool {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter your email"
            showError = true
            return false
        }
        
        if password.isEmpty {
            errorMessage = "Please enter your password"
            showError = true
            return false
        }
        
        return true
    }
    
    private func validateSignUpInput() -> Bool {
        if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter your first name"
            showError = true
            return false
        }
        
        if lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter your last name"
            showError = true
            return false
        }
        
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter your email"
            showError = true
            return false
        }
        
        if password.isEmpty {
            errorMessage = "Please enter a password"
            showError = true
            return false
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            showError = true
            return false
        }
        
        if !hasAcceptedTerms {
            errorMessage = "Please accept the terms and conditions"
            showError = true
            return false
        }
        
        return true
    }
    
    private func saveCredentials() {
        // TODO: Implement secure credential storage
        // This should use Keychain or similar secure storage
    }
    
    func clearError() {
        errorMessage = ""
        showError = false
    }
} 