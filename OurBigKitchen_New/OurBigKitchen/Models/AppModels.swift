import Foundation
import SwiftUI

public enum AppModels {
    // MARK: - User Models
    public enum UserRole: String, Codable, CaseIterable, Sendable, Equatable {
        case admin
        case manager
        case volunteer
        case guest
        case corporate
        case corporateVolunteer
        case wwcVolunteer
    }

    public struct UserPreferences: Codable, Sendable, Equatable {
        public var notificationsEnabled: Bool
        public var darkMode: Bool
        public var language: String
        
        public init(notificationsEnabled: Bool = true,
             darkMode: Bool = false,
             language: String = "en") {
            self.notificationsEnabled = notificationsEnabled
            self.darkMode = darkMode
            self.language = language
        }
    }

    public struct UserStats: Codable, Sendable, Equatable {
        public var hoursVolunteered: Int
        public var mealsPrepared: Int
        public var eventsAttended: Int
        
        public init(hoursVolunteered: Int = 0,
             mealsPrepared: Int = 0,
             eventsAttended: Int = 0) {
            self.hoursVolunteered = hoursVolunteered
            self.mealsPrepared = mealsPrepared
            self.eventsAttended = eventsAttended
        }
    }

    public struct UserAchievement: Codable, Identifiable, Sendable, Equatable {
        public let id: String
        public let title: String
        public let description: String
        public let dateAchieved: Date
        
        public init(id: String = UUID().uuidString,
             title: String,
             description: String,
             dateAchieved: Date = Date()) {
            self.id = id
            self.title = title
            self.description = description
            self.dateAchieved = dateAchieved
        }
    }

    public struct User: Identifiable, Codable, Sendable, Equatable {
        public var id: String
        public let firstName: String
        public let lastName: String
        public let email: String
        public let profileImageURL: String?
        public let bio: String?
        public let role: UserRole
        public let preferences: UserPreferences
        public let achievements: [UserAchievement]
        public let stats: UserStats
        public let hasFoodSafetyRegistration: Bool
        public var authProvider: String?
        public var company: String?
        
        // Optional fields for different volunteer types
        public var wwcNumber: String?
        public var wwcExpiryDate: Date?
        public var companyName: String?
        public var companyPosition: String?
        public var companyEmail: String?
        
        public init(id: String = UUID().uuidString,
             firstName: String,
             lastName: String,
             email: String,
             profileImageURL: String? = nil,
             bio: String? = nil,
             role: UserRole = .volunteer,
             preferences: UserPreferences = UserPreferences(),
             achievements: [UserAchievement] = [],
             stats: UserStats = UserStats(),
             hasFoodSafetyRegistration: Bool = false,
             authProvider: String? = nil,
             company: String? = nil) {
            self.id = id
            self.firstName = firstName
            self.lastName = lastName
            self.email = email
            self.profileImageURL = profileImageURL
            self.bio = bio
            self.role = role
            self.preferences = preferences
            self.achievements = achievements
            self.stats = stats
            self.hasFoodSafetyRegistration = hasFoodSafetyRegistration
            self.authProvider = authProvider
            self.company = company
        }
        
        public static func == (lhs: User, rhs: User) -> Bool {
            lhs.id == rhs.id &&
            lhs.firstName == rhs.firstName &&
            lhs.lastName == rhs.lastName &&
            lhs.email == rhs.email &&
            lhs.profileImageURL == rhs.profileImageURL &&
            lhs.bio == rhs.bio &&
            lhs.role == rhs.role &&
            lhs.preferences == rhs.preferences &&
            lhs.achievements == rhs.achievements &&
            lhs.stats == rhs.stats &&
            lhs.hasFoodSafetyRegistration == rhs.hasFoodSafetyRegistration &&
            lhs.authProvider == rhs.authProvider &&
            lhs.company == rhs.company &&
            lhs.wwcNumber == rhs.wwcNumber &&
            lhs.wwcExpiryDate == rhs.wwcExpiryDate &&
            lhs.companyName == rhs.companyName &&
            lhs.companyPosition == rhs.companyPosition &&
            lhs.companyEmail == rhs.companyEmail
        }
        
        public func isValid() -> Bool {
            return !id.isEmpty && !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty
        }
        
