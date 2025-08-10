import Foundation
import Security

@MainActor
struct TestUtils {
    static let testEmail = "test@example.com"
    static let testPassword = "Test123!"
    
    static func createTestUser() async {
        // Create a test user with predefined attributes
        let user = AppModels.User(
            firstName: "Test",
            lastName: "User",
            email: testEmail,
            role: .volunteer,
            preferences: AppModels.UserPreferences(),
            achievements: [],
            stats: AppModels.UserStats(),
            hasFoodSafetyRegistration: false,
            authProvider: "email"
        )
        
        // Save the user
        do {
            try PersistenceManager.shared.save(user, forKey: "user_\(testEmail)")
            
            // Set test password
            let hashedPassword = AuthService.shared.hashPassword(testPassword)
            try AuthService.shared.saveToKeychain(key: "password_\(testEmail)", data: hashedPassword)
            
            print("Test user created successfully")
        } catch {
            print("Error creating test user: \(error)")
        }
    }
    
    static func clearTestData() async {
        // Clear user data
        do {
            try PersistenceManager.shared.remove(forKey: "user_\(testEmail)")
            
            // Clear keychain entries
            try AuthService.shared.deleteFromKeychain(key: "password_\(testEmail)")
            try AuthService.shared.deleteFromKeychain(key: "reset_token_\(testEmail)")
            
            print("Test data cleared successfully")
        } catch {
            print("Error clearing test data: \(error)")
        }
    }
    
    static func printCurrentState() async {
        // Check if user exists
        if let user = try? PersistenceManager.shared.getObject(forKey: "user_\(testEmail)", as: AppModels.User.self) {
            print("User exists: \(user)")
        } else {
            print("User does not exist")
        }
        
        // Check if password exists
        if let _ = try? AuthService.shared.loadDataFromKeychain(key: "password_\(testEmail)") {
            print("Password exists in keychain")
        } else {
            print("Password does not exist in keychain")
        }
        
        // Check if reset token exists
        if let _ = try? AuthService.shared.loadDataFromKeychain(key: "reset_token_\(testEmail)") {
            print("Reset token exists in keychain")
        } else {
            print("Reset token does not exist in keychain")
        }
    }
} 