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
        var firstName: String
        var lastName: String
        var email: String
        var profileImageURL: String?
        var bio: String?
        var role: UserRole
        var preferences: UserPreferences
        var achievements: [UserAchievement]
        var stats: UserStats
        var hasFoodSafetyRegistration: Bool
        var authProvider: String?
        var company: String?
        var dob: Date?
        
        // WWCC fields
        var wwcNumber: String?
        var wwcExpiry: Date?
        
        // Corporate fields
        var companyName: String?
        var companyPosition: String?
        var companyEmail: String?
        
        // Contact fields
        var phone: String?
        var address: String?
        var city: String?
        var state: String?
        var postalCode: String?
        var country: String?
        
        // Integration fields
        var salesforceId: String?
        var volunteerType: String?
        
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
             companyEmail: String? = nil,
             salesforceId: String? = nil,
             phone: String? = nil,
             address: String? = nil,
             city: String? = nil,
             state: String? = nil,
             postalCode: String? = nil,
             country: String? = nil,
             volunteerType: String? = nil) {
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
            self.salesforceId = salesforceId
            self.phone = phone
            self.address = address
            self.city = city
            self.state = state
            self.postalCode = postalCode
            self.country = country
            self.volunteerType = volunteerType
        }
        
        // MARK: - Validation
        
        func isValid() -> Bool {
            return !id.isEmpty && !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty
        }
        
        // MARK: - Computed Properties
        
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
        
        // MARK: - Compatibility Aliases
        
        var dateOfBirth: Date? {
            return dob
        }
        
        var wwccNumber: String? {
            return wwcNumber
        }
    }

    // MARK: - Activity Models
    
    enum ActivityCategory: String, Codable, CaseIterable {
        case cooking
        case serving
        case cleaning
        case delivery
        case admin
        case fundraising
        case training
        case other
    }

    struct Activity: Codable, Identifiable {
        let id: String
        let title: String
        let description: String
        let category: ActivityCategory
        let date: Date
        let duration: TimeInterval
        let location: String?
        let participants: [String]
        let impact: ImpactMetric?
        
        init(id: String = UUID().uuidString,
             title: String,
             description: String,
             category: ActivityCategory,
             date: Date = Date(),
             duration: TimeInterval,
             location: String? = nil,
             participants: [String] = [],
             impact: ImpactMetric? = nil) {
            self.id = id
            self.title = title
            self.description = description
            self.category = category
            self.date = date
            self.duration = duration
            self.location = location
            self.participants = participants
            self.impact = impact
        }
    }

    // MARK: - Event Models
    
    struct Event: Codable, Identifiable {
        let id: String
        let title: String
        let description: String
        let date: Date
        let startTime: Date
        let endTime: Date
        let location: String
        let maxParticipants: Int
        let currentParticipants: Int
        let category: ActivityCategory
        let organizer: String
        let isActive: Bool
        
        init(id: String = UUID().uuidString,
             title: String,
             description: String,
             date: Date,
             startTime: Date,
             endTime: Date,
             location: String,
             maxParticipants: Int,
             currentParticipants: Int = 0,
             category: ActivityCategory,
             organizer: String,
             isActive: Bool = true) {
            self.id = id
            self.title = title
            self.description = description
            self.date = date
            self.startTime = startTime
            self.endTime = endTime
            self.location = location
            self.maxParticipants = maxParticipants
            self.currentParticipants = currentParticipants
            self.category = category
            self.organizer = organizer
            self.isActive = isActive
        }
        
        var isFull: Bool {
            return currentParticipants >= maxParticipants
        }
        
        var availableSpots: Int {
            return max(0, maxParticipants - currentParticipants)
        }
    }

    // MARK: - Impact Models
    
    struct ImpactMetric: Codable, Identifiable {
        let id: String
        let type: ImpactType
        let value: Double
        let unit: String
        let date: Date
        let description: String?
        
        init(id: String = UUID().uuidString,
             type: ImpactType,
             value: Double,
             unit: String,
             date: Date = Date(),
             description: String? = nil) {
            self.id = id
            self.type = type
            self.value = value
            self.unit = unit
            self.date = date
            self.description = description
        }
    }
    
    enum ImpactType: String, Codable, CaseIterable {
        case mealsServed
        case peopleFed
        case volunteerHours
        case foodWasteReduced
        case carbonFootprintReduced
        case donationsCollected
        case eventsOrganized
        case volunteer
    }

    // MARK: - Campaign Models
    
    struct Campaign: Codable, Identifiable {
        let id: String
        let title: String
        let description: String
        let startDate: Date
        let endDate: Date
        let goal: Double
        let currentAmount: Double
        let currency: String
        let organizer: String
        let isActive: Bool
        
        init(id: String = UUID().uuidString,
             title: String,
             description: String,
             startDate: Date,
             endDate: Date,
             goal: Double,
             currentAmount: Double = 0,
             currency: String = "AUD",
             organizer: String,
             isActive: Bool = true) {
            self.id = id
            self.title = title
            self.description = description
            self.startDate = startDate
            self.endDate = endDate
            self.goal = goal
            self.currentAmount = currentAmount
            self.currency = currency
            self.organizer = organizer
            self.isActive = isActive
        }
        
        var progress: Double {
            return min(currentAmount / goal, 1.0)
        }
        
        var isCompleted: Bool {
            return currentAmount >= goal
        }
        
        var remainingAmount: Double {
            return max(0, goal - currentAmount)
        }
    }

    // MARK: - Donation Models
    
    struct Donation: Codable, Identifiable {
        let id: String
        let amount: Double
        let currency: String
        let donorName: String
        let donorEmail: String?
        let message: String?
        let date: Date
        let campaignId: String?
        let isAnonymous: Bool
        
        init(id: String = UUID().uuidString,
             amount: Double,
             currency: String = "AUD",
             donorName: String,
             donorEmail: String? = nil,
             message: String? = nil,
             date: Date = Date(),
             campaignId: String? = nil,
             isAnonymous: Bool = false) {
            self.id = id
            self.amount = amount
            self.currency = currency
            self.donorName = donorName
            self.donorEmail = donorEmail
            self.message = message
            self.date = date
            self.campaignId = campaignId
            self.isAnonymous = isAnonymous
        }
    }

    // MARK: - Analytics Models
    
    struct AnalyticsReport: Codable, Identifiable {
        let id: String
        let title: String
        let dateRange: DateInterval
        let metrics: [ImpactMetric]
        let summary: String
        let generatedAt: Date
        
        init(id: String = UUID().uuidString,
             title: String,
             dateRange: DateInterval,
             metrics: [ImpactMetric],
             summary: String,
             generatedAt: Date = Date()) {
            self.id = id
            self.title = title
            self.dateRange = dateRange
            self.metrics = metrics
            self.summary = summary
            self.generatedAt = generatedAt
        }
    }
    
    // MARK: - Corporate Volunteer
    
    struct CorporateVolunteer: Codable, Identifiable {
        let id: String
        let companyName: String
        let companyEmail: String
        let companyPosition: String
        let volunteerType: VolunteerType
        let wwccNumber: String?
        let wwccExpiry: Date?
        let preferences: [String: String]
        let hoursContributed: Double
        let impactScore: Double
        
        init(companyName: String, companyEmail: String, companyPosition: String, volunteerType: VolunteerType, wwccNumber: String? = nil, wwccExpiry: Date? = nil, preferences: [String: String] = [:], hoursContributed: Double = 0.0, impactScore: Double = 0.0) {
            self.id = UUID().uuidString
            self.companyName = companyName
            self.companyEmail = companyEmail
            self.companyPosition = companyPosition
            self.volunteerType = volunteerType
            self.wwccNumber = wwccNumber
            self.wwccExpiry = wwccExpiry
            self.preferences = preferences
            self.hoursContributed = hoursContributed
            self.impactScore = impactScore
        }
        
        enum CodingKeys: String, CodingKey {
            case id, companyName, companyEmail, companyPosition, volunteerType, wwccNumber, wwccExpiry, preferences, hoursContributed, impactScore
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            companyName = try container.decode(String.self, forKey: .companyName)
            companyEmail = try container.decode(String.self, forKey: .companyEmail)
            companyPosition = try container.decode(String.self, forKey: .companyPosition)
            volunteerType = try container.decode(VolunteerType.self, forKey: .volunteerType)
            wwccNumber = try container.decodeIfPresent(String.self, forKey: .wwccNumber)
            wwccExpiry = try container.decodeIfPresent(Date.self, forKey: .wwccExpiry)
            preferences = try container.decode([String: String].self, forKey: .preferences)
            hoursContributed = try container.decode(Double.self, forKey: .hoursContributed)
            impactScore = try container.decode(Double.self, forKey: .impactScore)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(companyName, forKey: .companyName)
            try container.encode(companyEmail, forKey: .companyEmail)
            try container.encode(companyPosition, forKey: .companyPosition)
            try container.encode(volunteerType, forKey: .volunteerType)
            try container.encodeIfPresent(wwccNumber, forKey: .wwccNumber)
            try container.encode(preferences, forKey: .preferences)
            try container.encode(hoursContributed, forKey: .hoursContributed)
            try container.encode(impactScore, forKey: .impactScore)
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









// MARK: - Corporate Account Models
struct CorporateAccount: Identifiable, Codable {
    let id: String
    let companyName: String
    let contactEmail: String
    let contactPhone: String?
    let industry: String?
    let salesforceId: String?
    let employeeCount: Int?
    let partnershipLevel: PartnershipLevel
    
    enum PartnershipLevel: String, Codable, CaseIterable {
        case bronze
        case silver
        case gold
        case platinum
    }
    
    init(id: String = UUID().uuidString,
         companyName: String,
         contactEmail: String,
         contactPhone: String? = nil,
         industry: String? = nil,
         salesforceId: String? = nil,
         employeeCount: Int? = nil,
         partnershipLevel: PartnershipLevel = .bronze) {
        self.id = id
        self.companyName = companyName
        self.contactEmail = contactEmail
        self.contactPhone = contactPhone
        self.industry = industry
        self.salesforceId = salesforceId
        self.employeeCount = employeeCount
        self.partnershipLevel = partnershipLevel
    }
}

// MARK: - Event Models
// Event, EventCategory, VolunteerSession, and related models are defined in separate files:
// - Event.swift
// - VolunteerSession.swift (if exists)
// - ImpactMetric.swift (if exists) 