        // Convenience computed property for full name
        public var fullName: String {
            return "\(firstName) \(lastName)"
        }
        
        public var isWWCVerified: Bool {
            guard let expiryDate = wwcExpiryDate else { return false }
            return expiryDate > Date()
        }
        
        public var isCorporate: Bool {
            role == .corporateVolunteer
        }
        
        public var isWWC: Bool {
            role == .wwcVolunteer
        }
    }

    // MARK: - Activity Models
    public enum ActivityCategory: String, Codable, CaseIterable, Sendable, Equatable {
        case cooking
        case cleaning
        case serving
        case organizing
        case delivery
        case other
    }

    public struct Activity: Identifiable, Codable, Sendable, Equatable {
        public let id: String
        public let userId: String
        public let eventId: String?
        public let title: String
        public let description: String
        public let category: ActivityCategory
        public let date: Date
        public let duration: TimeInterval
        public let impact: ImpactMetric
        
        public enum CodingKeys: String, CodingKey {
            case id
            case userId
            case eventId
            case title
            case description
            case category
            case date
            case duration
            case impact
        }
        
        public init(id: String = UUID().uuidString,
             userId: String,
             eventId: String? = nil,
             title: String,
             description: String,
             category: ActivityCategory,
             date: Date = Date(),
             duration: TimeInterval,
             impact: ImpactMetric) {
            self.id = id
            self.userId = userId
            self.eventId = eventId
            self.title = title
            self.description = description
            self.category = category
            self.date = date
            self.duration = duration
            self.impact = impact
        }
        
        public func asDictionary() throws -> [String: Any] {
            let data = try JSONEncoder().encode(self)
            return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        }
    }

    // MARK: - Session Models
    public struct Session: Identifiable, Codable, Sendable, Equatable {
        public let id: String
        public let startTime: Date
        public let endTime: Date
        public let duration: TimeInterval
        
        public init(id: String = UUID().uuidString,
             startTime: Date,
             endTime: Date,
             duration: TimeInterval) {
            self.id = id
            self.startTime = startTime
            self.endTime = endTime
            self.duration = duration
        }
    }

    // MARK: - Impact Models
    public struct ImpactMetric: Codable, Sendable, Equatable {
        public let mealsServed: Int
        public let foodSavedKg: Double
        public let familiesHelped: Int
        public let livesTouched: Int
        
        public init(mealsServed: Int = 0, foodSavedKg: Double = 0, familiesHelped: Int = 0, livesTouched: Int = 0) {
            self.mealsServed = mealsServed
            self.foodSavedKg = foodSavedKg
            self.familiesHelped = familiesHelped
            self.livesTouched = livesTouched
        }
    }

    // MARK: - Corporate Volunteer Models
    struct CorporateVolunteer: Codable, Identifiable {
        let id: String
        var name: String
        var company: String
        var hoursContributed: Int
        var impactScore: Double
    }

    // MARK: - Analytics Report Model
    struct AnalyticsReport: Codable {
        let totalMealsServed: Int
        let totalVolunteers: Int
        let totalHoursVolunteered: Double
        let totalPeopleServed: Int
        let foodWasteReduced: Double
        let donationsReceived: Double
        let dailyBreakdown: [DailyStats]
        let impactMetrics: [ImpactMetric]
        let topVolunteers: [UserSummary]
        let topCorporatePartners: [CorporatePartner]
        
        struct UserSummary: Codable {
            let id: String
            let name: String
            let profileImageURL: String?
            let totalHours: Double
            let totalImpact: Int
        }
        
        struct CorporatePartner: Codable {
            let id: String
            let name: String
            let logoURL: String?
            let totalContribution: Double
            let employeeParticipation: Int
        }
    }
    
    // MARK: - Leaderboard Models
    public struct LeaderboardEntry: Codable, Sendable, Equatable {
        public let rank: Int
        public let user: User
        public let totalImpact: Int
        
        public init(rank: Int, user: User, totalImpact: Int) {
            self.rank = rank
            self.user = user
            self.totalImpact = totalImpact
        }
    }
}

// MARK: - Network Models
enum Endpoint {
    case volunteers
    case impact
    case events
    case registration
    case foodSafety
    case companies
    
