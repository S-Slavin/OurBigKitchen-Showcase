import Foundation
import ComposableArchitecture

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@Observable
class AuthManager: @unchecked Sendable {
    static let shared = AuthManager()
    
    private init() {}
    
    private(set) var isAuthenticated = false
    private(set) var currentToken: String?
    
    func signIn(token: String) {
        currentToken = token
        isAuthenticated = true
    }
    
    func signOut() {
        currentToken = nil
        isAuthenticated = false
    }
    
    func refreshToken(_ token: String) {
        currentToken = token
    }
    
    func getToken() -> String? {
        return currentToken
    }
    
    func isSignedIn() -> Bool {
        return isAuthenticated
    }
} 