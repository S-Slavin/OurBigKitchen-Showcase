import Foundation
import SwiftUI

enum AppModels {
    // MARK: - User Models
    enum UserRole: String, Codable, CaseIterable {
        case admin
        case manager
        case volunteer
        case guest
        case corporate
        case corporateVolunteer
        case wwcVolunteer
    }

    struct UserPreferences: Codable {
        var notificationsEnabled: Bool
        var darkMode: Bool
        var language: String
        
        init(notificationsEnabled: Bool = true,
             darkMode: Bool = false,
             language: String = "en") {
            self.notificationsEnabled = notificationsEnabled
            self.darkMode = darkMode
            self.language = language
        }
        
        mutating func update(with preferences: [String: Any]) {
            if let notificationsEnabled = preferences["notificationsEnabled"] as? Bool {
                self.notificationsEnabled = notificationsEnabled
            }
            if let darkMode = preferences["darkMode"] as? Bool {
                self.darkMode = darkMode
            }
            if let language = preferences["language"] as? String {
                self.language = language
            }
        }
    }

    struct UserStats: Codable {
        var hoursVolunteered: Int
        var mealsPrepared: Int
        var eventsAttended: Int
        
        init(hoursVolunteered: Int = 0,
             mealsPrepared: Int = 0,
             eventsAttended: Int = 0) {
            self.hoursVolunteered = hoursVolunteered
            self.mealsPrepared = mealsPrepared
            self.eventsAttended = eventsAttended
        }
    }

    struct UserAchievement: Codable, Identifiable {
        let id: String
        let title: String
        let description: String
        let dateAchieved: Date
        
        init(id: String = UUID().uuidString,
             title: String,
             description: String,
             dateAchieved: Date = Date()) {
            self.id = id
            self.title = title
            self.description = description
            self.dateAchieved = dateAchieved
        }
    }

    struct User: Identifiable, Codable {
        var id: String
        let firstName: String
        let lastName: String
        let email: String
        let profileImageURL: String?
        let bio: String?
        let role: UserRole
        var preferences: UserPreferences
        let achievements: [UserAchievement]
        let stats: UserStats
        let hasFoodSafetyRegistration: Bool
        var authProvider: String?
        var company: String?
        var dob: Date?
        
        // Optional fields for different volunteer types
        var wwcNumber: String?
        var wwcExpiry: Date?
        var companyName: String?
        var companyPosition: String?
        var companyEmail: String?
        
        init(id: String = UUID().uuidString,
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
             company: String? = nil,
             dob: Date? = nil,
             wwcNumber: String? = nil,
             wwcExpiry: Date? = nil,
             companyName: String? = nil,
             companyPosition: String? = nil,
             companyEmail: String? = nil) {
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
            self.dob = dob
            self.wwcNumber = wwcNumber
            self.wwcExpiry = wwcExpiry
            self.companyName = companyName
            self.companyPosition = companyPosition
            self.companyEmail = companyEmail
        }
        
        func isValid() -> Bool {
            return !id.isEmpty && !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty
        }
        
        // Convenience computed property for full name
        var fullName: String {
            return "\(firstName) \(lastName)"
        }
        
        var isWWCVerified: Bool {
            guard let expiryDate = wwcExpiry else { return false }
            return expiryDate > Date()
        }
        
        var isCorporate: Bool {
            role == .corporateVolunteer
        }
        
        var isWWC: Bool {
            role == .wwcVolunteer
        }
    }

    // MARK: - Activity Models
    enum ActivityCategory: String, Codable, CaseIterable {
        case cooking
        case cleaning
        case serving
        case organizing
        case delivery
        case other
    }

    struct Activity: Identifiable, Codable {
        let id: String
        let userId: String
        let eventId: String?
        let title: String
        let description: String
        let category: ActivityCategory
        let date: Date
        let duration: TimeInterval
        let impact: ImpactMetric
        
        enum CodingKeys: String, CodingKey {
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
        
