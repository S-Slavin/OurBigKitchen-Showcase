import Foundation

struct UserAchievement: Identifiable, Equatable, Sendable {
    let id: String
    let userId: String
    let title: String
    let description: String
    let type: AchievementType
    let dateEarned: Date
    let level: Int
    let progress: Double
    let isCompleted: Bool
    
    enum AchievementType: String, Codable, Equatable {
        case volunteer
        case donation
        case event
        case impact
        case social
    }
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        title: String,
        description: String,
        type: AchievementType,
        dateEarned: Date = Date(),
        level: Int = 1,
        progress: Double = 0,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.description = description
        self.type = type
        self.dateEarned = dateEarned
        self.level = level
        self.progress = progress
        self.isCompleted = isCompleted
    }
} 