import Foundation

enum UserRankingCategory: String, Codable, Equatable {
    case impact
    case volunteer
    case donation
    case event
}

struct UserRanking: Identifiable, Codable {
    let id: UUID
    let rank: Int
    let user: AppModels.User
    let score: Int
    let category: UserRankingCategory
    let timestamp: Date
    
    init(id: UUID = UUID(), rank: Int, user: AppModels.User, score: Int, category: UserRankingCategory, timestamp: Date = Date()) {
        self.id = id
        self.rank = rank
        self.user = user
        self.score = score
        self.category = category
        self.timestamp = timestamp
    }
} 