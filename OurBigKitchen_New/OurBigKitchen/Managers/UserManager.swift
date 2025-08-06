import Foundation
import Combine
import ComposableArchitecture

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@Observable
class UserManager: @unchecked Sendable {
    static let shared = UserManager()
    
    private init() {}
    
    private(set) var currentUser: AppModels.User?
    private(set) var isAuthenticated = false
    
    var currentUserId: String? { currentUser?.id }
    
    func setUser(_ user: AppModels.User) {
        currentUser = user
        isAuthenticated = true
    }
    
    func clearUser() {
        currentUser = nil
        isAuthenticated = false
    }
    
    func updateUser(_ user: AppModels.User) {
        currentUser = user
    }
    
    func getUserId() -> String? {
        return currentUser?.id
    }
    
    func getEmail() -> String? {
        return currentUser?.email
    }
    
    func getName() -> String? {
        guard let user = currentUser else { return nil }
        return "\(user.firstName) \(user.lastName)"
    }
    
    func getCurrentUser() -> AnyPublisher<AppModels.User?, Never> {
        return Just(currentUser)
            .eraseToAnyPublisher()
    }
    
    func getUserRankings(category: RankingCategory) -> AnyPublisher<[UserRanking], Error> {
        // Convert RankingCategory to UserRankingCategory
        let userCategory: UserRankingCategory
        switch category {
        case .impact:
            userCategory = .impact
        case .volunteers:
            userCategory = .volunteer
        case .donations:
            userCategory = .donation
        case .meals:
            userCategory = .impact // Map meals to impact category for now
        }
        
        // Mock implementation
        guard let user = currentUser else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let mockRankings = [
            UserRanking(
                rank: 1,
                user: user,
                score: 100,
                category: userCategory
            )
        ]
        
        return Just(mockRankings)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
} 