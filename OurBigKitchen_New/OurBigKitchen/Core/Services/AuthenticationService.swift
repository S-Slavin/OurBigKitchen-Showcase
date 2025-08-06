import Foundation
import Combine
import SwiftUI

@Observable
public final class AuthenticationService: @unchecked Sendable {
    public var isAuthenticated = false
    public var currentUser: AppModels.User?
    
    public static let shared = AuthenticationService()
    
    public init() {}
    
    public func signIn(email: String, password: String) async throws -> AppModels.User {
        // For demo purposes, just return a mock user
        let user = AppModels.User(
            id: "user1",
            firstName: "Demo",
            lastName: "User",
            email: email,
            profileImageURL: nil,
            bio: nil,
            role: .volunteer,
            preferences: AppModels.UserPreferences(),
            achievements: [],
            stats: AppModels.UserStats(),
            hasFoodSafetyRegistration: false,
            authProvider: "email"
        )
        
        try await Task.sleep(for: .milliseconds(500))
        currentUser = user
        isAuthenticated = true
        return user
    }
    
    public func signOut() async throws {
        currentUser = nil
        isAuthenticated = false
    }
    
    public func resetPassword(email: String) async throws {
        try await Task.sleep(for: .milliseconds(500))
    }
} 