import Foundation
import Combine
import SwiftUI
import CryptoKit

@MainActor
class RealAuthService: ObservableObject {
    static let shared = RealAuthService()
    
    @Published var currentUser: AppModels.User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let storageManager = StorageManager.shared
    private let keychainService = KeychainService.shared
    
    private init() {}
    
    // MARK: - Authentication Methods
    
    func signUp(
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        volunteerType: VolunteerType,
        dob: Date,
        wwcNumber: String?,
        wwcExpiryDate: Date?
    ) async throws -> AppModels.User {
        isLoading = true
        defer { isLoading = false }
        
        // Check if user already exists
        if let existingUser = storageManager.fetchUser(by: email) {
            throw AuthError.userAlreadyExists
        }
        
        // Validate input
        try validateSignUpInput(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            dob: dob,
            wwcNumber: wwcNumber,
            wwcExpiryDate: wwcExpiryDate
        )
        
        // Hash password and store securely
        let hashedPassword = hashPassword(password)
        try keychainService.savePassword(email: email, hashedPassword: hashedPassword)
        
        // Determine user role based on volunteer type
        let role: String
        let companyName: String?
        let companyPosition: String?
        let companyEmail: String?
        
        switch volunteerType {
        case .individual:
            role = "volunteer"
            companyName = nil
            companyPosition = nil
            companyEmail = nil
        case .corporate:
            role = "corporateVolunteer"
            companyName = "Corporate Organization"
            companyPosition = "Volunteer"
            companyEmail = email
        }
        
        // Create user in storage
        let appUser = storageManager.createUser(
            firstName: firstName,
            lastName: lastName,
            email: email,
            role: role,
            dob: dob,
            wwcNumber: wwcNumber,
            wwcExpiry: wwcExpiryDate,
            companyName: companyName,
            companyPosition: companyPosition,
            companyEmail: companyEmail
        )
        
        // Set current user and authentication state
        currentUser = appUser
        isAuthenticated = true
        
        // Save authentication state
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        UserDefaults.standard.set(true, forKey: "hasSignedIn")
        
        return appUser
    }
    
    func signIn(email: String, password: String) async throws -> AppModels.User {
        isLoading = true
        defer { isLoading = false }
        
        // Validate input
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidCredentials
        }
        
        // Verify password from keychain
        let hashedPassword = hashPassword(password)
        guard try keychainService.verifyPassword(email: email, hashedPassword: hashedPassword) else {
            throw AuthError.invalidCredentials
        }
        
        // Fetch user from storage
        guard let appUser = storageManager.fetchUser(by: email) else {
            throw AuthError.userNotFound
        }
        
        // Set current user and authentication state
        currentUser = appUser
        isAuthenticated = true
        
        // Save authentication state
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        UserDefaults.standard.set(true, forKey: "hasSignedIn")
        
