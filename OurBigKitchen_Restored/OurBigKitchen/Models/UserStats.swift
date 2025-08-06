import Foundation

struct UserStats: Equatable, Codable, Sendable {
    var totalVolunteerHours: Double
    var totalDonations: Double
    var totalEvents: Int
    var impactScore: Int
    var lastActivityDate: Date?
    
    init(
        totalVolunteerHours: Double = 0,
        totalDonations: Double = 0,
        totalEvents: Int = 0,
        impactScore: Int = 0,
        lastActivityDate: Date? = nil
    ) {
        self.totalVolunteerHours = totalVolunteerHours
        self.totalDonations = totalDonations
        self.totalEvents = totalEvents
        self.impactScore = impactScore
        self.lastActivityDate = lastActivityDate
    }
} 