        init(id: String = UUID().uuidString,
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
        
        func asDictionary() throws -> [String: Any] {
            let data = try JSONEncoder().encode(self)
            return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        }
    }

    // MARK: - Impact Models
    struct ImpactMetric: Codable {
        let mealsServed: Int
        let peopleFed: Int
        let wasteReduced: Double // in kilograms
        let carbonFootprintReduced: Double // in kilograms of CO2
        let volunteerHours: Double
        
        enum CodingKeys: String, CodingKey {
            case mealsServed
            case peopleFed
            case wasteReduced
            case carbonFootprintReduced
            case volunteerHours
        }
        
        init(mealsServed: Int = 0,
             peopleFed: Int = 0,
             wasteReduced: Double = 0.0,
             carbonFootprintReduced: Double = 0.0,
             volunteerHours: Double = 0.0) {
            self.mealsServed = mealsServed
            self.peopleFed = peopleFed
            self.wasteReduced = wasteReduced
            self.carbonFootprintReduced = carbonFootprintReduced
            self.volunteerHours = volunteerHours
        }
        
        func asDictionary() throws -> [String: Any] {
            let data = try JSONEncoder().encode(self)
            return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
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
            type: .cooking
        ),
        UpcomingSession(
            id: UUID(),
            title: "Meal Delivery",
            date: Date().addingTimeInterval(172800), // In 2 days
            location: "Distribution Center",
            duration: 5400, // 1.5 hours
            type: .delivery
        ),
        UpcomingSession(
            id: UUID(),
            title: "Volunteer Orientation",
            date: Date().addingTimeInterval(345600), // In 4 days
            location: "Community Hall",
            duration: 3600, // 1 hour
            type: .volunteering
        ),
        UpcomingSession(
            id: UUID(),
            title: "Kids Giving Back: Junior Chefs",
            date: Date().addingTimeInterval(345600), // In 4 days
            location: "Main Kitchen - Kids Area",
            duration: 9000, // 2.5 hours
            type: .cooking
        ),
        UpcomingSession(
            id: UUID(),
            title: "Food Rescue Operation",
            date: Date().addingTimeInterval(259200), // In 3 days
            location: "Community Hub",
            duration: 10800, // 3 hours
            type: .delivery
        ),
        UpcomingSession(
            id: UUID(),
            title: "Family Volunteering Day",
            date: Date().addingTimeInterval(518400), // In 6 days
            location: "Main Kitchen",
            duration: 10800, // 3 hours
            type: .volunteering
        ),
        UpcomingSession(
            id: UUID(),
            title: "Youth Leadership in Kitchen",
            date: Date().addingTimeInterval(432000), // In 5 days
            location: "Training Room",
            duration: 7200, // 2 hours
            type: .other
        )
    ]
}

// MARK: - Volunteer Models

struct VolunteerRegistration: Identifiable, Codable {
    let id: UUID
    let opportunityId: UUID
    let opportunityTitle: String
    let date: Date
    let duration: TimeInterval
    let name: String
    let email: String
    let phone: String
    let notes: String
    let registrationDate: Date
    
    var formattedDuration: String {
        let hours = Int(duration / 3600)
        return "\(hours) \(hours == 1 ? "hour" : "hours")"
    }
}

struct VolunteerOpportunity: Identifiable, Codable {
    let id: UUID
    let title: String
    let organization: String
    let description: String
    let date: Date
    let duration: TimeInterval
    let location: String
    let category: String
    let spotsTotal: Int
    let spotsTaken: Int
    let imageURL: String?
    
    var spotsAvailable: Int {
        spotsTotal - spotsTaken
    }
    
    var formattedDuration: String {
        let hours = Int(duration / 3600)
        return "\(hours) \(hours == 1 ? "hour" : "hours")"
    }
}

// MARK: - Contact Models

struct ContactMessage: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let message: String
    let timestamp: Date
    
    init(name: String, email: String, message: String, timestamp: Date = Date()) {
        self.id = UUID().uuidString
        self.name = name
        self.email = email
        self.message = message
        self.timestamp = timestamp
    }
} 