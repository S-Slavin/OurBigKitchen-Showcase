import Foundation

enum AuthError: Error {
    case invalidCredentials
    case invalidGroupCode
    case appleSignInFailed
    case googleSignInFailed
    case keychainError
    case wwccInvalid
    case wwccExpired
    case networkError
    case serverError
    case userNotFound
    case invalidEmail
    case invalidPassword
    case usernameTaken
    case emailTaken
    case invalidToken
    case sessionExpired
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .invalidGroupCode:
            return "Invalid group code"
        case .appleSignInFailed:
            return "Failed to sign in with Apple"
        case .googleSignInFailed:
            return "Failed to sign in with Google"
        case .keychainError:
            return "Failed to access secure storage"
        case .wwccInvalid:
            return "Invalid Working with Children Check number"
        case .wwccExpired:
            return "Working with Children Check has expired"
        case .networkError:
            return "Network connection error"
        case .serverError:
            return "Server error occurred"
        case .userNotFound:
            return "User not found"
        case .invalidEmail:
            return "Invalid email format"
        case .invalidPassword:
            return "Invalid password format"
        case .usernameTaken:
            return "Username is already taken"
        case .emailTaken:
            return "Email is already registered"
        case .invalidToken:
            return "Invalid authentication token"
        case .sessionExpired:
            return "Session has expired"
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 