import Foundation
import Combine
import SwiftUI

class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    static let shared = AuthenticationService()
    
    private init() {}
    
    func signIn(email: String, password: String) -> AnyPublisher<User, Error> {
        // For demo purposes, just return a mock user
        let user = User(
            id: "user1",
            firstName: "Demo",
            lastName: "User",
            email: email,
            profileImageURL: nil,
            bio: nil,
            role: .volunteer,
            preferences: UserPreferences(),
            achievements: [],
            stats: UserStats(),
            hasFoodSafetyRegistration: false,
            authProvider: "email"
        )
        
        return Just(user)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = true
            })
            .eraseToAnyPublisher()
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
    }
    
    func resetPassword(email: String) -> AnyPublisher<Void, Error> {
        return Just(())
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
} 