import Foundation

class PasswordResetService {
    static let shared = PasswordResetService()
    private init() {}
    
    // MARK: - Password Reset Methods
    func requestPasswordReset(email: String) async throws {
        // TODO: In a real app, this would make an API call to your backend
        // For now, we'll simulate the process
        
        // Validate email
        guard ValidationUtils.isValidEmail(email) else {
            throw PasswordResetError.invalidEmail
        }
        
        // Check if user exists
        guard let user = try? PersistenceManager.shared.load(AppModels.User.self, forKey: "currentUser"),
              user.email == email else {
            throw PasswordResetError.userNotFound
        }
        
        // Generate reset token
        let resetToken = UUID().uuidString
        let expiryDate = Date().addingTimeInterval(3600) // 1 hour expiry
        
        // Store reset token
        let resetRequest = PasswordResetRequest(
            email: email,
            token: resetToken,
            expiryDate: expiryDate
        )
        
        try PersistenceManager.shared.save(resetRequest, forKey: "passwordReset_\(email)")
        
        // TODO: In a real app, send email with reset link
        // For now, we'll just print the token
        print("Password reset token for \(email): \(resetToken)")
    }
    
    func resetPassword(email: String, token: String, newPassword: String) async throws {
        // Load reset request
        guard let resetRequest = try? PersistenceManager.shared.load(PasswordResetRequest.self, forKey: "passwordReset_\(email)") else {
            throw PasswordResetError.invalidToken
        }
        
        // Validate token
        guard resetRequest.token == token else {
            throw PasswordResetError.invalidToken
        }
        
        // Check expiry
        guard resetRequest.expiryDate > Date() else {
            throw PasswordResetError.tokenExpired
        }
        
        // Validate new password
        guard ValidationUtils.isValidPassword(newPassword) else {
            throw PasswordResetError.invalidPassword
        }
        
        // Update password
        let hashedPassword = AuthService.shared.hashPassword(newPassword)
        try AuthService.shared.saveToKeychain(key: "userPassword", data: hashedPassword)
        
        // Delete reset request
        try PersistenceManager.shared.remove(forKey: "passwordReset_\(email)")
    }
}

// MARK: - Supporting Types
struct PasswordResetRequest: Codable {
    let email: String
    let token: String
    let expiryDate: Date
}

enum PasswordResetError: LocalizedError {
    case invalidEmail
    case userNotFound
    case invalidToken
    case tokenExpired
    case invalidPassword
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .userNotFound:
            return "No account found with this email address"
        case .invalidToken:
            return "Invalid or expired reset token"
        case .tokenExpired:
            return "Password reset token has expired. Please request a new one"
        case .invalidPassword:
            return "Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character"
        }
    }
} 