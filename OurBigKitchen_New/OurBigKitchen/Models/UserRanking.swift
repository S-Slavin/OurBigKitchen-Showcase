import Foundation

public enum UserRankingCategory: String, Codable, Equatable {
    case impact
    case volunteer
    case donation
    case event
}

public struct UserRanking: Identifiable, Codable, Equatable {
    public let id: UUID
    public let rank: Int
    public let user: AppModels.User
    public let score: Int
    public let category: UserRankingCategory
    public let timestamp: Date
    
    public init(id: UUID = UUID(), rank: Int, user: AppModels.User, score: Int, category: UserRankingCategory, timestamp: Date = Date()) {
        self.id = id
        self.rank = rank
        self.user = user
        self.score = score
        self.category = category
        self.timestamp = timestamp
    }
} 