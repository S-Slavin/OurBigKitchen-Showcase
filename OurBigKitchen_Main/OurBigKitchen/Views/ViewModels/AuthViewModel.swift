import Foundation
import SwiftUI
import Combine

// MARK: - AuthViewModel

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
    private let authService: AuthenticationService
    private let userManager: UserManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(authService: AuthenticationService = AuthenticationService.shared, 
         userManager: UserManager = UserManager.shared) {
        self.authService = authService
        self.userManager = userManager
        
        // Check if user is already authenticated
        checkAuthenticationStatus()
    }
    
    // MARK: - Public Methods
    
    func loginAsIndividual() {
        // Handle individual login
        Task {
            await signIn()
        }
    }
    
    func loginWithApple() {
        // Handle Apple Sign In
        // For now, simulate Apple login success
        isLoading = true
        errorMessage = ""
        
        // Simulate authentication
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.isAuthenticated = true
            // In real implementation, would use AuthenticationServices framework
        }
    }
    
    func signIn() async {
        guard validateSignInInput() else { return }
        
        isLoading = true
        errorMessage = ""
        
        do {
            // Convert Combine publisher to async/await
            let user = try await withCheckedThrowingContinuation { continuation in
                authService.signIn(email: email, password: password)
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { user in
                            continuation.resume(returning: user)
                        }
                    )
                    .store(in: &cancellables)
            }
            
            // Save user to persistence
            try PersistenceManager.shared.save(user, forKey: "currentUser")
            
            await MainActor.run {
                self.isAuthenticated = true
                self.isLoading = false
                
                // Set authentication flags
                UserDefaults.standard.set(true, forKey: "isAuthenticated")
                UserDefaults.standard.set(true, forKey: "hasSignedIn")
                
                // Save credentials if remember password is enabled
                if rememberPassword {
                    saveCredentials()
                }
                
                // Post authentication notification
                NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
    
    func signUp(
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        volunteerType: VolunteerType,
        dateOfBirth: Date,
        wwccNumber: String?,
        wwccExpiryDate: Date?
    ) {
        isLoading = true
        errorMessage = ""
        
        // Validate input
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all required fields"
            isLoading = false
            return
        }
        
        // Validate email format
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        // Validate password strength
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters long"
            isLoading = false
            return
        }
        
        // Check if user is 18+ and requires WWCC
        let isAdult = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0 >= 18
        if isAdult && (wwccNumber?.isEmpty ?? true) {
            errorMessage = "WWCC number is required for volunteers 18 and older"
            isLoading = false
            return
        }
        
        Task {
            do {
                let user = try await withCheckedThrowingContinuation { continuation in
                    authService.createUser(
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        password: password,
                        volunteerType: volunteerType,
                        dateOfBirth: dateOfBirth,
                        wwccNumber: wwccNumber,
                        wwccExpiryDate: wwccExpiryDate
                    )
                    .sink(
                        receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { user in
                            continuation.resume(returning: user)
                        }
                    )
                    .store(in: &cancellables)
                }
                
                // Save user to persistence
                try PersistenceManager.shared.save(user, forKey: "currentUser")
                
                await MainActor.run {
                    self.isAuthenticated = true
                    self.isLoading = false
                    
                    // Set authentication flags
                    UserDefaults.standard.set(true, forKey: "isAuthenticated")
                    UserDefaults.standard.set(true, forKey: "hasSignedIn")
                    
                    // Save credentials if remember password is enabled
                    if rememberPassword {
                        saveCredentials()
                    }
                    
                    // Post authentication notification
                    NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func signOut() {
        authService.signOut()
        isAuthenticated = false
        clearForm()
    }
    
    func toggleMode() {
        isSignUp.toggle()
        clearForm()
    }
    
    func clearError() {
        showError = false
        errorMessage = ""
    }
    
    // MARK: - Private Methods
    
    private func validateSignInInput() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return false
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return false
        }
        
        return true
    }
    
    private func validateSignUpInput() -> Bool {
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return false
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return false
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return false
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func clearForm() {
        email = ""
        password = ""
        firstName = ""
        lastName = ""
        confirmPassword = ""
        errorMessage = ""
        showError = false
    }
    
    private func checkAuthenticationStatus() {
        // Check if user is already signed in
        isAuthenticated = authService.isAuthenticated
    }
    
    private func saveCredentials() {
        // Implementation for saving credentials securely
        // This would typically use Keychain
        UserDefaults.standard.set(email, forKey: "saved_email")
        UserDefaults.standard.set(rememberPassword, forKey: "remember_password")
    }
} 