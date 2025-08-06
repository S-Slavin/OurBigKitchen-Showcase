import Foundation
import CryptoKit
import Security
import KeychainAccess

class AuthService: @unchecked Sendable {
    static let shared = AuthService()
    private let keychain = Keychain(service: "com.ourbigkitchen.app")
    
    private init() {}
    
    // MARK: - Password Hashing
    func hashPassword(_ password: String) -> String {
        let salt = UUID().uuidString
        let saltedPassword = password + salt
        let inputData = Data(saltedPassword.utf8)
        let hashed = SHA256.hash(data: inputData)
        return "\(salt):\(hashed.hexString)"
    }
    
    private func verifyPassword(_ password: String, against storedHash: String) -> Bool {
        let components = storedHash.split(separator: ":")
        guard components.count == 2,
              let salt = components.first,
              let storedHash = components.last else {
            return false
        }
        
        let saltedPassword = password + salt
        let inputData = Data(saltedPassword.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.hexString == storedHash
    }
    
    // MARK: - Keychain Operations
    func saveToKeychain(key: String, data: String) throws {
        try keychain.set(data, key: key)
    }
    
    func loadDataFromKeychain(key: String) throws -> String? {
        return try keychain.get(key)
    }
    
    func deleteFromKeychain(key: String) throws {
        try keychain.remove(key)
    }
    
    // MARK: - Authentication
    func authenticateUser(email: String, password: String) throws -> Bool {
        guard let storedHash = try loadDataFromKeychain(key: "password_\(email)") else {
            return false
        }
        return verifyPassword(password, against: storedHash)
    }
    
    func registerUser(email: String, password: String, userData: [String: Any]) throws {
        let hashedPassword = hashPassword(password)
        try saveToKeychain(key: "password_\(email)", data: hashedPassword)
        
        // Save additional user data
        if let userDataJSON = try? JSONSerialization.data(withJSONObject: userData),
           let userDataString = String(data: userDataJSON, encoding: .utf8) {
            try saveToKeychain(key: "userdata_\(email)", data: userDataString)
        }
    }
    
    // MARK: - Password Reset
    func generateResetToken(for email: String) throws -> String {
        let token = UUID().uuidString
        try saveToKeychain(key: "reset_token_\(email)", data: token)
        return token
    }
    
    func validateResetToken(_ token: String, for email: String) throws -> Bool {
        guard let storedToken = try loadDataFromKeychain(key: "reset_token_\(email)") else {
            return false
        }
        return storedToken == token
    }
    
    func resetPassword(email: String, newPassword: String, resetToken: String) throws -> Bool {
        guard try validateResetToken(resetToken, for: email) else {
            return false
        }
        
        let hashedPassword = hashPassword(newPassword)
        try saveToKeychain(key: "password_\(email)", data: hashedPassword)
        try deleteFromKeychain(key: "reset_token_\(email)")
        return true
    }
}

// MARK: - SHA256 Extension
private extension SHA256.Digest {
    var hexString: String {
        return self.compactMap { String(format: "%02x", $0) }.joined()
    }
} 