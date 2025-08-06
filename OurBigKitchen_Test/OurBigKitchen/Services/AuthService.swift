import Foundation
import CryptoKit
import Security

class AuthService {
    static let shared = AuthService()
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
        
        let saltedPassword = password + String(salt)
        let inputData = Data(saltedPassword.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.hexString == storedHash
    }
    
    // MARK: - Keychain Operations
    func saveToKeychain(key: String, data: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw AuthError.keychainError(status)
        }
    }
    
    func loadFromKeychain(key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw AuthError.keychainError(status)
        }
        
        return string
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
            throw AuthError.keychainError(status)
        }
        
        return data
    }
    
    public func deleteFromKeychain(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AuthError.keychainError(status)
        }
    }
    
    // MARK: - Authentication Methods
    func signUp(user: AppModels.User, password: String) async throws {
        // Hash password
        let hashedPassword = hashPassword(password)
        
        // Save user data
        try PersistenceManager.shared.save(user, forKey: "currentUser")
        
        // Save hashed password to keychain
        try saveToKeychain(key: "userPassword", data: hashedPassword)
        
        // Set authentication state
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        UserDefaults.standard.set(true, forKey: "hasSignedIn")
        NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
    }
    
    func login(email: String, password: String) async throws {
        // Load user
        guard let user = try? PersistenceManager.shared.load(AppModels.User.self, forKey: "currentUser"),
              user.email == email else {
            throw AuthError.invalidCredentials
        }
        
        // Load and verify password
        let storedHash = try loadFromKeychain(key: "userPassword")
        guard verifyPassword(password, against: storedHash) else {
            throw AuthError.invalidCredentials
        }
        
        // Set authentication state
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        UserDefaults.standard.set(true, forKey: "hasSignedIn")
        NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
    }
    
    func logout() {
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        UserDefaults.standard.set(false, forKey: "hasSignedIn")
        NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
    }
}

// MARK: - Extensions
extension Digest {
    var hexString: String {
        self.map { String(format: "%02x", $0) }.joined()
    }
} 