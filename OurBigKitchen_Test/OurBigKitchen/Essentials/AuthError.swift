import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case networkError
    case serverError(String)
    case storageError
    case keychainError(OSStatus)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError:
            return "Network error occurred. Please check your connection."
        case .serverError(let message):
            return "Server error: \(message)"
        case .storageError:
            return "Failed to save authentication data"
        case .keychainError(let status):
            return "Keychain error: \(status)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 