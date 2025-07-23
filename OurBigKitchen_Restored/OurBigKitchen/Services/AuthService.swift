import Foundation
import Combine
import SwiftUI
import CryptoKit

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: AppModels.User?
    
    private let networkManager: NetworkManager
    private let userManager: UserManager
    
    init(networkManager: NetworkManager = NetworkManager.shared, userManager: UserManager = UserManager.shared) {
        self.networkManager = networkManager
        self.userManager = userManager
    }
    
    func signIn(email: String, password: String) async throws -> AppModels.User {
        // For testing, return a mock user
        let mockUser = AppModels.User(
            id: UUID().uuidString,
            firstName: "Test",
            lastName: "User",
            email: email,
            role: .volunteer
        )
        self.currentUser = mockUser
        return mockUser
    }
    
    func signInWithGroupCode(code: String) async throws -> AppModels.User {
        // For testing, return a mock user
        let mockUser = AppModels.User(
            id: UUID().uuidString,
            firstName: "Group",
            lastName: "User",
            email: "group@example.com",
            role: .volunteer
        )
        self.currentUser = mockUser
        return mockUser
    }
    
    func signInWithApple() async throws -> AppModels.User {
        // For testing, return a mock user
        let mockUser = AppModels.User(
            id: UUID().uuidString,
            firstName: "Apple",
            lastName: "User",
            email: "apple@example.com",
            role: .volunteer
        )
        self.currentUser = mockUser
        return mockUser
    }
    
    func signInWithGoogle() async throws -> AppModels.User {
        // For testing, return a mock user
        let mockUser = AppModels.User(
            id: UUID().uuidString,
            firstName: "Google",
            lastName: "User",
            email: "google@example.com",
            role: .volunteer
        )
        self.currentUser = mockUser
        return mockUser
    }
    
    func signOut() async throws {
        // Clear user data
        self.currentUser = nil
    }
    
    // MARK: - Keychain Methods
    
    func hashPassword(_ password: String) -> Data {
        let salt = "OurBigKitchen" // In production, use a unique salt per user
        let saltedPassword = password + salt
        let inputData = Data(saltedPassword.utf8)
        let hashed = SHA256.hash(data: inputData)
        return Data(hashed)
    }
    
    func saveToKeychain(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            throw AuthError.keychainError
        }
    }
    
    func loadDataFromKeychain(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            throw AuthError.keychainError
        }
        
        return data
    }
    
    func deleteFromKeychain(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw AuthError.keychainError
        }
    }
    
    func signUp(
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        dob: Date,
        wwcNumber: String?,
        wwcExpiry: Date?
    ) async throws -> AppModels.User {
        // For testing, return a mock user
        let mockUser = AppModels.User(
            id: UUID().uuidString,
            firstName: firstName,
            lastName: lastName,
            email: email,
            role: .volunteer,
            dob: dob,
            wwcNumber: wwcNumber,
            wwcExpiry: wwcExpiry
        )
        self.currentUser = mockUser
        return mockUser
    }
    
    // MARK: - Helper Methods
    
    private func validateWWCC(number: String, expiryDate: Date) throws {
        // Check if WWCC number is valid
        guard number.count >= 8 else {
            throw AuthError.wwccInvalid
        }
        
        // Check if WWCC is expired
        if expiryDate <= Date() {
            throw AuthError.wwccExpired
        }
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func validatePassword(_ password: String) -> Bool {
        // Password must be at least 8 characters long and contain at least one number
        let passwordRegex = "^(?=.*[0-9]).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
} 