    var path: String {
        switch self {
        case .volunteers: return "/volunteers"
        case .impact: return "/impact"
        case .events: return "/events"
        case .registration: return "/registration"
        case .foodSafety: return "/foodsafety"
        case .companies: return "/companies"
        }
    }
}

// MARK: - Food Safety Models
struct FoodSafetyRegistration: Identifiable, Codable {
    let id: UUID
    let participantName: String
    let participantEmail: String
    let agreementAccepted: Bool
    let registrationDate: Date
    
    init(id: UUID = UUID(),
         participantName: String,
         participantEmail: String,
         agreementAccepted: Bool = true,
         registrationDate: Date = Date()) {
        self.id = id
        self.participantName = participantName
        self.participantEmail = participantEmail
        self.agreementAccepted = agreementAccepted
        self.registrationDate = registrationDate
    }
}

struct Company: Identifiable, Codable {
    let id: String
    let name: String
    let contactEmail: String?
    let contactPhone: String?
    let industry: String?
    let salesforceId: String?
    
    init(id: String = UUID().uuidString,
         name: String,
         contactEmail: String? = nil,
         contactPhone: String? = nil,
         industry: String? = nil,
         salesforceId: String? = nil) {
        self.id = id
        self.name = name
        self.contactEmail = contactEmail
        self.contactPhone = contactPhone
        self.industry = industry
        self.salesforceId = salesforceId
    }
}

// Model for upcoming user sessions shown in the Impact page
struct UpcomingSession: Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let location: String
    let duration: TimeInterval
    let type: SessionType
    let volunteers: Int
    
    enum SessionType {
        case cooking
        case delivery
        case volunteering
        case other
        
        var iconName: String {
            switch self {
            case .cooking:
                return "oven.fill"
            case .delivery:
                return "car.fill"
            case .volunteering:
                return "hands.sparkles.fill"
            case .other:
                return "calendar"
            }
        }
        
        var color: Color {
            switch self {
            case .cooking:
                return Color.orange
            case .delivery:
                return Color.blue
            case .volunteering:
                return Color.green
            case .other:
                return Color.purple
            }
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var daysUntil: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// Helper extension for sample data
extension UpcomingSession {
    static var samples: [UpcomingSession] = [
        UpcomingSession(
            id: UUID(),
            title: "Community Kitchen Day",
            date: Date().addingTimeInterval(86400), // Tomorrow
            location: "Main Kitchen",
            duration: 7200, // 2 hours
            type: .cooking,
            volunteers: 12
        ),
        UpcomingSession(
            id: UUID(),
            title: "Meal Delivery",
            date: Date().addingTimeInterval(172800), // In 2 days
            location: "Distribution Center",
            duration: 5400, // 1.5 hours
            type: .delivery,
            volunteers: 8
        ),
        UpcomingSession(
            id: UUID(),
            title: "Volunteer Orientation",
            date: Date().addingTimeInterval(345600), // In 4 days
            location: "Community Hall",
            duration: 3600, // 1 hour
            type: .volunteering,
            volunteers: 15
        ),
        UpcomingSession(
            id: UUID(),
            title: "Kids Giving Back: Junior Chefs",
            date: Date().addingTimeInterval(345600), // In 4 days
            location: "Main Kitchen - Kids Area",
            duration: 9000, // 2.5 hours
            type: .cooking,
            volunteers: 10
        ),
        UpcomingSession(
            id: UUID(),
            title: "Food Rescue Operation",
            date: Date().addingTimeInterval(259200), // In 3 days
            location: "Community Hub",
            duration: 10800, // 3 hours
            type: .delivery,
            volunteers: 6
        ),
        UpcomingSession(
            id: UUID(),
            title: "Family Volunteering Day",
            date: Date().addingTimeInterval(518400), // In 6 days
            location: "Main Kitchen",
            duration: 10800, // 3 hours
            type: .volunteering,
            volunteers: 20
        ),
        UpcomingSession(
            id: UUID(),
            title: "Youth Leadership in Kitchen",
            date: Date().addingTimeInterval(432000), // In 5 days
            location: "Training Room",
            duration: 7200, // 2 hours
            type: .other,
            volunteers: 8
        )
    ]
} 