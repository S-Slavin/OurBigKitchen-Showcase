import Foundation
import Combine

@MainActor
class ActivityManager {
    static let shared = ActivityManager()
    private let networkManager: NetworkManager
    private let persistenceManager: PersistenceManager
    private let recentActivitiesKey = "recent_activities"
    
    private init(networkManager: NetworkManager? = nil,
                persistenceManager: PersistenceManager? = nil) {
        self.networkManager = networkManager ?? NetworkManager.shared
        self.persistenceManager = persistenceManager ?? PersistenceManager.shared
    }
    
    // MARK: - Activity Operations
    
    func getRecentActivities() -> AnyPublisher<[Activity], Error> {
        return networkManager.get(endpoint: "/activities/recent")
            .handleEvents(receiveOutput: { [weak self] activities in
                try? self?.persistenceManager.save(activities, forKey: self?.recentActivitiesKey ?? "")
            })
            .catch { [weak self] error -> AnyPublisher<[Activity], Error> in
                guard let self = self else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                do {
                    let cachedActivities = try self.persistenceManager.getObject(forKey: self.recentActivitiesKey, as: [Activity].self)
                    return Just(cachedActivities)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func getActivitiesForUser(userId: String) -> AnyPublisher<[Activity], Error> {
        return networkManager.get(endpoint: "/activities/user/\(userId)")
    }
    
    func getActivitiesForEvent(eventId: String) -> AnyPublisher<[Activity], Error> {
        return networkManager.get(endpoint: "/activities/event/\(eventId)")
    }
    
    func createActivity(_ activity: Activity) -> AnyPublisher<Activity, Error> {
        return networkManager.post(endpoint: "/activities", body: activity)
    }
    
    func updateActivity(_ activity: Activity) -> AnyPublisher<Activity, Error> {
        return networkManager.put(endpoint: "/activities/\(activity.id)", body: activity)
    }
    
    func deleteActivity(activityId: String) -> AnyPublisher<Void, Error> {
        return networkManager.delete(endpoint: "/activities/\(activityId)")
    }
    
    func getActivityImpact(activityId: String) -> AnyPublisher<ImpactMetric, Error> {
        return networkManager.get(endpoint: "/activities/\(activityId)/impact")
    }
    
    func updateActivityImpact(activityId: String, impact: ImpactMetric) -> AnyPublisher<ImpactMetric, Error> {
        return networkManager.put(endpoint: "/activities/\(activityId)/impact", body: impact)
    }
    
    func getActivityCategories() -> AnyPublisher<[ActivityCategory], Error> {
        return Just(ActivityCategory.allCases)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Async Versions
    
    func getRecentActivities() async throws -> [Activity] {
        do {
            // Try to get from network
            let activities: [Activity] = try await networkManager.getAsync(endpoint: "/activities/recent")
            try persistenceManager.save(activities, forKey: recentActivitiesKey)
            return activities
        } catch {
            // Try to get from cache
            do {
                return try persistenceManager.getObject(forKey: recentActivitiesKey, as: [Activity].self)
            } catch {
                // Create mock data for demo purposes
                return [
                    Activity(
                        title: "Meal Preparation",
                        description: "Prepared 50 meals for local shelter",
                        category: .cooking,
                        date: Date().addingTimeInterval(-86400), // Yesterday
                        duration: 3600, // 1 hour
                        location: "Local Shelter",
                        participants: ["user123"],
                        impact: ImpactMetric(type: .mealsServed, value: 50, unit: "meals", date: Date().addingTimeInterval(-86400))
                    ),
                    Activity(
                        title: "Food Delivery",
                        description: "Delivered meals to 25 families",
                        category: .delivery,
                        date: Date().addingTimeInterval(-172800), // 2 days ago
                        duration: 7200, // 2 hours
                        location: "Community Center",
                        participants: ["user123"],
                        impact: ImpactMetric(type: .mealsServed, value: 25, unit: "meals", date: Date().addingTimeInterval(-172800))
                    )
                ]
            }
        }
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        do {
            try persistenceManager.remove(forKey: recentActivitiesKey)
        } catch {
            // Log error but don't fail - cache clearing is not critical
            print("Failed to clear cache: \(error.localizedDescription)")
        }
    }
}
