import Foundation
import ComposableArchitecture
import Dependencies

struct ActivityClient {
    var getRecentActivities: @Sendable () async throws -> [Activity]
    var getActivitiesForUser: @Sendable (String) async throws -> [Activity]
    var getActivitiesForEvent: @Sendable (String) async throws -> [Activity]
    var createActivity: @Sendable (Activity) async throws -> Activity
    var updateActivity: @Sendable (Activity) async throws -> Activity
    var deleteActivity: @Sendable (String) async throws -> Void
    var getActivityImpact: @Sendable (String) async throws -> AppModels.ImpactMetric
    var updateActivityImpact: @Sendable (String, AppModels.ImpactMetric) async throws -> AppModels.ImpactMetric
}

extension ActivityClient: DependencyKey {
    static let liveValue = Self(
        getRecentActivities: {
            // TODO: Implement actual API call
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
        },
        getActivitiesForUser: { userId in
            // TODO: Implement actual API call
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
        },
        getActivitiesForEvent: { eventId in
            // TODO: Implement actual API call
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
        },
        createActivity: { activity in
            // TODO: Implement actual API call
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
        },
        updateActivity: { activity in
            // TODO: Implement actual API call
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
        },
        deleteActivity: { activityId in
            // TODO: Implement actual API call
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
        },
        getActivityImpact: { activityId in
            // TODO: Implement actual API call
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
        },
        updateActivityImpact: { activityId, impact in
            // TODO: Implement actual API call
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
        }
    )
    
    static let testValue = Self(
        getRecentActivities: {
            [
                Activity(
                    userId: "user123",
                    type: .volunteer,
                    details: "Prepared 50 meals for local shelter"
                )
            ]
        },
        getActivitiesForUser: { _ in [] },
        getActivitiesForEvent: { _ in [] },
        createActivity: { $0 },
        updateActivity: { $0 },
        deleteActivity: { _ in },
        getActivityImpact: { _ in
            AppModels.ImpactMetric(
                mealsServed: 50,
                foodSavedKg: 10.0,
                familiesHelped: 15,
                livesTouched: 50
            )
        },
        updateActivityImpact: { _, impact in impact }
    )
}

extension DependencyValues {
    var activityClient: ActivityClient {
        get { self[ActivityClient.self] }
        set { self[ActivityClient.self] = newValue }
    }
} 