import Foundation
import ComposableArchitecture

struct Activity: Identifiable, Equatable, Sendable {
    let id: String
    let userId: String
    let type: ActivityType
    let timestamp: Date
    let details: String
    
    enum ActivityType: String, Codable, Equatable, Sendable {
        case volunteer
        case donation
        case event
        case impact
    }
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        type: ActivityType,
        timestamp: Date = Date(),
        details: String
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.timestamp = timestamp
        self.details = details
    }
}

struct HomeActivityItem: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timestamp: Date
    let type: Activity.ActivityType
    
    init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String,
        timestamp: Date = Date(),
        type: Activity.ActivityType
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.timestamp = timestamp
        self.type = type
    }
    
    init(from activity: Activity) {
        self.id = activity.id
        self.title = activity.type.rawValue.capitalized
        self.subtitle = activity.details
        self.timestamp = activity.timestamp
        self.type = activity.type
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@Observable
class ActivityManager: @unchecked Sendable {
    static let shared = ActivityManager()
    
    private init() {}
    
    private(set) var recentActivities: [Activity] = []
    
    func addActivity(_ activity: Activity) {
        recentActivities.append(activity)
        recentActivities.sort { $0.timestamp > $1.timestamp }
        if recentActivities.count > 50 {
            recentActivities = Array(recentActivities.prefix(50))
        }
    }
    
    func getActivities(for userId: String) -> [Activity] {
        return recentActivities.filter { $0.userId == userId }
    }
    
    func getRecentActivities(limit: Int = 10) -> [Activity] {
        return Array(recentActivities.prefix(limit))
    }
    
    func getHomeActivityItems(limit: Int = 10) -> [HomeActivityItem] {
        return getRecentActivities(limit: limit).map { HomeActivityItem(from: $0) }
    }
    
    func clearActivities() {
        recentActivities.removeAll()
    }
} 