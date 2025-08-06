import Foundation
import ComposableArchitecture
import Dependencies

struct UserClient {
    var getCurrentUser: @Sendable () async throws -> AppModels.User
    var getUserStats: @Sendable () async throws -> AppModels.UserStats
    var getUserAchievements: @Sendable () async throws -> [AppModels.UserAchievement]
    var updateUser: @Sendable (AppModels.User) async throws -> AppModels.User
    var updateProfileImage: @Sendable (Data) async throws -> String
}

extension UserClient: DependencyKey {
    static let liveValue = Self(
        getCurrentUser: {
            // TODO: Implement actual API call
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
        },
        getUserStats: {
            // TODO: Implement actual API call
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
        },
        getUserAchievements: {
            // TODO: Implement actual API call
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
        },
        updateUser: { user in
            // TODO: Implement actual API call
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
        },
        updateProfileImage: { imageData in
            // TODO: Implement actual API call
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
        }
    )
    
    static let testValue = Self(
        getCurrentUser: {
            AppModels.User(
                id: "test-user-id",
                firstName: "John",
                lastName: "Doe",
                email: "john.doe@example.com",
                role: .volunteer
            )
        },
        getUserStats: {
            AppModels.UserStats(
                hoursVolunteered: 10,
                mealsPrepared: 50,
                eventsAttended: 5
            )
        },
        getUserAchievements: {
            [
                AppModels.UserAchievement(
                    title: "First Timer",
                    description: "Completed first volunteer session"
                ),
                AppModels.UserAchievement(
                    title: "Meal Master",
                    description: "Prepared over 100 meals"
                )
            ]
        },
        updateUser: { user in user },
        updateProfileImage: { _ in "https://example.com/profile.jpg" }
    )
}

extension DependencyValues {
    var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
} 