        return appUser
    }
    
    func signInWithApple() async throws -> AppModels.User {
        // For now, return a mock user - in production this would integrate with Apple Sign In
        let mockUser = AppModels.User(
            id: UUID().uuidString,
            firstName: "Apple",
            lastName: "User",
            email: "apple@example.com",
            role: .volunteer,
            authProvider: "apple"
        )
        
        currentUser = mockUser
        isAuthenticated = true
        
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        UserDefaults.standard.set(true, forKey: "hasSignedIn")
        
        return mockUser
    }
    
    func signInWithGoogle() async throws -> AppModels.User {
        // For now, return a mock user - in production this would integrate with Google Sign In
        let mockUser = AppModels.User(
            id: UUID().uuidString,
            firstName: "Google",
            lastName: "User",
            email: "google@example.com",
            role: .volunteer,
            authProvider: "google"
        )
        
        currentUser = mockUser
        isAuthenticated = true
        
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        UserDefaults.standard.set(true, forKey: "hasSignedIn")
        
        return mockUser
    }
    
    func signOut() async throws {
        currentUser = nil
        isAuthenticated = false
        
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        UserDefaults.standard.set(false, forKey: "hasSignedIn")
    }
    
    // MARK: - User Management
    
    func updateUserProfile(_ user: AppModels.User) async throws {
        guard let existingUser = storageManager.fetchUser(by: user.id) else {
            throw AuthError.userNotFound
        }
        
        // Update user in storage
        let updatedUser = AppModels.User(
            id: user.id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            role: user.role,
            bio: user.bio,
            companyName: user.companyName,
            companyPosition: user.companyPosition,
            companyEmail: user.companyEmail,
            dob: user.dob,
            wwcNumber: user.wwcNumber,
            wwcExpiry: user.wwcExpiry,
            profileImageURL: user.profileImageURL,
            isVerified: user.isVerified,
            createdAt: user.createdAt,
            lastActive: Date()
        )
        
        storageManager.updateUser(updatedUser)
        
        // Update current user
        currentUser = updatedUser
    }
    
    func updateWWCC(userId: String, wwcNumber: String, wwcExpiryDate: Date) async throws {
        guard let existingUser = storageManager.fetchUser(by: userId) else {
            throw AuthError.userNotFound
        }
        
        // Validate WWCC
        try validateWWCC(number: wwcNumber, expiryDate: wwcExpiryDate)
        
        // Update user in storage
        var updatedUser = existingUser
        updatedUser.wwcNumber = wwcNumber
        updatedUser.wwcNumber = wwcExpiryDate
        
        storageManager.updateUser(updatedUser)
        
        // Update current user if it's the same user
        if currentUser?.id == userId {
            currentUser?.wwcNumber = wwcNumber
            currentUser?.wwcExpiry = wwcExpiryDate
        }
    }
    
    func checkAuthenticationStatus() {
        let isAuthenticatedInDefaults = UserDefaults.standard.bool(forKey: "isAuthenticated")
        
        if isAuthenticatedInDefaults {
            // Try to restore user session
            if let email = UserDefaults.standard.string(forKey: "lastUserEmail"),
               let appUser = storageManager.fetchUser(by: email) {
                currentUser = appUser
                isAuthenticated = true
            } else {
                // Clear invalid authentication state
                UserDefaults.standard.set(false, forKey: "isAuthenticated")
                UserDefaults.standard.set(false, forKey: "hasSignedIn")
                isAuthenticated = false
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func validateSignUpInput(
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        dob: Date,
        wwcNumber: String?,
        wwcExpiryDate: Date?
    ) throws {
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidInput
        }
        
        guard validateEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        guard validatePassword(password) else {
            throw AuthError.weakPassword
        }
        
        // Validate age
        let calendar = Calendar.current
        let age = calendar.dateComponents([.year], from: dob, to: Date()).year ?? 0
        guard age >= 13 else {
            throw AuthError.underage
        }
        
        // Validate WWCC if provided
        if let wwcNumber = wwcNumber, let wwcExpiryDate = wwcExpiryDate {
            try validateWWCC(number: wwcNumber, expiryDate: wwcExpiryDate)
        }
    }
    
    private func validateWWCC(number: String, expiryDate: Date) throws {
        guard number.count >= 8 else {
            throw AuthError.wwccInvalid
        }
        
        guard expiryDate > Date() else {
            throw AuthError.wwccExpired
        }
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func validatePassword(_ password: String) -> Bool {
        // Password must be at least 8 characters long and contain at least one number
        let passwordRegex = "^(?=.*[0-9]).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    private func hashPassword(_ password: String) -> Data {
        let salt = "OurBigKitchen" // In production, use a unique salt per user
        let saltedPassword = password + salt
        let inputData = Data(saltedPassword.utf8)
        let hashed = SHA256.hash(data: inputData)
        return Data(hashed)
    }
    

}

// MARK: - Keychain Service

class KeychainService {
    static let shared = KeychainService()
    
    private init() {}
    
    func savePassword(email: String, hashedPassword: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecValueData as String: hashedPassword
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            throw AuthError.keychainError
        }
    }
    
    func verifyPassword(email: String, hashedPassword: Data) throws -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let storedData = result as? Data else {
            return false
        }
        
        return storedData == hashedPassword
    }
    
    func deletePassword(email: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw AuthError.keychainError
        }
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case invalidCredentials
    case userNotFound
    case userAlreadyExists
    case invalidInput
    case invalidEmail
    case weakPassword
    case underage
    case wwccInvalid
    case wwccExpired
    case keychainError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .userNotFound:
            return "User not found"
        case .userAlreadyExists:
            return "User already exists with this email"
        case .invalidInput:
            return "Please fill in all required fields"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 8 characters and contain a number"
        case .underage:
            return "You must be at least 13 years old to register"
        case .wwccInvalid:
            return "Invalid WWCC number"
        case .wwccExpired:
            return "WWCC has expired"
        case .keychainError:
            return "Security error occurred"
        }
    }
}
